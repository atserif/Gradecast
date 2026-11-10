//
//  Course.swift
//  Gradecast
//
//  Created by Aram Soneson on 6/2/26.
//

import Foundation

struct Course: Identifiable, Equatable, Codable {
	var id: UUID = UUID()
	let number: Int
	
	var name: String
	var grade: Grade
	var level: Level
	var credits: Double
	
	mutating func reset() {
		name = "Course \(number)"
		grade = .a
		level = .regular
		credits = 1
	}
}
