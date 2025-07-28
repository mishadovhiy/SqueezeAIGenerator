//
//  CardsViewModel.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 26.07.2025.
//

import SwiftUI

class CardsViewModel: ObservableObject {
    let data: [CardData]
    typealias Selection = [UUID: String]
    let donePressed: (Selection)->()
    var selectedOptions: Selection = [:]
    @Published var currentIndex: Int = 0 {
        willSet {
            let id = data[currentIndex]
            if newValue > currentIndex {
            } else {
                selectedOptions.removeValue(forKey: id.id)
            }
        }
    }
    @Published var collectionHeight: [UUID: CGFloat] = [:]
    @Published var dragPosition: CGPoint = .zero
    @Published var scrollSized: [ScrollSized] = []
    @Published var selectedActions: [CollectionViewController.CollectionData] = []
    
    struct ViewProperties: Hashable, Equatable {
        let data: [CardData]
    }
    
    init(_ proeprties: ViewProperties,
         donePressed: @escaping (Selection)->()) {
        self.data = proeprties.data
        self.donePressed = donePressed
    }
    
    var currentData: CardData? {
        if data.count - 1 >= currentIndex {
            return data[currentIndex]
        }
        return nil
    }
    
    func didSelectButton(button: CollectionViewController.CollectionData) {
        let id = data[currentIndex]
        selectedOptions.updateValue(button.id, forKey: id.id)

        withAnimation {
            currentIndex += 1
            dragPosition = .zero
        }
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
}

extension CardsViewModel {
    enum ScrollSized: String, Equatable, CaseIterable {
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
        
        static func additionalProperties(_ i: Int) -> [Self]? {
            return switch i {
            case 5: [.left, .top].sorted(by: {
                $0.index <= $1.index
            })
            case 6: [.right, .top].sorted(by: {
                $0.index <= $1.index
            })
            case 7: [.bottom, .right].sorted(by: {
                $0.index <= $1.index
            })
            case 8: [.bottom, .left].sorted(by: {
                $0.index <= $1.index
            })
            default: nil
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
