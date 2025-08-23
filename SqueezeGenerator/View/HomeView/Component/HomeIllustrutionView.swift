//
//  HomeIllustrutionView.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 16.08.2025.
//

import SwiftUI

struct HomeIllustrutionView: View {
    let width: CGFloat = 365
    @State var skyData: BottomSky = .init()
    @State var skyPos: CGFloat = 0.5

    var body: some View {
        VStack {
            Spacer()
                .frame(maxHeight: .infinity)
            HStack {
                Spacer()
                ZStack {
                    maskedImage
                        .mask {
                            Circle()
                                .aspectRatio(1, contentMode: .fit)
                        }
                    notMaskedComponents
                }
                .shadow(radius: 10)

                Spacer()

            }
            .frame(maxWidth: .infinity)
            .frame(height: width)
            Spacer().frame(maxHeight: .infinity)
        }
    }

    private var leftSky: some View {
        HStack {
            HStack {
                Spacer()
                    .frame(maxWidth: .infinity)

                VStack {
                    sun
                    Spacer()
                        .frame(maxHeight: .infinity)
                        .overlay {
                            VStack {
                                VStack {
                                    Spacer().frame(maxHeight: .infinity)
                                    HStack {
                                        moon(.first)
                                            .offset(x: -30)
                                        Spacer().frame(maxWidth: .infinity)
                                    }
                                    .frame(maxWidth: .infinity)
                                    Spacer().frame(maxHeight: .infinity)
                                }
                                .frame(maxHeight: .infinity)
                                Spacer().frame(maxHeight: .infinity)
                            }
                        }
                }
                .overlay {
                    VStack {
                        Spacer()
                            .frame(maxHeight: .infinity)

                    }
                }
            }
            Color.clear
                .overlay {
                    ZStack {
                        HStack {
                            VStack {
                                VStack {
                                    Spacer().frame(maxHeight: .infinity)
                                    moon(.second)
                                    Spacer().frame(maxHeight: .infinity)
                                }
                                .frame(maxHeight: .infinity)
                                Spacer().frame(maxHeight: .infinity)
                            }
                            Spacer()
                                .frame(maxWidth: .infinity)
                        }

                        .frame(maxHeight: .infinity)
                        .padding(.leading, 10)
                        VStack {
                            VStack {
                                Spacer()
                                    .frame(maxHeight: .infinity)
                                moon(.third)
                            }

                            .frame(maxHeight: .infinity)
                            Spacer()
                                .frame(maxHeight: .infinity)
                        }
                    }

                    .frame(maxHeight: .infinity)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxHeight: .infinity)

    }

    public var notMaskedComponents: some View {
        VStack {
            HStack {
                VStack(spacing: 14) {
                    HStack {
                        HStack {
                            Spacer()
                                .frame(maxWidth: .infinity)
                        }
                        .frame(maxWidth: .infinity)
                        Spacer()
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .frame(height: 220, alignment: .top)
            .overlay {
                leftSky
            }
            Spacer().frame(maxWidth: .infinity)
        }
    }

    public var maskedImage: some View {
        ZStack {
            buildings
            skys
        }
    }
}

fileprivate extension HomeIllustrutionView {
    var sun: some View {
        ZStack {
            Image(.HomeIllustration.City1.Components.oval)
                .resizable()
                .frame(width: 50, height: 50)
            Image(.HomeIllustration.City1.Components.sunLight)
                .resizable()
                .aspectRatio(1, contentMode: .fit)
        }
        .frame(height: 96)
    }

    func moon(_ type: Moon) -> some View {
        Image(.HomeIllustration.City1.Components.oval)
            .resizable()
            .frame(width: type.size,
                   height: type.size)
    }

    var buildings: some View {
        VStack {
            Spacer().frame(height: 100)
            HStack {
                Spacer()
                ZStack {
                    VStack {
                        Spacer().frame(maxHeight: .infinity)
                        bigBuildings
                    }
                }
                .frame(alignment: .bottom)
                Spacer()
            }
        }
    }

    var skys: some View {
        VStack {
            Spacer()
                .frame(maxHeight: .infinity)
            HStack {
                Image("homeIllustration/city1/sky/\(skyData.imageSuffix)")
                    .offset(x: width * skyData.positionMultiplier)
                    .animation(.smooth(duration: 2), value: skyData.positionMultiplier)
                    .opacity(Double(skyData.opacity))
                Spacer()
                    .frame(maxWidth: .infinity)
            }
            .frame(height: 68)
        }
        .onAppear {
            addSky()
        }
    }

    func addSky() {
        print("tgerfwda")
        self.skyData.opacity = 1
        let duration: TimeInterval = 10//skyData.animationDuration
        withAnimation(.smooth(duration: 10)) {
            skyData.positionMultiplier = -0.6
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 10, execute: {
            skyData.opacity = 0
            withAnimation(.smooth(duration: 1)) {
                skyData = .init()
//                skyPos = 1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.addSky()
                    }
        })
    }
}

fileprivate extension HomeIllustrutionView {
    var bigBuildings: some View {
        HStack(alignment: .bottom, spacing: .zero) {
            VStack {
                Spacer().frame(maxHeight: .infinity)
                Image(.HomeIllustration.City1.Building._1)
                    .resizable()
                    .scaledToFit()
                    .padding(.top, -20)
                    .overlay {
                        HStack {
                            Spacer()
                                .frame(maxWidth: .infinity)
                            Spacer()
                                .frame(maxWidth: .infinity)
                            Image(.HomeIllustration.City1.Building._1Inside)
                                .resizable()
                                .scaledToFit()
                                .padding(.top, 20)
                            Spacer()
                                .frame(maxWidth: .infinity)
                        }
                    }
            }
            Image(.HomeIllustration.City1.Building._2)
                .resizable()
                .scaledToFit()
                .overlay {
                    VStack {
                        Spacer().frame(maxHeight: .infinity)
                        HStack {
                            Image(.HomeIllustration.City1.Building._2Inside)
                                .resizable()
                                .scaledToFit()
                            Image(.HomeIllustration.City1.Building._3Inside)
                                .resizable()
                                .scaledToFit()
                        }
                    }
                }

            VStack {
                Spacer().frame(maxHeight: .infinity)
                Image(.HomeIllustration.City1.Building._3)
                    .resizable()
                    .scaledToFit()
            }
            .offset(x: -7)
        }
        .shadow(radius: 10)

        .frame(height: 240, alignment: .bottom)
    }
}

fileprivate extension HomeIllustrutionView {
    enum Moon {
        case first, second
        case third

        var size: CGFloat {
            switch self {
            case .first: 20
            case .second: 25
            case .third: 40
            }
        }
    }
}

extension HomeIllustrutionView {
    struct BottomSky {
        let imageSuffix: Int
        var positionMultiplier: CGFloat
        var opacity: Int
        let animationDuration: TimeInterval

        init() {
            self.imageSuffix = Int.random(in: 1..<Configuration.AssetHelper.HomeIllustration.maxSky)
            self.positionMultiplier = 1
            self.opacity = 0
            self.animationDuration = .random(in: 5..<12)
        }
    }
}
