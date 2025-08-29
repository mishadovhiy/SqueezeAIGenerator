//
//  SqueezeGeneratorApp.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 14.07.2025.
//

import SwiftUI
import Combine
import UIKit

@main
struct SqueezeGeneratorApp: App {
    @StateObject var db: LocalDataBaseManager = .init()
    @StateObject var appServices: AppServiceManager = .init()

#warning("todo: move to ServiceManager, @enviroment no combine")
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
//            IconsView()
                .environment(\.colorScheme, .dark)
                .preferredColorScheme(.dark)
                .modifier(
                    TutorialModifier()
                )
                .environmentObject(db)
                .environmentObject(appServices)
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
                .onChange(of: appServices.alertManager.currentMessage?.id.uuidString) { newValue in
                    print(newValue, " hefrds ")
                    guard let data = appServices.alertManager.currentMessage else {


                        return
                    }
                    let vc = UIHostingController(rootView: AlertView(data: appServices.alertManager.currentMessage!, dismiss: {
                        if let vc = UIApplication.shared.keyWindow?.rootViewController?.topViewController,
                           vc.view.layer.name == "alert"
                        {
                            vc.dismiss(animated: true) {
                                appServices.alertManager.dismiss()
                            }
                        }

                    }))
                    vc.view.layer.name = "alert"
                    vc.modalPresentationStyle = .overFullScreen
                    vc.modalTransitionStyle = .crossDissolve
                    vc.view.backgroundColor = .clear
                    UIApplication.shared.keyWindow?.rootViewController?.present(vc)
                }
        }
    }
}

extension UIWindow: @retroactive UIGestureRecognizerDelegate {

    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return super.hitTest(point, with: event)
    }
}

extension UINavigationController: UIScrollViewDelegate, UINavigationControllerDelegate {
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
#warning("no need: testing")
        SqueezeGeneratorApp.navigationHeight(with: navigationBar.frame.size.height ?? 0)
    }
}

extension UIViewController {
    func present(_ viewController: UIViewController) {
        if let vc = self.presentedViewController {
            vc.present(viewController)
        } else {
            self.present(viewController, animated: true)
        }
    }

    var topViewController: UIViewController {
        if let presentedViewController {
            return presentedViewController.topViewController
        } else {
            return self
        }
    }
}


struct IconsView: View {
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                AsyncImage(url: .init(string: Keys.apiBaseURL.rawValue + "/generateSqueeze/icons/depression.png")) { phas in
                    switch phas {
                    case .empty:
                        ProgressView()
                            .progressViewStyle(.circular)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            
                    case .failure(let error):
                        Image(.chart)
                            .resizable()
                                               .scaledToFit()
                                               .frame(width: 20, height: 20)
                    }
                }
                Spacer()
            }
            Spacer()
        }

    }
}
