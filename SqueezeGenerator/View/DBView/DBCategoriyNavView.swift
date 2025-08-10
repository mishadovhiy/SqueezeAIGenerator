//
//  DBCategoriyView.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 22.07.2025.
//

import SwiftUI


struct DBCategoriyNavView: View {
    @EnvironmentObject private var db: AppData
    @Environment(\.dismiss) private var dismiss

    let selectedType: String

    @State var nav: [NavRout] = []

    var body: some View {
        VStack(spacing: 0) {
            NavigationStack(path: $nav,
                            root: {
                DBCategoriyView(
                    presenter: .init(
                        selectedCategory: db.db.responses
                            .first(where: {$0.save.request?.type == selectedType})?.save.request?.category ?? "",
                        selectedType: selectedType
                    )
                )
                .toolbarColorScheme(.dark, for: .navigationBar)

                .toolbar {
                    ToolbarItem(placement: .navigation) {
                        closeButton
                    }

                }
                .opacity(nav.isEmpty ? 1 : 0)
                .animation(.smooth, value: nav.isEmpty)
                .navigationDestination(for: NavRout.self) { path in
                    navigationDestination(path)
                        .opacity(path == self.nav.last ? 1 : 0)
                        .animation(.smooth, value: path == self.nav.last)
                        .toolbarColorScheme(.dark, for: .navigationBar)
                        .navigationBarTitleDisplayMode(.large)

                }
                .navigationViewStyle(StackNavigationViewStyle())
            })
            .padding(.top, -40)
        }

        .background {
            ClearBackgroundView()
        }
    }

    var closeButton: some View {
        Button {
            dismiss.callAsFunction()
        } label: {
            Image(.close)
                .resizable()
                .scaledToFit()
        }
        .smallButtonStyle()

    }

    //    var navigationTopBackground: some View {
    //        VStack(spacing: 0) {
    //            Color.black
    //                .frame(height: UIApplication.shared.safeArea.top + 39)
    //            Spacer()
    //        }
    //        .ignoresSafeArea(.all)
    //
    //    }

    @ViewBuilder
    func navigationDestination(_ nav: NavRout) -> some View {
        switch nav {
        case .dbDetail(let data):
            DBDetailView(item: data)
        default: EmptyView()
        }
    }
}
