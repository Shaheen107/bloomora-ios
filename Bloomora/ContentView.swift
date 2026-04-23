import UIKit

final class BloomoraHomeViewController: BloomoraBaseViewController {
    private let sceneView = BotanicalSceneView(
        species: .sunflower,
        stage: .seed,
        style: .rooted
    ).useAutoLayout()
    private let emptyArtworkView = BloomoraEmptyHomeArtworkView().useAutoLayout()

    private let dateLabel = UILabel().useAutoLayout()
    private let titleLabel = UILabel().useAutoLayout()
    private let menuButton = UIButton(type: .system).useAutoLayout()
    private let navFlowerImageView = UIImageView().useAutoLayout()
    private let heroButton = UIControl().useAutoLayout()
    private let heroValueLabel = UILabel().useAutoLayout()
    private let heroUnitLabel = UILabel().useAutoLayout()
    private let emptyStateStack = UIStackView().useAutoLayout()
    private let emptyStateImageView = UIImageView().useAutoLayout()
    private let emptyStateTitleLabel = UILabel().useAutoLayout()
    private let emptyStateBodyLabel = UILabel().useAutoLayout()

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        refresh()
    }

    override func storeDidUpdate() {
        refresh()
    }

    private func configure() {
        view.addSubview(sceneView)
        view.addSubview(emptyArtworkView)

        NSLayoutConstraint.activate([
            sceneView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sceneView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sceneView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            sceneView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.72),

            emptyArtworkView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyArtworkView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyArtworkView.topAnchor.constraint(equalTo: view.topAnchor),
            emptyArtworkView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        let contentView = UIView().useAutoLayout()
        view.addSubview(contentView)

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            contentView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor)
        ])

        let titleStack = UIStackView(arrangedSubviews: [dateLabel, titleLabel]).useAutoLayout()
        titleStack.axis = .vertical
        titleStack.spacing = 4
        titleStack.alignment = .leading

        let topRow = UIStackView(arrangedSubviews: [titleStack, UIView(), menuButton]).useAutoLayout()
        topRow.axis = .horizontal
        topRow.alignment = .top

        dateLabel.font = .bloomoraRounded(size: 18, weight: .medium)
        dateLabel.textColor = .secondaryLabel

        titleLabel.font = .bloomoraSerif(size: 27, weight: .medium)
        titleLabel.text = "DRINKBLOOM"
        titleLabel.textColor = .black

        let menuSymbolConfig = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        menuButton.setImage(UIImage(systemName: "line.3.horizontal", withConfiguration: menuSymbolConfig), for: .normal)
        menuButton.tintColor = .black
        menuButton.addTarget(self, action: #selector(openProfile), for: .touchUpInside)

        heroButton.addTarget(self, action: #selector(openLogger), for: .touchUpInside)

        heroValueLabel.font = .bloomoraSerifItalic(size: 72)
        heroValueLabel.textColor = .black
        heroValueLabel.adjustsFontSizeToFitWidth = true
        heroValueLabel.minimumScaleFactor = 0.55

        heroUnitLabel.font = .bloomoraSerifItalic(size: 26)
        heroUnitLabel.textColor = .secondaryLabel
        heroUnitLabel.text = "ml"
        heroUnitLabel.adjustsFontSizeToFitWidth = true
        heroUnitLabel.minimumScaleFactor = 0.8

        let heroStack = UIStackView(arrangedSubviews: [heroValueLabel, heroUnitLabel]).useAutoLayout()
        heroStack.axis = .horizontal
        heroStack.alignment = .firstBaseline
        heroStack.spacing = 4
        heroStack.isUserInteractionEnabled = false
        heroButton.addSubview(heroStack)
        heroButton.accessibilityTraits = .button
        heroButton.accessibilityLabel = "Open water logger"

        navFlowerImageView.image = UIImage(named: "navFlower")
        navFlowerImageView.contentMode = .scaleAspectFit
        navFlowerImageView.clipsToBounds = false

        emptyStateStack.axis = .vertical
        emptyStateStack.spacing = 18
        emptyStateStack.alignment = .center
        emptyStateStack.isUserInteractionEnabled = false

        emptyStateImageView.image = UIImage(named: "FlowerIm")
        emptyStateImageView.contentMode = .scaleAspectFit

        emptyStateTitleLabel.font = .bloomoraRounded(size: 19, weight: .medium)
        emptyStateTitleLabel.textColor = .bloomoraMutedText
        emptyStateTitleLabel.textAlignment = .center
        emptyStateTitleLabel.numberOfLines = 0
        emptyStateTitleLabel.text = "Flowers have been sown today"

        emptyStateBodyLabel.font = .bloomoraRounded(size: 16, weight: .medium)
        emptyStateBodyLabel.textColor = .bloomoraSecondaryText
        emptyStateBodyLabel.textAlignment = .center
        emptyStateBodyLabel.numberOfLines = 0
        emptyStateBodyLabel.setBloomoraText(
            "Click on the number above to complete your water drinking goal and harvest your flowers.",
            lineSpacing: 6
        )

        let emptyTextStack = UIStackView(arrangedSubviews: [emptyStateTitleLabel, emptyStateBodyLabel]).useAutoLayout()
        emptyTextStack.axis = .vertical
        emptyTextStack.spacing = 10
        emptyTextStack.alignment = .fill

        emptyStateStack.addArrangedSubviews([emptyStateImageView, emptyTextStack])

        contentView.addSubview(topRow)
        contentView.addSubview(navFlowerImageView)
        contentView.addSubview(heroButton)
        contentView.addSubview(emptyStateStack)

        NSLayoutConstraint.activate([
            topRow.topAnchor.constraint(equalTo: contentView.topAnchor),
            topRow.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            topRow.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            menuButton.widthAnchor.constraint(equalToConstant: 42),
            menuButton.heightAnchor.constraint(equalToConstant: 42),

            navFlowerImageView.topAnchor.constraint(equalTo: topRow.bottomAnchor, constant: 18),
            navFlowerImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            navFlowerImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            navFlowerImageView.heightAnchor.constraint(equalTo: navFlowerImageView.widthAnchor, multiplier: 248.0 / 1964.0),

            heroButton.topAnchor.constraint(equalTo: navFlowerImageView.bottomAnchor, constant: 8),
            heroButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            heroButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            heroStack.centerXAnchor.constraint(equalTo: heroButton.centerXAnchor),
            heroStack.topAnchor.constraint(equalTo: heroButton.topAnchor),
            heroStack.bottomAnchor.constraint(equalTo: heroButton.bottomAnchor),
            heroStack.leadingAnchor.constraint(greaterThanOrEqualTo: heroButton.leadingAnchor),
            heroStack.trailingAnchor.constraint(lessThanOrEqualTo: heroButton.trailingAnchor),

            emptyStateStack.topAnchor.constraint(equalTo: heroButton.bottomAnchor, constant: -20),
            emptyStateStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            emptyStateStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            emptyStateStack.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor),

            emptyStateImageView.widthAnchor.constraint(equalToConstant: 92),
            emptyStateImageView.heightAnchor.constraint(equalToConstant: 92)
        ])
    }

    private func refresh() {
        let today = Date()
        let total = store.totalIntake(on: today)
        let goal = store.dailyGoal
        let stage = store.stage(for: today)

        dateLabel.text = BloomoraFormatters.homeDate.string(from: today)
        heroValueLabel.text = "\(total)/\(goal)"

        sceneView.stage = stage
        sceneView.isHidden = !store.hasLoggedEntries
        emptyArtworkView.isHidden = store.hasLoggedEntries
        emptyStateStack.isHidden = store.hasLoggedEntries
    }

    @objc private func openProfile() {
        navigationController?.pushViewController(BloomoraProfileViewController(store: store), animated: true)
    }

    @objc private func openLogger() {
        navigationController?.pushViewController(BloomoraLoggerViewController(store: store), animated: true)
    }
}

private final class BloomoraEmptyHomeArtworkView: UIView {
    private let imageView = UIImageView(image: UIImage(named: "RootImg"))

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let width = bounds.width
        let height = width * (148.0 / 600.0)
        let yOffset = width * (12.0 / 600.0)
        imageView.frame = CGRect(
            x: 0,
            y: bounds.height - height + yOffset,
            width: width,
            height: height
        )
    }
}
