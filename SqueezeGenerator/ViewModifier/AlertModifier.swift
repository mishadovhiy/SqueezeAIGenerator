//
//  sa.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 31.08.2025.
//

import SwiftUI

struct AlertModifier: ViewModifier {
    @EnvironmentObject var appServices: AppServiceManager
    
    func body(content: Content) -> some View {
        content
            .onChange(of: appServices.alertManager.currentMessage?.id) { newValue in
                print(newValue, " hefrds ")
                guard let _ = appServices.alertManager.currentMessage else {


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
