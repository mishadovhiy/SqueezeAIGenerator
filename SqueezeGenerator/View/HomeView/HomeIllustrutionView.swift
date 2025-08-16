//
//  HomeIllustrutionView.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 16.08.2025.
//

import SwiftUI

struct HomeIllustrutionView: View {
    var body: some View {
        HStack {
            Spacer()
            ZStack {
                maskedImage
                    .mask {
                        Circle()
                            .aspectRatio(1, contentMode: .fit)
                            .padding(.bottom, -20)


                    }
                notMaskedComponents
            }
            .shadow(radius: 10)

            Spacer()

        }
        .frame(maxWidth: .infinity)
        .frame(height: 365)
        .tint(.black)
        .foregroundColor(.black)
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

                    VStack {
                        Spacer()
                            .frame(maxHeight: .infinity)
                        insideBuildings
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
                Spacer()
                    .frame(maxWidth: .infinity)
                Spacer()
                    .frame(maxWidth: .infinity)
                Spacer()
                    .frame(maxWidth: .infinity)
                Image(.HomeIllustration.City1.Sky._1)
                Spacer()
                    .frame(maxWidth: .infinity)
            }
            .frame(height: 68)
        }
    }
}

fileprivate extension HomeIllustrutionView {
    var bigBuildings: some View {
        HStack(alignment: .bottom) {
            Image(.HomeIllustration.City1.Building._1)
                .resizable()
                .scaledToFit()
            Image(.HomeIllustration.City1.Building._2)
                .resizable()
                .scaledToFit()

            Image(.HomeIllustration.City1.Building._3)
                .resizable()
                .scaledToFit()
        }
        .shadow(radius: 10)

        .frame(height: 240, alignment: .bottom)
    }

    var insideBuildings: some View {
        HStack(alignment: .bottom) {
            Image(.HomeIllustration.City1.Building._1Inside)
                .resizable()
                .scaledToFit()
            Image(.HomeIllustration.City1.Building._2Inside)
                .resizable()
                .scaledToFit()

            Image(.HomeIllustration.City1.Building._3Inside)
                .resizable()
                .scaledToFit()

            Image(.HomeIllustration.City1.Building._4Inside)
                .resizable()
                .scaledToFit()
        }
        .shadow(radius: 5)

        .frame(height:150, alignment: .bottom)
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
