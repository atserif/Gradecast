//
//  GradingPeriod.swift
//  Gradecast
//
//  Created by Aram Soneson on 6/5/26.
//

struct GradingPeriod: Identifiable, Equatable, Codable {
	let id: Int
	let name: String
	let calculators: [Calculator]
	let type: `Type`
	var grade: Grade
}
