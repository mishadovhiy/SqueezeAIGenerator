//
//  CardView.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 02.09.2025.
//

import SwiftUI

struct CardView: View {
    let viewSize: CGSize
    let data: CardData
    let viewModel: CardsViewModel
    @EnvironmentObject private var appService: AppServiceManager

    var body: some View {
        let position = viewModel.cardPosition(data, viewSize: viewSize)
        let currentData = viewModel.currentData
        cardContentView(data)
            .rotationEffect(
                data.id == currentData?
                    .id || (viewModel.dragEnded && viewModel.data.prefix(viewModel.currentIndex + 1).last?.id == data.id) ? .zero :
                        .degrees(data.rotation)
            )

            .frame(maxHeight: .infinity)
            .offset(x: position.x, y: position.y - (data.id == currentData?
                .id ? 0 : viewModel.inactiveCardPositionY))
            .scaleEffect(data.id == currentData?.id ? 1 : 1.3)
            .animation(.bouncy, value: viewModel.currentIndex)
            .gesture(
                cardGesture
            )
            .disabled(currentData?.id != data.id)
            .modifier(TutorialTargetModifier(targetType: .swipeOption))
    }
    
    @ViewBuilder
    private func cardContentView(_ data: CardData) -> some View {
        let height = viewModel.collectionHeight[data.id] ?? .zero
        let currentData = viewModel.currentData
        let backgroundColor = data.color
        let isLightBackground = backgroundColor.isLight
        VStack {
            VStack {
                cardTextualContentView(data, isLightBackground)
                Spacer().frame(maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            if data.id == currentData?.id {
                cardCollection(
                    data,
                    height: height,
                    currentData: currentData
                )
            }

        }
        .padding(.top, 25)
        .padding(.horizontal, 10)
        .padding(.bottom, 10)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: backgroundColor.withAlphaComponent(0.2)).opacity(0.3))
        .background(.white)
        .animation(.smooth, value: currentData)
        .cornerRadius(30)
        .shadow(radius: 20)
    }

    var cardGesture: some Gesture {
        DragGesture()
            .onChanged({ value in
                viewModel.dragPosition = .init(x: value.translation.width, y: value.translation.height)
            })
            .onEnded({ value in
                appService.tutorialManager.removeTypeWhenMatching(.swipeOption)
                if let first = viewModel.selectedActions.first {
                    viewModel.didSelectButton(button: first)
                } else {
                    withAnimation(.bouncy(duration: 0.4)) {
                        viewModel.dragPosition = .zero
                    }
                }
            })
    }

    func cardCollection(
        _ data: CardData,
        height: CGFloat,
        currentData: CardData?
    ) -> some View {
        CollectionView(contentHeight: .init(get: {
            height
        }, set: {
            viewModel.collectionHeight.updateValue($0, forKey: data.id)
        }), isopacityCells: false, canUpdate: false, data: data.buttons) { at in
            appService.tutorialManager.removeTypeWhenMatching(.selectOption)
            viewModel.didSelectButton(button: data.buttons[at ?? 0])
        }
        .frame(height: height >= 20 ? height - 20 : 0)
        .animation(.bouncy(duration: 0.9), value: data.id == currentData?.id)
        .transition(.move(edge: .bottom))
        .modifier(TutorialTargetModifier(targetType: .selectOption))
    }

    func cardTextualContentView(
        _ data: CardData,
        _ isLightBackground: Bool
    ) -> some View {
        VStack(spacing: 0) {
            Text(data.title)
                .foregroundColor(.black)
                .font(.typed(data.title.count >= 40 ? .text : .largeTitle))
                .frame(maxWidth: .infinity, alignment: .leading)
                .opacity(!isLightBackground ? 0.4 : 0.2)
            Spacer().frame(height: 5)
            Text(data.description)
                .foregroundColor(.black)
                .font(.typed(.section))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
