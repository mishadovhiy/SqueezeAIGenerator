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
                .first(where: {$0.save.request?.type == selectedType})?.save.category ?? "",
            selectedType: selectedType
        )
    )
                    .toolbar {
                        ToolbarItem(placement: .navigation) {
                            closeButton
                        }

                    }
                    .overlay(content: {
                        navigationTopBackground
                    })
                    .navigationDestination(for: NavRout.self) { path in
                        navigationDestination(path)
                            .overlay(content: {
                                navigationTopBackground
                            })

                    }
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
                .tint(.black)
        }
        .padding(8)
        .padding(.leading, 9)
        .background(.white.opacity(0.3))
        .frame(width: 36, height: 36)
        .cornerRadius(6)
    }

    var navigationTopBackground: some View {
        VStack(spacing: 0) {
            Color.black
                .frame(height: UIApplication.shared.safeArea.top + 39)
            Spacer()
        }
        .ignoresSafeArea(.all)

    }

    @ViewBuilder
    func navigationDestination(_ nav: NavRout) -> some View {
        switch nav {
        case .dbDetail(let data):
            DBDetailView(item: data)
        default: EmptyView()
        }
    }
}
