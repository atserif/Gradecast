//
//  PickerLabelStyle.swift
//  Grades
//
//  Created by Aram Soneson on 7/24/26.
//

import SwiftUI

struct PickerLabelStyle: LabelStyle {
	@Environment(\.accessibilityShowBorders) private var showBorders
	@ScaledMetric(relativeTo: .largeTitle) private var dynamicPadding: CGFloat = 12
	
	func makeBody(configuration: Configuration) -> some View {
		if !showBorders {
			HStack(spacing: 4) {
				configuration.icon
				
				configuration.title
				
				Image(systemName: "chevron.up.chevron.down")
					.imageScale(.small)
			}
			.tint(.secondary)
		} else {
			HStack(spacing: 4) {
				configuration.icon
				
				configuration.title
					.underline(false)
				
				Image(systemName: "chevron.up.chevron.down")
					.imageScale(.small)
			}
			.tint(.secondary)
			// Matches default Picker styling when Show Borders is enabled
			.padding(.vertical, 8)
			.padding(.horizontal, dynamicPadding)
			.background(Color(.tertiarySystemFill))
			.clipShape(.capsule)
		}
	}
}

extension LabelStyle where Self == PickerLabelStyle {
	static var picker: PickerLabelStyle {
		PickerLabelStyle()
	}
}
