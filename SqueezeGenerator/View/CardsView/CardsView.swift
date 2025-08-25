//
//  CardsView.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 25.07.2025.
//

import SwiftUI

struct CardsView: View {
    @StateObject var viewModel: CardsViewModel

    init(_ presenter: Presenter) {
        _viewModel = StateObject(wrappedValue: .init(presenter.properties, donePressed: presenter.completedSqueeze))
    }

    var body: some View {
        VStack {
            header
            Spacer()
            if viewModel.viewAppeared {
                cardsView
                    .frame(maxWidth: 800)
                    .scaleEffect(viewModel.viewAppeared ? 1 : 0)
                    .transition(.move(edge: .bottom))
                    .animation(.smooth(duration: !viewModel.viewAnimationCompleted ? 0.9 : 0.2), value: viewModel.viewAppeared)
            }
            Spacer()
        }
        .overlay(content: {
            scrollLabelOverlay
        })
        .padding(10)
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button {
                    withAnimation {
                        viewModel.currentIndex -= 1
                    }
                } label: {
                    Color.clear
                    .overlay {
                        Image(.back)
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(
                                .init(
                                    uiColor: tintColor)
                            )
                            .padding(.horizontal, 7)
                            .opacity(0.6)
                            .shadow(radius: 10)

                    }
                    .frame(width: 40, height: 40)
                    .blurBackground()
                    .background {
                        RoundedRectangle(cornerRadius: .CornerRadius.large.rawValue)
                            .stroke(Color(uiColor: tintColor).opacity(0.3), lineWidth: 1)
                    }
                }
                .disabled(viewModel.currentIndex <= 0)
            }
        }
        .foregroundColor(.black)
        .navigationTitle(viewModel.properties.type.addSpaceBeforeCapitalizedLetters.capitalized)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300), execute: {
                withAnimation(.bouncy(duration: 0.9)) {
                    viewModel.viewAppeared = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(900), execute: {
                    viewModel.viewAnimationCompleted = true
                })
            })
        }
    }

    var tintColor: UIColor {
        .init(
            hex: viewModel.properties.selectedResponseItem?.color?.top ?? ""
        ) ?? UIColor
            .white
    }
    var header: some View {
        VStack {
            progressView
        }
    }

    var progressView: some View {
        HStack {
            ForEach(0..<viewModel.data.count, id: \.self) { i in
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(uiColor: tintColor), lineWidth: 3)
                    .background {
                        Color(uiColor: viewModel.currentIndex >= i ? tintColor  : .clear)
                    }
                    .cornerRadius(8)
                    .shadow(radius: 10)

            }
        }
        .frame(height: viewModel.viewAppeared ? 15 : 0)
        .opacity(viewModel.viewAppeared ? 1 : 0)
        .animation(.smooth, value: viewModel.viewAppeared)
    }

    var cardsView: some View {
        GeometryReader { proxy in
            VStack {
                Spacer().frame(height: 50)
                ZStack(alignment: .center) {
                    CardCompletionView(
                        viewModel: viewModel,
                        tintColor: tintColor,
                        needIllustration: .constant(viewModel.currentIndex >= viewModel.data.count)
                    )
                    ForEach(viewModel.data.reversed(), id: \.id) { data in
                        cardView(data, viewSize: proxy.size)
                    }
                }
                .frame(alignment: .center)
                .padding(.horizontal, 5)
                Spacer().frame(height: 80)
            }
            .onChange(of: viewModel.dragPosition) { newValue in
                viewModel.setScrollActions(viewSize: proxy.size)
            }
            .onChange(of: proxy.frame(in: .global).size) { newValue in
                viewModel.viewSize = newValue
            }
            .onAppear {
                viewModel.viewSize = proxy.frame(in: .global).size
            }
        }
    }

    @ViewBuilder
    var scrollLabelOverlay: some View {
        let actions = viewModel.selectedActions
        VStack {
            Spacer()
                .frame(maxHeight: .infinity)
            Spacer()
                .frame(maxHeight: .infinity)

            Text(actions.compactMap({
                $0.title
            }).joined(separator: ", "))
            .foregroundColor(.black)
            .font(.typed(.text))
            .foregroundColor(.white)
            .padding(.horizontal, 15)
            .padding(.vertical, 8)
            .background(
                Color(
                    uiColor: actions.isEmpty ? .clear : (
                        viewModel.currentData?.color.withAlphaComponent(0.2) ?? .clear
                    )
                )
            )
            .background(.white)
            .cornerRadius(8)
            .shadow(radius: 20)
            .opacity(actions.isEmpty ? 0 : 1)
            .animation(.smooth, value: actions.isEmpty)
        }
        .disabled(true)
    }

    @ViewBuilder
    private func cardContentView(_ data: CardData) -> some View {
        let height = viewModel.collectionHeight[data.id] ?? .zero
        let currentData = viewModel.currentData
        let backgroundColor = data.color
        let isLightBackground = backgroundColor.isLight
        VStack {
            VStack {
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
                Spacer().frame(maxHeight: .infinity)

            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            if data.id == currentData?.id {
                CollectionView(contentHeight: .init(get: {
                    height
                }, set: {
                    viewModel.collectionHeight.updateValue($0, forKey: data.id)
                }), isopacityCells: false, canUpdate: false, data: data.buttons) { at in
                    viewModel.didSelectButton(button: data.buttons[at ?? 0])
                }
                .frame(height: height >= 20 ? height - 20 : 0)
                .animation(.bouncy(duration: 0.9), value: data.id == currentData?.id)
                .transition(.move(edge: .bottom))
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

    @ViewBuilder
    func cardView(_ data: CardData, viewSize: CGSize) -> some View {
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
    }

    var cardGesture: some Gesture {
        DragGesture()
            .onChanged({ value in
                viewModel.dragPosition = .init(x: value.translation.width, y: value.translation.height)
            })
            .onEnded({ value in
                if let first = viewModel.selectedActions.first {
                    viewModel.didSelectButton(button: first)
                } else {
                    withAnimation(.bouncy(duration: 0.4)) {
                        viewModel.dragPosition = .zero
                    }
                }

            })
    }
}


extension CardsView {
    struct Presenter: Equatable, Hashable {
        let id: UUID
        let completedSqueeze: (CardsViewModel.Selection)->()
        let properties: CardsViewModel.ViewProperties

        init(properties: CardsViewModel.ViewProperties,
             completedSqueeze: @escaping (CardsViewModel.Selection) -> Void) {
            self.id = .init()
            self.properties = properties
            self.completedSqueeze = completedSqueeze
        }

        static func == (lhs: CardsView.Presenter, rhs: CardsView.Presenter) -> Bool {
            lhs.id == rhs.id
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
}
