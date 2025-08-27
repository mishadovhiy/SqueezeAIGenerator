//
//  TutorialModifier.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 27.08.2025.
//

import SwiftUI

struct TutorialModifier: ViewModifier {
    @EnvironmentObject var db: LocalDataBaseManager
    @State var appAppeared: Bool = false

    func body(content: Content) -> some View {
        content
            .onAppear(perform: {
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
                    withAnimation(.spring(duration: 3)) {
                        appAppeared = true
                    }
                })
            })
            .overlay {
                if db.db.tutorials.needPresenting() && appAppeared {
                    TutorialNavigationView()
                        .transition(.asymmetric(insertion: .opacity, removal: .scale))
                        .animation(.spring(), value: appAppeared)
                }
            }
    }
}
