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
                })

                .overlay(content: {
                    draggableView
                })

        }
        .onChange(of: model.dragPositionX) { newValue in
            self.dragPositionX = newValue
        }
        .onChange(of: viewWidth) { newValue in
            self.model.viewWidth = newValue
        }
        .onAppear {
            self.model.viewWidth = viewWidth
            self.model.dragPositionX = dragPositionX
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
