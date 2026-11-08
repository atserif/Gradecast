//
//  HeaderGlow.swift
//  Grades
//
//  Created by Aram Soneson on 11/7/26.
//

import SwiftUI

struct HeaderGlow: ViewModifier {
	@Environment(\.colorScheme) private var colorScheme
	
	@State private var glowOpacity: Double = 0.3
	
	var color: Color
	var isHiddenOnScroll: Bool = true
	
	func body(content: Content) -> some View {
		GeometryReader { geometry in
			content
				.background(alignment: .top) {
					if colorScheme == .dark {
						EllipticalGradient(stops: [.init(color: color.opacity(glowOpacity), location: 0), .init(color: .clear, location: 1)], center: .top)
							.frame(width: geometry.size.width * 3, height: geometry.safeAreaInsets.top * 5)
							.padding(.top, -50)
							.ignoresSafeArea()
					}
				}
				.onScrollGeometryChange(for: Bool.self) { geometry in
					geometry.contentOffset.y + geometry.contentInsets.top - 10 > 0
				} action: { _, isScrolled in
					withAnimation {
						glowOpacity = isHiddenOnScroll && isScrolled ? 0 : 0.3
					}
				}
		}
	}
}

extension View {
	func headerGlow(_ color: Color, isHiddenOnScroll: Bool = true) -> some View {
		modifier(HeaderGlow(color: color, isHiddenOnScroll: isHiddenOnScroll))
	}
}
