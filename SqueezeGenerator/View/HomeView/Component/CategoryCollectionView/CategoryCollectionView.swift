//
//  HomeCollectionView.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 16.08.2025.
//

import SwiftUI

struct CategoryCollectionView: View {

    @EnvironmentObject private var viewModel: HomeViewModel
    @EnvironmentObject private var appService: AppServiceManager

    typealias SectionModel = CollectionViewController.CollectionData

    var body: some View {
        GeometryReader { proxy in
            ScrollViewReader(content: { scrollProxy in
                ScrollView(.vertical, showsIndicators: false) {
                    DetailHomeCollectionView(
                        proxy: proxy,
                        sectionHeader: sectionListView
                    )
                }
                .onChange(of: viewModel.scrollToItemID) { newValue in
                    if let newValue {
                        scrollProxy.scrollTo(newValue)
                        viewModel.scrollToItemID = nil
                    }
                }
            })
            .onAppear {
                viewModel.viewSize = proxy.size.height
                viewModel.viewWidth = proxy.size.width
            }
            .onChange(of: proxy.size) { newValue in
                viewModel.viewSize = newValue.height
                viewModel.viewWidth = newValue.width
            }
        }
    }

    @ViewBuilder
    var sectionListView: some View {
        let paddings = viewModel.collectionSubviewPaddings
        let height: CGFloat = viewModel.largeParentCollections ? 120 : 50
        let spacing = viewModel.maxCollectionPaddings * 0.6

        ScrollView(
            .horizontal,
            showsIndicators: false
        ) {
            LazyHStack(spacing: spacing) {
                ForEach(viewModel.collectionData, id:\.id) { item in
                    cell(item)
                }
                Spacer().frame(width: viewModel.maxCollectionPaddings)
            }
            .padding(.leading, paddings)
            .frame(height: height)
            .animation(.bouncy, value: viewModel.largeParentCollections)
        }
    }

    @ViewBuilder
    func cell(_ item: SectionModel) -> some View {
        Button {
            appService.haptic.play()
            appService.tutorialManager.removeTypeWhenMatching(.selectParentCategory)
            viewModel.parentCollectionSelected(item)
        } label: {
            cellContent(item)
        }
        .background(content: {
            cellBackground(item)
        })
        .blurBackground(
            opacity: 0.05,
            cornerRadius: .CornerRadius.medium.rawValue
        )
        .cornerRadius(.CornerRadius.large.rawValue)
        .compositingGroup()
    }

    func cellContent(_ item: SectionModel) -> some View {
        VStack(alignment: .leading) {
            cellTitle(item)
            Spacer()
            Spacer()
                .frame(height: viewModel.largeParentCollections ? Configuration.progressBarHeight : 0)
                .animation(.smooth, value: viewModel.selectedGeneralKeyID)
        }
        .overlay(content: {
            VStack {
                Spacer().frame(maxHeight: .infinity)
                progress(item)
                    .clipped()
                    .animation(.bouncy, value: viewModel.largeParentCollections)
            }
        })
        .frame(maxWidth: 250, alignment: .leading)
        .background(content: {
            sectionImage(item)
        })
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
    }
    
    @ViewBuilder
    func sectionImage(_ item: SectionModel) -> some View {
        VStack(alignment: .trailing) {
            HStack {
                Spacer()
                    .frame(maxWidth: viewModel.selectedGeneralKeyID == nil ? .zero : .infinity)
                    .animation(.smooth, value: viewModel.selectedGeneralKeyID)
                if let _: URL = .init(string: item.imageURL) {
                    CachedAsyncImage(url: item.imageURL)
                    .shadow(radius: 15)
                    .frame(maxWidth: Configuration.maxImageWidth)
                }
                Spacer()
                    .frame(maxWidth: viewModel.selectedGeneralKeyID != nil ? .zero : .infinity)
                    .animation(.smooth, value: viewModel.selectedGeneralKeyID)
            }
            Spacer()
                .frame(maxHeight: .infinity)
        }
        
    }

    @ViewBuilder
    func progress(_ item: SectionModel) -> some View {
        let data = viewModel.statsPreview[item.id]
        let height: CGFloat = viewModel.largeParentCollections ? .infinity : .zero
        VStack(content: {
            Spacer().frame(maxHeight: .infinity)
            HStack {
                cellParameters("count", "\(data?.completedSubcategoriesCount ?? 0)/\(data?.subcategoriesCount ?? 0)", icon: .folders)
//                Divider()
//                    .background(.white.opacity(.Opacity.separetor.rawValue))
                cellParameters("score", "\(data?.avarageGrade ?? 0)%", icon: .scoreGraph)
            }
        })
        .opacity(.Opacity.description.rawValue)
        .frame(
            maxWidth: .infinity,
            maxHeight: height
        )
    }
}

fileprivate extension CategoryCollectionView {
    @ViewBuilder
    func cellBackground(_ item: SectionModel) -> some View {
        let opacity = item.id == viewModel.selectedGeneralKeyID ? 0.05 : 0
        Color.white.opacity(opacity)
            .animation(.smooth, value: viewModel.selectedGeneralKeyID)
            .cornerRadius(.CornerRadius.large.rawValue)
    }

    @ViewBuilder
    func cellTitle(_ item: SectionModel) -> some View {
        let spacer: CGFloat = viewModel.largeParentCollections ? .zero : .infinity
        let opacity = viewModel.selectedGeneralKeyID == item.id ? 0.6 : .Opacity.background.rawValue
        Spacer()
            .frame(maxHeight: spacer)
            .animation(
                .bouncy,
                value: viewModel.largeParentCollections
            )
        HStack {
            Spacer().frame(width: viewModel.selectedGeneralKeyID == nil ? Configuration.maxImageWidth - 10 : .zero)
                .animation(.smooth, value: viewModel.selectedGeneralKeyID == nil)
            Text(item.title.addSpaceBeforeCapitalizedLetters.capitalized)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                .foregroundColor(
                    .white.opacity(opacity)
                )
                .font(.Type.section.font)
                .padding(.horizontal, 22)
                .shadow(radius: 5)
                .minimumScaleFactor(0.3)
            Spacer()
                .frame(width: viewModel.selectedGeneralKeyID != nil ? Configuration.maxImageWidth / 5 : .zero)
                .animation(.smooth, value: viewModel.selectedGeneralKeyID == nil)
        }
    }

    func cellParameters(_ title: String, _ value: String, icon: ImageResource) -> some View {
        HStack(spacing: 4) {
            Image(icon)
                .resizable()
                .scaledToFit()
                .frame(width: 10)
            Text(title)
                .font(.Type.small.font)
                .multilineTextAlignment(.leading)
                .frame(alignment: .leading)
//            Spacer()
            Text(value)
                .font(.Type.small.font(weight: .semibold))
                .multilineTextAlignment(.leading)
                .frame(alignment: .trailing)
            Spacer()
        }
        .padding(.leading, 5)
        .frame(maxWidth: .infinity)
        .frame(height: Configuration.progressBarHeight)
        .background(.white.opacity(0.1))
        .cornerRadius(5)
    }
}


fileprivate extension CategoryCollectionView {
    struct Configuration {
        static let maxImageWidth: CGFloat = 40
        static let progressBarHeight: CGFloat = 25
    }
}
