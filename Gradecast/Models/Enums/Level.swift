//
//  Level.swift
//  Gradecast
//
//  Created by Aram Soneson on 6/1/26.
//

enum Level: Double, CaseIterable, Codable {
	case regular = 0
	case honors = 0.5
	case gtap = 1
	
	var description: String {
		switch self {
		case .regular: "Regular"
		case .honors: "Honors"
		case .gtap: "G/T · AP"
		}
	}
}
