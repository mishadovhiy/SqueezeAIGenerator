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
    @EnvironmentObject private var viewModel: CardsViewModel
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
        let isDark = (viewModel.data.firstIndex(of: data) ?? 0) % 2 == 0
        VStack {
            cardTextualContentView(data, !isDark)
            Spacer()
            if data.id == currentData?.id {
                cardCollection(
                    data,
                    height: height,
                    currentData: currentData, isDark: isDark
                )
            }

        }
        .padding(.top, 30)
        .padding(.horizontal, 30)
        .padding(.bottom, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(content: {
            ZStack(content: {
                if isDark {
                    Color.init(uiColor: .init(hex: "29466A")!)
                }
                Color.white
                    .cornerRadius(30)
                    .padding(isDark ? 20 : 0)
                if !isDark {
                    Color.init(uiColor: .init(hex: "29466A")!)
                        .cornerRadius(30)
                        .padding(20)

                }

            })
            .cornerRadius(30)
            .shadow(radius: 20)
        })
        .animation(.smooth, value: currentData)
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
        currentData: CardData?, isDark: Bool
    ) -> some View {
        CollectionView(contentHeight: .init(get: {
            height
        }, set: {
            viewModel.collectionHeight.updateValue($0, forKey: data.id)
        }), isopacityCells: false, canUpdate: false, isDark: isDark, data: data.buttons) { at in
            appService.tutorialManager.removeTypeWhenMatching(.selectOption)
            viewModel.didSelectButton(button: data.buttons[at ?? 0])
        }
        .frame(height: height >= 20 ? height - 20 : 0)
        .frame(maxWidth: .infinity)
        .animation(.bouncy(duration: 0.9), value: data.id == currentData?.id)
        .transition(.move(edge: .bottom))
        .modifier(TutorialTargetModifier(targetType: .selectOption))
    }

    func cardTextualContentView(
        _ data: CardData,
        _ isLightBackground: Bool
    ) -> some View {
        VStack(spacing: 5) {
            Text(data.title)
                .foregroundColor(!isLightBackground ? Color(uiColor: .init(hex: "29466A")!) : .white)
                .font(.typed(data.title.count >= 80 ? .text : .largeTitle))
            Text(data.description)
                .foregroundColor(!isLightBackground ? Color(uiColor: .init(hex: "29466A")!) : .white)
                .multilineTextAlignment(.center)
                .font(.system(size: 15, weight: .semibold))
                .frame(maxWidth: .infinity)
//                .padding(8)
//                .background(.white)
//                .cornerRadius(18)
//                .padding(.top, 5)
//                .padding(.leading, 4)
//                .padding(.trailing, 29)
//                .padding(.bottom, 8)
//                .background(.blue)
//                .cornerRadius(19)
//                .padding(.leading, 10)
            
        }

    }
    
    var titleLabel: some View {
        Text(data.title)
            .foregroundColor(.black)
            .font(.typed(data.title.count >= 40 ? .text : .largeTitle))
            .frame(maxHeight: 60)
            .minimumScaleFactor(0.2)
            .padding(.bottom, 54)
            .padding(.horizontal, 19)
            .padding(.top, 13)
            .background(.white)
            .cornerRadius(13)
            .padding(.trailing, 4)
            .padding(.leading, 17)
            .padding(.top, 7)
            .padding(.bottom, 8)
            .background(.red)
            .cornerRadius(14)
            .offset(x: -20)
    }
}
