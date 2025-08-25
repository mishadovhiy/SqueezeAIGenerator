//
//  CardsViewModel.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 26.07.2025.
//

import SwiftUI

class CardsViewModel: ObservableObject {
    var data: [CardData] {
        properties.data
    }
    typealias Selection = [UUID: String]
    let donePressed: (Selection)->()
    var selectedOptions: Selection = [:]
    @Published var viewAppeared = false
    @Published var viewAnimationCompleted = false

    @Published var currentIndex: Int = 0 {
        willSet {
            let id = data.count - 1 >= currentIndex ?  data[currentIndex] : data.last
            if newValue > currentIndex {
            } else if let id = id?.id {
                selectedOptions.removeValue(forKey: id)
            }
        }
    }
    @Published var collectionHeight: [UUID: CGFloat] = [:]
    @Published var dragPosition: CGPoint = .zero
    @Published var dragEnded: Bool = false
    @Published var viewSize: CGSize = .zero
    @Published var scrollSized: [ScrollSized] = []
    @Published var selectedActions: [CollectionViewController.CollectionData] = []
    let properties: ViewProperties
    init(_ proeprties: ViewProperties,
         donePressed: @escaping (Selection)->()) {
        self.properties = proeprties
        self.donePressed = donePressed
    }
    
    var currentData: CardData? {
        if data.count - 1 >= currentIndex {
            return data[currentIndex]
        }
        return nil
    }
    private var lastDragPosition: CGPoint?

    func didSelectButton(button: CollectionViewController.CollectionData) {

        let id = data[currentIndex]
        selectedOptions.updateValue(button.id, forKey: id.id)
        let holder = dragPosition
        let lastPosition = (scrollSized.first ?? .right).onEndedPointMult
        let result = CGPoint(
            x: viewSize.width * lastPosition.width,
            y: viewSize.height * lastPosition.height)
        withAnimation(.bouncy(duration: 0.44)) {
            dragEnded = true
            self.dragPosition = .init(
                x: lastPosition.width == .zero ? holder.x : result.x,
                y: lastPosition.width == .zero ? result.y : holder.y
                                )
            self.lastDragPosition = dragPosition
            self.scrollSized.removeAll()
            self.selectedActions.removeAll()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(440), execute: {
            withAnimation {
                self.currentIndex += 1
                self.dragPosition = .zero
                self.dragEnded = false
                self.oldPositions.updateValue(self.lastDragPosition!, forKey: id.id)
                self.selectedActions.removeAll()
            }
        })
    }

    private var oldPositions: [UUID: CGPoint] = [:]
    func cardPosition(_ data: CardData,
                      viewSize: CGSize) -> CGPoint {
        if currentData?.id == data.id {
            return dragPosition
        } else {
            let isNotCompletedCard = self.data.firstIndex(where: {
                $0.id == data.id
            }) ?? 0 >= currentIndex
            let isLast = data.id == self.data.prefix(currentIndex + (dragEnded ? 1 : 0)).last?.id
            if !isNotCompletedCard {
                let `default`: CGPoint = .init(x: viewSize.width * 1.5, y: 0)
                let position = oldPositions[data.id]
                return isLast ? lastDragPosition ?? `default` : (position ?? `default`)
            } else {
                return .zero
            }

        }
    }
    
    func setScrollActions(viewSize: CGSize) {
        let percent: CGPoint = .init(x: dragPosition.x / viewSize.width, y: dragPosition.y / viewSize.height)
        scrollSized = ScrollSized.allCases.filter({
            if $0.percent <= 0 {
                return $0.isHorizontal ? $0.percent >= percent.x : $0.percent >= percent.y
            } else {
                return $0.isHorizontal ? $0.percent <= percent.x : $0.percent <= percent.y
            }
        })
        guard let currentItem = self.currentData else {
            scrollSized.removeAll()
            return
        }
        var selectedActions = selectedActions
        selectedActions.removeAll()
        let buttons = currentItem.buttons.dropFirst(4)
        if scrollSized.count >= 2 && currentItem.buttons.count >= 5 {

            for i in 0..<4 {
                let sizes = ScrollSized.additionalProperties(i + 4)
                
                if scrollSized.sorted(by: {
                    $0.index <= $1.index
                }) == sizes {
                    if currentItem.buttons.count - 1 >= i + 3 {
                        selectedActions.append(currentItem.buttons[i + 3])
                    }
                    
                }
            }
        }
        else {
            for i in 0..<currentItem.buttons.count {
                if scrollSized.contains(where: {
                    $0.index == i
                }) {
                    selectedActions.append(currentItem.buttons[i])
                }
            }
        }
        self.selectedActions = selectedActions
    }

    var inactiveCardPositionY: CGFloat {
        UIDevice.current.userInterfaceIdiom == .pad ? -500 : -100
    }
}

extension CardsViewModel {
    struct ViewProperties: Hashable, Equatable {
        let type: String
        let selectedResponseItem: NetworkRequest.SqueezeRequest?
        let data: [CardData]
    }
}
