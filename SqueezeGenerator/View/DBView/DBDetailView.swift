//
//  DBDetailView.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 22.07.2025.
//

import SwiftUI

struct DBDetailView: View {

    let item: AdviceQuestionModel
    @State var collectionHeights: [String: CGFloat] = [:]
    @EnvironmentObject var db: AppData
    @State var scrollModifier: ScrollReaderModifier.ScrollResult = .init()
    typealias DataKey = NetworkResponse.AdviceResponse.QuestionResponse

    var body: some View {
        ScrollView(.vertical) {
            VStack {
                noneFixedHeader
                tableView
            }
        }
        .navigationTitle(item.save.request?.type ?? "-")
        .background {
            ClearBackgroundView()
        }
        .toolbar {
            if item.save.aiResult != nil {
                ToolbarItem {
                    NavigationLink(value: NavRout.resultResponse(item)) {
                        Text("result")
                    }
                }
            }
        }
    }

    var tableView: some View {
        LazyVStack(pinnedViews: .sectionHeaders) {
            Section {
                dataSection
                    .padding(10)
                    .blurBackground(.dark)
                    .padding(10)

            } header: {
                sectionHeader
                    .padding(.vertical, (10 * (scrollModifier.percentPositive + 1)))
                    .blurBackground(
                        .dark,
                        opacityMultiplier: 1 - scrollModifier.percentPositiveMax,
                        cornerRadius: 0
                    )


            }

        }
    }

    @ViewBuilder
    var noneFixedHeader: some View {
        Text(item.save.request?.description ?? "-")
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(10)
            .modifier(ScrollReaderModifier(scrollPosition: $scrollModifier))
        HStack {
            VStack {
                Text("Category")
                Text(item.save.request?.category ?? "")
            }
            .frame(maxWidth: .infinity)
            VStack {
                Text("Date")
                Text(item.save.date.stringDate)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(10)
    }

    var sectionHeader: some View {
        HStack {
            Text("\(item.save.grade)/\(item.response.questions.totalGrade) (\(item.resultPercentInt)%)")
                .frame(maxWidth: .infinity)
            Text("questions: \(item.response.questions.count)")
                .frame(maxWidth: .infinity)
        }
    }

    @ViewBuilder
    func actionsCollection(_ key: DataKey) -> some View {
        let height = collectionHeights[key.id.uuidString] ?? 0
        CollectionView(
            contentHeight: .init(get: {
                height
            }, set: {
                collectionHeights.updateValue($0, forKey: key.id.uuidString)
            }),
            isopacityCells: false,
            data: key.options.compactMap({
                .init(title: $0.optionName)
            })
        )
        .frame(height: height >= 30 ? height - 30 : 0)
    }

    @ViewBuilder
    func dataRow(_ key: DataKey) -> some View {
        Text(key.questionName)
            .font(.Type.section.font)
            .frame(maxWidth: .infinity, alignment: .leading)
        Text(key.description)
            .frame(maxWidth: .infinity, alignment: .leading)
            .opacity(.Opacity.description.rawValue)
    }
    
    var dataSection: some View {
        VStack {
            ForEach(Array(item.save.questionResults.keys), id:\.id) { key in
                dataRow(key)
                Spacer().frame(height: 25)
                actionsCollection(key)
                Divider()
                    .padding(.vertical, 10)
            }
        }
    }
}
