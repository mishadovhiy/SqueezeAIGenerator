import SwiftUI

struct HomeView: View {
    @EnvironmentObject var db: AppData
    @StateObject var viewModel: HomeViewModel = .init()
    
    var body: some View {
        VStack(spacing: 15) {
            if let _ = viewModel.appResponse {
                if let _ = viewModel.response {
                    headerView
                    navigationStack
                    buttonsView
                } else {
                    homeView
                }
            } else if viewModel.appDataLoading {
                ProgressView()
                    .progressViewStyle(.circular)
            } else {
                Text("Error loading app data")
            }
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
    
    var buttonsView: some View {
        VStack(spacing: 10) {
            if viewModel.currentQuestion == nil && self.viewModel.response?.save.questionResults.isEmpty ?? true {
                Button("Start") {
                    viewModel.navValues.append(.question(viewModel.response!.response.questions.first!))
                    
                }
            }
            actionButtonsView
        }
    }
    
    var actionButtonsView: some View {
        ForEach(viewModel.currentQuestion?.options ?? [], id: \.id) { option in
            Button(option.optionName + " (\(option.grade))") {
                viewModel.actionButtonPressed(option)
            }
        }
    }
    
    var homeView: some View {
        VStack {
            if viewModel.rqStarted {
                ProgressView().progressViewStyle(.circular)
            } else {
                Button("db") {
                    self.viewModel.dbPresenting = true
                }

                Spacer()
                requestEditorView
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
        .frame(height: 44)
    }
    
    var navigationStack: some View {
        NavigationStack(path: $viewModel.navValues) {
            VStack(content: {
                Text("request is ready")
                    .background {
                        ClearBackgroundView()
                    }
            })
            .background {
                ClearBackgroundView()
            }
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
        CollectionView(contentHeight: $viewModel.contentHeight, data: viewModel.collectionData, didSelect: { at in
            viewModel.collectionViewSelected(at: at ?? 0)
        })
        .frame(height: viewModel.contentHeight)
        .opacity(1)
    }
    
    var requestEditorView: some View {
        GeometryReader { proxy in
            ScrollView(.vertical) {
                VStack {
                    Spacer().frame(height: proxy.size.height * 0.8)
                    collectionView
                }
            }
        }
    }
}
