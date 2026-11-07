//
//  ContentView.swift
//  Grades
//
//  Created by Aram Soneson on 1/20/26.
//

import SwiftUI

private enum TabSelection {
	case courses
	case gpa
}

struct ContentView: View {
	@State private var tabSelection: TabSelection = .courses
	
	var body: some View {
		TabView(selection: $tabSelection) {
			Tab("Courses", systemImage: "timeline.selection", value: .courses) {
				CoursesView()
			}
			
			Tab("GPA", systemImage: "sum", value: .gpa) {
				GPAView()
			}
		}
		.sensoryFeedback(.selection, trigger: tabSelection)
	}
}

#Preview {
	ContentView()
}
