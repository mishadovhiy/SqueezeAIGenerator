//
//  PinchScrollModifier.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 26.08.2025.
//

import SwiftUI

struct PinchMaskedScrollModifier<SomeView: View>: ViewModifier {
    let viewWidth: CGFloat
    let targedBackgroundView: SomeView
    let disabled: Bool

    @Binding var dragPositionX: CGFloat
    @StateObject var model: PinchMaskedScrollModifierModel = .init()

    func body(content: Content) -> some View {
        ZStack {
            targedBackgroundView
                .frame(maxWidth: model.maxScrollX, alignment: .leading)
                .zIndex(model.isOpened && !model.isScrollActive ? 9999 : 0)

            content
                .disabled(model.isOpened)
                .mask({
                    RoundedRectangle(cornerRadius: 16)
                        .offset(x: model.validatedPosition)
                        .ignoresSafeArea(.all)
                        .opacity(disabled ? 0 : 1)
                        .animation(.smooth, value: disabled)
                })

                .overlay(content: {
                    draggableView
                        .opacity(disabled ? 0 : 1)
                        .animation(.smooth, value: disabled)
                })
            closeView
        }
        .onChange(of: model.dragPositionX) { newValue in
            self.dragPositionX = newValue
            print(model.dragPercent, " yh5gterfwd ")
        }
        .onChange(of: viewWidth) { newValue in
            self.model.viewWidth = newValue
        }
        .onAppear {
            self.model.viewWidth = viewWidth
            self.model.dragPositionX = dragPositionX
        }
    }

    var closeView: some View {
        VStack {
            HStack {
                Button {
                    model.toggleMenuPressed()
                } label: {
                    closeIcon
                }

                Spacer().frame(maxWidth: .infinity)
            }
            Spacer().frame(maxHeight: .infinity)
        }
    }

    @ViewBuilder
    var closeIcon: some View {
        let dragPercent = model.dragPercent
        let toOpenPercent = model.toOpenScrollingPercent
        let toClosePercent = model.toCloseScrollingPercent
        ZStack(
            content: {
            MenuIconShape(
                type: .menu
            )
            .trim(
                to: model.isScrollActive ? toOpenPercent : model.isOpened ? 0 : 1
            )
                .stroke(.white, lineWidth: 2)
                .shadow(radius: 4)
                .scaleEffect(model.isScrollActive ? toOpenPercent : !model.isOpened ? 1 : 0.5)
                .animation(.smooth, value: model.isOpened)

            MenuIconShape(
                type: .close
            )
            .trim(
                to: model.isScrollActive ? toClosePercent : model.isOpened ? 1 : 0
            )
                .stroke(.white, lineWidth: 2)
                .shadow(radius: 4)
                .scaleEffect(model.isScrollActive ? toClosePercent : model.isOpened ? 1 : 0.5)
                .animation(.smooth, value: model.isOpened)
        })
        .frame(width: 24, height: 24)
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
