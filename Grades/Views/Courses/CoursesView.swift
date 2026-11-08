//
//  CoursesView.swift
//  Grades
//
//  Created by Aram Soneson on 7/12/26.
//

import SwiftUI

struct CoursesView: View {
	@Environment(\.colorScheme) private var colorScheme
	@Environment(\.horizontalSizeClass) private var horizontalSizeClass
	
	@AppStorage("rememberCoursesChanges") private var rememberCoursesChanges: Bool = true
	@AppStorage("gradingPeriodsData") private var gradingPeriodsData: Data = Data()
	
	@State private var calculatorSelection: Calculator = .fullYear
	@State private var gradingPeriods: [GradingPeriod] = [
		GradingPeriod(id: 1, name: "Quarter 1", calculators: [.fullYear, .semester, .stateAssessed], type: .quarter, grade: .a),
		GradingPeriod(id: 2, name: "Quarter 2", calculators: [.fullYear, .semester, .stateAssessed], type: .quarter, grade: .a),
		GradingPeriod(id: 3, name: "Quarter 3", calculators: [.fullYear, .stateAssessed], type: .quarter, grade: .a),
		GradingPeriod(id: 4, name: "Quarter 4", calculators: [.fullYear, .stateAssessed], type: .quarter, grade: .a),
		GradingPeriod(id: 5, name: "Final", calculators: [.fullYear, .semester], type: .exam, grade: .a),
		GradingPeriod(id: 5, name: "State Assessment", calculators: [.stateAssessed], type: .exam, grade: .a)
	]
	
	@State private var selectionFeedbackTrigger: Int = 0
	@State private var successFeedbackTrigger: Int = 0
	@State private var infoSheetPresented: Bool = false
	
	private var courseGrade: Grade {
		let quarterTotal: Double
		let examTotal: Double
		
		switch calculatorSelection {
		case .fullYear:
			quarterTotal = gradingPeriods.filter { $0.calculators.contains(.fullYear) && $0.type == .quarter }.map { $0.grade.rawValue }.reduce(0, +) * 22.5
			examTotal = gradingPeriods.filter { $0.calculators.contains(.fullYear) && $0.type == .exam }.map { $0.grade.rawValue }.reduce(0, +) * 10
		case .semester:
			quarterTotal = gradingPeriods.filter { $0.calculators.contains(.semester) && $0.type == .quarter }.map { $0.grade.rawValue }.reduce(0, +) * 45
			examTotal = gradingPeriods.filter { $0.calculators.contains(.semester) && $0.type == .exam }.map { $0.grade.rawValue }.reduce(0, +) * 10
		case .stateAssessed:
			quarterTotal = gradingPeriods.filter { $0.calculators.contains(.stateAssessed) && $0.type == .quarter }.map { $0.grade.rawValue }.reduce(0, +) * 20
			examTotal = gradingPeriods.filter { $0.calculators.contains(.stateAssessed) && $0.type == .exam }.map { $0.grade.rawValue }.reduce(0, +) * 20
		}
		
		let average: Double = (quarterTotal + examTotal) / 100
		
		return switch average {
		case 3.5...: .a
		case 2.5..<3.5: .b
		case 1.5..<2.5: .c
		case 0.75..<1.5: .d
		default: .e
		}
	}
	
	var body: some View {
		NavigationStack {
			Form {
				Section {
					Picker("Calculator", selection: $calculatorSelection.animation()) {
						ForEach(Calculator.allCases, id: \.self) { calculator in
							Text(calculator.description)
								.tag(calculator)
						}
					}
					.pickerStyle(.segmented)
					.controlSize(horizontalSizeClass == .compact ? .extraLarge : .regular)
					.sensoryFeedback(.selection, trigger: calculatorSelection)
				}
				// 1 pt bottom inset accounts for the segmented Picker's arbitrary vertical offset
				.listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 1, trailing: 0))
				.listRowBackground(Color.clear)
				
				Section {
					ForEach($gradingPeriods.filter { $0.wrappedValue.calculators.contains(calculatorSelection) }, id: \.wrappedValue.id) { $gradingPeriod in
						Picker(selection: $gradingPeriod.grade) {
							ForEach(Grade.allCases, id: \.self) { grade in
								Text(grade.description)
									.tag(grade)
							}
						} label: {
							Text(gradingPeriod.name)
								.contentTransition(.numericText())
						}
						// Prevents tapping anywhere in the row from triggering the menu
						.pickerStyle(.menu)
						.tint(.secondary)
						.swipeActions {
							Button("Reset", systemImage: "arrow.counterclockwise") {
								gradingPeriod.grade = .a
							}
						}
						.contextMenu {
							Button("Reset", systemImage: "arrow.counterclockwise") {
								gradingPeriod.grade = .a
								selectionFeedbackTrigger += 1
							}
						}
					}
				} header: {
					Text(calculatorSelection != .stateAssessed ? "Quarter & Exam Grades" : "Quarter & Assessment Grades")
						.contentTransition(.numericText())
				}
				
				Section {
					LabeledContent("Course Grade") {
						Text(courseGrade.description)
							.monospacedDigit()
							.contentTransition(.numericText())
							.animation(.default, value: courseGrade)
					}
					.contextMenu {
						Button("Copy Course Grade", systemImage: "document.on.document") {
							UIPasteboard.general.string = courseGrade.description
							successFeedbackTrigger += 1
						}
					}
				}
			}
			// Syncs Final and State Assessment grades
			.onChange(of: gradingPeriods[4].grade) { _, newValue in
				gradingPeriods[5].grade = newValue
			}
			.onChange(of: gradingPeriods[5].grade) { _, newValue in
				gradingPeriods[4].grade = newValue
			}
			.toolbar {
				ToolbarItem(placement: .title) {
					StaticNavigationTitle(title: "Courses")
				}
				
				ToolbarItem(placement: .primaryAction) {
					Menu("More", systemImage: "ellipsis") {
						Toggle("Remember Changes", systemImage: "brain", isOn: $rememberCoursesChanges)
						
						Divider()
						
						Button("About Courses", systemImage: "info.circle") {
							infoSheetPresented = true
						}
					}
					.sensoryFeedback(.selection, trigger: rememberCoursesChanges)
					.sensoryFeedback(.selection, trigger: infoSheetPresented) { _, newValue in
						newValue
					}
				}
			}
			.sheet(isPresented: $infoSheetPresented) {
				CoursesInfoView()
					.presentationRimLight(.visible)
			}
			.sensoryFeedback(.selection, trigger: selectionFeedbackTrigger)
			.sensoryFeedback(.success, trigger: successFeedbackTrigger)
			// Accounts for the 2 2/3 pt gap between the vertical bounds of the segmented Picker and List row
			.contentMargins(.top, 7 + (1 / 3))
			.toolbarTitleDisplayMode(.inline)
			.toolbarRole(.editor)
			.scrollEdgeEffectStyle(.soft, for: .all)
			// Implements the header glow effect
			.scrollContentBackground(colorScheme == .dark ? .hidden : .visible)
			.headerGlow(.accent)
		}
		.onAppear {
			if rememberCoursesChanges {
				loadGradingPeriods()
			}
		}
		.onChange(of: gradingPeriods) {
			if rememberCoursesChanges {
				saveGradingPeriods()
			}
		}
	}
	
	private func loadGradingPeriods() {
		if let decoded = try? JSONDecoder().decode([GradingPeriod].self, from: gradingPeriodsData) {
			gradingPeriods = decoded
		}
	}
	private func saveGradingPeriods() {
		if let encoded = try? JSONEncoder().encode(gradingPeriods) {
			gradingPeriodsData = encoded
		}
	}
}

#Preview {
	CoursesView()
}
