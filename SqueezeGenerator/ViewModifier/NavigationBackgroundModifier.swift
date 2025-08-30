//
//  NavigationBackgroundModifier.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 29.08.2025.
//

import SwiftUI

struct NavigationBackgroundModifier: ViewModifier {

    @EnvironmentObject private var db: LocalDataBaseManager

    static let cornerRadius: CGFloat = 24
    let largeNavigationHeight: CGFloat = 96
    let compactNavigationHeight: CGFloat = 44

    func body(content: Content) -> some View {
        content
            .overlay {
                GeometryReader { proxy in
                    VStack(spacing: 0) {
                        background(proxy)
                        Spacer().frame(maxHeight: .infinity)
                    }
                    .ignoresSafeArea(.all)
                }
            }

    }

    func background(_ proxy: GeometryProxy) -> some View {
        ZStack {
            Color(uiColor: .black.withAlphaComponent(1))
                .frame(
                    height: proxy.safeAreaInsets
                        .top + (NavigationBackgroundModifier.cornerRadius + 8)
                )
                .opacity(Double(1) - ((db.navHeight - compactNavigationHeight) / (largeNavigationHeight - compactNavigationHeight)))
                .cornerRadius(NavigationBackgroundModifier.cornerRadius)
        }
        .padding(.top, -NavigationBackgroundModifier.cornerRadius)
        .clipped()
    }

}
