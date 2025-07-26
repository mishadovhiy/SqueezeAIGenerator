//
//  CardsView.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 25.07.2025.
//

import SwiftUI

struct CardsView: View {
    @StateObject var viewModel: CardsViewModel
    
    init(_ data: [CardData]) {
        _viewModel = StateObject(wrappedValue: .init(data: data))
    }
    
    var body: some View {
        GeometryReader { proxy in
            VStack {
                HStack {
                    Button("<") {
                        withAnimation {
                            viewModel.currentIndex -= 1
                        }
                    }
                    .disabled(viewModel.currentIndex <= 0)
                    Spacer()
                }
                .frame(height: 100)
                ZStack {
                    completionView
                    ForEach(viewModel.data.reversed(), id: \.id) { data in
                        cardView(data, viewSize: proxy.size)
                    }
                    scrollLabelOverlay
                }
                .padding(.horizontal, 50)
                Spacer().frame(height: 100)
            }
            .onChange(of: viewModel.dragPosition) { newValue in
                viewModel.dragPositionChanged(viewSize: proxy.size)
            }
        }
    }
    
    @ViewBuilder
    var scrollLabelOverlay: some View {
        VStack {
            Text(viewModel.scrollSized.compactMap({$0.rawValue}).joined(separator: ", ") + (viewModel.selectedActions.isEmpty ? "" : "\n\n") + viewModel.selectedActions.compactMap({
                $0.title
            }).joined(separator: ", "))
                .font(.title)
                .foregroundColor(.white)
                .padding(.horizontal, 15)
                .padding(.vertical, 8)
                .background(Color(uiColor: viewModel.scrollSized.isEmpty ? .clear : (viewModel.currentData?.color ?? .clear)))
                .cornerRadius(8)
                .shadow(radius: 20)
                .opacity(viewModel.scrollSized.isEmpty ? 0 : 1)
                .animation(.smooth, value: viewModel.scrollSized.isEmpty)
            
            Spacer()
                .frame(maxHeight: .infinity)
            Spacer()
                .frame(maxHeight: .infinity)
        }
        .disabled(true)
    }
    
    @ViewBuilder
    var completionView: some View {
        Text("No data")
    }
    
    private func cardContentView(_ data: CardData) -> some View {
        VStack {
            Spacer()
            VStack {
                Text(data.title)
                Text(data.description)
            }
            Spacer()
            CollectionView(contentHeight: .init(get: {
                viewModel.collectionHeight[data.id] ?? .zero
            }, set: {
                viewModel.collectionHeight.updateValue($0, forKey: data.id)
            }), data: data.buttons) { at in
                withAnimation {
                    viewModel.currentIndex += 1
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: data.color))
        .cornerRadius(30)
        .shadow(radius: 20)
    }
    
    @ViewBuilder
    func cardView(_ data: CardData, viewSize: CGSize) -> some View {
        let position = viewModel.cardPosition(data, viewSize: viewSize)
        cardContentView(data)
            .rotationEffect(data.id == viewModel.currentData?.id ? .zero : .degrees(data.rotation))
        .offset(x: position.x, y: position.y)
        .animation(.bouncy, value: viewModel.currentIndex)
        .gesture(
            cardGesture
        )
        .disabled(viewModel.currentData?.id != data.id)
    }
    
    var cardGesture: some Gesture {
        DragGesture()
            .onChanged({ value in
                viewModel.dragPosition = .init(x: value.translation.width, y: value.translation.height)
            })
            .onEnded({ value in
                withAnimation(.bouncy(duration:0.4)) {
                    viewModel.dragPosition = .zero
                }
            })
    }
}

#Preview {
    CardsView(.demo)
}
