//
//  HeaderGlow.swift
//  Grades
//
//  Created by Aram Soneson on 11/7/26.
//

import SwiftUI

struct HeaderGlow: ViewModifier {
	@Environment(\.colorScheme) private var colorScheme
	@State private var glowOpacity: Double = 0.5
	
	var color: Color
	var isHiddenOnScroll: Bool = true
	
	func body(content: Content) -> some View {
		GeometryReader { geometry in
			content
				.background {
					if colorScheme == .dark {
						VStack {
							Ellipse()
								.fill(color)
								.frame(maxWidth: .infinity, maxHeight: geometry.safeAreaInsets.top * 2)
								.padding(.top, -geometry.safeAreaInsets.top - 10)
								.opacity(glowOpacity)
								.blur(radius: 140)
								.ignoresSafeArea()
							
							Spacer()
						}
					}
				}
				.onScrollGeometryChange(for: Bool.self) { geometry in
					geometry.contentOffset.y + geometry.contentInsets.top - 10 > 0
				} action: { _, isScrolled in
					withAnimation {
						glowOpacity = isHiddenOnScroll && isScrolled ? 0 : 0.5
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
