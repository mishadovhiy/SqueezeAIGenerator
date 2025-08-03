//
//  DBCategoriyView.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 04.08.2025.
//

import SwiftUI

struct DBCategoriyView: View {

    @EnvironmentObject private var db: AppData
    let presenter: Presenter

    var body: some View {
        ScrollView {
            LazyVStack(pinnedViews:[.sectionHeaders], content: {
                viewTitle
                Section {
                    tableView
                } header: {
                    header
                }
            })
        }
        .background {
            ClearBackgroundView()
        }
        .navigationTitle(presenter.selectedCategory)
    }

    var viewTitle: some View {
        Text(presenter.selectedType)
            .font(.title)
            .frame(maxWidth: .infinity, alignment: .leading)
            .multilineTextAlignment(.leading)
            .padding(.horizontal, 20)
            .padding(.horizontal, 10)
    }

    var tableView: some View {
        VStack {
            if data.isEmpty {
                Text("no saved data")
            }
            listView
        }
        .background {
            sectionBackground
        }
        .padding(.horizontal, 10)
    }

    var sectionBackground: some View {
        Color.black.opacity(0.12)
            .overlay(content: {
                BlurView()
            })
            .cornerRadius(12)
    }

    var header: some View {
        HStack(content: {
            HStack {
                Text("Date")
                Spacer()
                HStack {
                    Text("Score")
                    Text("Difficulty")
                }
            }
            .padding(.horizontal, 20)
            .opacity(0.5)
            .padding(.vertical, 10)
        })
        .frame(maxWidth: .infinity)
        .background(content: {
            BlurView()
                .frame(maxWidth: .infinity)
                .background(.black.opacity(0.15))
                .ignoresSafeArea(.all)
        })
    }

    func responseCell(_ response: AdviceQuestionModel) -> some View {
        VStack {
            HStack {
                Text(response.save.date.stringDate)

                Spacer()
                HStack {
                    Text("\(Int(response.resultPercent * 100))%")
                    Text(response.save.request?.difficulty?.rawValue ?? "")
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 5)
        .frame(maxWidth: .infinity)
        .tint(.white)
    }

    var listView: some View {
        ForEach(data, id: \.id) { response in
            NavigationLink(value: NavRout.dbDetail(response)) {
                responseCell(response)
            }
            Divider()
        }
    }

    private var data: [AdviceQuestionModel] {
        db.db.responses.filter({
            $0.save.request?.type == presenter.selectedType
        })
    }
}

extension DBCategoriyView {
    struct Presenter: Equatable, Hashable {
        let selectedCategory: String
        let selectedType: String
    }
}
