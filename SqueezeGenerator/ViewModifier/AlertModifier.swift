//
//  sa.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 31.08.2025.
//

import SwiftUI
import UIKit

struct AlertModifier: ViewModifier {
    @EnvironmentObject var appServices: AppServiceManager
    @State private var appeareAnimationCompleted: Bool = false
    
    func body(content: Content) -> some View {
        content
            .onChange(of: appServices.alertManager.currentMessage?.id) { newValue in
                guard let _ = appServices.alertManager.currentMessage else {
                    appServices.alertManager.dismiss()
                    return
                }
                self.presentViewController()
            }
            .onChange(of: appServices.alertManager.dismissingMessage?.id) { newValue in
                if newValue != nil {
                    self.dismissViewController()
                }
            }
    }
    
    private func presentViewController() {
        let vc = UIHostingController(rootView: AlertView(data: appServices.alertManager.currentMessage!, dismiss: {
            appServices.alertManager.dismiss()
        }, appeareAnimationCompleted: $appeareAnimationCompleted))
        
        vc.view.layer.name = "alert"
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        vc.view.backgroundColor = .clear
        UIApplication.shared.activeWindow?.rootViewController?.present(vc)
    }
    
    private func dismissViewController() {
        if let vc = UIApplication.shared.activeWindow?.rootViewController?.topViewController,
           vc.view.layer.name == "alert"
        {
            withAnimation(.smooth(duration: 0.3)) {
                appeareAnimationCompleted = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300), execute: {
                vc.dismiss(animated: true) {
                    appServices.alertManager.dissmissAnimationCompleted()
                }
            })
           
            
        }
    }
}
