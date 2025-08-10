//
//  ScrollReaderModifier.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 10.08.2025.
//

import SwiftUI

struct ScrollReaderModifier: ViewModifier {

    @Binding var scrollPosition: ScrollResult

    func body(content: Content) -> some View {
        content.background {
            GeometryReader { proxy in
                Color.clear
                    .onChange(of: proxy.frame(in: .global).origin) { newValue in
                        scrollPosition.position = newValue
                    }
                    .onAppear {
                        scrollPosition.position = proxy.frame(in: .global).origin
                        print(scrollPosition.position, " gtrefdwsa ")
                    }
            }
        }
    }
}

extension ScrollReaderModifier {
    struct ScrollResult {

        private let isHorizontal: Bool

        var position: CGPoint = .zero {
            didSet {
                if appearePosition == nil {
                    appearePosition = position
                } else if appearePosition != position && initialPosition == nil {
                    initialPosition = position
                }
            }
        }

        fileprivate var initialPosition: CGPoint?
        fileprivate var appearePosition: CGPoint?

        init(isHorizontal: Bool = false) {
            self.isHorizontal = isHorizontal
        }


        var percentPositive: CGFloat {
            let value = percent
            if value <= 0 {
                return 0
            } else {
                return value
            }
        }
        var percentPositiveMax: CGFloat {
            let value = percentMax
            if value <= 0 {
                return 0
            } else {
                return value
            }
        }
        var percent: CGFloat {
            var value: CGFloat {
                if isHorizontal {
                    return position.x / (initialPosition?.x ?? 0)
                } else {
                    return position.y / (initialPosition?.y ?? 0)
                }
            }
            print(value, " grterfwed ", position.y, " ", initialPosition?.y)

            if value.isFinite {
                return value
            } else {
                return 1
            }
        }

        var percentMax: CGFloat {
            let value = percent
            if value >= 1 {
                return 1
            } else {
                return value
            }
        }
    }
}
