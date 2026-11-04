//
//  CoursesView.swift
//  Grades
//
//  Created by Aram Soneson on 7/12/26.
//

import SwiftUI

private enum CalculatorSelection: CaseIterable {
	case fullYear
	case semester
	case stateAssessed
	
	var description: String {
		switch self {
		case .fullYear: "Full Year"
		case .semester: "Semester"
		case .stateAssessed: "State-Assessed"
		}
	}
}

struct CoursesView: View {
	@Environment(\.horizontalSizeClass) private var horizontalSizeClass
	
	@AppStorage("rememberCoursesChanges") private var rememberCoursesChanges: Bool = true
	@AppStorage("resetAllCalculators") private var resetAllCalculators: Bool = true
	@AppStorage("fullYearGradingPeriodsData") private var fullYearGradingPeriodsData: Data = Data()
	@AppStorage("semesterGradingPeriodsData") private var semesterGradingPeriodsData: Data = Data()
	@AppStorage("stateAssessedGradingPeriodsData") private var stateAssessedGradingPeriodsData: Data = Data()
	
	@State private var calculatorSelection: CalculatorSelection = .fullYear
	@State private var fullYearGradingPeriods: [GradingPeriod] = [
		GradingPeriod(name: "Quarter 1", type: .quarter, grade: .A),
		GradingPeriod(name: "Quarter 2", type: .quarter, grade: .A),
		GradingPeriod(name: "Quarter 3", type: .quarter, grade: .A),
		GradingPeriod(name: "Quarter 4", type: .quarter, grade: .A),
		GradingPeriod(name: "Final", type: .exam, grade: .A)
	]
	@State private var semesterGradingPeriods: [GradingPeriod] = [
		GradingPeriod(name: "Quarter 1", type: .quarter, grade: .A),
		GradingPeriod(name: "Quarter 2", type: .quarter, grade: .A),
		GradingPeriod(name: "Final", type: .exam, grade: .A),
	]
	@State private var stateAssessedGradingPeriods: [GradingPeriod] = [
		GradingPeriod(name: "Quarter 1", type: .quarter, grade: .A),
		GradingPeriod(name: "Quarter 2", type: .quarter, grade: .A),
		GradingPeriod(name: "Quarter 3", type: .quarter, grade: .A),
		GradingPeriod(name: "Quarter 4", type: .quarter, grade: .A),
		GradingPeriod(name: "State Assessment", type: .exam, grade: .A)
	]
	
	@State private var selectionFeedback: Int = 0
	@State private var infoSheetPresented: Bool = false
	
	var body: some View {
		NavigationStack {
			Form {
				Section {
					Picker("Grading Format", selection: $calculatorSelection.animation()) {
						ForEach(CalculatorSelection.allCases, id: \.self) { calculator in
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
				
				switch calculatorSelection {
				case .fullYear:
					FullYearView(gradingPeriods: $fullYearGradingPeriods)
				case .semester:
					SemesterView(gradingPeriods: $semesterGradingPeriods)
				case .stateAssessed:
					StateAssessedView(gradingPeriods: $stateAssessedGradingPeriods)
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
							if resetAllCalculators {
								calculatorSelection = .fullYear
								
								fullYearGradingPeriods.indices.forEach { fullYearGradingPeriods[$0].grade = .A }
								semesterGradingPeriods.indices.forEach { semesterGradingPeriods[$0].grade = .A }
								stateAssessedGradingPeriods.indices.forEach { stateAssessedGradingPeriods[$0].grade = .A }
							} else {
								switch calculatorSelection {
								case .fullYear:
									fullYearGradingPeriods.indices.forEach { fullYearGradingPeriods[$0].grade = .A }
								case .semester:
									semesterGradingPeriods.indices.forEach { semesterGradingPeriods[$0].grade = .A }
								case .stateAssessed:
									stateAssessedGradingPeriods.indices.forEach { stateAssessedGradingPeriods[$0].grade = .A }
								}
							}
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
		.onChange(of: [fullYearGradingPeriods, semesterGradingPeriods, stateAssessedGradingPeriods]) {
			saveGradingPeriods()
		}
	}
	
	private func saveGradingPeriods() {
		if let encoded = try? JSONEncoder().encode(fullYearGradingPeriods) {
			fullYearGradingPeriodsData = encoded
		}
		if let encoded = try? JSONEncoder().encode(semesterGradingPeriods) {
			semesterGradingPeriodsData = encoded
		}
		if let encoded = try? JSONEncoder().encode(stateAssessedGradingPeriods) {
			stateAssessedGradingPeriodsData = encoded
		}
	}
	private func loadGradingPeriods() {
		if let decoded = try? JSONDecoder().decode([GradingPeriod].self, from: fullYearGradingPeriodsData) {
			fullYearGradingPeriods = decoded
		}
		if let decoded = try? JSONDecoder().decode([GradingPeriod].self, from: semesterGradingPeriodsData) {
			semesterGradingPeriods = decoded
		}
		if let decoded = try? JSONDecoder().decode([GradingPeriod].self, from: stateAssessedGradingPeriodsData) {
			stateAssessedGradingPeriods = decoded
		}
	}
}

#Preview {
	CoursesView()
}
