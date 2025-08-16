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
    var duration: TimeInterval {
        if type == .loading {
            return 3
        }
        return 5
    }
    
    struct BakcgroundProperties {
        var blurAlpha: CGFloat? = nil
        var needOval: Bool = true

        var backgroundGradient: NetworkResponse.CategoriesResponse.Categories.Color? = nil
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
    
    var body: some View {
        ZStack(content: {
            primaryGradient
                .opacity(0.8)
                .blur(radius: 20)
            curclesOverlayView
            VStack {
                Spacer()
                    .frame(maxHeight: .infinity)
                HomeIllustrutionView()
                    .tint(.init(uiColor: .init(hex: backgroundColors.topLeft!)!))
                    .foregroundColor(.init(uiColor: .init(hex: backgroundColors.topLeft!)!))

                Spacer()
                    .frame(maxHeight: .infinity)
                Spacer()
                    .frame(maxHeight: .infinity)
                Spacer()
                    .frame(maxHeight: .infinity)
            }
        })
        .blur(radius: blurAlpha)
        .animation(.smooth, value: blurAlpha)
        .ignoresSafeArea(.all)
        .background {
            Color.black
                .ignoresSafeArea(.all)
        }

    }
    
    var primaryGradient: some View {
        let def = defaultBackgroundColors
        return ZStack {

            ZStack {
                LinearGradient(colors: [
                    .init(uiColor: .init(hex: backgroundColors.top ?? def.top!)!),
                    .init(uiColor: .init(hex: backgroundColors.bottom)!)
                ], startPoint: .top, endPoint: .bottom)

                VStack {
                    HStack {
                        RadialGradient(colors: [
                            .init(uiColor: .init(hex: backgroundColors.topLeft ?? def.topLeft!)!),
                            .init(uiColor: .init(hex: backgroundColors.topLeft ?? def.topLeft!)!).opacity(0)
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

                VStack {
                    Spacer()
                        .frame(maxHeight: .infinity)
                    LinearGradient(colors: [
                        .init(uiColor: .init(hex: backgroundColors.left ?? def.left!)!),
                        .init(uiColor: .init(hex: backgroundColors.left ?? def.left!)!).opacity(0),
                        .init(uiColor: .init(hex: backgroundColors.right ?? def.right!)!).opacity(0),
                        .init(uiColor: .init(hex: backgroundColors.right ?? def.right!)!)
                    ], startPoint: .leading, endPoint: .trailing)
                    .padding(.leading, -50)
                    .padding(.leading, -20)
                    .rotationEffect(.degrees(10))
                    Spacer()
                        .frame(maxHeight: .infinity)
                }

                RadialGradient(colors: [
                    .init(uiColor: .init(hex: backgroundColors.top ?? def.top!)!),
                    .init(uiColor: .init(hex: backgroundColors.top ?? def.top!)!).opacity(0)
                ], center: .center, startRadius: 1, endRadius: 100)
                .offset(x: -10, y: -35)
                .opacity(1)

                RadialGradient(colors: [
                    .init(uiColor: .init(hexColor: .lightPink)!),
                    .init(uiColor: .init(hexColor: .lightPink)!).opacity(0)
                ], center: .center, startRadius: 1, endRadius: 100)
                .offset(
                    x: animate ? [-30, -100, -30, 20, -5, 30, 25].randomElement()! : [20, 50, 10, -30].randomElement()!,
                    y: animate ? [40, -100, -20, 20, 50, 30, 25]
                        .randomElement()! : [100, 105, 50, 90, 80, 120]
                        .randomElement()!
                )
                .opacity(properties.needOval ? (animate ? [0.9, 0.8, 0.6, 0.9].randomElement()! : 0.9) : 0)
                .animation(.bouncy(duration: duration)
                    .repeatForever()
                    .delay(0.6),
                           value: animate)

                VStack {
                    Spacer().frame(maxHeight: .infinity)
                    Spacer().frame(maxHeight: .infinity)
                    HStack {
                        Spacer().frame(maxWidth: .infinity)
                        RadialGradient(colors: [
                            .init(uiColor: .init(hex: backgroundColors.bottomRight ?? def.bottomRight!)!),
                            .init(uiColor: .init(hex: backgroundColors.bottomRight ?? def.bottomRight!)!).opacity(0)
                        ], center: .center, startRadius: 1, endRadius: 200)
                        .padding(.trailing, -100)
                        .padding(.bottom, -100)
                        .opacity(1)
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .animation(.smooth, value: backgroundColors.decode)
        }
        .blur(radius: 30)
        .opacity(type == .loading ? 0 : 1)
        .animation(.smooth, value: type)
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

#Preview {
    HomeBackgroundView(
        type: .constant(.regular),
        properties: .constant(.init(blurAlpha: 1))
    )
}
