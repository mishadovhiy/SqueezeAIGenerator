//
//  ScrollSized.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 08.08.2025.
//

import Foundation

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

        var onEndedPointMult: CGSize {
    //            .init(width: 1.5, height: 0)
            switch self {
            case .left, .right:
                    .init(
                        width: 1.5 * (self == .left ? -1 : 1),
                        height: 0
                    )
            case .bottom, .top:
                    .init(
                        width: 0,
                        height: 1.5 * (self == .bottom ? 1 : -1)
                    )
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
