//
//  PinchScrollModifier.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 26.08.2025.
//

import SwiftUI

struct SidebarModifier<SomeView: View>: ViewModifier {
    let viewWidth: CGFloat
    let targedBackgroundView: SomeView
    let disabled: Bool

    @StateObject var model: PinchMaskedScrollModifierModel = .init()

    func body(content: Content) -> some View {
        let dragPercent = model.dragPercent
        ZStack {
            targedBackgroundView
                .frame(maxWidth: model.maxScrollX, alignment: .leading)
                .zIndex(model.sideBarZindex)

            content
                .disabled(model.isOpened)
                .mask({
                    RoundedRectangle(cornerRadius: 32 * dragPercent)
                        .offset(x: (model.viewWidth * 0.4) * dragPercent)
                        .ignoresSafeArea(.all)
                        .padding(.top, 27 * dragPercent)
                        .padding(.bottom, 33 * dragPercent)
                        .rotationEffect(.degrees(5 * dragPercent))
                        .animation(.smooth, value: model.isScrollActive)
                })

                .overlay(content: {
                    draggableView
                        .opacity(disabled ? 0 : 1)
                        .animation(.smooth, value: disabled)
                })
            sidebarButtonView
        }
        .onChange(of: viewWidth) { newValue in
            self.model.viewWidth = newValue
        }
        .onAppear {
            self.model.viewWidth = viewWidth
        }
    }

    var sidebarButtonView: some View {
        VStack {
            HStack {
                Button {
                    model.toggleMenuPressed()
                } label: {
                    ZStack(
                        content: {
                            menuIcon(.menu,
                                     scrollPercent: model.toOpenScrollingPercent)

                            menuIcon(.close,
                                     scrollPercent: model.toCloseScrollingPercent)
                        })
                    .frame(width: 24, height: 24)
                }

                Spacer().frame(maxWidth: .infinity)
            }
            Spacer().frame(maxHeight: .infinity)
        }
    }

    var draggableView: some View {
        HStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(.white.opacity(0.05))
                .frame(width: 30)
                .offset(x: model.dragPositionX)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            model.scrollStarted()
                            model.dragPositionX = value.translation.width + model.lastPosition
                        }
                        .onEnded { _ in
                            model.lastPosition = model.dragPositionX
                            model.scrollEnded()
                        }
                )
            Spacer().frame(maxWidth: .infinity)
        }
    }
}

fileprivate extension SidebarModifier {
    @ViewBuilder
    func menuIcon(_ type: MenuIconShape.`Type`,
                  scrollPercent: CGFloat) -> some View {
        var iconActive: Bool {
            switch type {
            case .menu:
                return !model.isOpened
            case .close:
                return model.isOpened
            }
        }

        MenuIconShape(
            type: type
        )
        .trim(
            to: model.isScrollActive ? scrollPercent : iconActive ? 1 : 0
        )
        .stroke(.white, lineWidth: 2)
        .shadow(radius: 4)
        .scaleEffect(model.isScrollActive ? scrollPercent : iconActive ? 1 : 0.5)
        .animation(.smooth, value: model.isOpened)
    }
}
