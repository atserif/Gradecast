//
//  GPAView.swift
//  Grades
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
		let newCourse = Course(number: courseNumber, name: "Course \(courseNumber)", grade: .A, level: .regular, credits: 1.0)
		
		courses.append(newCourse)
	}
	private func resetCourse(at index: Int) {
		courses[index].name = "Course \(courses[index].number)"
		courses[index].grade = .A
		courses[index].level = .regular
		courses[index].credits = 1.0
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
					if editMode == .inactive {
						selection.removeAll()
					}
				}
				// Multiple selection context menu
				.contextMenu(forSelectionType: Course.ID.self) { selectedCourses in
					if selectedCourses.isEmpty { } else if selection.count > 1 {
						Button("Reset", systemImage: "arrow.counterclockwise") {
							for index in courses.indices {
								if selectedCourses.contains(courses[index].id) {
									resetCourse(at: index)
								}
							}
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
									withAnimation {
										editMode = .inactive
									}
								}
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
					
					if editMode == .inactive {
						ToolbarItem(placement: .topBarTrailing) {
							Button {
								if focused != nil {
									focused = nil
									
									Task {
										withAnimation {
											editMode = .active
										}
									}
								} else {
									withAnimation {
										editMode = .active
									}
								}
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
									
									selectionFeedbackTrigger += 1
								}
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
							.sensoryFeedback(.selection, trigger: infoSheetPresented) { oldValue, newValue in
								newValue == true
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
								withAnimation {
									editMode = .inactive
								}
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
						.confirmationDialog("Are you sure you want to delete \(selection.count == 1 ? "this course?" : "these courses?")", isPresented: $deleteConfirmationPresented, titleVisibility: .visible) {
							Button("Delete \(selection.count == 1 ? "Course" : "\(selection.count) Courses")", role: .destructive) {
								withAnimation {
									courses.removeAll { course in
										temporarySelection.contains(course.id)
									}
									
									editMode = .inactive
								}
							}
						}
						.disabled(selection.isEmpty)
					}
				}
				.sheet(isPresented: $infoSheetPresented) {
					GPAInfoView()
				}
				.sensoryFeedback(.selection, trigger: selectionFeedbackTrigger)
				.sensoryFeedback(.success, trigger: successFeedbackTrigger)
				.sensoryFeedback(.selection, trigger: editMode)
				.toolbarVisibility(editMode == .inactive ? .visible : .hidden, for: .tabBar)
				.toolbarVisibility(editMode == .inactive ? .hidden : .visible, for: .bottomBar)
				.toolbarTitleDisplayMode(.inline)
				.toolbarRole(.editor)
				.scrollEdgeEffectStyle(.soft, for: .all)
				// Implements the header glow effect
				.scrollContentBackground(colorScheme == .dark ? .hidden : .visible)
				.headerGlow(.accent, isHiddenOnScroll: !courses.isEmpty)
				.scrollDismissesKeyboard(.immediately)
				.animation(.default, value: selection)
				.environment(\.editMode, $editMode)
			}
		}
		.onAppear {
			if rememberGPAChanges {
				loadCourses()
			} else {
				courseNumber = 0
			}
		}
		.onChange(of: courses) {
			saveCourses()
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
