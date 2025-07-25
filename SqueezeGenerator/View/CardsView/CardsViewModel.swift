//
//  CardsViewModel.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 26.07.2025.
//

import Foundation

class CardsViewModel: ObservableObject {
    let data: [CardData] = .demo
    @Published var currentIndex: Int = 0
    @Published var collectionHeight: [UUID: CGFloat] = [:]
    @Published var dragPosition: CGPoint = .zero
    @Published var scrollSized: [ScrollSized] = []

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
    }
    
    var currentData: CardData? {
        if data.count - 1 >= currentIndex {
            return data[currentIndex]
        }
        return nil
    }
}

extension CardsViewModel {
    enum ScrollSized: String, CaseIterable {
        case left, right, top, bottom
        
        var percent: CGFloat {
            switch self {
            case .left, .top:
                -0.3
            case .right, .bottom:
                0.3
            }
        }
        
        var isHorizontal: Bool {
            switch self {
            case .left, .right: true
            default: false
            }
        }
    }
}
