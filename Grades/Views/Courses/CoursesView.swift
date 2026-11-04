//
//  CoursesView.swift
//  Grades
//
//  Created by Aram Soneson on 7/12/26.
//

import SwiftUI

struct CoursesView: View {
	@Environment(\.horizontalSizeClass) private var horizontalSizeClass
	
	@AppStorage("rememberCoursesChanges") private var rememberCoursesChanges: Bool = true
	@AppStorage("resetAllCalculators") private var resetAllCalculators: Bool = true
	@AppStorage("gradingPeriodsData") private var gradingPeriodsData: Data = Data()
	
	@State private var calculatorSelection: Calculator = .fullYear
	@State private var gradingPeriods: [GradingPeriod] = [
		GradingPeriod(id: 1, name: "Quarter 1", calculators: [.fullYear, .semester, .stateAssessed], type: .quarter, grade: .A),
		GradingPeriod(id: 2, name: "Quarter 2", calculators: [.fullYear, .semester, .stateAssessed], type: .quarter, grade: .A),
		GradingPeriod(id: 3, name: "Quarter 3", calculators: [.fullYear, .stateAssessed], type: .quarter, grade: .A),
		GradingPeriod(id: 4, name: "Quarter 4", calculators: [.fullYear, .stateAssessed], type: .quarter, grade: .A),
		GradingPeriod(id: 5, name: "Final", calculators: [.fullYear, .semester], type: .exam, grade: .A),
		GradingPeriod(id: 5, name: "State Assessment", calculators: [.stateAssessed], type: .exam, grade: .A)
	]
	
	@State private var selectionFeedback: Int = 0
	@State private var infoSheetPresented: Bool = false
	
	private var courseGrade: Grade {
		var letterGrade: Grade
		
		let quarterTotal: Double
		let examTotal: Double
		let average: Double
		
		switch calculatorSelection {
		case .fullYear:
			quarterTotal = gradingPeriods.filter { $0.calculators.contains(.fullYear) && $0.type == .quarter }.map { $0.grade.rawValue }.reduce(0, +) * 22.5
			examTotal = gradingPeriods.filter { $0.calculators.contains(.fullYear) && $0.type == .exam }.map { $0.grade.rawValue }.reduce(0, +) * 10
			average = (quarterTotal + examTotal) / 100
		case .semester:
			quarterTotal = gradingPeriods.filter { $0.calculators.contains(.semester) && $0.type == .quarter }.map { $0.grade.rawValue }.reduce(0, +) * 45
			examTotal = gradingPeriods.filter { $0.calculators.contains(.semester) && $0.type == .exam }.map { $0.grade.rawValue }.reduce(0, +) * 10
			average = (quarterTotal + examTotal) / 100
		case .stateAssessed:
			quarterTotal = gradingPeriods.filter { $0.calculators.contains(.stateAssessed) && $0.type == .quarter }.map { $0.grade.rawValue }.reduce(0, +) * 20
			examTotal = gradingPeriods.filter { $0.calculators.contains(.stateAssessed) && $0.type == .exam }.map { $0.grade.rawValue }.reduce(0, +) * 20
			average = (quarterTotal + examTotal) / 100
		}
		
		switch average {
		case 3.5...:
			letterGrade = .A
		case 2.5..<3.5:
			letterGrade = .B
		case 1.5..<2.5:
			letterGrade = .C
		case 0.75..<1.5:
			letterGrade = .D
		default:
			letterGrade = .E
		}
		
		return letterGrade
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
				}
				// 1 pt bottom inset accounts for the segmented Picker's arbitrary vertical offset
				.listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 1, trailing: 0))
				.listRowBackground(Color.clear)
				
				Section {
					ForEach($gradingPeriods.filter { $0.wrappedValue.calculators.contains(calculatorSelection) }, id: \.wrappedValue.id) { $gradingPeriod in
						Picker(gradingPeriod.name, selection: $gradingPeriod.grade) {
							ForEach(Grade.allCases, id: \.self) { grade in
								Text(grade.description)
									.tag(grade)
							}
						}
						// Prevents tapping anywhere in the row from triggering the menu
						.pickerStyle(.menu)
						.tint(.secondary)
						.swipeActions {
							Button("Reset", systemImage: "arrow.clockwise") {
								gradingPeriod.grade = .A
							}
						}
						.contextMenu {
							Button("Reset", systemImage: "arrow.clockwise") {
								gradingPeriod.grade = .A
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
						}
					}
				}
			}
			.onChange(of: calculatorSelection) {
				selectionFeedback += 1
			}
			.toolbar {
				ToolbarItem(placement: .title) {
					StaticNavigationTitle(title: "Courses")
				}
				
				ToolbarItem(placement: .primaryAction) {
					Menu("More", systemImage: "ellipsis") {
						Button("About Courses", systemImage: "info.circle") {
							infoSheetPresented = true
						}
						
						Divider()
						
						Button("Reset", systemImage: "arrow.clockwise") {
							calculatorSelection = .fullYear
							gradingPeriods.indices.forEach { gradingPeriods[$0].grade = .A }
						}
					}
				}
			}
			.sheet(isPresented: $infoSheetPresented) {
				CoursesInfoView()
			}
			.sensoryFeedback(.selection, trigger: selectionFeedback)
			// Accounts for the 2 2/3 pt gap between the segmented Picker's and List row's vertical bounds
			.contentMargins(.top, 7 + (1 / 3))
			.toolbarTitleDisplayMode(.inline)
			.toolbarRole(.editor)
			.scrollEdgeEffectStyle(.soft, for: .all)
		}
		.onAppear {
			if rememberCoursesChanges {
				loadGradingPeriods()
			}
		}
		.onChange(of: gradingPeriods) {
			saveGradingPeriods()
		}
	}
	
	private func saveGradingPeriods() {
		if let encoded = try? JSONEncoder().encode(gradingPeriods) {
			gradingPeriodsData = encoded
		}
	}
	private func loadGradingPeriods() {
		if let decoded = try? JSONDecoder().decode([GradingPeriod].self, from: gradingPeriodsData) {
			gradingPeriods = decoded
		}
	}
}

#Preview {
	CoursesView()
}
