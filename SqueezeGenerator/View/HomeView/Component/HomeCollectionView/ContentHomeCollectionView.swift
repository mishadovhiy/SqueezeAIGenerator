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
//            sections
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

   
}
