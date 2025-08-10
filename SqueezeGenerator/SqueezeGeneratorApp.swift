//
//  SqueezeGeneratorApp.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 14.07.2025.
//

import SwiftUI
import Combine

@main
struct SqueezeGeneratorApp: App {
    @StateObject var db: AppData = .init()

    static var adPresenting = PassthroughSubject<Bool, Never>()
    static func triggerAdPresenting(with newValue: Bool = false) {
        adPresenting.send(newValue)
    }

    fileprivate static var navigationHeight = PassthroughSubject<CGFloat, Never>()
    static func navigationHeight(with newValue: CGFloat = .zero) {
        navigationHeight.send(newValue)
    }

    var body: some Scene {
        WindowGroup {
//            CardsView(.demo)
            HomeView()
                .environment(\.colorScheme, .dark)
                .preferredColorScheme(.dark)
                .environmentObject(db)
                .onAppear {
                    SqueezeGeneratorApp.adPresenting.sink { newValue in
                        self.db.adPresenting = newValue
                    }.store(in: &db.adPresentingValue)

                    SqueezeGeneratorApp.navigationHeight.sink { newValue in
                        self.db.navHeight = newValue
                    }.store(in: &db.navHeightValue)

                    let appearance = UINavigationBarAppearance()
                    appearance.configureWithTransparentBackground()
                    appearance.backgroundColor = .clear
                    appearance.shadowColor = .clear
                    
                    UINavigationBar.appearance().standardAppearance = appearance
                    UINavigationBar.appearance().scrollEdgeAppearance = appearance
                }
        }
    }
}

extension UIWindow: @retroactive UIGestureRecognizerDelegate {

    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        print("erfwedas")
        return super.hitTest(point, with: event)
    }
}

extension UINavigationController: UIScrollViewDelegate, UINavigationControllerDelegate {
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        SqueezeGeneratorApp.navigationHeight(with: navigationBar.frame.size.height ?? 0)
        print(navigationBar.frame.size.height ?? 0, " gterfwdas ")
    }
}
