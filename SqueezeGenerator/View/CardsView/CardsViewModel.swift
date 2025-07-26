//
//  CardsViewModel.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 26.07.2025.
//

import Foundation

class CardsViewModel: ObservableObject {
    let data: [CardData]
    @Published var currentIndex: Int = 0
    @Published var collectionHeight: [UUID: CGFloat] = [:]
    @Published var dragPosition: CGPoint = .zero
    @Published var scrollSized: [ScrollSized] = []
    @Published var selectedActions: [CollectionViewController.CollectionData] = []
    
    init(data: [CardData]) {
        self.data = data
    }
    
    var currentData: CardData? {
        if data.count - 1 >= currentIndex {
            return data[currentIndex]
        }
        return nil
    }
    
    func cardPosition(_ data: CardData,
                      viewSize: CGSize) -> CGPoint {
        .init(x: currentData?.id == data.id ? dragPosition.x : self.data.firstIndex(where: {
            $0.id == data.id
        }) ?? 0 >= currentIndex ? .zero : viewSize.width * 1.5, y: currentData?.id == data.id ? dragPosition.y : 0)
    }
    
    func dragPositionChanged(viewSize: CGSize) {
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
        var removedButtons = currentItem.buttons.prefix(4)
        for i in 0..<removedButtons.count {
            if scrollSized.contains(where: {
                $0.index == i
            }) {
                selectedActions.append(removedButtons[i])
            }
        }
        if scrollSized.count >= 2 && currentItem.buttons.count >= 5 {
            
            var buttons = currentItem.buttons.filter({ button in
                !removedButtons.contains(where: {
                    button.id == $0.id
                })
            })
            
            print(buttons, " rgterfwd ")
        }
        self.selectedActions = selectedActions
    }
}

extension CardsViewModel {
    enum ScrollSized: String, CaseIterable {
        case left, top, right, bottom
        
        var percent: CGFloat {
            switch self {
            case .left, .top:
                -0.3
            case .right, .bottom:
                0.3
            }
        }
        
        var index: Int {
            ScrollSized.allCases.firstIndex(of: self) ?? 0
        }
        
        var isHorizontal: Bool {
            switch self {
            case .left, .right: true
            default: false
            }
        }
    }
}
