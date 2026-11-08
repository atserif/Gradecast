//
//  Course.swift
//  Gradecast
//
//  Created by Aram Soneson on 6/2/26.
//

import SwiftUI

struct Course: Identifiable, Equatable, Codable {
	var id: UUID = UUID()
	let number: Int
	
	var name: String
	var grade: Grade
	var level: Level
	var credits: Double
}
