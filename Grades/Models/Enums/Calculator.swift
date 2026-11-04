//
//  Calculator.swift
//  Grades
//
//  Created by Aram Soneson on 11/4/26.
//

enum Calculator: CaseIterable, Codable {
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
