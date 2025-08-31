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

    func cellImage(_ item: CollectionViewController.CollectionData) -> some View {
        AsyncImage(url: .init(string: item.imageURL)) {
            switch $0 {
            case .empty:
                ProgressView().progressViewStyle(.circular)
            case .success(let image):
                image
                    .resizable()
                    .scaledToFit()
            default:
                EmptyView()
            }
        }
        .frame(width: 40)
        .aspectRatio(1, contentMode: .fit)
        .padding(10)
        .blurBackground(count: 4)
    }

    func cell(_ item: CollectionViewController.CollectionData) -> some View {
        VStack {
            HStack(alignment: .top) {
                cellImage(item)

                Spacer().frame(maxWidth: .infinity)
                if !item.isType {
                    Image(.arrowDown)
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.white)
                        .frame(width: 20)
                        .padding(10)
                        .blurBackground()
                        .frame(alignment: .top)
                        .rotationEffect(.degrees(item.id == viewModel.selectedGeneralKeyID ? -180 : 0))
                        .animation(.smooth, value: item.id == viewModel.selectedGeneralKeyID)
                }
            }
            Spacer().frame(maxWidth: .infinity)
            VStack(alignment: .leading) {
                Text(item.title.addSpaceBeforeCapitalizedLetters.capitalized)
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white.opacity(0.5))
                    .frame(maxWidth: .infinity, alignment: .leading)
                //Double(item.percent ?? "0")
                if let progressString = item.percent,
                   let progress = Double(progressString) {
                    ProgressView(value: progress / 100)
                        .progressViewStyle(.linear)
                }

            }
            .onAppear {
                print(item.percent ?? "0", " yhrtgerfsed")
            }
        }
        .padding(7)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .aspectRatio(0.8, contentMode: .fit)
        .blurBackground()
    }
    
    var sectionContent: some View {
        VStack {
            Spacer().frame(height: 12)

            LazyVGrid(
                columns: [
                .init(.flexible()),
                .init(.flexible())
            ],
                spacing: viewModel.collectionSubviewPaddings,
                content: {
                ForEach(viewModel.collectionDataForKey, id: \.id) { item in

                    Button {
                        viewModel.collectionViewSelected(category: item, didSelect: { selectedCategory, selectedRequest in
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
                    } label: {
                        cell(item)
                    }

                }
            })
//            CollectionView(
//                contentHeight: $viewModel.contentHeight,
//                data: viewModel.collectionDataForKey,
//                didSelect: { at in
//                    viewModel.collectionViewSelected(at: at ?? 0, didSelect: { selectedCategory, selectedRequest in
//                        guard let selectedCategory else {
//                            return
//                        }
//                        appService.tutorialManager.removeTypeWhenMatching(.selectType, .selectTypeDB)
//                        navigationManager.append(
//                                .requestToGenerateParameters(
//                                    .init(get: {
//                                        self.viewModel.selectedRequest
//                                    }, set: {
//                                        self.viewModel.selectedRequest = $0
//                                    }), selectedCategory
//                                )
//                            )
//                    })
//            })
//            .padding(.leading, viewModel.collectionSubviewPaddings)
//            .padding(.trailing, 5)
//            .frame(height: viewModel.contentHeight)
//            .animation(.bouncy, value: viewModel.selectedGeneralKeyID)
            .modifier(ScrollReaderModifier(scrollPosition: $viewModel.scrollPosition))
            .modifier(TutorialTargetViewModifier(targetType: .selectType))
            .modifier(TutorialTargetViewModifier(targetType: .selectTypeDB))

        }
        .padding(.horizontal, viewModel.collectionSubviewPaddings)
    }
}
