import SwiftUI

struct HomeView: View {
    @EnvironmentObject var db: LocalDataBaseManager
    @EnvironmentObject private var appService: AppServiceManager
    @StateObject var viewModel: HomeViewModel = .init()
    @StateObject var navigationManager: NavigationManager = .init()

    var body: some View {
        let buttonsHeight = viewModel.buttonsViewHeight
        ZStack {
            VStack(spacing: 0) {
               // navigationStack
                   // .ignoresSafeArea(.all)
                DBCategoriyNavView(selectedType:"Psychopathy")
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
        .background(content: {
            HomeBackgroundView(type: .constant(viewModel.circleType), properties: .constant(viewModel.backgroundProperties))
        })
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
        .onChange(of: viewModel.selectedIDs) { newValue in
            self.viewModel.updateTableData()
        }
        .sheet(isPresented: $viewModel.textPresenting) {
            TextView(text: viewModel.response?.response.textHolder ?? "??", needScroll: true)
        }
        .task(priority: .userInitiated) {
            viewModel.loadAppSettings(db: db)
        }
        .modifier(
            SidebarModifier(
                viewWidth: viewModel.viewWidth,
                targedBackgroundView: SideBarView(),
                disabled: !navigationManager.routs.isEmpty && !viewModel.sheetPresenting
            )
        )
        .background {
            Color.black
                .ignoresSafeArea(.all)
        }
        .environmentObject(navigationManager)
        .onAppear {
            viewModel.navManager = self.navigationManager
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
        let background1 = viewModel.backgroundProperties.backgroundGradient?.topLeft ?? String.HexColor.puroure2Light.rawValue
        let buttonBackground: UIColor = .init(hex: background1)!
        let isLight = buttonBackground.isLight
        let disabled = viewModel.selectedRequest == nil ? false : (viewModel.selectedRequest?.difficulty == nil)
        VStack {
            Spacer()
            Button {
                appService.tutorialManager
                    .removeTypeWhenMatching(.pressGenerate)
                viewModel.primaryButtonPressed(db: db)
            } label: {
                Text(viewModel.response != nil ? "squeeze" : "Start")
                    .foregroundColor(isLight ? .black.opacity(0.7) : .white)
                    .font(.system(size: 28, weight: .regular))
                    .opacity(disabled ? 0.3 : 1)
                    .shadow(radius: 5)
            }
                .padding(.horizontal, 50)
                .frame(height: needButton)
                .frame(maxWidth: .infinity)
                .clipped()
                .background(
                    Color(
                        uiColor: buttonBackground
                    )
                )
                .overlay(content: {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(uiColor: buttonBackground), lineWidth: 2)
                        .shadow(radius: 10)
                })
                .cornerRadius(16)
                .disabled(disabled)
                .foregroundColor(.white.opacity(viewModel.selectedRequest?.difficulty == nil && viewModel.selectedRequest != nil ? 0.5 : 1))
                .animation(.smooth, value: needButton > 0)
                .shadow(
                    color: Color(uiColor: buttonBackground),
                    radius: 20,
                    x: 20, y: 15
                )
                .modifier(TutorialTargetViewModifier(targetType: .pressGenerate))

        }
        .padding(.horizontal, 5)
        .padding(.bottom, 15)
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
                ReadyView(presenter: .init(cancelPressed: {
                    withAnimation {
                        viewModel.response = nil
                        viewModel.rqStarted = false
                    }
                }))

            } else {
                HomeCollectionView()
                    .environmentObject(viewModel)
                    .overlay {
                        VStack {
                            Button("cards") {
                                navigationManager.append(
                                        .cardView(
                                            .init(
                                                properties: .init(
                                                    type: "demo",
                                                    selectedResponseItem: nil,
                                                    data: .demo
                                                ),
                                                completedSqueeze: { selection in

                                        })
)
                                    )
                            }
                            .frame(height: 40)
                            Spacer()
                        }
                    }
            }

        }
        .opacity(navigationManager.routs.isEmpty ? 1 : 0)
        .animation(.smooth, value: navigationManager.routs.isEmpty)
    }

    var navigationStack: some View {
        NavigationStack(path: $navigationManager.routs) {
            homeRoot
            .navigationDestination(for: NavigationRout.self) { navRout in
                navRout.body($viewModel.selectedRequest)
                    .opacity(navigationManager.routs.last == navRout ? 1 : 0)
                    .background {
                        ClearBackgroundView()
                    }
                    .animation(.smooth, value: navigationManager.routs.last == navRout)

            }
            .background {
                ClearBackgroundView()
            }
            .onChange(of: navigationManager.routs) { newValue in
                if newValue.isEmpty && !viewModel.rqStarted {
                    withAnimation {
                        viewModel.selectedRequest = nil
                    }
                }
            }
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                appService.tutorialManager.removeTypeWhenMatching(.waitingForSqueezeCompletion, .generateResult)
            }

        }
        .tint(.white)
        .navigationViewStyle(StackNavigationViewStyle())
        .background {
            ClearBackgroundView()
        }
        
    }
}
