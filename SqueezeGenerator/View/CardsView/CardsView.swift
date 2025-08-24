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
            cardsView
            Spacer()
        }
        .overlay(content: {
            scrollLabelOverlay
        })
        .padding(10)
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button("<") {
                    withAnimation {
                        viewModel.currentIndex -= 1
                    }
                }
                .disabled(viewModel.currentIndex <= 0)
            }
        }
        .foregroundColor(.black)
        .navigationTitle(viewModel.properties.type)
        .navigationBarTitleDisplayMode(.inline)

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
                    .stroke(Color(uiColor: .init(hexColor: .purpureLight)!), lineWidth: 2)
                    .background {
                        Color(uiColor: viewModel.currentIndex >= i ? .init(hexColor: .purpureLight)!  : .clear)
                    }
                    .cornerRadius(8)
                    .shadow(radius: 4)

            }
        }
        .frame(height: 15)
    }

    var cardsView: some View {
        GeometryReader { proxy in
            VStack {
                Spacer().frame(height: 50)
                ZStack {
                    completionView
                    ForEach(viewModel.data.reversed(), id: \.id) { data in
                        cardView(data, viewSize: proxy.size)
                    }
                }
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
    var completionView: some View {
        VStack {
            Text("No data")
            Button("done") {
                viewModel.donePressed(viewModel.selectedOptions)
            }
        }
    }

    @ViewBuilder
    private func cardContentView(_ data: CardData) -> some View {
        let height = viewModel.collectionHeight[data.id] ?? .zero
        let currentData = viewModel.currentData
        VStack {
            VStack {
                VStack(spacing: 0) {
                    Text(data.title)
                        .font(.typed(data.title.count >= 40 ? .text : .largeTitle))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .opacity(0.2)
                    Spacer().frame(height: 5)
                    Text(data.description)
                        .font(.typed(.section))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                Spacer().frame(maxHeight: .infinity)

            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            CollectionView(contentHeight: .init(get: {
                height
            }, set: {
                viewModel.collectionHeight.updateValue($0, forKey: data.id)
            }), isopacityCells: false, canUpdate: false, data: data.buttons) { at in
                viewModel.didSelectButton(button: data.buttons[at ?? 0])
            }
            .frame(height: height >= 20 ? height - 20 : 0)
            .animation(.bouncy, value: data.id == currentData?.id)
        }
        .padding(.top, 25)
        .padding(.horizontal, 10)
        .padding(.bottom, 10)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: data.color.withAlphaComponent(0.2)))
        .background(.white)
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
            .offset(x: position.x, y: position.y)
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
