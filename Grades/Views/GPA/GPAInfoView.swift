//
//  GPAInfoView.swift
//  Grades
//
//  Created by Aram Soneson on 7/30/26.
//

import SwiftUI

struct GPAInfoView: View {
	@Environment(\.dismiss) private var dismiss
	@Environment(\.accessibilityShowBorders) private var showBorders
	
	@State private var feedbackTrigger: Int = 0
	
	var body: some View {
		NavigationStack {
			List {
				Section {
					Text("Grade Values")
						.font(.headline)
					
					ForEach(Grade.allCases, id: \.self) { grade in
						LabeledContent(grade.description, value: "\(grade.rawValue)")
							.monospacedDigit()
					}
				}
				
				Section {
					Text("Level Values")
						.font(.headline)
					
					ForEach(Level.allCases, id: \.self) { level in
						LabeledContent(level.description, value: "+ \(level.rawValue)")
							.monospacedDigit()
					}
				}
				
				Section {
					Text("All GPA calculation information is derived from \(Text("[Howard County Public School System Policy 8020](https://policy.hcpss.org/8000/8020/)")).")
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
						feedbackTrigger += 1
						dismiss()
					}
					.sensoryFeedback(.selection, trigger: feedbackTrigger)
				}
			}
			.navigationTitle("About GPA")
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
			GPAInfoView()
				.interactiveDismissDisabled()
		}
}
