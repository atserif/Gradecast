//
//  PresentationRimLight.swift
//  Grades
//
//  Created by Aram Soneson on 7/29/26.
//

import SwiftUI

struct PresentationRimLight: ViewModifier {
	@Environment(\.colorScheme) private var colorScheme
	
	var visibility: Visibility
	
	func body(content: Content) -> some View {
		if visibility == .visible {
			content
				.overlay {
					ContainerRelativeShape()
						.strokeBorder(.white.opacity(0.075).exposureAdjust(colorScheme == .dark ? 1 : 1.8), lineWidth: 1)
						.mask {
							VStack(spacing: 0) {
								LinearGradient(gradient: Gradient(colors: [.black, .clear]), startPoint: .top, endPoint: .bottom)
									.frame(height: 70)
								
								Rectangle()
									.fill(.clear)
							}
						}
						.ignoresSafeArea()
				}
		}
	}
}

extension View {
	func presentationRimLight(_ visibility: Visibility) -> some View {
		modifier(PresentationRimLight(visibility: visibility))
	}
}
