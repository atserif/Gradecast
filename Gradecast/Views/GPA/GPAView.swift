//
//  GPAView.swift
//  Gradecast
//
//  Created by Aram Soneson on 1/20/26.
//

import SwiftUI

struct GPAView: View {
	@Environment(\.colorScheme) private var colorScheme
	@Environment(\.horizontalSizeClass) private var horizontalSizeClass
	@Environment(\.accessibilityShowBorders) private var showBorders
	
	@AppStorage("rememberGPAChanges") private var rememberGPAChanges: Bool = true
	@AppStorage("coursesData") private var coursesData: Data = Data()
	@AppStorage("courseNumber") private var courseNumber: Int = 0
	
	@State private var hasLaunched: Bool = false
	
	@State private var courses: [Course] = []
	@State private var editMode: EditMode = .inactive
	@State private var selection: Set<UUID> = []
	// Prevents changes in selection while deletion is occurring
	@State private var temporarySelection: Set<UUID> = []
	
	@State private var selectionFeedbackTrigger: Int = 0
	@State private var successFeedbackTrigger: Int = 0
	@State private var deleteConfirmationPresented: Bool = false
	@State private var infoSheetPresented: Bool = false
	
	@FocusState private var focused: UUID?
	
	private var unweightedGPA: Double {
		let points: Double = courses.map { $0.grade.rawValue * $0.credits }.reduce(0, +)
		let credits: Double = courses.map { $0.credits }.reduce(0, +)
		return points / credits
	}
	private var weightedGPA: Double {
		let points: Double = courses.map { ($0.grade.rawValue > 1 ? $0.grade.rawValue + $0.level.rawValue : $0.grade.rawValue) * $0.credits }.reduce(0, +)
		let credits: Double = courses.map { $0.credits }.reduce(0, +)
		return points / credits
	}
	
	private func newCourse() {
		courseNumber += 1
		let newCourse: Course = Course(number: courseNumber, name: "Course \(courseNumber)", grade: .a, level: .regular, credits: 1)
		
		courses.append(newCourse)
	}
	private func resetCourse(at index: Int) {
		courses[index].name = "Course \(courses[index].number)"
		courses[index].grade = .a
		courses[index].level = .regular
		courses[index].credits = 1
	}
	
	var body: some View {
		NavigationStack {
			ScrollViewReader { proxy in
				List(selection: $selection) {
					if !courses.isEmpty {
						GPAContent(courses: $courses, editMode: $editMode, selectionFeedbackTrigger: $selectionFeedbackTrigger, successFeedbackTrigger: $successFeedbackTrigger, focused: $focused, unweightedGPA: unweightedGPA, weightedGPA: weightedGPA)
					}
				}
				.onAppear {
					// Enables better reordering UI and behavior
					UICollectionView.appearance().dragDelegate = nil
					UICollectionView.appearance().dropDelegate = nil
				}
				.onChange(of: courses.count) {
					if courses.isEmpty {
						courseNumber = 0
					}
				}
				// TODO: Implement a better method of disabling selected row highlight when editMode is disabled
				.onChange(of: selection) {
					if !editMode.isEditing {
						selection.removeAll()
					}
				}
				// Multiple selection context menu
				.contextMenu(forSelectionType: UUID.self) { selectedCourses in
					if !selectedCourses.isEmpty && selection.count > 1 {
						Button("Reset", systemImage: "arrow.counterclockwise") {
							for index in courses.indices where selectedCourses.contains(courses[index].id) {
								resetCourse(at: index)
							}
							
							selectionFeedbackTrigger += 1
						}
						
						Divider()
						
						Button("Delete", systemImage: "trash", role: .destructive) {
							// Avoids animation conflicts by delaying
							Task {
								try? await Task.sleep(for: .seconds(0.75))
								
								withAnimation {
									courses.removeAll { selectedCourses.contains($0.id) }
								}
								
								selection.removeAll()
								
								if courses.isEmpty {
									editMode = .inactive
								}
								
								selectionFeedbackTrigger += 1
							}
						}
					}
				}
				.overlay {
					if courses.isEmpty {
						ContentUnavailableView {
							Label("No Courses", systemImage: "sum")
								.symbolVariant(.fill)
						} description: {
							Text("Courses you add will appear here.")
						}
						// Ensures the header glow effect shines through
						.background(colorScheme == .dark ? .clear : Color(.systemGroupedBackground))
					}
				}
				.toolbar {
					ToolbarItem(placement: .title) {
						StaticNavigationTitle(title: "GPA")
					}
					
					if !editMode.isEditing {
						ToolbarItem(placement: .topBarTrailing) {
							Button {
								if focused != nil {
									focused = nil
									
									Task {
										editMode = .active
									}
								} else {
									editMode = .active
								}
								
								selectionFeedbackTrigger += 1
							} label: {
								Text("Select")
									// Fixes default styling when Show Borders is enabled
									.padding(.horizontal, showBorders ? 12 : 0)
									.underline(false)
							}
							.disabled(courses.isEmpty)
						}
						
						ToolbarSpacer(.fixed, placement: .topBarTrailing)
						
						ToolbarItemGroup(placement: .primaryAction) {
							Button("New Course", systemImage: "plus") {
								withAnimation {
									newCourse()
									proxy.scrollTo("bottom", anchor: .top)
								}
								
								selectionFeedbackTrigger += 1
							}
							.disabled(courses.count >= 20)
							
							Menu("More", systemImage: "ellipsis") {
								Toggle("Remember Changes", systemImage: "brain", isOn: $rememberGPAChanges)
								
								Divider()
								
								Button("About GPA", systemImage: "info.circle") {
									infoSheetPresented = true
								}
							}
							.sensoryFeedback(.selection, trigger: rememberGPAChanges)
							.sensoryFeedback(.selection, trigger: infoSheetPresented) { _, newValue in
								newValue
							}
						}
					} else {
						if selection.count == courses.count {
							ToolbarItem(placement: .topBarTrailing) {
								Button {
									selection.removeAll()
									selectionFeedbackTrigger += 1
								} label: {
									Text("Deselect All")
										// Fixes default styling when Show Borders is enabled
										.padding(.horizontal, showBorders ? 12 : 0)
										.underline(false)
								}
							}
						} else {
							ToolbarItem(placement: .topBarTrailing) {
								Button {
									selection = Set(courses.map { $0.id })
									selectionFeedbackTrigger += 1
								} label: {
									Text("Select All")
										// Fixes default styling when Show Borders is enabled
										.padding(.horizontal, showBorders ? 12 : 0)
										.underline(false)
								}
							}
						}
						
						ToolbarItem(placement: .confirmationAction) {
							Button("Confirm", systemImage: "checkmark", role: .confirm) {
								editMode = .inactive
								selectionFeedbackTrigger += 1
							}
						}
					}
					
					ToolbarItem(placement: .bottomBar) {
						Button("Reset", systemImage: "arrow.counterclockwise") {
							for index in courses.indices where selection.contains(courses[index].id) {
								resetCourse(at: index)
							}
							
							selectionFeedbackTrigger += 1
						}
						.disabled(selection.isEmpty)
					}
					
					ToolbarSpacer(horizontalSizeClass == .compact ? .flexible : .fixed, placement: .bottomBar)
					
					ToolbarItem(placement: .bottomBar) {
						ZStack {
							Text("00 selected")
								.monospacedDigit()
								.opacity(0)
							
							Text("\(selection.count) Selected")
								.bold()
								.monospacedDigit()
								.contentTransition(.numericText(value: Double(-selection.count)))
						}
						.padding(.horizontal, 12)
						.fixedSize(horizontal: true, vertical: false)
					}
					.sharedBackgroundVisibility(.hidden)
					
					ToolbarSpacer(horizontalSizeClass == .compact ? .flexible : .fixed, placement: .bottomBar)
					
					ToolbarItem(placement: .bottomBar) {
						Button("Delete", systemImage: "trash", role: .destructive) {
							temporarySelection = selection
							deleteConfirmationPresented = true
							
							selectionFeedbackTrigger += 1
						}
						.confirmationDialog("Are you sure you want to delete \(temporarySelection.count == 1 ? "this course?" : "these courses?")", isPresented: $deleteConfirmationPresented, titleVisibility: .visible) {
							Button("Delete \(temporarySelection.count == 1 ? "Course" : "\(temporarySelection.count) Courses")", role: .destructive) {
								withAnimation {
									courses.removeAll { temporarySelection.contains($0.id) }
								}
								
								editMode = .inactive
								selectionFeedbackTrigger += 1
							}
						}
						.disabled(selection.isEmpty)
					}
				}
				.sheet(isPresented: $infoSheetPresented) {
					GPAInfoView()
						.presentationCompactAdaptation(.sheet)
						.presentationRimLight(.visible)
				}
				.sensoryFeedback(.selection, trigger: selectionFeedbackTrigger)
				.sensoryFeedback(.success, trigger: successFeedbackTrigger)
				.toolbarVisibility(!editMode.isEditing ? .visible : .hidden, for: .tabBar)
				.toolbarVisibility(!editMode.isEditing ? .hidden : .visible, for: .bottomBar)
				.toolbarTitleDisplayMode(.inline)
				.toolbarRole(.editor)
				.scrollEdgeEffectStyle(.soft, for: .all)
				// Implements the header glow effect
				.scrollContentBackground(colorScheme == .dark ? .hidden : .visible)
				.headerGlow(.accent, isHiddenOnScroll: !courses.isEmpty)
				.scrollDismissesKeyboard(.immediately)
				.animation(.default, value: selection)
				.animation(.default, value: editMode)
				.environment(\.editMode, $editMode)
			}
		}
		.onAppear {
			guard !hasLaunched else { return }
			hasLaunched = true
			
			if rememberGPAChanges {
				loadCourses()
			} else {
				courseNumber = 0
			}
		}
		.onChange(of: courses) {
			if rememberGPAChanges {
				saveCourses()
			}
		}
		.onChange(of: rememberGPAChanges) {
			if rememberGPAChanges {
				saveCourses()
			}
		}
	}
	
	private func loadCourses() {
		if let decoded = try? JSONDecoder().decode([Course].self, from: coursesData) {
			courses = decoded
		}
	}
	private func saveCourses() {
		if let encoded = try? JSONEncoder().encode(courses) {
			coursesData = encoded
		}
	}
}

#Preview {
	GPAView()
}
