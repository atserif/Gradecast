//
//  Grade.swift
//  Gradecast
//
//  Created by Aram Soneson on 6/1/26.
//

enum Grade: Double, CaseIterable, Codable {
	case a = 4
	case b = 3
	case c = 2
	case d = 1
	case e = 0
	
	var description: String {
		switch self {
		case .a: "A"
		case .b: "B"
		case .c: "C"
		case .d: "D"
		case .e: "E"
		}
	}
}
