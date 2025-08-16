//
//  HomeCollectionView.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 16.08.2025.
//

import SwiftUI

struct HomeCollectionView: View {
    @Binding var viewModel: HomeViewModel

    var body: some View {
        GeometryReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {

                LazyVStack(pinnedViews: .sectionHeaders) {
                    Spacer().frame(height: proxy.size.height * 0.39)
//                    Section {
                        ContentHomeCollectionView(proxy: proxy, viewModel: $viewModel)
//                    } header: {
//                        collectionHeader
//                    }

                }
            }
        }
    }

    @ViewBuilder
    var appTextMask: some View {
        let opacityGradient = viewModel.gradientOpacity
        HStack {
            VStack {
                Circle()
                    .frame(width: 120 * (1 - (opacityGradient >= 0.9 ? 0.9 : opacityGradient)))
                    .aspectRatio(1, contentMode: .fill)
                Spacer()
                    .overlay {
                        ForEach([20, 5, 40], id:\.self) { i in
                            Circle()
                                .frame(width: (10 + (i / 10)) * (1 - (opacityGradient >= 0.9 ? 0.9 : opacityGradient)))
                                .aspectRatio(1, contentMode: .fill)
                                .offset(x: i, y: i * -1)
                        }
                    }
            }
            Spacer()
                .overlay {
                    ForEach([-20, 50, 10], id:\.self) { i in
                        Circle()
                            .frame(width: (10 + (i / 10)) * (1 - (opacityGradient >= 0.9 ? 0.9 : opacityGradient)))
                            .aspectRatio(1, contentMode: .fill)
                            .offset(x: i, y: (i == 50 ? i : -i) / 20)
                    }
                }
            VStack {
                Spacer()
                    .overlay {
                        ForEach([-60, -20, -40], id:\.self) { i in
                            Circle()
                                .frame(width: (10 + (i / 10)) * (1 - (opacityGradient >= 0.9 ? 0.9 : opacityGradient)))
                                .aspectRatio(1, contentMode: .fill)
                                .offset(x: i, y: (i == -20 ? i : -i) / 20)
                        }
                    }
                Circle()
                    .frame(width: 150 * (1 - (opacityGradient >= 0.9 ? 0.9 : opacityGradient)))
                    .aspectRatio(1, contentMode: .fill)
                    .offset(x: -65 * opacityGradient,
                            y: -10 * opacityGradient)

            }
        }
        .padding(.top, 30 * (1 - (opacityGradient >= 0.5 ? 0.5 : opacityGradient)))
        .padding(.leading, 30 * (1 - (opacityGradient >= 0.5 ? 0.5 : opacityGradient)))
        .frame(maxWidth: .infinity)
        .animation(.bouncy, value: opacityGradient)
    }

    @ViewBuilder
    var collectionHeader: some View {
        let opacityGradient = viewModel.gradientOpacity
        VStack {
            ZStack(content: {
                //                appTitle
                //                    .background(content: {
                //                        Color.clear
                //                            .blurBackground(
                //                                opacity: .Opacity.lightBackground.rawValue * viewModel.gradientOpacity,
                //                                cornerRadius: .CornerRadius.medium.rawValue)
                //                            .padding(.vertical, -10)
                //                    })
                //                    .offset(x: opacityGradient * viewModel.collectionSubviewPaddings,
                //                            y: opacityGradient * 10
                //                    )
            })
            .frame(maxWidth: .infinity,
                   alignment: .leading)
            Spacer()

        }
        .frame(height: 220)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    //    var headerGradient: some View {
    //        LinearGradient(//here
    //            gradient: Gradient(colors: [
    //                .black, .black, .clear, .clear
    //            ]),
    //            startPoint: .top,
    //            endPoint: .bottom
    //        )
    //        .offset(y: -50)
    //        .frame(maxHeight: .infinity, alignment: .top)
    //        .frame(height: 220)
    //        .opacity(viewModel.gradientOpacity)
    //        .animation(.smooth, value: viewModel.gradientOpacity)
    //    }

    @ViewBuilder
    var appTitle: some View {
        let opacityGradient = viewModel.gradientOpacity
        Text("Squeeze generator")
            .multilineTextAlignment(.leading)
            .foregroundColor(.white.opacity(0.1 + (opacityGradient / 3)))
            .padding(.horizontal, 15)
            .lineSpacing(0)
            .lineLimit(nil)
            .font(
                .system(
                    size: Configuration.UI.FontType.extraLarge.rawValue * (
                        1 - (opacityGradient >= 0.8 ? 0.8 : opacityGradient)
                    ),
                    weight: .semibold
                )
            )
    }
}
