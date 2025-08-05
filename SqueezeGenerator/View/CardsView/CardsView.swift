//
//  CardsView.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 25.07.2025.
//

import SwiftUI

struct CardsView: View {
    @StateObject var viewModel: CardsViewModel
    
    init(_ properties: CardsViewModel.ViewProperties,
         done: @escaping(CardsViewModel.Selection)->()) {
        _viewModel = StateObject(wrappedValue: .init(properties, donePressed: done))
    }
    
    var body: some View {
        VStack {
            header
            Spacer()
            cardsView
            Spacer()
        }
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
    }
    
    var header: some View {
        VStack {
            
            progressView
        }
    }
    
    var progressView: some View {
        HStack {
            ForEach(0..<viewModel.data.count, id: \.self) { i in
                RoundedRectangle(cornerRadius: 4)
                    .stroke(.red, lineWidth: 1)
                    .background {
                        Color(viewModel.currentIndex >= i ? .red : .clear)
                    }
                    .cornerRadius(4)
                    
            }
        }
        .frame(height: 10)
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
                    scrollLabelOverlay
                }
                .padding(.horizontal, 20)
                Spacer().frame(height: 80)
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
                .background(Color(uiColor: viewModel.selectedActions.isEmpty ? .clear : (viewModel.currentData?.color ?? .clear)))
                .cornerRadius(8)
                .shadow(radius: 20)
                .opacity(viewModel.selectedActions.isEmpty ? 0 : 1)
                .animation(.smooth, value: viewModel.selectedActions.isEmpty)

            Spacer()
                .frame(maxHeight: .infinity)
            Spacer()
                .frame(maxHeight: .infinity)
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
            }), isopacityCells: false, data: data.buttons) { at in
                viewModel.didSelectButton(button: data.buttons[at ?? 0])
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

#Preview {
    CardsView(.init(data: .demo), done: { _ in
        
    })
}
