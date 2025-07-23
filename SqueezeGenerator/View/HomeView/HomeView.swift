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
        .animation(.smooth, value: viewModel.response != nil && viewModel.appResponse != nil)
        .overlay {
            networkResponseView
        }
        .opacity(viewModel.dbPresenting ? 0 : 1)
        .animation(.smooth(duration: 1.2), value: viewModel.dbPresenting)
        .background(content: {
            HomeBackgroundView(type: .constant(viewModel.circleType))
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
        if viewModel.currentQuestion == nil && self.viewModel.response?.save.questionResults.isEmpty ?? true && viewModel.rqStarted && !viewModel.requestLoading {
            Button("Start") {
                viewModel.navValues.append(.question(viewModel.response!.response.questions.first!))
            }
            .padding(.horizontal, 50)
            .padding(.vertical, 10)
            .background(.red)
            .cornerRadius(8)
            
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
        .frame(height: viewModel.selectedRequest != nil ? 44 : 0)
        .animation(.smooth, value: viewModel.selectedRequest != nil)
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
                            viewModel.selectedRequest = nil
                        }
                    }

                } else {
                    Button("db") {
                        self.viewModel.dbPresenting = true
                    }
                    Spacer()
                    collectionView
                }
                
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
        case .requestToGenerateParameters(let request):
            RequestParametersView(request: request) { request in
                withAnimation {
                    viewModel.navValues.append(.empty)
                    viewModel.selectedRequest = request
                    viewModel.startGenerationRequest()
                }
            }
        case .requestGenerated:
            ReadyView(cancelPressed:{
                withAnimation {
                    viewModel.navValues.removeAll()
                    viewModel.selectedRequest = nil
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
