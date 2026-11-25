//
//  FocusedValues.swift
//  Gradecast
//
//  Created by Aram Soneson on 11/23/26.
//

import SwiftUI

struct SelectedTabKey: FocusedValueKey {
	typealias Value = Binding<TabSelection>
}

struct CourseCalculatorKey: FocusedValueKey {
	typealias Value = Binding<Calculator>
}

struct CourseCountKey: FocusedValueKey {
	typealias Value = Int
}

extension FocusedValues {
	var selectedTab: Binding<TabSelection>? {
		get { self[SelectedTabKey.self] }
		set { self[SelectedTabKey.self] = newValue }
	}
	
	var courseCalculator: Binding<Calculator>? {
		get { self[CourseCalculatorKey.self] }
		set { self[CourseCalculatorKey.self] = newValue }
	}
	
	var courseCount: Int? {
		get { self[CourseCountKey.self] }
		set { self[CourseCountKey.self] = newValue }
	}
}
