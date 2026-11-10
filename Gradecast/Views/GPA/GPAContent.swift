//
//  GPAContent.swift
//  Gradecast
//
//  Created by Aram Soneson on 6/12/26.
//

import SwiftUI

struct GPAContent: View {
	@State private var textSelection: TextSelection?
	
	@Binding var courses: [Course]
	@Binding var editMode: EditMode
	
	@Binding var selectionFeedbackTrigger: Int
	@Binding var successFeedbackTrigger: Int
	
	var focused: FocusState<UUID?>.Binding
	
	let unweightedGPA: Double
	let weightedGPA: Double
	
	private func deleteCourse(id: UUID) {
		withAnimation {
			courses.removeAll { $0.id == id }
		}
		
		if courses.isEmpty {
			editMode = .inactive
		}
	}
	
	var body: some View {
		Section {
			ForEach($courses, editActions: .move) { course in
				GPARow(textSelection: $textSelection, course: course, editMode: editMode, focused: focused)
					// Prevents horizontal ScrollView from clipping when scrolled
					.listRowInsets(EdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 0))
					.alignmentGuide(.listRowSeparatorLeading) { _ in 16 }
					.swipeActions {
						Button("Delete", systemImage: "trash", role: .destructive) {
							if focused.wrappedValue == course.id {
								focused.wrappedValue = nil
							}
							
							deleteCourse(id: course.id)
						}
						
						Button("Reset", systemImage: "arrow.counterclockwise") {
							if focused.wrappedValue == course.id {
								focused.wrappedValue = nil
							}
							
							course.wrappedValue.reset()
						}
					}
					// Individual selection context menu
					.contextMenu {
						Button("Rename", systemImage: "character.cursor.ibeam") {
							editMode = .inactive
							focused.wrappedValue = course.id
							
							Task {
								textSelection = TextSelection(range: course.wrappedValue.name.startIndex..<course.wrappedValue.name.endIndex)
							}
							
							selectionFeedbackTrigger += 1
						}
						
						Button("Reset", systemImage: "arrow.counterclockwise") {
							if focused.wrappedValue == course.id {
								focused.wrappedValue = nil
							}
							
							course.wrappedValue.reset()
							
							selectionFeedbackTrigger += 1
						}
						
						Divider()
						
						Button("Delete", systemImage: "trash", role: .destructive) {
							if focused.wrappedValue == course.id {
								focused.wrappedValue = nil
							}
							
							Task {
								deleteCourse(id: course.id)
							}
							
							selectionFeedbackTrigger += 1
						}
					}
					.id(course.id)
					// Fixes animation issues when allowsHitTesting is toggled
					.geometryGroup()
			}
		} header: {
			Text("Course Grades, Levels, & Credits")
		}
		
		Section {
			HStack(spacing: 16) {
				LabeledContent("Unweighted") {
					Text(unweightedGPA.formatted(.number.precision(.fractionLength(2))))
						.monospacedDigit()
						.contentTransition(.numericText())
						.animation(.default, value: unweightedGPA)
				}
				.frame(maxWidth: .infinity, alignment: .leading)
				
				// Replicates default List row separator styling
				Rectangle()
					.fill(Color(.separator))
					.frame(width: 1)
				
				LabeledContent {
					Text(weightedGPA.formatted(.number.precision(.fractionLength(2))))
						.monospacedDigit()
						.contentTransition(.numericText())
						.animation(.default, value: weightedGPA)
				} label: {
					ZStack(alignment: .leading) {
						Text("Unweighted")
							.opacity(0)
						
						Text("Weighted")
					}
				}
				.frame(maxWidth: .infinity, alignment: .leading)
			}
			.listRowBackground(Color(.secondarySystemGroupedBackground))
		}
		.contextMenu {
			Button("Copy Unweighted", systemImage: "document.on.document") {
				UIPasteboard.general.string = unweightedGPA.formatted(.number.precision(.fractionLength(2)))
				successFeedbackTrigger += 1
			}
			
			Button("Copy Weighted", systemImage: "document.on.document") {
				UIPasteboard.general.string = weightedGPA.formatted(.number.precision(.fractionLength(2)))
				successFeedbackTrigger += 1
			}
		}
		.id("bottom")
	}
}

#Preview {
	GPAView()
}
