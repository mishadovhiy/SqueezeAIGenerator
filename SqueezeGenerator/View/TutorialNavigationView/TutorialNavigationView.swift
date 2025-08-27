//
//  TutorialNavigationView.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 27.08.2025.
//

import SwiftUI

struct TutorialNavigationView: View {
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color.black.opacity(0.8)
                    .ignoresSafeArea(.all)
                    .allowsTightening(true)
                RoundedRectangle(cornerRadius: 12)
                    .fill(.red)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .offset(y: proxy.frame(in: .global).height * 0.4)
                    .blendMode(.destinationOut)
            }
            .compositingGroup()
            .allowsHitTesting(false)
        }
    }
}

#Preview {
    TutorialNavigationView()
}
