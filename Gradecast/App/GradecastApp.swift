//
//  GradecastApp.swift
//  Gradecast
//
//  Created by Aram Soneson on 1/20/26.
//

import SwiftUI

@main
struct GradecastApp: App {
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
	}
}
