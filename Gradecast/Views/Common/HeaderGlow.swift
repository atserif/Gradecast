//
//  HeaderGlow.swift
//  Gradecast
//
//  Created by Aram Soneson on 11/7/26.
//

import SwiftUI

struct HeaderGlow: ViewModifier {
	@Environment(\.colorScheme) private var colorScheme
	
	@State private var isScrolled: Bool = false
	
	var color: Color
	var isFocused: Bool = true
	var isHiddenOnScroll: Bool = true

	private var glowOpacity: Double {
		isHiddenOnScroll && isScrolled ? 0 : 0.3
	}
	
	func body(content: Content) -> some View {
		GeometryReader { geometry in
			content
				.background(alignment: .top) {
					if colorScheme == .dark {
						EllipticalGradient(stops: [.init(color: color.opacity(glowOpacity), location: 0), .init(color: .clear, location: 1)], center: .top)
							.frame(width: geometry.size.width * 2, height: geometry.safeAreaInsets.top * 5)
							.padding(.top, -50)
							.saturation(isFocused ? 1 : 0)
							.ignoresSafeArea()
							.animation(.default, value: glowOpacity)
							.animation(.default, value: isFocused)
					}
				}
				.onScrollGeometryChange(for: Bool.self) { scrollGeometry in
					scrollGeometry.contentOffset.y + scrollGeometry.contentInsets.top - 10 > 0
				} action: { _, newValue in
					isScrolled = newValue
				}
		}
	}
}

extension View {
	func headerGlow(_ color: Color, isFocused: Bool, isHiddenOnScroll: Bool = true) -> some View {
		modifier(HeaderGlow(color: color, isFocused: isFocused, isHiddenOnScroll: isHiddenOnScroll))
	}
}
