//
//  TapThroughtModifier.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 27.08.2025.
//

import SwiftUI

struct TapThroughtModifier: ViewModifier {
    let didPress: ()->()

    func body(content: Content) -> some View {
        content
            .overlay {
                TapthoughViewRepresentable(didPress: didPress)
            }
    }
}

fileprivate struct TapthoughViewRepresentable: UIViewRepresentable {
    let didPress: ()->()

    func makeUIView(context: Context) -> some UIView {
        TapthoughViewController(didPress: didPress)
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {

    }
}

fileprivate class TapthoughViewController: UIView {
    let didPress: ()->()

    init(didPress: @escaping () -> Void) {
        self.didPress = didPress
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        didPress()
        return superview?.hitTest(point, with: event)
    }
}
