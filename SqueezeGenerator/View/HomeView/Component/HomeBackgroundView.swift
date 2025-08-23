//
//  BackgroundView.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 20.07.2025.
//

import SwiftUI

struct HomeBackgroundView: View {
    @Binding var type: `Type`
    @Binding var properties: BakcgroundProperties

    var body: some View {
        ZStack(content: {
            primaryGradient
                .opacity(0.5 - gradientOpacity)
                .blur(radius: 20 + blurAlpha)

            curclesOverlayView
//            HomeIllustrutionView()
//                .tint(.init(uiColor: .init(hex: backgroundColors.topLeft!)!))
//                .foregroundStyle(
//                    LinearGradient(
//                        colors: [
//                            .init(uiColor: .init(hex: backgroundColors.topLeft!)!),
//                            .init(uiColor: .init(hex: backgroundColors.bottomRight!)!)
//                        ],
//                        startPoint: .topLeading,
//                        endPoint: .bottomTrailing
//                    )
//                )
////                .foregroundColor(.init(uiColor: .init(hex: backgroundColors.topLeft!)!))
//                .scaleEffect(properties.illustrationScale)
//                .animation(.bouncy, value: properties.illustrationScale)
//                .blur(radius: blurAlpha)

        })
//        .blur(radius: blurAlpha)
//        .animation(.smooth, value: blurAlpha)
        .ignoresSafeArea(.all)
        .background {
            Color.black
                .ignoresSafeArea(.all)
        }

    }

    private var defaultBackgroundColors: NetworkResponse.CategoriesResponse.Categories.Color {
        .init(
            tint: nil,
            topLeft: .HexColor.lightPink.rawValue,
            top: .HexColor.puroure2Light.rawValue,
            left: .HexColor.puroure2Light.rawValue,
            right: .HexColor.lightPink.rawValue,
            bottom: .HexColor.purpureLight.rawValue,
            bottomRight: .HexColor.puroure2Light.rawValue
        )
    }

    var backgroundColors: NetworkResponse.CategoriesResponse.Categories.Color {
        properties.backgroundGradient ?? defaultBackgroundColors
    }

    var duration: TimeInterval {
        if type == .loading {
            return 3
        }
        return 5
    }

    var blurAlpha: CGFloat {
        if let alpha = properties.blurAlpha {
            return alpha
        }
        let ignorBlur: [Type] = [.loading, .regular, .topBig, .topRegular]
        if ignorBlur.contains(type) {
            return 0
        }

        return type.isBig || type.isTop  ? 20 : 0
    }

    var gradientOpacity: CGFloat {
        let min = 0.3
        let result = blurAlpha / 100
        return result <= min ? result : min
    }

    var primaryGradient: some View {
        let defaultColor = defaultBackgroundColors
        return ZStack {

            ZStack {
                verticalGradient(defaultColor)

                topLeftGradient(defaultColor)

                horizontalGradient(defaultColor)
//
//                topGradient(defaultColor)


                bottomTrailingGradient(defaultColor)

                circleGradientOverlay

            }
            .animation(.smooth, value: backgroundColors.decode)
        }
        .blur(radius: 30)
        .opacity(type == .loading ? 0 : 1)
        .animation(.smooth, value: type)
    }

    private var circleGradientOverlay: some View {
        RadialGradient(colors: [
            .init(uiColor: .init(hexColor: .lightPink)!),
            .init(uiColor: .init(hexColor: .lightPink)!).opacity(0)
        ], center: .center, startRadius: 1, endRadius: 100)
        .offset(
            x: gradientCirclePosition.x,
            y: gradientCirclePosition.y
        )
        .opacity(properties.needOval ? gradientCircleOpacity : 0)
        .animation(.bouncy(duration: duration),
                   value: gradientCircleOpacity)
        .onAppear {
            animateGradientCircle()
        }
    }

    func animateGradientCircle() {
        withAnimation(.smooth(duration: 6)) {
            gradientCircleOpacity = [0.9, 0.8, 0.6, 0.9].randomElement()!
            gradientCirclePosition = .init(
                x: animate ? [-30, -100, -30, 20, -5, 30, 25].randomElement()! : [20, 50, 10, -30].randomElement()!,
                y: animate ? [40, -100, -20, 20, 50, 30, 25]
                                                           .randomElement()! : [100, 105, 50, 90, 80, 120]
                                                           .randomElement()!)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(6), execute: {
            self.animateGradientCircle()
        })
    }

    @State var gradientCircleOpacity: CGFloat = 0
    @State var gradientCirclePosition: CGPoint = .zero

    func bottomTrailingGradient(_ color: NetworkResponse.CategoriesResponse.Categories.Color) -> some View {
        VStack {
            Spacer().frame(maxHeight: .infinity)
            Spacer().frame(maxHeight: .infinity)
            HStack {
                Spacer().frame(maxWidth: .infinity)
                RadialGradient(colors: [
                    .init(uiColor: .init(hex: backgroundColors.bottomRight ?? color.bottomRight!)!),
                    .init(uiColor: .init(hex: backgroundColors.bottomRight ?? color.bottomRight!)!).opacity(0)
                ], center: .center, startRadius: 1, endRadius: 200)
                .padding(.trailing, -100)
                .padding(.bottom, -100)
                .opacity(1)
                .frame(maxWidth: .infinity)
            }
        }
    }

    func horizontalGradient(_ color: NetworkResponse.CategoriesResponse.Categories.Color) -> some View {
        VStack {
            Spacer()
                .frame(maxHeight: .infinity)
            LinearGradient(colors: [
                .init(uiColor: .init(hex: backgroundColors.left ?? color.left!)!),
                .init(uiColor: .init(hex: backgroundColors.left ?? color.left!)!).opacity(0),
                .init(uiColor: .init(hex: backgroundColors.right ?? color.right!)!).opacity(0),
                .init(uiColor: .init(hex: backgroundColors.right ?? color.right!)!)
            ], startPoint: .leading, endPoint: .trailing)
            .padding(.leading, -50)
            .padding(.leading, -20)
            .rotationEffect(.degrees(10))
            Spacer()
                .frame(maxHeight: .infinity)
        }
    }

    func topGradient(_ color: NetworkResponse.CategoriesResponse.Categories.Color) -> some View {
        RadialGradient(colors: [
            .init(uiColor: .init(hex: backgroundColors.top ?? color.top!)!),
            .init(uiColor: .init(hex: backgroundColors.top ?? color.top!)!).opacity(0)
        ], center: .center, startRadius: 1, endRadius: 100)
        .offset(x: -10, y: -35)
        .opacity(1)
    }

    func topLeftGradient(_ color: NetworkResponse.CategoriesResponse.Categories.Color) -> some View {
        VStack {
            HStack {
                RadialGradient(colors: [
                    .init(uiColor: .init(hex: backgroundColors.topLeft ?? color.topLeft!)!),
                    .init(uiColor: .init(hex: backgroundColors.topLeft ?? color.topLeft!)!).opacity(0)
                ], center: .center, startRadius: 1, endRadius: 200)
                .padding(.leading, -100)
                .padding(.top, -120)
                .opacity(1)
                .frame(maxWidth: .infinity)
                Spacer().frame(maxWidth: .infinity)
            }
            Spacer().frame(maxHeight: .infinity)
            Spacer().frame(maxHeight: .infinity)
        }
    }

    func verticalGradient(_ defaultColor: NetworkResponse.CategoriesResponse.Categories.Color) -> some View {
        LinearGradient(colors: [
            .init(uiColor: .init(hex: backgroundColors.top ?? defaultColor.top!)!),
            .init(uiColor: .init(hex: backgroundColors.bottom)!)
        ], startPoint: .top, endPoint: .bottom)
    }

    let gradient: AngularGradient = .init(gradient: .init(colors: [.pink, .purple, .red, .yellow, .orange, .blue]), center: .center)
    @State var animate: Bool = false
    var circleScale: CGFloat {
        if type == .loading {
            return animate ? 0.6 : 0.25
        }
        return animate ? 1.5 : 0.75
    }
    var opacity: CGFloat {
        animate ? (type == .loading ? 0 : (type.isTop ? 0 : 0)) : 1
    }
    var angle: Angle {
        .degrees(animate ? 0 : 360)
    }
    @State var circleCount: Int = 4
    
    @ViewBuilder
    var curclesOverlayView: some View {
        VStack {
            Spacer()
                .frame(maxHeight: (type.isTop ? (type != .topRegular ? .zero : 150) : .infinity))
                .animation(.bouncy, value: type)
            Spacer()
                .frame(maxHeight: type.isTop ? 0 : .infinity)
                .animation(.bouncy, value: type)
            circles
            Spacer()
                .frame(maxHeight: .infinity)
            Spacer()
                .frame(maxHeight: .infinity)
        }
    }
    
    var circles: some View {
        ZStack {
            ForEach(0..<circleCount, id: \.self) { i in
                Circle()
                    .stroke(gradient, lineWidth: 8)
                    .scaleEffect(circleScale)
                    .opacity(opacity)
                    .rotation3DEffect(angle, axis: self.axis(i))
                    .shadow(color: .blue.opacity(0.8),
                            radius: 10)
                    .hueRotation(angle)
                    .animation(.easeInOut(duration: duration)
                        .repeatForever()
                        .delay(Double(i) * 0.4),
                               value: animate)
                    .blur(radius: type == .loading ? 0 : 10)
            }
        }
        .frame(width: type == .big ? 550 : 150)
        .animation(.bouncy, value: type)
        .aspectRatio(1, contentMode: .fit)
        .onAppear {
            animate.toggle()
        }
        .onChange(of: type) { newValue in
            if type != holder {
                holder = type
                animate = false
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5), execute: {
                    animate = true
                })
            }
            
        }
    }
    @State var holder: Type?
    func axis(_ i: Int) -> (x: CGFloat, y: CGFloat, z: CGFloat) {
        switch i {
        case 0: (x: 1, y: 0, z: 0)
        case 1: (x: 0, y: 1, z: 1)
        case 2: (x: 1, y: 0, z: 1)
        default: (x: 1, y: 0, z: 0)
        }
    }

}

extension HomeBackgroundView {
    enum `Type`:String {
        case big, loading, regular, topRegular, topBig
        static let `default`: Self = .regular

        var isTop: Bool {
            rawValue.lowercased().contains("top")
        }

        var isBig: Bool {
            rawValue.lowercased().contains("big")
        }
    }

    struct BakcgroundProperties {
        var blurAlpha: CGFloat? = nil
        var needOval: Bool = true
        var illustrationScale: CGFloat = 1
        var backgroundGradient: NetworkResponse.CategoriesResponse.Categories.Color? = nil
    }
}

#Preview {
    HomeBackgroundView(
        type: .constant(.regular),
        properties: .constant(.init(blurAlpha: 1))
    )
}
