//
//  PinchMaskedScrollModifierModel.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 26.08.2025.
//

import SwiftUI

class PinchMaskedScrollModifierModel: ObservableObject {
    var viewWidth: CGFloat = 0
    @Published var dragPositionX: CGFloat = 0

    @Published var isScrollActive: Bool = false
    var lastPosition: CGFloat = 0
    @Published var isOpened = false

    var validatedPosition: CGFloat {
        dragPositionX >= 0 ? dragPositionX : 0
    }
    let maxPercent = 0.7
    let openPercent = 0.2
    /// percent to opened position
    let closePercent = 0.74
    func scrollEnded() {
        let newPosition: CGFloat
        let openPosition = (maxPercent * viewWidth)
        let multiplier = (isOpened ? (closePercent * maxPercent) : openPercent)
        let targetWidth = multiplier * viewWidth
        if isOpened {
            newPosition = dragPositionX < targetWidth ? .zero : openPosition
        } else {
            newPosition = dragPositionX > targetWidth ? openPosition : .zero
        }
        DispatchQueue.main.async {
            let isOpened = newPosition >= self.openPercent
            withAnimation(.smooth(duration: 0.5)) { [weak self] in
                guard let self else { return }
                dragPositionX = newPosition
                lastPosition = newPosition
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: { [weak self] in
                guard let self else { return }
                self.isOpened = isOpened
                self.isScrollActive = false

            })
        }
    }

    func scrollStarted() {
        if isScrollActive {
            return
        }
        isScrollActive = true
        isOpened = lastPosition >= openPercent
        print(isOpened, " yhrtgerfed")
    }
    var maxScrollX: CGFloat {
        viewWidth * maxPercent
    }
}
