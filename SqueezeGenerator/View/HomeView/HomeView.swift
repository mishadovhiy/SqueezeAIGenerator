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
                        viewModel.navValues.append(
.cardView(
.init(
    type: viewModel.selectedRequest?.type ?? "", data: viewModel.response!.response.questions.compactMap(
        { question in
                .init(
                    title: question.questionName,
                    description: question.description,
                    id: question.id,
                    buttons: question.options.compactMap(
                        { button in
                            let selectedOption = viewModel.response!.save.questionResults[question]
                            return .init(
                                title: button.optionName,
                                isSelected: selectedOption?.id == button.id,
                                id: button.id.uuidString,
                                extraSmall: true
                            )
                        })
                )
        }))
)
)
                    } else {
                        withAnimation {
                            viewModel.navValues.append(.empty)
                            viewModel.startGenerationRequest()
                        }
                    }
                }
                .font(.typed(.section))
                .padding(.horizontal, 50)
                .frame(height: needButton)
                .frame(maxWidth: .infinity)
                .clipped()
                .background(Color(uiColor: .init(hexColor: .puroure2Light)!))
                .cornerRadius(16)
                .disabled(viewModel.selectedRequest == nil ? false : (viewModel.selectedRequest?.difficulty == nil))
                .foregroundColor(.white.opacity(viewModel.selectedRequest?.difficulty == nil && viewModel.selectedRequest != nil ? 0.5 : 1))
                .animation(.smooth, value: needButton > 0)
                .shadow(radius: 10)
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
                HomeCollectionView()
                    .environmentObject(viewModel)
                    .overlay {
                        VStack {
                            Button("cards") {
                                viewModel.navValues.append(.cardView(.init(type: "test", data: .demo)))
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
            .navigationBarTitleDisplayMode(.large)

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
}
