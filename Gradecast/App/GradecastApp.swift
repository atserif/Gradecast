//
//  GradecastApp.swift
//  Gradecast
//
//  Created by Aram Soneson on 1/20/26.
//

import SwiftUI

extension Notification.Name {
	static let newCourseTrigger = Notification.Name("newCourseTrigger")
}

@main
struct GradecastApp: App {
	@FocusedValue(\.selectedTab) private var selectedTab
	@FocusedBinding(\.courseCalculator) private var courseCalculator
	@FocusedValue(\.courseCount) private var courseCount
	
	init() {
		// Set version and build numbers
		if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String, let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
			UserDefaults.standard.set("\(version) (\(build))", forKey: "version")
		}
	}
	
	var body: some Scene {
		WindowGroup {
			ContentView()
		}
		.commands {
			CommandGroup(before: .newItem) {
				Button("New Course", systemImage: "plus") {
					NotificationCenter.default.post(name: .newCourseTrigger, object: nil)
				}
				.keyboardShortcut("n")
				.disabled(selectedTab != .gpa || courseCount ?? 0 >= 20)
			}
			
			CommandGroup(before: .toolbar) {
				Picker("Calculator", selection: $courseCalculator.animation()) {
					ForEach(Calculator.allCases, id: \.self) { calculator in
						Text(calculator.description)
							.tag(calculator)
							.keyboardShortcut(calculator.keyboardShortcut)
					}
				}
				.disabled(selectedTab != .courses)
			}
		}
	}
}
