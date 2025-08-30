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
            LazyVStack(pinnedViews: .sectionHeaders) {
                Section {
                    dataSection
                } header: {
                    sectionHeader
                }
            }
            .modifier(ScrollReaderModifier(scrollPosition: $scrollModifier))
        }
        .navigationTitle(item.save.request?.type.addSpaceBeforeCapitalizedLetters.capitalized ?? "-")
        .background {
            ClearBackgroundView()
        }
        .modifier(NavigationBackgroundModifier())
    }
    
    @ViewBuilder
    var sectionHeader: some View {
        let scr = scrollModifier.percent
        let scrMax = scr <= 0 ? 0 : scr
        HStack {
            circleView(scr)
            headGroupedSections(scr)
        }
        .overlay(content: {
            categoryLabel
        })
        .background {
            headerBackgroundCircle(scr)
        }
        .background(content: {
            headerBackgroundRactengle(scr)
        })
        .padding(.top, 15)
        .padding(.vertical, 30 * (scr >= 0 ? scr : 0))
        .padding(.trailing, 10)
        .compositingGroup()
        .shadow(radius: 10)
        .padding(.vertical, (5 * (scrMax + 1)))
        .background(.black.opacity(0.05 * (1 - scrMax)))
        .blurBackground(
            .dark,
            opacityMultiplier: 1 - scrMax,
            cornerRadius: 0,
            count: 5
        )
        .padding(.top, -15)
        .animation(.smooth, value: scr <= 0.3)
    }
    
    @ViewBuilder
    func headGroupedSections(_ scr: CGFloat) -> some View {
        VStack(alignment: .trailing, spacing: 0) {
            headerSections(scr)
        }
        .frame(maxWidth: scr >= 0.3 ? .infinity : .zero, maxHeight: scr >= 0.3 ? .infinity : .zero, alignment: .trailing)
        .clipped()
        .animation(.bouncy, value: scr <= 0)
        
        HStack(spacing: 10) {
            headerSections(scr)
        }
        .frame(maxWidth: scr < 0.3 ? .infinity : .zero)
        .clipped()
        .frame(height: 40)
        .animation(.bouncy, value: scr <= 0)
    }

    @ViewBuilder
    func headerSections(_ scr: CGFloat) -> some View {
        headerRow(title: "Questions", value: "\(item.response.questions.count)", scrollPercent: scr)
            .frame(maxWidth: .infinity)
        headerRow(
            title: "Difficulty",
            value: item.save.request?.difficulty?.rawValue.capitalized ?? "",
            scrollPercent: scr
        )
        headerRow(
            title: "Date",
            value: item.save.date.stringDate(needTime: false),
            scrollPercent: scr
        )
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
                        .shadow(radius: 10)
                }
            }
            .padding(.horizontal, 10)
        }
    }
    
    var dataSection: some View {
        VStack(alignment: .leading, spacing: 5) {
            ResultView(saveModel: item, canScroll: false)
            Spacer().frame(height: 25)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Questions")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.leading, 10)
                questionList
            }
            .padding(.top, 10)
            .blurBackground(.light, count: 4)
            Spacer().frame(height: 20)
        }
        .padding(10)
        .padding(.top, -20)
    }
    
    @ViewBuilder
    var questionList: some View {
        ForEach(Array(item.save.questionResults.keys), id:\.id) { key in
            VStack {
                dataRow(key)
                    .padding(.horizontal, 10)
                Spacer().frame(height: 15)
                actionsCollection(key)
            }
            .padding(.vertical, 10)
            .background(.white.opacity(0.1))
            .cornerRadius(12)
            .shadow(radius: 10)
            .padding(.horizontal, 10)
            Divider()
                .background(.white.opacity(.Opacity.separetor.rawValue))
                .padding(.horizontal, 10)
        }
    }
}

fileprivate extension DBDetailView {
    @ViewBuilder
    func headerRow(
        title: String,
        value: String,
        hidden: Bool = false,
        scrollPercent: CGFloat
    ) -> some View {
        
        let scroll = scrollPercent >= 0.5 ? scrollPercent : 0.5
        VStack(alignment: .trailing) {
            Text(title)
                .font(.system(size: 9, weight: .regular))
                .minimumScaleFactor(0.1)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .multilineTextAlignment(.trailing)
                .foregroundColor(.white.opacity(0.3))
            Text(value)
                .font(.system(size: 18 * scroll, weight: .semibold))
                .minimumScaleFactor(0.2)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .multilineTextAlignment(.trailing)
                .lineLimit(1)
                .foregroundColor(.white.opacity(0.5))
                .shadow(radius: 5)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .frame(maxWidth: hidden ? 0 : .infinity,
               alignment: .trailing)
    }

    
    func circleView(_ scrollPercent: CGFloat) -> some View {
        CircularProgressView(
            progress: item.resultPercent,
            widthMultiplier: scrollPercent >= 0.2 ? scrollPercent : 0.2,
            imageURL: item.save.apiCategory?.imageURL, color: .init(hex: item.save.apiCategory?.color?.topLeft ?? "") ?? .red)
        .frame(maxWidth: scrollPercent <= 0.3 ? nil : .infinity, alignment: .leading)
        .padding(10)
        .frame(maxHeight: .infinity)
        .background {
            Circle()
                .fill()
                .blendMode(.destinationOut)
                .frame(maxHeight: .infinity)
                .aspectRatio(1, contentMode: .fit)
        }
    }
    
    func headerBackgroundCircle(_ scr: CGFloat) -> some View {
        HStack {
            Circle()
                .fill(.white)
                .blendMode(.destinationOut)
                .frame(width: scr <= 0.6 ? .zero : ((180) * (scr <= 0.2 ? 0.2 : scr)))
                .aspectRatio(1, contentMode: .fit)
            Spacer().frame(maxWidth: .infinity)
        }
    }
    
    func headerBackgroundRactengle(_ scr: CGFloat) -> some View {
        HStack {
            Spacer()
                .frame(width: ((150 / 2) * (scr <= 0.9 ? 0.9 : scr)))
            Color.white
                .opacity(0.15 * scr)
                .cornerRadius(24)
        }
    }
    
    var categoryLabel: some View {
        VStack {
            Spacer()
            Text(item.save.request?.category.addSpaceBeforeCapitalizedLetters.capitalized ?? "")
                .font(.system(size: 9, weight: .semibold))
                .blendMode(.destinationOut)
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
}
