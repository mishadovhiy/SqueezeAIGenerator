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
    @EnvironmentObject var db: LocalDataBaseManager
    @State var scrollModifier: ScrollReaderModifier.ScrollResult = .init()
    typealias DataKey = NetworkResponse.AdviceResponse.QuestionResponse

    var body: some View {
        ScrollView(.vertical) {
            VStack {
                noneFixedHeader
                tableView
            }
        }
        .navigationTitle(item.save.request?.type.addSpaceBeforeCapitalizedLetters.capitalized ?? "-")
        .background {
            ClearBackgroundView()
        }
        .modifier(NavigationBackgroundModifier())
//        .toolbar {
//            if item.save.aiResult != nil {
//                ToolbarItem {
//                    NavigationLink(value: NavigationRout.resultResponse(item)) {
//                        Text("result")
//                    }
//                }
//            }
//        }
    }

    var tableView: some View {
        LazyVStack(pinnedViews: .sectionHeaders) {
            Section {
                dataSection

            } header: {
                sectionHeader
                    .padding(.vertical, (5 * (scrollModifier.percentPositive + 1)))
                    .background(.black.opacity(0.05 * (1 - scrollModifier.percentPositiveMax)))
                    .blurBackground(
                        .dark,
                        opacityMultiplier: 1 - scrollModifier.percentPositiveMax,
                        cornerRadius: 0,
                        count: 5
                    )
                    .offset(y: -3)


            }

        }
    }

    @ViewBuilder
    var noneFixedHeader: some View {
        HStack {
            headerRow(title: "Category", value: item.save.request?.category.addSpaceBeforeCapitalizedLetters.capitalized ?? "")
                .frame(maxWidth: .infinity)
            Divider().background(.white.opacity(.Opacity.separetor.rawValue))
            headerRow(title: "Date", value: item.save.date.stringDate(needTime: false))
            .frame(maxWidth: .infinity)
        }
        .modifier(ScrollReaderModifier(scrollPosition: $scrollModifier))
        .padding(10)
    }

    func headerRow(
        title: String,
        value: String,
        hidden: Bool = false
    ) -> some View {
        VStack {
            Text(title)
                .font(.system(size: 9, weight: .regular))
                .foregroundColor(.white.opacity(0.3))
            Text(value)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.white.opacity(0.5))
                .shadow(radius: 5)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background {
            Color.clear
                .blurBackground(opacityMultiplier: scrollModifier.percent <= 0 ? 1 : 1 - scrollModifier.percent)
                .opacity(hidden ? 0 : 1)
        }
        .frame(maxWidth: hidden ? 0 : .infinity)
    }

    var sectionHeader: some View {
        HStack {
            CircularProgressView(
                progress: item.resultPercent,
                widthMultiplier: scrollModifier.percent >= 0.2 ? scrollModifier.percent : 0.2)
            .frame(maxWidth: scrollModifier.percent <= 0.3 ? nil : .infinity)
            .animation(.bouncy, value: scrollModifier.percent <= 0.3)

            HStack(spacing: 0) {
                headerRow(title: "Questions", value: "\(item.response.questions.count)")
                    .frame(maxWidth: .infinity)
                headerRow(
                    title: "Category",
                    value: item.save.request?.category.addSpaceBeforeCapitalizedLetters.capitalized ?? "",
                    hidden: !(scrollModifier.percent <= 0)
                )
                .animation(.bouncy, value: scrollModifier.percent <= 0)
                headerRow(
                    title: "Date",
                    value: item.save.date.stringDate(needTime: false),
                    hidden: !(scrollModifier.percent <= 0)
                )
                .animation(.bouncy, value: scrollModifier.percent <= 0)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 40)
            .animation(.bouncy, value: scrollModifier.percent <= 0)
        }
        .animation(.bouncy, value: scrollModifier.percent <= 0.3)
        .padding(.horizontal, 15)
    }

    @ViewBuilder
    func actionsCollection(_ key: DataKey) -> some View {
        let selectedOption = self.item.save.questionResults[key]
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHGrid(rows: [.init()]) {
                ForEach(key.options, id: \.id) { option in
                    Text(option.optionName)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(selectedOption == option ? .black : .white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.white.opacity(selectedOption == option ? 1 : 0.15))
                        .cornerRadius(9)
                }
            }
            .padding(.horizontal, 10)
        }
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
            VStack {
                ForEach(Array(item.save.questionResults.keys), id:\.id) { key in
                    dataRow(key)
                        .padding(.horizontal, 10)
                    Spacer().frame(height: 15)
                    actionsCollection(key)
                    Divider()
                        .background(.white.opacity(.Opacity.separetor.rawValue))
                        .padding(.vertical, 10)
                        .padding(.horizontal, 10)
                }
            }
            .padding(.top, 10)
            .blurBackground(.light, count: 4)
            
            Spacer().frame(height: 50)
            ResultView(saveModel: item, canScroll: false)
        }
        .padding(10)
    }
}
