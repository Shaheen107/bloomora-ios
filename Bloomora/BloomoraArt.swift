import UIKit

enum BotanicalSceneStyle {
    case standard
    case rooted
}

extension FlowerSpecies {
    var bloomColor: UIColor {
        switch self {
        case .sunflower:
            UIColor(red: 0.98, green: 0.77, blue: 0.04)
        case .blueBloom:
            UIColor(red: 0.49, green: 0.68, blue: 0.97)
        case .lily:
            UIColor(red: 0.94, green: 0.98, blue: 1.00)
        case .rose:
            UIColor(red: 0.79, green: 0.20, blue: 0.20)
        }
    }
}

extension DrinkKind {
    var cardTint: UIColor {
        switch self {
        case .water:
            UIColor(red: 0.86, green: 0.91, blue: 0.96)
        case .milk:
            .white
        case .coffee:
            UIColor(red: 0.89, green: 0.86, blue: 0.86)
        case .drink:
            UIColor(red: 0.96, green: 0.89, blue: 0.84)
        case .milkTea:
            UIColor(red: 0.89, green: 0.88, blue: 0.84)
        case .tea:
            UIColor(red: 0.86, green: 0.94, blue: 0.89)
        case .other:
            UIColor(red: 0.83, green: 0.92, blue: 0.94)
        }
    }

    var assetName: String {
        switch self {
        case .water:
            "water"
        case .milk:
            "milk"
        case .coffee:
            "coffee"
        case .drink:
            "drink"
        case .milkTea:
            "milkTea"
        case .tea:
            "tea"
        case .other:
            "Other"
        }
    }
}

final class BloomoraProgressTrackView: UIView {
    var stage: FlowerStage = .seed {
        didSet { setNeedsDisplay() }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isOpaque = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        let y = rect.midY
        let linePath = UIBezierPath()
        linePath.move(to: CGPoint(x: 14, y: y))
        linePath.addLine(to: CGPoint(x: rect.width - 14, y: y - 1))
        UIColor.black.withAlphaComponent(0.75).setStroke()
        linePath.lineWidth = 2.2
        linePath.lineCapStyle = .round
        linePath.stroke()

        let usableWidth = rect.width - 12
        let positions = [
            CGPoint(x: 6 + usableWidth * 0.00, y: y),
            CGPoint(x: 6 + usableWidth * 0.333, y: y),
            CGPoint(x: 6 + usableWidth * 0.666, y: y),
            CGPoint(x: 6 + usableWidth * 1.00, y: y)
        ]

        drawSeed(at: positions[0], active: stage.rawValue >= FlowerStage.seed.rawValue, in: context)
        drawSprout(at: positions[1], active: stage.rawValue >= FlowerStage.sprout.rawValue, in: context)
        drawBud(at: positions[2], active: stage.rawValue >= FlowerStage.bud.rawValue, in: context)
        drawBloom(at: positions[3], active: stage.rawValue >= FlowerStage.bloom.rawValue, in: context)
    }

    private func drawSeed(at center: CGPoint, active: Bool, in context: CGContext) {
        context.saveGState()
        context.translateBy(x: center.x, y: center.y)
        context.rotate(by: -CGFloat.degreesToRadians(12))

        let rect = CGRect(x: -8, y: -4.5, width: 16, height: 9)
        let capsule = UIBezierPath(roundedRect: rect, cornerRadius: 4.5)
        (active ? UIColor(red: 0.48, green: 0.72, blue: 0.42) : .white).setFill()
        capsule.fill()
        UIColor.black.setStroke()
        capsule.lineWidth = 1.5
        capsule.stroke()
        context.restoreGState()
    }

    private func drawSprout(at center: CGPoint, active: Bool, in context: CGContext) {
        context.saveGState()
        context.translateBy(x: center.x, y: center.y)

        let stemPath = UIBezierPath()
        stemPath.move(to: CGPoint(x: 0, y: 7))
        stemPath.addLine(to: CGPoint(x: 0, y: -2))
        UIColor.black.setStroke()
        stemPath.lineWidth = 2
        stemPath.lineCapStyle = .round
        stemPath.stroke()

        drawLeaf(
            rect: CGRect(x: -10, y: -6, width: 10, height: 5),
            rotation: -CGFloat.degreesToRadians(28),
            fill: active ? UIColor(red: 0.68, green: 0.84, blue: 0.62) : .white,
            in: context
        )
        drawLeaf(
            rect: CGRect(x: 0, y: -6, width: 10, height: 5),
            rotation: CGFloat.degreesToRadians(28),
            fill: active ? UIColor(red: 0.68, green: 0.84, blue: 0.62) : .white,
            in: context
        )

        context.restoreGState()
    }

    private func drawBud(at center: CGPoint, active: Bool, in context: CGContext) {
        context.saveGState()
        context.translateBy(x: center.x, y: center.y)

        let stemPath = UIBezierPath()
        stemPath.move(to: CGPoint(x: 0, y: 8))
        stemPath.addLine(to: CGPoint(x: 0, y: 0))
        UIColor.black.setStroke()
        stemPath.lineWidth = 2
        stemPath.lineCapStyle = .round
        stemPath.stroke()

        let dropRect = CGRect(x: -4, y: -12, width: 8, height: 12)
        let dropPath = teardropPath(in: dropRect)
        (active ? UIColor(red: 0.85, green: 0.85, blue: 0.85) : .white).setFill()
        dropPath.fill()
        UIColor.black.setStroke()
        dropPath.lineWidth = 1.2
        dropPath.stroke()

        context.restoreGState()
    }

    private func drawBloom(at center: CGPoint, active: Bool, in context: CGContext) {
        context.saveGState()
        context.translateBy(x: center.x, y: center.y)

        for index in 0..<6 {
            context.saveGState()
            context.rotate(by: CGFloat.degreesToRadians(Double(index) * 60))
            let petalRect = CGRect(x: -3, y: -10, width: 6, height: 11)
            let petalPath = UIBezierPath(roundedRect: petalRect, cornerRadius: 3)
            (active ? UIColor(red: 0.92, green: 0.90, blue: 0.70) : .white).setFill()
            petalPath.fill()
            UIColor.black.setStroke()
            petalPath.lineWidth = 0.9
            petalPath.stroke()
            context.restoreGState()
        }

        let centerPath = UIBezierPath(ovalIn: CGRect(x: -2.5, y: -2.5, width: 5, height: 5))
        UIColor.white.setFill()
        centerPath.fill()
        UIColor.black.setStroke()
        centerPath.lineWidth = 1
        centerPath.stroke()

        context.restoreGState()
    }

    private func drawLeaf(rect: CGRect, rotation: CGFloat, fill: UIColor, in context: CGContext) {
        context.saveGState()
        context.translateBy(x: rect.midX, y: rect.midY)
        context.rotate(by: rotation)

        let path = UIBezierPath(roundedRect: CGRect(x: -rect.width / 2, y: -rect.height / 2, width: rect.width, height: rect.height), cornerRadius: rect.height / 2)
        fill.setFill()
        path.fill()
        UIColor.black.setStroke()
        path.lineWidth = 1
        path.stroke()

        context.restoreGState()
    }

    private func teardropPath(in rect: CGRect) -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.midY),
            controlPoint: CGPoint(x: rect.maxX, y: rect.minY + rect.height * 0.18)
        )
        path.addQuadCurve(
            to: CGPoint(x: rect.midX, y: rect.maxY),
            controlPoint: CGPoint(x: rect.maxX, y: rect.maxY - rect.height * 0.16)
        )
        path.addQuadCurve(
            to: CGPoint(x: rect.minX, y: rect.midY),
            controlPoint: CGPoint(x: rect.minX, y: rect.maxY - rect.height * 0.16)
        )
        path.addQuadCurve(
            to: CGPoint(x: rect.midX, y: rect.minY),
            controlPoint: CGPoint(x: rect.minX, y: rect.minY + rect.height * 0.18)
        )
        return path
    }
}

final class BotanicalSceneView: UIView {
    var species: FlowerSpecies {
        didSet { updateScene() }
    }

    var stage: FlowerStage {
        didSet { updateScene() }
    }

    var style: BotanicalSceneStyle {
        didSet { updateScene() }
    }

    private let rootImageView = UIImageView().useAutoLayout()
    private let plantImageView = UIImageView().useAutoLayout()

    init(species: FlowerSpecies, stage: FlowerStage, style: BotanicalSceneStyle = .standard) {
        self.species = species
        self.stage = stage
        self.style = style
        super.init(frame: .zero)
        configure()
        updateScene()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutScene()
    }

    private func configure() {
        clipsToBounds = true
        backgroundColor = .clear

        rootImageView.contentMode = .scaleAspectFit
        plantImageView.contentMode = .scaleAspectFit

        addSubview(rootImageView)
        addSubview(plantImageView)
    }

    private func updateScene() {
        rootImageView.image = UIImage(named: "RootImg")
        plantImageView.image = UIImage(named: currentAssetName)
        rootImageView.isHidden = !(style == .rooted && currentPlantAssetName != nil)
        if let plantAssetName = currentPlantAssetName, style == .rooted {
            plantImageView.image = UIImage(named: plantAssetName)
        }
        setNeedsLayout()
    }

    private func layoutScene() {
        guard bounds.width > 0, bounds.height > 0 else { return }

        if style == .rooted, let plantAssetName = currentPlantAssetName, let plantImage = UIImage(named: plantAssetName) {
            let rootHeight = bounds.width * rootAspectRatio
            let rootBottomInset = rootHeight * rootBottomInsetRatio
            let rootTopAnchor = rootHeight - rootBottomInset

            rootImageView.frame = CGRect(
                x: 0,
                y: bounds.height - rootHeight + rootBottomInset,
                width: bounds.width,
                height: rootHeight
            )

            let maxWidth = bounds.width * rootedPlantWidthFactor
            let maxHeight = max(bounds.height - rootTopAnchor + rootJoinOverlap, 0)
            let plantBottom = bounds.height - (rootTopAnchor - rootJoinOverlap)
            let plantBox = CGRect(
                x: (bounds.width - maxWidth) / 2,
                y: plantBottom - maxHeight,
                width: maxWidth,
                height: maxHeight
            )
            plantImageView.frame = aspectFitRect(for: plantImage, inside: plantBox)
        } else if let image = UIImage(named: currentAssetName) {
            rootImageView.frame = .zero

            let fittingBox = CGRect(
                x: (bounds.width - bounds.width * widthFactor) / 2,
                y: bounds.height - bounds.height * heightFactor,
                width: bounds.width * widthFactor,
                height: bounds.height * heightFactor
            )
            plantImageView.frame = aspectFitRect(for: image, inside: fittingBox)
        }
    }

    private var currentAssetName: String {
        switch (species, stage) {
        case (_, .seed), (_, .sprout):
            "FlowerSeed"
        case (.sunflower, .bud):
            "FlowerSunflowerBud"
        case (.sunflower, .bloom):
            "FlowerSunflowerBloom"
        case (.blueBloom, .bud), (.blueBloom, .bloom):
            "FlowerBlueBloom"
        case (.lily, .bud), (.lily, .bloom):
            "FlowerLilyBud"
        case (.rose, .bud), (.rose, .bloom):
            "FlowerRoseBud"
        }
    }

    private var currentPlantAssetName: String? {
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
        case .seed, .sprout:
            0.88
        case .bud:
            0.90
        case .bloom:
            species == .sunflower ? 0.92 : 0.88
        }
    }

    private var rootedPlantWidthFactor: CGFloat {
        switch stage {
        case .seed, .sprout:
            0.84
        case .bud:
            0.90
        case .bloom:
            0.92
        }
    }

    private var heightFactor: CGFloat {
        switch stage {
        case .seed, .sprout:
            0.74
        case .bud:
            0.92
        case .bloom:
            0.94
        }
    }

    private var rootAspectRatio: CGFloat { 148.0 / 600.0 }
    private var rootBottomInsetRatio: CGFloat { 12.0 / 148.0 }
    private var rootJoinOverlap: CGFloat { 3 }

    private func aspectFitRect(for image: UIImage, inside rect: CGRect) -> CGRect {
        guard image.size.width > 0, image.size.height > 0, rect.width > 0, rect.height > 0 else {
            return rect
        }

        let scale = min(rect.width / image.size.width, rect.height / image.size.height)
        let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        return CGRect(
            x: rect.midX - size.width / 2,
            y: rect.maxY - size.height,
            width: size.width,
            height: size.height
        )
    }
}

private extension CGFloat {
    static func degreesToRadians(_ degrees: Double) -> CGFloat {
        CGFloat(degrees * .pi / 180)
    }
}
