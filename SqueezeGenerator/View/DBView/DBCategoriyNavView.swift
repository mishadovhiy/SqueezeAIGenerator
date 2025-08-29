//
//  DBCategoriyView.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 22.07.2025.
//

import SwiftUI


struct DBCategoriyNavView: View {
    @EnvironmentObject private var db: LocalDataBaseManager
    @EnvironmentObject private var appService: AppServiceManager
    @Environment(\.dismiss) private var dismiss

    let selectedType: String

    @State var nav: [NavigationRout] = []

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
                .navigationDestination(for: NavigationRout.self) { path in
                    path.body(.constant(nil))
                        .opacity(path == self.nav.last ? 1 : 0)
                        .animation(.smooth, value: path == self.nav.last)
                        .toolbarColorScheme(.dark, for: .navigationBar)
                        .navigationBarTitleDisplayMode(.large)

                }
                .navigationViewStyle(StackNavigationViewStyle())
            })
            .tint(.white)
            .padding(.top, -40)
        }
        .onAppear(perform: {
#warning("fix not appearing second")
//            self.appService.alertManager.present(.init(title: "some error"))
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
//                self.appService.alertManager.present(.init(title: "some error 2"))
//            })
        })
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
}
