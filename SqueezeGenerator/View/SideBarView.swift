//
//  SideBarView.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 26.08.2025.
//

import SwiftUI

struct SideBarView: View {
    @EnvironmentObject var db: LocalDataBaseManager
    @EnvironmentObject var appService: AppServiceManager
    @EnvironmentObject var navigationManager: NavigationManager
    
    var body: some View {
        VStack(spacing: 20) {
            button("Support", image: .support) {
                navigationManager.append(.support)
            }
            button("App website", image: .globe) {
                let url = URL(string: Keys.websiteURL.rawValue)
                guard let url, UIApplication.shared.canOpenURL(url) else {
                    return
                }
                UIApplication.shared.open(url)
            }
            
            Spacer()
            button("Resturt tutorial", image: .tutorial) {
                db.db.tutorials = .init()
                appService.tutorialManager = .init()
            }
            
            button("Privacy policy", image: .privacy) {
                navigationManager.append(.webview(.privacy))
            }
        }
        .padding(.leading, 5)
        .padding(.top, 60)
        .padding(.bottom, 25)
        .frame(maxWidth: .infinity,
               maxHeight: .infinity,
               alignment: .leading)
    }
    
    func button(
        _ title: String,
        image: ImageResource,
        didPress: @escaping()->()
    ) -> some View {
        HStack {
            Button {
                didPress()
            } label: {
                HStack() {
                    Image(image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 15)
                    Text(title)
                        .font(.system(size: 14, weight: .medium))
                        .multilineTextAlignment(.leading)
                }
                .frame(alignment: .leading)
                .padding(.trailing, 12)
                .padding(.leading, 9)
                .padding(.vertical, 7)
                .background(.white.opacity(0.1))
                .cornerRadius(4)
                .tint(.white)
            }

            Spacer()
        }
    }
}
