//
//  ContentHomeCollectionView.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 16.08.2025.
//

import SwiftUI

struct ContentHomeCollectionView: View {
    let proxy: GeometryProxy
    @EnvironmentObject var viewModel: HomeViewModel

    var body: some View {
        VStack {
            Spacer().frame(height: proxy.size.height * 0.12)
            sections
            Spacer().frame(height: 12)
            CollectionView(
                contentHeight: $viewModel.contentHeight,
                data: viewModel.collectionDataForKey,
                didSelect: { at in
                viewModel.collectionViewSelected(at: at ?? 0)
            })
            .padding(.leading, viewModel.collectionSubviewPaddings)
            .padding(.trailing, 5)
            .frame(height: viewModel.contentHeight)
            .animation(.bouncy, value: viewModel.selectedGeneralKeyID)
            .modifier(ScrollReaderModifier(scrollPosition: $viewModel.scrollPosition))

        }
    }

    @ViewBuilder
    func cell(_ item: CollectionViewController.CollectionData) -> some View {
        Button {
            viewModel.parentCollectionSelected(item)
        } label: {
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
        .blurBackground(cornerRadius: .CornerRadius.medium.rawValue)

    }

    @ViewBuilder
    var sections: some View {
        let paddings = viewModel.collectionSubviewPaddings
        ScrollView(.horizontal,
                   showsIndicators: false) {
            LazyHStack(spacing: viewModel.maxCollectionPaddings * 0.6) {
                ForEach(viewModel.collectionData, id:\.id) { item in

                    cell(item)
                }
                Spacer().frame(width: viewModel.maxCollectionPaddings)
            }
            .padding(.leading, paddings)
            .frame(height: viewModel.largeParentCollections ? 120 : 50)
            .animation(.bouncy, value: viewModel.largeParentCollections)

        }
    }

    func headRowItem(_ title: String, _ value: String) -> some View {
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

    @ViewBuilder
    func cellTitle(_ item: CollectionViewController.CollectionData) -> some View {
        Spacer().frame(maxHeight: viewModel.largeParentCollections ? .zero : .infinity)
            .animation(.bouncy, value: viewModel.largeParentCollections)
        Text(item.title)
            .foregroundColor(.white.opacity(.Opacity.descriptionLight.rawValue))
            .font(.Type.section.font)
            .padding(.horizontal, 22)
    }

    @ViewBuilder
    func progress(_ item: CollectionViewController.CollectionData) -> some View {
        let data = viewModel.statsPreview[item.id]

        VStack {
            headRowItem("count", "\(data?.subcategoriesCount ?? 0)/\(data?.completedSubcategoriesCount ?? 0)")
            Divider()
            headRowItem("score", "\(data?.avarageGrade ?? 0)%")
        }
        .opacity(.Opacity.description.rawValue)
        .frame(maxWidth: .infinity,
               maxHeight: viewModel.largeParentCollections ? .infinity : .zero)
    }
}
