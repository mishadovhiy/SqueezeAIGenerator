//
//  CardsView.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 25.07.2025.
//

import SwiftUI

struct CardsView: View {
    @StateObject private var viewModel: CardsViewModel
    @EnvironmentObject private var appService: AppServiceManager
    @EnvironmentObject private var navigationManager: NavigationManager
    
    init(_ presenter: Presenter) {
        _viewModel = StateObject(wrappedValue: .init(presenter.properties, donePressed: presenter.completedSqueeze))
    }

    var body: some View {
        ZStack {
            cardCompletionView
            contentView
        }
        .modifier(TutorialTargetModifier(targetType: .waitingForSqueezeCompletion))
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                closeButton
            }
            ToolbarItem(placement: .topBarTrailing) {
                removeLastActionButton
            }
        }
        .foregroundColor(.black)
        .navigationTitle(viewModel.properties.type.addSpaceBeforeCapitalizedLetters.capitalized)
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: viewModel.currentIndex) { newValue in
            appService.haptic.play()
        }
        .onAppear {
            viewModel.viewDidAppear()
        }
        .environmentObject(viewModel)
        .navigationBarBackButtonHidden()
    }

    @ViewBuilder
    var cardCompletionView: some View {
        if viewModel.viewAppeared {
            CardCompletionView(
                viewModel: viewModel,
                tintColor: viewModel.tintColor,
                needIllustration: .constant(viewModel.currentIndex >= viewModel.data.count)
            )
            .frame(maxHeight: .infinity)
            .transition(.move(edge: .bottom))
            .animation(.bouncy, value: viewModel.viewAppeared)
        }
    }

    var contentView: some View {
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
    }

    var header: some View {
        VStack {
            progressView
        }
    }

    var closeButton: some View {
        Button {
            appService.alertManager.present(.init(title: "Are you sure?", description: "Your progress would be lost", buttons: [
                .init(title: "Cancel"),
                .init(title: "Yes", pressed: {
                    withAnimation(.smooth) {
                        navigationManager.routs.removeAll()
                    }
                })
            ]))
        } label: {
            Image(.close)
                .resizable()
                .scaledToFit()
                .foregroundColor(.white)
                .frame(width: 20, height: 20)
        }
    }
    
    var removeLastActionButton: some View {
        Button {
            withAnimation {
                viewModel.currentIndex -= 1
            }
        } label: {
            removeLastActionButtonConten
        }
        .disabled(viewModel.currentIndex <= 0)
    }

    var removeLastActionButtonConten: some View {
        Color.clear
        .overlay {
            Image(.undo)
                .resizable()
                .scaledToFit()
                .foregroundColor(
                    .init(
                        uiColor: viewModel.tintColor)
                )
                .padding(.horizontal, 7)
                .opacity(0.6)
                .shadow(radius: 10)

        }
        .frame(width: 40, height: 40)
        .blurBackground()
        .background {
            RoundedRectangle(cornerRadius: .CornerRadius.large.rawValue)
                .stroke(Color(uiColor: viewModel.tintColor).opacity(0.3), lineWidth: 1)
        }
    }

    var progressView: some View {
        HStack {
            ForEach(0..<viewModel.data.count, id: \.self) { i in
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(uiColor: viewModel.tintColor), lineWidth: 3)
                    .background {
                        Color(uiColor: viewModel.currentIndex >= i ? viewModel.tintColor  : .clear)
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
                    ForEach(viewModel.data.reversed(), id: \.id) { data in
                        CardView(viewSize: proxy.size, data: data)
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
