import SwiftUI

struct HomeView: View {
    @EnvironmentObject var db: AppData
    @StateObject var viewModel: HomeViewModel = .init()
    
    var body: some View {
        ZStack() {
            VStack {
                headerView
                navigationStack
                buttonsView
            }
            .frame(maxHeight: viewModel.response != nil && viewModel.appResponse != nil ? .infinity : 0)
            .clipped()
            .animation(.smooth, value: viewModel.response != nil && viewModel.appResponse != nil)
            homeView
                .frame(maxHeight: .infinity)
                .opacity(viewModel.appResponse != nil && viewModel.response == nil ? 1 : 0)
                .animation(.smooth, value: viewModel.appResponse != nil && viewModel.response == nil)

        }
        .overlay {
            networkResponseView
        }
        .opacity(viewModel.dbPresenting ? 0 : 1)
        .animation(.smooth(duration: 1.2), value: viewModel.dbPresenting)
        .frame(maxWidth: .infinity,
               maxHeight: .infinity)
        .padding()
        .background(content: {
            HomeBackgroundView()
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
        
        if viewModel.appDataLoading {
            ProgressView()
                .progressViewStyle(.circular)
        } else if viewModel.appResponse == nil {
            Text("Error loading app data")
        }
    }
    
    @ViewBuilder
    var buttonsView: some View {
        if viewModel.currentQuestion == nil && self.viewModel.response?.save.questionResults.isEmpty ?? true {
            Button("Start") {
                viewModel.navValues.append(.question(viewModel.response!.response.questions.first!))
                
            }
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
    
    @ViewBuilder
    var homeView: some View {
        if viewModel.rqStarted {
            ProgressView().progressViewStyle(.circular)
        } else {
            VStack {
                Button("db") {
                    self.viewModel.dbPresenting = true
                }

                Spacer()
                collectionView
            }
            .frame(maxHeight: .infinity)
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
        .frame(height: 44)
    }
    
    var navigationStack: some View {
        NavigationStack(path: $viewModel.navValues) {
            VStack(content: {
                Text("request is ready")
            })
            .navigationDestination(for: NavRout.self) { navRout in
                navigationDestination(for: navRout)
                    .background {
                        ClearBackgroundView()
                    }
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
            ResultView(savePressed: .init(get: {
                false
            }, set: {
                if $0 {
                    viewModel.savePressed(db: db)
                }
            }))
        }
    }

    var collectionView: some View {
        GeometryReader { proxy in
            ScrollView(.vertical) {
                VStack {
                    Spacer().frame(height: proxy.size.height * 0.8)
                    CollectionView(contentHeight: $viewModel.contentHeight, data: viewModel.collectionData, didSelect: { at in
                        viewModel.collectionViewSelected(at: at ?? 0)
                    })
                    .frame(height: viewModel.contentHeight)
                }
            }
        }
    }
}
