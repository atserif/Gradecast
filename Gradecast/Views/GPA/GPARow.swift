//
//  GPARow.swift
//  Gradecast
//
//  Created by Aram Soneson on 7/7/26.
//

import SwiftUI

struct GPARow: View {
	@State private var credits: [Double] = [1, 0.5, 0.25]
	@Binding var course: Course
	@Binding var editMode: EditMode
	@Binding var textSelection: TextSelection?
	
	var focused: FocusState<UUID?>.Binding
	
	var body: some View {
		VStack(alignment: .leading) {
			TextField("Course Name", text: $course.name, selection: $textSelection, prompt: Text("Course Name"))
				// Enables editing when rename button is pressed
				.allowsHitTesting(editMode == .inactive && focused.wrappedValue != nil && course.id == focused.wrappedValue)
				.font(.headline)
				.padding(.horizontal)
				.focused(focused, equals: course.id)
				.submitLabel(.done)
				.autocorrectionDisabled()
				.textInputAutocapitalization(.words)
				.writingToolsBehavior(.disabled)
				.writingToolsAffordanceVisibility(.hidden)
			
			ScrollView(.horizontal) {
				HStack(spacing: 12) {
					Menu(course.grade.description, systemImage: "checkmark.circle") {
						Picker("Grade", selection: $course.grade) {
							ForEach(Grade.allCases, id: \.self) { grade in
								Text(grade.description)
									.tag(grade)
							}
						}
						// Shows header in Menu
						.labelsVisibility(.visible)
					}
					
					Menu(course.level.description, systemImage: "square.3.layers.3d") {
						Picker("Level", selection: $course.level) {
							ForEach(Level.allCases, id: \.self) { level in
								Text(level.description)
									.tag(level)
							}
						}
						.labelsVisibility(.visible)
					}
					
					Menu(course.credits.description, systemImage: "scalemass") {
						Picker("Credits", selection: $course.credits) {
							ForEach(credits, id: \.self) { creditValue in
								Text(creditValue.description)
									.tag(creditValue)
							}
						}
						.labelsVisibility(.visible)
					}
				}
				.labelStyle(.picker)
				.buttonStyle(.borderless)
				.padding(.horizontal)
			}
			.allowsHitTesting(editMode == .inactive)
			.scrollIndicators(.hidden)
			.scrollBounceBehavior(.basedOnSize, axes: .horizontal)
			.mask {
				// Applies fade out effect
				HStack(spacing: 0) {
					LinearGradient(gradient: Gradient(colors: [.clear, .black]), startPoint: .leading, endPoint: .trailing)
						.frame(width: 16)
					
					Rectangle()
						.fill(.black)
					
					LinearGradient(gradient: Gradient(colors: [.clear, .black]), startPoint: .trailing, endPoint: .leading)
						.frame(width: 16)
				}
			}
			.animation(.default, value: editMode)
		}
	}
}

#Preview {
	GPAView()
}
