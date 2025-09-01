//
//  AlertView.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 29.08.2025.
//

import SwiftUI

struct AlertView: View {

    let data: AlertContentModel
    let dismiss: ()->()
    @Binding var appeareAnimationCompleted: Bool

    @State private var textSize: CGSize = .zero
    @State private var viewSize: CGSize = .zero
    
    var body: some View {
        ZStack {
            BlurView()
                .opacity(appeareAnimationCompleted ? 1 : 0)
                .animation(.smooth, value: appeareAnimationCompleted)
            VStack {
                if needScrollView {
                    ScrollView(.vertical, showsIndicators: false) {
                        contentView
                    }
                } else {
                    contentView
                }
                buttonsStack
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 10)
            .background(content: {
                Color.white.opacity(0.8)
                    .background(BlurView())
            })
            .cornerRadius(35)
            .shadow(radius: 15)
            .offset(y: appeareAnimationCompleted ? 0 : viewSize.height)
            .animation(.smooth, value: appeareAnimationCompleted)
            .frame(
                maxWidth: Constants.maxViewWidth,
                maxHeight: Constants.maxContentHeight + totalButtonsHeight
            )
        }
        .zIndex(99999)
        .background(content: {
            contentHeightReader
        })
        .onAppear {
            calculateTextHeight()
            withAnimation(.smooth) {
                appeareAnimationCompleted = true
            }
        }
    }
    
    var contentView: some View {
        VStack(spacing: 20) {
            Spacer().frame(height: 0)
            if let image = data.imageName {
                Image(image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: Constants.iconHeight)
            }
            Text(data.title)
                .multilineTextAlignment(.center)
                .font(.system(size: Constants.titleFont.pointSize, weight: .medium))
                .foregroundColor(.black)
            Text(data.description)
                .multilineTextAlignment(.center)
                .font(.system(size: Constants.descriptionFont.pointSize, weight: .regular))
                .foregroundColor(.black).opacity(0.6)
            Spacer().frame(height: 0)
        }
    }
    
    @ViewBuilder
    var buttonsStack: some View {
        if data.buttons.count <= 2 {
            HStack {
                buttonList
            }
        } else {
            VStack {
                buttonList
            }
        }
    }
    
    @ViewBuilder
    var buttonList: some View {
        ForEach(data.buttons, id: \.title) { button in
            Button {
                if let action = button.pressed {
                    action()
                } else {
                    dismiss()
                }
            } label: {
                Text(button.title)
            }
            .frame(maxWidth: .infinity)
            .frame(height: Constants.buttonHeight)
            .background(data.buttons.first?.title == button.title ? .blue : .black.opacity(0.1))
            .tint(data.buttons.first?.title == button.title ? .white : .white)
            .font(.system(size: 14, weight: .medium))
            .cornerRadius(16)
        }
    }
}

fileprivate extension AlertView {
    var contentHeightReader: some View {
        GeometryReader { proxy in
            Color.clear
                .onAppear {
                    viewSize = proxy.size
                }
                .onChange(of: proxy.size) { _ in
                    viewSize = proxy.size
                }
        }
    }
    
    var needScrollView: Bool {
        let additionalSpace = totalButtonsHeight + Constants.iconHeight + 60
        let targetHeight = viewSize.height < Constants.maxContentHeight ? (viewSize.height - additionalSpace) : Constants.maxContentHeight
        return textSize.height >= targetHeight
    }
    
    var totalButtonsHeight: CGFloat {
        CGFloat(data.buttons.count >= 3 ? (CGFloat(data.buttons.count) * Constants.buttonHeight) : Constants.buttonHeight)
    }
    
    func calculateTextHeight() {
        let description = Constants.descriptionFont.textSize(viewWidth: Constants.maxViewWidth, text: data.description)
        let title = Constants.titleFont.textSize(viewWidth: Constants.maxViewWidth, text: data.title)
        self.textSize = .init(width: description.width, height: description.height + title.height)
    }
}

fileprivate extension AlertView {
    struct Constants {
        static let iconHeight: CGFloat = 60
        static let buttonHeight: CGFloat = 45
        static let maxViewWidth: CGFloat = 320
        static let titleFont: UIFont = .systemFont(ofSize: 24, weight: .semibold)
        static let descriptionFont: UIFont = .systemFont(ofSize: 14, weight: .regular)
        static let maxContentHeight: CGFloat = 540
    }
}
