import SwiftUI

struct HomeView: View {
    @EnvironmentObject var db: AppData
    @StateObject var viewModel: HomeViewModel = .init()

    var body: some View {
        let buttonsHeight = viewModel.buttonsViewHeight
        ZStack {
//            headerView
            VStack(spacing: 0) {
                navigationStack
                    .ignoresSafeArea(.all)
                if buttonsHeight > 0 {
                    Spacer().frame(height: buttonsHeight)
                }
            }
            .opacity(db.sheetPresenting ? 0 : 1)
            .animation(.smooth, value: db.sheetPresenting)
            buttonsView
                .padding(.horizontal, 10)
                .opacity(db.sheetPresenting ? 0 : 1)
                .animation(.smooth, value: db.sheetPresenting)

        }
        .foregroundColor(.white)
        .animation(.smooth, value: viewModel.response != nil && viewModel.appResponse != nil)
        .overlay {
            networkResponseView
        }
        .opacity(viewModel.dbPresenting ? 0 : 1)
        .animation(.smooth(duration: 1.2), value: viewModel.dbPresenting)
        .onChange(of: db.db.responses.count) { newValue in
            viewModel.dbHolder = db.db.responses
        }
        .onChange(of: db.db.responses) { newValue in
            viewModel.dbUpdated(db)
        }
        .onChange(of: viewModel.collectionData) { newValue in
            if self.viewModel.statsPreview.isEmpty {
                self.viewModel.dbUpdated(db)
            }
        }
        .background(content: {
            HomeBackgroundView(type: .constant(viewModel.circleType), properties: .constant(viewModel.backgroundProperties))
        })
        .sheet(isPresented: $viewModel.textPresenting) {
            TextView(text: viewModel.response?.response.textHolder ?? "??", needScroll: true)
        }
        .task(priority: .userInitiated) {
            viewModel.loadAppSettings(db: db)
        }
        .onChange(of: viewModel.selectedIDs) { newValue in
            self.viewModel.updateTableData()
        }
    }
    
    @ViewBuilder
    var networkResponseView: some View {
        if viewModel.appDataLoading || (viewModel.rqStarted && viewModel.response == nil) {
        } else if viewModel.appResponse == nil {
            Text("Error loading app data")
        }
    }
    
    @ViewBuilder
    var buttonsView: some View {
        let needButton = viewModel.buttonsViewHeight
        VStack {
            Spacer()
                Button(viewModel.response != nil ? "squeeze" : "Start") {
                    if viewModel.response != nil {
    //                    viewModel.navValues.append(.question(viewModel.response!.response.questions.first!))
                        viewModel.navValues.append(.cardView(.init(data: viewModel.response!.response.questions.compactMap({
                            .init(title: $0.questionName, description: $0.description, id: $0.id, buttons: $0.options.compactMap({
                                .init(title: $0.optionName, id: $0.id.uuidString, extraSmall: true)
                            }))
                        }))))
                    } else {
                        withAnimation {
                            viewModel.navValues.append(.empty)
                            viewModel.startGenerationRequest()
                        }
                    }
                }
                .padding(.horizontal, 50)
                .padding(.vertical, needButton > 0 ? 10 : 0)
                .frame(height: needButton)
                .frame(maxWidth: .infinity)
                .clipped()
                .background(.red)
                .cornerRadius(8)
                .disabled(viewModel.selectedRequest == nil ? false : (viewModel.selectedRequest?.difficulty == nil))
                .foregroundColor(.white.opacity(viewModel.selectedRequest?.difficulty == nil && viewModel.selectedRequest != nil ? 0.5 : 1))
                .animation(.smooth, value: needButton > 0)
        }
//        actionButtonsView
    }
    
    var actionButtonsView: some View {
        ForEach(viewModel.currentQuestion?.options ?? [], id: \.id) { option in
            Button(option.optionName + " (\(option.grade))") {
                viewModel.actionButtonPressed(option)
            }
        }
    }
    
    
    var headerView: some View {
        HStack {
            Text("\(viewModel.response?.save.grade ?? 0) / \(viewModel.response?.response.questions.totalGrade ?? 0)")
            Text("| \(viewModel.response?.response.questions.count ?? 0)")
            Spacer()
            Button("text") {
                viewModel.textPresenting = true
            }
        }
        .frame(height: viewModel.response != nil ? 44 : 0)
        .animation(.smooth, value: viewModel.response != nil)
        .clipped()
    }

    var homeRoot: some View {
        VStack {
            if viewModel.response != nil {
                ReadyView {
                    withAnimation {
                        viewModel.response = nil
                        viewModel.rqStarted = false
                    }
                }

            } else {
                collectionView
                    .overlay {
                        VStack {
                            Button("cards") {
                                viewModel.navValues.append(.cardView(.init(data: .demo)))
                            }
                            .frame(height: 40)
                            Spacer()
                        }
                    }
            }

        }
        .opacity(viewModel.navValues.isEmpty ? 1 : 0)
        .animation(.smooth, value: viewModel.navValues.isEmpty)
    }

    var navigationStack: some View {
        NavigationStack(path: $viewModel.navValues) {
            homeRoot
            .navigationDestination(for: NavRout.self) { navRout in
                navigationDestination(for: navRout)
                    .opacity(viewModel.navValues.last == navRout ? 1 : 0)
                    .background {
                        ClearBackgroundView()
                    }
                    .animation(.smooth, value: viewModel.navValues.last == navRout)
            }
            .background {
                ClearBackgroundView()
            }
            .onChange(of: viewModel.navValues) { newValue in
                if newValue.isEmpty && !viewModel.rqStarted {
                    withAnimation {
                        viewModel.selectedRequest = nil
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .background {
            ClearBackgroundView()
        }
        
    }
    
    @ViewBuilder
    func navigationDestination(for rout: NavRout) -> some View {
        switch rout {
        case .question(let response):
            SqueezeView(response: response)
        case .result:
            ResultView(saveModel: viewModel.response ?? .init(response: .init(data: .init()), save: .init(date: .init())), savePressed: .init(get: {
                false
            }, set: {
                if $0 {
                    viewModel.savePressed(db: db)
                }
            }))
        case .requestToGenerateParameters(let request):
            RequestParametersView(request: $viewModel.selectedRequest)
            //{
//                withAnimation {
//                    viewModel.navValues.append(.empty)
//                    viewModel.selectedRequest = request
//                    viewModel.startGenerationRequest()
//                }
//            }
        case .requestGenerated:
            ReadyView(cancelPressed:{
                withAnimation {
                    viewModel.navValues.removeAll()
                    viewModel.rqStarted = false
                }
            })
        case .empty:
            VStack(content: {
                Spacer()
                    .frame(maxHeight: .infinity)
                Spacer()
                    .frame(maxHeight: .infinity)
                Text("Generating")
                    .font(.Type.section.font)
                    .opacity(.Opacity.descriptionLight.rawValue)
                Spacer()
                    .frame(maxHeight: .infinity)
            })
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden()
        case .cardView(let properties):
            CardsView(properties) { selection in
                let questions = viewModel.response?.response.questions ?? []
                viewModel.response?.save = .init(date: .init(), category: viewModel.category, request: viewModel.selectedRequest, questionResults: [:])
                selection.forEach { (key: UUID, value: String) in
                    print("rtgerfwde key: ", key, " value: ", value)
                    if let question = questions.first(where: {
                        $0.id == key
                    }) {
                        if let options = question.options.first(where: {
                            $0.id == .init(uuidString: value)!
                        }) {
                            viewModel.response?.save.questionResults.updateValue(options, forKey: question)
                        } else {
                            fatalError()
                        }
                        
                    } else {
                        fatalError()
                    }
                    
                }
                DispatchQueue.main.async {
                    viewModel.savePressed(db: db)
                }
            }
        case .dbDetail(_):
            ClearBackgroundView()
        }
    }


    func selected(_ item: String?) {
        let data = viewModel.appResponse?.categories.first(where: { response in
            response.id == item
        })?.list?.compactMap({
            viewModel.performAddTableData($0, parentID: item ?? "")
        }) ?? []
        withAnimation {
            self.viewModel.collectionDataForKey = data
        }
    }


    func parentCellHeadRow(_ title: String, _ value: String) -> some View {
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
    func parentCell(_ item: CollectionViewController.CollectionData) -> some View {
        let data = viewModel.statsPreview[item.id]
        Button {
            viewModel.parentCollectionSelected(item)
        } label: {
            VStack {
                Spacer().frame(maxHeight: viewModel.largeParentCollections ? .zero : .infinity)
                    .animation(.bouncy, value: viewModel.largeParentCollections)
                Text(item.title)
                    .foregroundColor(.white.opacity(.Opacity.descriptionLight.rawValue))
                    .font(.Type.section.font)
                    .padding(.horizontal, 22)

                Spacer()
                    .frame(maxHeight: .infinity)
                VStack {
                    parentCellHeadRow("count", "\(data?.subcategoriesCount ?? 0)/\(data?.completedSubcategoriesCount ?? 0)")
                    Divider()
                    parentCellHeadRow("score", "\(data?.avarageGrade ?? 0)%")
                }
                .opacity(.Opacity.description.rawValue)
                .frame(maxWidth: .infinity,
                       maxHeight: viewModel.largeParentCollections ? .infinity : .zero)
                .clipped()
                .animation(.bouncy, value: viewModel.largeParentCollections)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
        }
        .blurBackground(cornerRadius: .CornerRadius.medium.rawValue)
    }

    @ViewBuilder
    var collectiomParentSections: some View {
        let paddings = viewModel.collectionSubviewPaddings
        ScrollView(.horizontal,
                   showsIndicators: false) {
            LazyHStack(spacing: viewModel.maxCollectionPaddings * 0.6) {
                ForEach(viewModel.collectionData, id:\.id) { item in
                    parentCell(item)
                }
                Spacer().frame(width: viewModel.maxCollectionPaddings)
            }
            .padding(.leading, paddings)
            .frame(height: viewModel.largeParentCollections ? 120 : 50)
            .animation(.bouncy, value: viewModel.largeParentCollections)

        }
    }

    func collectionViewSection(_ proxy: GeometryProxy) -> some View {
        VStack {
            Spacer().frame(height: proxy.size.height * 0.12)
            collectiomParentSections
            Spacer().frame(height: 12)
            CollectionView(contentHeight: $viewModel.contentHeight, data: viewModel.collectionDataForKey, didSelect: { at in
                    viewModel.collectionViewSelected(at: at ?? 0)

                })
            .padding(.leading, viewModel.collectionSubviewPaddings)
            .padding(.trailing, 5)
                .frame(height: viewModel.contentHeight)
                .animation(.bouncy, value: viewModel.selectedGeneralKeyID)
                .modifier(ScrollReaderModifier(scrollPosition: $viewModel.scrollPosition))

        }
    }

    var collectionView: some View {
        GeometryReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {

                LazyVStack(pinnedViews: .sectionHeaders) {
                    Spacer().frame(height: proxy.size.height * 0.39)
                    Section {
                        collectionViewSection(proxy)
                    } header: {
                        collectionHeader
                    }
                    
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
                appTitle
                    .background(content: {
                        Color.clear
                            .blurBackground(
                                opacity: .Opacity.lightBackground.rawValue * viewModel.gradientOpacity,
                                cornerRadius: .CornerRadius.medium.rawValue)
                            .padding(.vertical, -10)
                    })
                    .offset(x: opacityGradient * viewModel.collectionSubviewPaddings,
                            y: opacityGradient * 10
                    )
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
