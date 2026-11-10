//
//  PickerLabelStyle.swift
//  Gradecast
//
//  Created by Aram Soneson on 7/24/26.
//

import SwiftUI

struct PickerLabelStyle: LabelStyle {
	@Environment(\.accessibilityShowBorders) private var showBorders
	@ScaledMetric(relativeTo: .largeTitle) private var dynamicPadding: CGFloat = 12
	
	func makeBody(configuration: Configuration) -> some View {
		HStack(spacing: 4) {
			configuration.icon
			
			configuration.title
				.underline(false)
			
			Image(systemName: "chevron.up.chevron.down")
				.imageScale(.small)
		}
		.tint(.secondary)
		// Matches default Picker styling when Show Borders is enabled
		.padding(.vertical, showBorders ? 8 : 0)
		.padding(.horizontal, showBorders ? dynamicPadding : 0)
		.background {
			if showBorders {
				Capsule()
					.fill(Color(.tertiarySystemFill))
			}
		}
	}
}

extension LabelStyle where Self == PickerLabelStyle {
	static var picker: PickerLabelStyle {
		PickerLabelStyle()
	}
}
