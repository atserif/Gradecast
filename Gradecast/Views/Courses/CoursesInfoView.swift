//
//  CoursesInfoView.swift
//  Gradecast
//
//  Created by Aram Soneson on 7/29/26.
//

import SwiftUI

struct CoursesInfoView: View {
	@Environment(\.dismiss) private var dismiss
	
	@State private var selectionFeedbackTrigger: Int = 0
	
	var body: some View {
		NavigationStack {
			List {
				Section {
					Text("Full Year")
						.font(.headline)
					
					// Divides by 100 because of how .percent handles decimals
					Text("Quarter grades are worth \((22.5 / 100).formatted(.percent)) each. The final exam is worth \(10.formatted(.percent)).")
						.font(.subheadline)
						.foregroundStyle(.secondary)
				}
				
				Section {
					Text("Semester")
						.font(.headline)
					
					Text("Quarter grades are worth \(45.formatted(.percent)) each. The final exam is worth \(10.formatted(.percent)).")
						.font(.subheadline)
						.foregroundStyle(.secondary)
				}
				
				Section {
					Text("State-Assessed")
						.font(.headline)
					
					Text("Quarter grades, as well as the state assessment, are worth \(20.formatted(.percent)) each.")
						.font(.subheadline)
						.foregroundStyle(.secondary)
				}
				
				Section {
					Text("All grade calculation information is derived from \(Text("[Howard County Public School System Policy 8020](https://policy.hcpss.org/8000/8020/)")).")
						.font(.subheadline)
						.foregroundStyle(.secondary)
				}
				.listRowBackground(Color.clear)
				.listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 16))
			}
			.listSectionSpacing(20)
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button("Close", systemImage: "xmark", role: .close) {
						dismiss()
						selectionFeedbackTrigger += 1
					}
					.sensoryFeedback(.selection, trigger: selectionFeedbackTrigger)
				}
			}
			.navigationTitle("About Courses")
			.toolbarTitleDisplayMode(.inline)
			.scrollEdgeEffectStyle(.soft, for: .all)
			.contentMargins(.top, 10)
		}
	}
}

#Preview {
	// Previews View as a sheet
	VStack { }
		.sheet(isPresented: .constant(true)) {
			CoursesInfoView()
				.interactiveDismissDisabled()
				.presentationRimLight(.visible)
		}
}
