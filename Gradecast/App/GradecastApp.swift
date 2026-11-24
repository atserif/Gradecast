//
//  GradecastApp.swift
//  Gradecast
//
//  Created by Aram Soneson on 1/20/26.
//

import SwiftUI

@main
struct GradecastApp: App {
	@FocusedBinding(\.selectedTab) private var selectedTab
	@FocusedBinding(\.courseCalculator) private var courseCalculator
	
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
