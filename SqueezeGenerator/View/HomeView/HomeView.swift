import SwiftUI

struct HomeView: View {
    @EnvironmentObject var db: AppData
    @StateObject var viewModel: HomeViewModel = .init()
    
    var body: some View {
        VStack {
            headerView
            navigationStack
                .ignoresSafeArea(.all)
            buttonsView
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
        .background(content: {
            VStack(spacing: 0) {
                Color.black
                    .ignoresSafeArea(.all)
                    .frame(height: 33, alignment: .top)
                    
                Spacer()
            }
            .opacity(viewModel.gradientOpacity)//viewModel.gradientOpacity > 0.1 ? viewModel.gradientOpacity * 6 : viewModel.gradientOpacity)
            .animation(.smooth, value: viewModel.gradientOpacity)

            
        })
        .background(content: {
            HomeBackgroundView(type: .constant(viewModel.circleType), properties: .constant(viewModel.backgroundProperties))
        })
        .fullScreenCover(isPresented: $viewModel.dbPresenting, content: {
            DBView()
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
            ProgressView()
                .progressViewStyle(.circular)
        } else if viewModel.appResponse == nil {
            Text("Error loading app data")
        }
    }
    
    @ViewBuilder
    var buttonsView: some View {
        if viewModel.navValues.last?.needDoneButton ?? false || (viewModel.response != nil && viewModel.navValues.isEmpty) {
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
            .padding(.vertical, 10)
            .frame(height: 44)
            .clipped()
            .background(.red)
            .cornerRadius(8)
            .disabled(viewModel.selectedRequest == nil ? false : (viewModel.selectedRequest?.difficulty == nil))
            .foregroundColor(.white.opacity(viewModel.selectedRequest?.difficulty == nil && viewModel.selectedRequest != nil ? 0.5 : 1))
            .animation(.smooth, value: viewModel.selectedRequest?.difficulty == nil)
        }
        actionButtonsView
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
    
    var navigationStack: some View {
        NavigationStack(path: $viewModel.navValues) {
            VStack {
                if viewModel.response != nil {
                    ReadyView {
                        withAnimation {
                            viewModel.response = nil
                            viewModel.rqStarted = false
                        }
                    }
                    
                } else {
                    HStack {
                        Button("cards") {
                            viewModel.navValues.append(.cardView(.init(data: .demo)))
                        }
                    }
                    Spacer()
                    collectionView
                }
                
            }
            .opacity(viewModel.navValues.isEmpty ? 1 : 0)
            .animation(.smooth, value: viewModel.navValues.isEmpty)
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
                Spacer()
                    .frame(maxHeight: .infinity)
            })
            .onAppear(perform: {
                print("sfdasvfasd")
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
        }
    }


    func selected(_ item: String?) {
        self.viewModel.collectionDataForKey = viewModel.appResponse?.categories.first(where: { response in
            response.id == item
        })?.list?.compactMap({
            viewModel.performAddTableData($0, parentID: item ?? "")
        }) ?? []
    }

    var collectiomParentSections: some View {
        ScrollView(.horizontal,
                   showsIndicators: false) {
            LazyHStack {
                Spacer().frame(width: 20)
                ForEach(viewModel.collectionData, id:\.id) { item in
                    Button {
                        self.viewModel.collectionDataForKey.removeAll()
                        self.viewModel.selectedIDs.removeAll()
                        if self.viewModel.selectedGeneralKeyID != item.id {
                            self.viewModel.selectedGeneralKeyID = item.id
                            self.viewModel.selectedIDs.append(item.id)
                        } else {
                            self.viewModel.selectedGeneralKeyID = nil
                            self.viewModel.selectedIDs.removeAll()
                        }
                        self.viewModel.updateTableData()
//                        self.selected(self.viewModel.selectedGeneralKeyID)
//                        self.viewModel.updateTableData()

//                        self.viewModel.collectionDataForKey = self
                    } label: {
                        VStack {
                            Text(item.title)
                                .foregroundColor(.white.opacity(0.5))
                                .font(.system(size: 18, weight: .semibold))
                            Spacer()
                        }
                        .padding(.horizontal, 30)
                        .padding(.vertical, 8)
                    }
                    .background(.white.opacity(0.1))
                    .cornerRadius(14)

                }
                Spacer().frame(width: 20)
            }
            .frame(height: viewModel.selectedGeneralKeyID == nil ? 120 : 50)

        }
    }

    var collectionView: some View {
        GeometryReader { proxy in
            ScrollView(.vertical) {

                LazyVStack(pinnedViews: .sectionHeaders) {
                    Spacer().frame(height: proxy.size.height * 0.3)
                        .overlay {
                            Image(.shape)
                                .foregroundColor(.red)
                        }
                    Section {
                        VStack {
                            Spacer().frame(height: proxy.size.height * 0.23)
                            collectiomParentSections
//                            if !viewModel.collectionDataForKey.isEmpty {
                            CollectionView(contentHeight: $viewModel.contentHeight, data: viewModel.collectionDataForKey, didSelect: { at in
                                    viewModel.collectionViewSelected(at: at ?? 0)
                                    
                                })
                                .padding(.horizontal, 12)
                                .background {
                                    GeometryReader { proxy in
                                        Color.clear
                                            .onChange(of: proxy.frame(in: .global).origin) { newValue in
                                                viewModel.scrollPosition = newValue
                                                print(viewModel.scrollPosition, "rtgerfwda")
                                            }
                                            .onAppear {
                                                viewModel.scrollPosition = proxy.frame(in: .global).origin
                                            }
                                    }
                                }
                                .frame(height: viewModel.contentHeight)
//                            }

                        }
                    } header: {
                        collectionHeader
                    }
                    
                }
            }
        }
    }
    
    var appTextMask: some View {
        HStack {
            VStack {
                Circle()
                    .frame(width: 120 * (1 - (viewModel.gradientOpacity >= 0.9 ? 0.9 : viewModel.gradientOpacity)))
                    .aspectRatio(1, contentMode: .fill)
                Spacer()
                    .overlay {
                        ForEach([20, 5, 40], id:\.self) { i in
                            Circle()
                                .frame(width: (10 + (i / 10)) * (1 - (viewModel.gradientOpacity >= 0.9 ? 0.9 : viewModel.gradientOpacity)))
                                .aspectRatio(1, contentMode: .fill)
                                .offset(x: i, y: i * -1)
                        }
                    }
            }
            Spacer()
                .overlay {
                    ForEach([-20, 50, 10], id:\.self) { i in
                        Circle()
                            .frame(width: (10 + (i / 10)) * (1 - (viewModel.gradientOpacity >= 0.9 ? 0.9 : viewModel.gradientOpacity)))
                            .aspectRatio(1, contentMode: .fill)
                            .offset(x: i, y: (i == 50 ? i : -i) / 20)
                    }
                }
            VStack {
                Spacer()
                    .overlay {
                        ForEach([-60, -20, -40], id:\.self) { i in
                            Circle()
                                .frame(width: (10 + (i / 10)) * (1 - (viewModel.gradientOpacity >= 0.9 ? 0.9 : viewModel.gradientOpacity)))
                                .aspectRatio(1, contentMode: .fill)
                                .offset(x: i, y: (i == -20 ? i : -i) / 20)
                        }
                    }
                Circle()
                    .frame(width: 150 * (1 - (viewModel.gradientOpacity >= 0.9 ? 0.9 : viewModel.gradientOpacity)))
                    .aspectRatio(1, contentMode: .fill)
                    .offset(x: -65 * viewModel.gradientOpacity, y: -10 * viewModel.gradientOpacity)
                
            }
        }
        .padding(.top, 30 * (1 - (viewModel.gradientOpacity >= 0.5 ? 0.5 : viewModel.gradientOpacity)))
        .padding(.leading, 30 * (1 - (viewModel.gradientOpacity >= 0.5 ? 0.5 : viewModel.gradientOpacity)))
        .frame(maxWidth: .infinity)
        .animation(.bouncy, value: viewModel.gradientOpacity)
    }
    
    
    
    var collectionHeader: some View {
        VStack {
            ZStack(content: {
                appTitle
//                appTitle
//                    .foregroundColor(.black)
//                    .background(.red)
//                    .mask {
//                        appTextMask
//                    }
            })
            .frame(maxWidth: .infinity,
                       alignment: .leading)
            Spacer()
            
        }
        .frame(height: 220)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(content: {
            headerGradient
        })
    }
    
    var headerGradient: some View {
        LinearGradient(//here
            gradient: Gradient(colors: [
                .black, .black, .clear, .clear
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        .offset(y: -50)
        .frame(maxHeight: .infinity, alignment: .top)
        .frame(height: 220)
        .opacity(viewModel.gradientOpacity)
        .animation(.smooth, value: viewModel.gradientOpacity)
    }
    
    var appTitle: some View {
        Text("Squeeze generator")
            .multilineTextAlignment(.leading)
            .padding(.horizontal, 15)
            .lineSpacing(0)
            .lineLimit(nil)
            .font(.system(size: 80 * (1 - (viewModel.gradientOpacity >= 0.8 ? 0.8 : viewModel.gradientOpacity)),
                          weight: .semibold))
    }
}
