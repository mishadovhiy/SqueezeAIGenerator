//
//  TutorialTargetViewModifier.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 27.08.2025.
//

import SwiftUI

/// sets frame of the content, for current matching target.
/// - frame used in 'TutorialModifier'
struct TutorialTargetModifier: ViewModifier, TutorialModifierUIService {
    
    @EnvironmentObject var appService: AppServiceManager
    let targetType: DataBase.Tutorial.TutorialType
    
    func body(content: Content) -> some View {
        content
            .background {
                GeometryReader { proxy in
                    frameUpdater(proxy)
                }
            }
    }
    
    private func frameUpdater(_ proxy: GeometryProxy) -> some View {
        Color.clear
            .onAppear {
                if targetType == appService.tutorialManager.type {
                    updateTargetFrame(proxy)
                }
            }
            .onChange(of: proxy.frame(in: .global)) { newValue in
                if targetType == appService.tutorialManager.type {
                    updateTargetFrame(proxy)
                }
            }
            .onChange(of: appService.tutorialManager.type) { newValue in
                if newValue == targetType {
                    updateTargetFrame(proxy)
                }
            }
    }
    
    private func updateTargetFrame(_ proxy: GeometryProxy) {
        var frame = proxy.frame(in: .global)
        if appService.tutorialManager.type?.isLocalX ?? false {
            frame.origin = .init(x: proxy.frame(in: .local).minX, y: frame.minY)
        }
        if appService.tutorialManager.type?.xPositionFromStart ?? false {
            frame.origin = .init(x: 0, y: frame.minY)
            frame.size = .init(width: UIApplication.shared.activeWindow?.frame.width ?? frame.width, height: frame.height)
        }
        withAnimation(defaultAnimation) {
            appService.tutorialManager.frame = frame
        }
    }
}
