//
//  HomeCollectionView.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 16.08.2025.
//

import SwiftUI

struct HomeCollectionView: View {

    @EnvironmentObject private var viewModel: HomeViewModel
    typealias SectionModel = CollectionViewController.CollectionData

    var body: some View {
        GeometryReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                ContentHomeCollectionView(proxy: proxy, sectionHeader: sectionList)
            }
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
    var sectionList: some View {
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
            viewModel.parentCollectionSelected(item)
        } label: {
            cellContent(item)
        }
        .background(content: {
            cellBackground(item)
        })
        .blurBackground(
            opacity: 0.1,
            cornerRadius: .CornerRadius.medium.rawValue
        )
        .cornerRadius(.CornerRadius.large.rawValue)
    }

    func cellContent(_ item: SectionModel) -> some View {
        VStack {
            cellTitle(item)
            Spacer()
                .frame(maxHeight: .infinity)
            progress(item)
                .clipped()
                .animation(.bouncy, value: viewModel.largeParentCollections)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
    }

    @ViewBuilder
    func progress(_ item: SectionModel) -> some View {
        let data = viewModel.statsPreview[item.id]
        let height: CGFloat = viewModel.largeParentCollections ? .infinity : .zero
        VStack {
            cellParameters("count", "\(data?.subcategoriesCount ?? 0)/\(data?.completedSubcategoriesCount ?? 0)")
            Divider()
                .background(.white.opacity(.Opacity.separetor.rawValue))
            cellParameters("score", "\(data?.avarageGrade ?? 0)%")
        }
        .opacity(.Opacity.description.rawValue)
        .frame(
            maxWidth: .infinity,
            maxHeight: height
        )
    }
}

fileprivate extension HomeCollectionView {
    @ViewBuilder
    func cellBackground(_ item: SectionModel) -> some View {
        let opacity = item.id == viewModel.selectedGeneralKeyID ? 0.1 : 0
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
        Text(item.title)
            .foregroundColor(
                .white.opacity(opacity)
            )
            .font(.Type.section.font)
            .padding(.horizontal, 22)
    }

    func cellParameters(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .font(.Type.small.font)
                .multilineTextAlignment(.leading)
                .frame(alignment: .leading)
            Spacer()
            Text(value)
                .multilineTextAlignment(.leading)
                .frame(alignment: .trailing)
        }
        .frame(maxWidth: .infinity)
    }
}
