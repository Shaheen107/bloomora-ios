import SwiftUI

// MARK: - Color Extensions
extension FlowerSpecies {
    var bloomColor: Color {
        switch self {
        case .sunflower: Color(red: 0.98, green: 0.77, blue: 0.04)
        case .blueBloom: Color(red: 0.49, green: 0.68, blue: 0.97)
        case .lily:      Color(red: 0.94, green: 0.98, blue: 1.00)
        case .rose:      Color(red: 0.79, green: 0.20, blue: 0.20)
        }
    }
}

extension DrinkKind {
    var cardTint: Color {
        switch self {
        case .water:   Color(red: 0.86, green: 0.91, blue: 0.96)
        case .milk:    Color.white
        case .coffee:  Color(red: 0.89, green: 0.86, blue: 0.86)
        case .drink:   Color(red: 0.96, green: 0.89, blue: 0.84)
        case .milkTea: Color(red: 0.89, green: 0.88, blue: 0.84)
        case .tea:     Color(red: 0.86, green: 0.94, blue: 0.89)
        case .other:   Color(red: 0.83, green: 0.92, blue: 0.94)
        }
    }

    var symbolName: String {
        switch self {
        case .water:   "drop"
        case .milk:    "cup.and.saucer.fill"
        case .coffee:  "cup.and.saucer"
        case .drink:   "takeoutbag.and.cup.and.straw"
        case .milkTea: "takeoutbag.and.cup.and.straw.fill"
        case .tea:     "leaf"
        case .other:   "sparkles"
        }
    }
}

// MARK: - Progress Track (matches screenshot: 4 hand-drawn stage icons on a line)

struct BloomoraProgressTrack: View {
    let stage: FlowerStage

    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width

            ZStack {
                // Base line
                Path { path in
                    path.move(to: CGPoint(x: 14, y: proxy.size.height / 2))
                    path.addLine(to: CGPoint(x: w - 14, y: proxy.size.height / 2 - 1))
                }
                .stroke(Color.black.opacity(0.75), style: StrokeStyle(lineWidth: 2.2, lineCap: .round))

                HStack {
                    MiniGrowthMark(stage: .seed,   isActive: stage.rawValue >= FlowerStage.seed.rawValue)
                    Spacer()
                    MiniGrowthMark(stage: .sprout, isActive: stage.rawValue >= FlowerStage.sprout.rawValue)
                    Spacer()
                    MiniGrowthMark(stage: .bud,    isActive: stage.rawValue >= FlowerStage.bud.rawValue)
                    Spacer()
                    MiniGrowthMark(stage: .bloom,  isActive: stage.rawValue >= FlowerStage.bloom.rawValue)
                }
                .padding(.horizontal, 6)
            }
        }
    }
}

private struct MiniGrowthMark: View {
    let stage: FlowerStage
    let isActive: Bool

    var body: some View {
        ZStack {
            switch stage {
            case .seed:
                Capsule()
                    .fill(isActive ? Color(red: 0.48, green: 0.72, blue: 0.42) : Color.white)
                    .frame(width: 16, height: 9)
                    .rotationEffect(.degrees(-12))
                    .overlay(
                        Capsule()
                            .stroke(Color.black, lineWidth: 1.5)
                            .rotationEffect(.degrees(-12))
                    )

            case .sprout:
                VStack(spacing: 0) {
                    Capsule()
                        .fill(Color.black)
                        .frame(width: 2, height: 9)
                    HStack(spacing: 2) {
                        Capsule()
                            .fill(isActive ? Color(red: 0.68, green: 0.84, blue: 0.62) : .white)
                            .frame(width: 10, height: 5)
                            .rotationEffect(.degrees(-28))
                            .overlay(Capsule().stroke(.black, lineWidth: 1))
                        Capsule()
                            .fill(isActive ? Color(red: 0.68, green: 0.84, blue: 0.62) : .white)
                            .frame(width: 10, height: 5)
                            .rotationEffect(.degrees(28))
                            .overlay(Capsule().stroke(.black, lineWidth: 1))
                    }
                }
                .frame(width: 18, height: 18)

            case .bud:
                VStack(spacing: 0) {
                    Capsule()
                        .fill(Color.black)
                        .frame(width: 2, height: 8)
                    TeardropShape()
                        .fill(isActive ? Color(red: 0.85, green: 0.85, blue: 0.85) : .white)
                        .frame(width: 8, height: 12)
                        .overlay(TeardropShape().stroke(.black, lineWidth: 1.2))
                }
                .frame(width: 18, height: 20)

            case .bloom:
                ZStack {
                    ForEach(0..<6, id: \.self) { i in
                        Capsule()
                            .fill(isActive ? Color(red: 0.92, green: 0.90, blue: 0.70) : .white)
                            .frame(width: 6, height: 11)
                            .offset(y: -4)
                            .rotationEffect(.degrees(Double(i) * 60))
                            .overlay(
                                Capsule()
                                    .stroke(.black, lineWidth: 0.9)
                                    .frame(width: 6, height: 11)
                                    .offset(y: -4)
                                    .rotationEffect(.degrees(Double(i) * 60))
                            )
                    }
                    Circle()
                        .fill(.white)
                        .frame(width: 5, height: 5)
                        .overlay(Circle().stroke(.black, lineWidth: 1))
                }
                .frame(width: 18, height: 18)
            }
        }
    }
}

// MARK: - BotanicalSceneView (uses image assets)
enum BotanicalSceneStyle {
    case standard
    case rooted
}

struct BotanicalSceneView: View {
    let species: FlowerSpecies
    let stage: FlowerStage
    var style: BotanicalSceneStyle = .standard

    var body: some View {
        GeometryReader { proxy in
            if style == .rooted, let plantAssetName {
                rootedScene(in: proxy, plantAssetName: plantAssetName)
            } else {
                standardScene(in: proxy)
            }
        }
    }

    private func standardScene(in proxy: GeometryProxy) -> some View {
        ZStack(alignment: .bottom) {
            Image(assetName)
                .resizable()
                .interpolation(.high)
                .scaledToFit()
                .frame(
                    maxWidth: proxy.size.width * widthFactor,
                    maxHeight: proxy.size.height * heightFactor
                )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }

    private func rootedScene(in proxy: GeometryProxy, plantAssetName: String) -> some View {
        let rootHeight = proxy.size.width * rootAspectRatio
        let rootBottomInset = rootHeight * rootBottomInsetRatio
        let rootTopAnchor = rootHeight - rootBottomInset

        return ZStack(alignment: .bottom) {
            Image("RootImg")
                .resizable()
                .interpolation(.high)
                .scaledToFit()
                .frame(width: proxy.size.width)
                .offset(y: rootBottomInset)

            Image(plantAssetName)
                .resizable()
                .interpolation(.high)
                .scaledToFit()
                .frame(
                    maxWidth: proxy.size.width * rootedPlantWidthFactor,
                    maxHeight: max(proxy.size.height - rootTopAnchor + rootJoinOverlap, 0),
                    alignment: .bottom
                )
                .offset(y: -(rootTopAnchor - rootJoinOverlap))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }

    private var assetName: String {
        switch (species, stage) {
        case (_, .seed), (_, .sprout):       "FlowerSeed"
        case (.sunflower, .bud):             "FlowerSunflowerBud"
        case (.sunflower, .bloom):           "FlowerSunflowerBloom"
        case (.blueBloom, .bud),
             (.blueBloom, .bloom):           "FlowerBlueBloom"
        case (.lily, .bud),
             (.lily, .bloom):                "FlowerLilyBud"
        case (.rose, .bud),
             (.rose, .bloom):                "FlowerRoseBud"
        }
    }

    private var plantAssetName: String? {
        switch (species, stage) {
        case (.sunflower, .seed), (.sunflower, .sprout):
            "FlowerSeedPlant"
        case (.sunflower, .bud):
            "FlowerSunflowerBudPlant"
        case (.sunflower, .bloom):
            "FlowerSunflowerBloomPlant"
        default:
            nil
        }
    }

    private var widthFactor: CGFloat {
        switch stage {
        case .seed, .sprout:  0.88
        case .bud:            0.90
        case .bloom:          species == .sunflower ? 0.92 : 0.88
        }
    }

    private var rootedPlantWidthFactor: CGFloat {
        switch stage {
        case .seed, .sprout:  0.84
        case .bud:            0.90
        case .bloom:          0.92
        }
    }

    private var heightFactor: CGFloat {
        switch stage {
        case .seed, .sprout: 0.74
        case .bud:           0.92
        case .bloom:         0.94
        }
    }

    private var rootAspectRatio: CGFloat { 148.0 / 600.0 }
    private var rootBottomInsetRatio: CGFloat { 12.0 / 148.0 }
    private var rootJoinOverlap: CGFloat { 3 }
}

// MARK: - Ambient Background Backdrop
struct AmbientFlowerBackdrop: View {
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                // Top-right green flower blob
                FlowerOutline(petals: 8)
                    .stroke(Color(red: 0.97, green: 0.69, blue: 0.70).opacity(0.45), lineWidth: 2)
                    .frame(
                        width:  proxy.size.width * 0.72,
                        height: proxy.size.width * 0.72
                    )
                    .offset(x:  proxy.size.width * 0.34, y: -proxy.size.height * 0.02)

                FlowerOutline(petals: 8)
                    .fill(Color(red: 0.87, green: 0.94, blue: 0.89))
                    .frame(
                        width:  proxy.size.width * 0.70,
                        height: proxy.size.width * 0.70
                    )
                    .offset(x: proxy.size.width * 0.38, y: proxy.size.height * 0.02)

                // Bottom-left rounded rect blob
                RoundedRectangle(cornerRadius: 40, style: .continuous)
                    .fill(Color(red: 0.86, green: 0.90, blue: 0.95).opacity(0.55))
                    .frame(
                        width:  proxy.size.width * 0.54,
                        height: proxy.size.width * 0.54
                    )
                    .rotationEffect(.degrees(12))
                    .offset(x: -proxy.size.width * 0.42, y: proxy.size.height * 0.38)

                RoundedRectangle(cornerRadius: 34, style: .continuous)
                    .stroke(Color(red: 0.77, green: 0.83, blue: 0.91), lineWidth: 2)
                    .frame(
                        width:  proxy.size.width * 0.44,
                        height: proxy.size.width * 0.44
                    )
                    .rotationEffect(.degrees(18))
                    .offset(x: -proxy.size.width * 0.36, y: proxy.size.height * 0.45)
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: - Shapes
struct FlowerOutline: Shape {
    let petals: Int

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center      = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) * 0.42
        let innerRadius = outerRadius * 0.58

        for i in 0..<petals {
            let angle = (Double(i) / Double(petals)) * .pi * 2
            let point = CGPoint(
                x: center.x + cos(angle) * outerRadius,
                y: center.y + sin(angle) * outerRadius
            )
            let petalRect = CGRect(
                x: point.x - innerRadius * 0.62,
                y: point.y - innerRadius,
                width:  innerRadius * 1.24,
                height: innerRadius * 2
            )
            path.addEllipse(in: petalRect)
        }
        return path
    }
}

struct LeafShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.midY),
            control: CGPoint(x: rect.midX, y: rect.minY - rect.height * 0.3)
        )
        path.addQuadCurve(
            to: CGPoint(x: rect.minX, y: rect.midY),
            control: CGPoint(x: rect.midX, y: rect.maxY + rect.height * 0.3)
        )
        return path
    }
}

struct TeardropShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.midY),
            control: CGPoint(x: rect.maxX, y: rect.minY + rect.height * 0.18)
        )
        path.addQuadCurve(
            to: CGPoint(x: rect.midX, y: rect.maxY),
            control: CGPoint(x: rect.maxX, y: rect.maxY - rect.height * 0.16)
        )
        path.addQuadCurve(
            to: CGPoint(x: rect.minX, y: rect.midY),
            control: CGPoint(x: rect.minX, y: rect.maxY - rect.height * 0.16)
        )
        path.addQuadCurve(
            to: CGPoint(x: rect.midX, y: rect.minY),
            control: CGPoint(x: rect.minX, y: rect.minY + rect.height * 0.18)
        )
        return path
    }
}
