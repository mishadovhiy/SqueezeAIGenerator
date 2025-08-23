//
//  HomeCollectionView.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 16.08.2025.
//

import SwiftUI

struct HomeCollectionView: View {
    @EnvironmentObject var viewModel: HomeViewModel

    var body: some View {
        GeometryReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {

                LazyVStack(pinnedViews: .sectionHeaders) {

                    Spacer().frame(height: proxy.size.height * 0.56)
                    collectionHeader

                    Section {
                        ContentHomeCollectionView(proxy: proxy)

                    } header: {
                        sections
                    }

                }
            }
            .onAppear {
                viewModel.viewSize = proxy.size.height
            }
            .onChange(of: proxy.size.height) { newValue in
                viewModel.viewSize = newValue
            }
        }
    }

    var collectionBackground: some View {
        VStack {
            Spacer()
            //                    .frame(maxHeight: (viewModel.viewSize * (scroll)) - 50)
            Color.white.opacity(0.05)
                .background(content: {
                    BlurView()
                })
                .cornerRadius(23)
                .frame(height: (viewModel.viewSize * (1 - scroll)) + (viewModel.selectedGeneralKeyID == nil ? 400 : 350))
                .padding(.bottom, -200)
        }
        .ignoresSafeArea(.all)
    }

    var scroll: CGFloat {
        let value = viewModel.scrollPosition.percent
        print(value, " evfsdc")
        if value >= 1 {
            return 1
        } else {
            return value
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
                appTitle
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
        //        .frame(height: 220)
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
        //* (
       // 1 - (opacityGradient >= 0.8 ? 0.8 : opacityGradient)
   // )
//        let opacityGradient = viewModel.gradientOpacity
        Text("Squeeze generator")
            .multilineTextAlignment(.leading)
            .foregroundColor(.white.opacity(0.1))// + (opacityGradient / 3)))
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
        //        .blurBackground(opacity: item.id == viewModel.selectedGeneralKeyID ? 1 : nil, cornerRadius: .CornerRadius.medium.rawValue)
        .background(content: {
            Color.white.opacity(item.id == viewModel.selectedGeneralKeyID ? 0.1 : 0)
                .animation(.smooth, value: viewModel.selectedGeneralKeyID)
                .cornerRadius(.CornerRadius.large.rawValue)

        })
        .blurBackground(
            opacity: 0.1,
            cornerRadius: .CornerRadius.medium.rawValue
        )
        .cornerRadius(.CornerRadius.large.rawValue)

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
        //            .foregroundColor(
        //                .init(uiColor: item.id == viewModel.selectedGeneralKeyID ? .black : .white).opacity(
        //                    viewModel.selectedGeneralKeyID != nil ? 0.5 : .Opacity.descriptionLight.rawValue
        //                )
        //            )
            .foregroundColor(
                .white.opacity(viewModel.selectedGeneralKeyID == item.id ? 0.6 : .Opacity.descriptionLight.rawValue)
            )
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
