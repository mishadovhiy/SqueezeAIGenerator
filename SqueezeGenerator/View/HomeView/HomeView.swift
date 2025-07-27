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
        .background(content: {
            VStack(spacing: 0) {
                Color.black
                    .ignoresSafeArea(.all)
                    .frame(height: 33, alignment: .top)
//                LinearGradient(
//                    gradient: Gradient(colors: [
//                        .black, .black.opacity(0)
//                    ]),
//                    startPoint: .top,
//                    endPoint: .bottom
//                )
//                .frame(height: 80)
                    
                Spacer()
            }
            .opacity(viewModel.gradientOpacity)//viewModel.gradientOpacity > 0.1 ? viewModel.gradientOpacity * 6 : viewModel.gradientOpacity)
            .animation(.smooth, value: viewModel.scrollPosition.y )

            
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
                    HStack {
                        Button("db") {
                            self.viewModel.dbPresenting = true
                        }
                        Button("cards") {
                            viewModel.navValues.append(.cardView(.init(data: .demo)))
                        }
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
                    .opacity(viewModel.navValues.last == navRout ? 1 : 0)
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
        case .cardView(let properties):
            CardsView(properties)
        }
    }
    
    var collectionView: some View {
        GeometryReader { proxy in
            ScrollView {
                
                LazyVStack(pinnedViews: .sectionHeaders) {
                    Spacer().frame(height: proxy.size.height * 0.4)
                    Section {
                        VStack {
                            Spacer().frame(height: proxy.size.height * 0.2)
                            
                            CollectionView(contentHeight: $viewModel.contentHeight, data: viewModel.collectionData, didSelect: { at in
                                viewModel.collectionViewSelected(at: at ?? 0)
                            })
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
    }
    
    
    
    var collectionHeader: some View {
        VStack {
            ZStack(content: {
                appTitle
                appTitle
                    .foregroundColor(.black)
                    .background(.red)
                    .mask {
                        appTextMask
                    }
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
        .animation(.smooth, value: viewModel.scrollPosition.y)
    }
    
    var appTitle: some View {
        Text("Squeeze generator")
            .multilineTextAlignment(.leading)
            .padding(.horizontal, 15)
            .lineSpacing(0)
            .lineLimit(nil)
            .font(.system(size: 80 * (1 - (viewModel.gradientOpacity >= 0.8 ? 0.8 : viewModel.gradientOpacity)),
                          weight: .bold))
    }
}
