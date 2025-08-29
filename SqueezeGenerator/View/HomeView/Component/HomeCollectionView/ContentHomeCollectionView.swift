//
//  ContentHomeCollectionView.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 16.08.2025.
//

import SwiftUI

struct ContentHomeCollectionView<Content: View>: View {

    @EnvironmentObject private var viewModel: HomeViewModel
    @EnvironmentObject private var appService: AppServiceManager
    @EnvironmentObject private var navigationManager: NavigationManager
    let proxy: GeometryProxy
    var sectionHeader: Content

    var body: some View {
        LazyVStack(pinnedViews: .sectionHeaders) {
            Spacer()
                .frame(
                    height: (viewModel.spaceToBottom(proxy)))
            appHeader
            Spacer().frame(height: 10)
            Section {
                sectionContent
            } header: {
                sectionHeader
                    .modifier(TutorialTargetViewModifier(targetType: .selectParentCategory))
            }
        }
    }

    @ViewBuilder
    var appHeader: some View {
        VStack {
            ZStack(content: {
                appTitle
            })
            .frame(maxWidth: .infinity,
                   alignment: .leading)
            Spacer()

        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    var appTitle: some View {
        Text("Squeeze generator")
            .multilineTextAlignment(.leading)
            .foregroundColor(.white.opacity(0.1))
            .padding(.horizontal, 15)
            .lineSpacing(0)
            .lineLimit(nil)
            .font(
                .system(
                    size: Configuration.UI.FontType.extraLarge.rawValue,
                    weight: .semibold
                )
            )
    }

    var sectionContent: some View {
        VStack {
            Spacer().frame(height: 12)
            CollectionView(
                contentHeight: $viewModel.contentHeight,
                data: viewModel.collectionDataForKey,
                didSelect: { at in
                    viewModel.collectionViewSelected(at: at ?? 0, didSelect: { selectedCategory, selectedRequest in
                        guard let selectedCategory else {
                            return
                        }
                        appService.tutorialManager.removeTypeWhenMatching(.selectType, .selectTypeDB)
                        navigationManager.append(
                                .requestToGenerateParameters(
                                    .init(get: {
                                        self.viewModel.selectedRequest
                                    }, set: {
                                        self.viewModel.selectedRequest = $0
                                    }), selectedCategory
                                )
                            )
                    })
            })
            .padding(.leading, viewModel.collectionSubviewPaddings)
            .padding(.trailing, 5)
            .frame(height: viewModel.contentHeight)
            .animation(.bouncy, value: viewModel.selectedGeneralKeyID)
            .modifier(ScrollReaderModifier(scrollPosition: $viewModel.scrollPosition))
            .modifier(TutorialTargetViewModifier(targetType: .selectType))
            .modifier(TutorialTargetViewModifier(targetType: .selectTypeDB))

        }
    }
}
