import UIKit

class BloomoraBaseViewController: UIViewController {
    let store: BloomoraStore

    private var storeObserver: NSObjectProtocol?

    init(store: BloomoraStore) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        if let storeObserver {
            NotificationCenter.default.removeObserver(storeObserver)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .bloomoraBackground

        storeObserver = NotificationCenter.default.addObserver(
            forName: .bloomoraStoreDidChange,
            object: store,
            queue: .main
        ) { [weak self] _ in
            self?.storeDidUpdate()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    func storeDidUpdate() {
    }
}

final class BloomoraHeaderView: UIView {
    private let backButton = UIButton(type: .system).useAutoLayout()
    private let titleLabel = UILabel().useAutoLayout()
    private let trailingSpacer = UIView().useAutoLayout()

    var onBack: (() -> Void)?

    var title: String = "" {
        didSet { titleLabel.text = title }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        backgroundColor = .clear

        let stackView = UIStackView(arrangedSubviews: [backButton, titleLabel, trailingSpacer]).useAutoLayout()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill

        backButton.tintColor = .black
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)

        titleLabel.font = .bloomoraRounded(size: 19, weight: .medium)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .black

        addSubview(stackView)

        NSLayoutConstraint.activate([
            backButton.widthAnchor.constraint(equalToConstant: 32),
            backButton.heightAnchor.constraint(equalToConstant: 32),
            trailingSpacer.widthAnchor.constraint(equalToConstant: 32),
            trailingSpacer.heightAnchor.constraint(equalToConstant: 32),

            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    @objc private func handleBack() {
        onBack?()
    }
}

final class BloomoraMenuRowView: UIControl {
    private let iconView = UIImageView().useAutoLayout()
    private let titleLabel = UILabel().useAutoLayout()
    private let trailingLabel = UILabel().useAutoLayout()
    private let chevronView = UIImageView().useAutoLayout()

    override var isHighlighted: Bool {
        didSet {
            alpha = isHighlighted ? 0.82 : 1
        }
    }

    init(icon: String, title: String, trailing: String? = nil) {
        super.init(frame: .zero)
        configure()
        update(icon: icon, title: title, trailing: trailing)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(icon: String, title: String, trailing: String?) {
        if let assetImage = UIImage(named: icon) {
            iconView.image = assetImage.withRenderingMode(.alwaysOriginal)
            iconView.tintColor = nil
        } else {
            iconView.image = UIImage(systemName: icon)
            iconView.tintColor = .black
        }
        titleLabel.text = title
        trailingLabel.text = trailing
        trailingLabel.isHidden = trailing == nil
    }

    private func configure() {
        backgroundColor = .white
        layer.cornerRadius = 28

        iconView.tintColor = .black
        iconView.contentMode = .scaleAspectFit

        titleLabel.font = .bloomoraRounded(size: 17, weight: .medium)
        titleLabel.textColor = .black

        trailingLabel.font = .bloomoraRounded(size: 17, weight: .medium)
        trailingLabel.textColor = .black
        trailingLabel.textAlignment = .right

        chevronView.image = UIImage(systemName: "chevron.right")
        chevronView.tintColor = UIColor(red: 0.65, green: 0.65, blue: 0.65)
        chevronView.contentMode = .scaleAspectFit

        addSubview(iconView)
        addSubview(titleLabel)
        addSubview(trailingLabel)
        addSubview(chevronView)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 84),

            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 22),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 32),
            iconView.heightAnchor.constraint(equalToConstant: 32),

            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 14),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            chevronView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -22),
            chevronView.centerYAnchor.constraint(equalTo: centerYAnchor),
            chevronView.widthAnchor.constraint(equalToConstant: 14),
            chevronView.heightAnchor.constraint(equalToConstant: 14),

            trailingLabel.trailingAnchor.constraint(equalTo: chevronView.leadingAnchor, constant: -12),
            trailingLabel.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 12),
            trailingLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

final class BloomoraDrinkCardView: UIView {
    private let iconView = UIImageView().useAutoLayout()
    private let titleLabel = UILabel().useAutoLayout()
    private let totalLabel = UILabel().useAutoLayout()
    private let addButton = UIButton(type: .system).useAutoLayout()

    private let kind: DrinkKind

    var addAction: (() -> Void)?

    init(kind: DrinkKind) {
        self.kind = kind
        super.init(frame: .zero)
        configure()
        update(total: 0)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(total: Int) {
        titleLabel.text = kind.title
        totalLabel.text = "\(total)ml"
    }

    private func configure() {
        backgroundColor = kind.cardTint
        layer.cornerRadius = 28
        layer.borderWidth = kind == .milk ? 1 : 0
        layer.borderColor = kind == .milk ? UIColor.black.withAlphaComponent(0.06).cgColor : UIColor.clear.cgColor

        iconView.image = UIImage(named: kind.assetName)
        iconView.contentMode = .scaleAspectFit

        titleLabel.font = .bloomoraRounded(size: 19, weight: .medium)
        titleLabel.textColor = .black

        totalLabel.font = .bloomoraRounded(size: 19, weight: .medium)
        totalLabel.textColor = .black

        addButton.tintColor = UIColor(red: 0.45, green: 0.45, blue: 0.45)
        addButton.setImage(UIImage(systemName: "plus"), for: .normal)
        addButton.backgroundColor = .bloomoraBackground
        addButton.layer.cornerRadius = 17
        addButton.addTarget(self, action: #selector(handleAdd), for: .touchUpInside)

        addSubview(iconView)
        addSubview(titleLabel)
        addSubview(totalLabel)
        addSubview(addButton)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 92),

            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 56),
            iconView.heightAnchor.constraint(equalToConstant: 56),

            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 14),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            addButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -18),
            addButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            addButton.widthAnchor.constraint(equalToConstant: 34),
            addButton.heightAnchor.constraint(equalToConstant: 34),

            totalLabel.trailingAnchor.constraint(equalTo: addButton.leadingAnchor, constant: -18),
            totalLabel.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 12),
            totalLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    @objc private func handleAdd() {
        addAction?()
    }
}

final class BloomoraReminderRowView: UIView {
    private let titleLabel = UILabel().useAutoLayout()
    private let timeLabel = UILabel().useAutoLayout()
    private let toggleSwitch = UISwitch().useAutoLayout()

    private var reminderID: UUID?
    var toggleAction: ((UUID, Bool) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(reminder: ReminderSlot) {
        reminderID = reminder.id
        titleLabel.text = reminder.title
        timeLabel.text = BloomoraFormatters.reminderTime.string(from: reminder.date)
        toggleSwitch.isOn = reminder.enabled
    }

    private func configure() {
        backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.98)
        layer.cornerRadius = 26

        titleLabel.font = .bloomoraRounded(size: 17, weight: .semibold)
        titleLabel.textColor = .black

        timeLabel.font = .bloomoraRounded(size: 15, weight: .medium)
        timeLabel.textColor = .secondaryLabel

        toggleSwitch.onTintColor = .bloomoraToggleGreen
        toggleSwitch.addTarget(self, action: #selector(handleToggle), for: .valueChanged)

        let labelStack = UIStackView(arrangedSubviews: [titleLabel, timeLabel]).useAutoLayout()
        labelStack.axis = .vertical
        labelStack.spacing = 4
        labelStack.alignment = .leading

        addSubview(labelStack)
        addSubview(toggleSwitch)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 82),

            labelStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            labelStack.centerYAnchor.constraint(equalTo: centerYAnchor),

            toggleSwitch.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -18),
            toggleSwitch.centerYAnchor.constraint(equalTo: centerYAnchor),

            labelStack.trailingAnchor.constraint(lessThanOrEqualTo: toggleSwitch.leadingAnchor, constant: -14)
        ])
    }

    @objc private func handleToggle() {
        guard let reminderID else { return }
        toggleAction?(reminderID, toggleSwitch.isOn)
    }
}

final class BloomoraSpeciesPosterCardView: UIView {
    private let placeholderLabel = UILabel().useAutoLayout()
    private let sceneView = BotanicalSceneView(species: .sunflower, stage: .bloom).useAutoLayout()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(species: FlowerSpecies) {
        let hasBloomIllustration: Bool = {
            switch species {
            case .sunflower, .blueBloom:
                true
            case .lily, .rose:
                false
            }
        }()

        placeholderLabel.isHidden = hasBloomIllustration
        sceneView.species = species
        sceneView.stage = .bloom
    }

    private func configure() {
        backgroundColor = UIColor(red: 0.93, green: 0.93, blue: 0.94)
        layer.cornerRadius = 34
        clipsToBounds = true

        placeholderLabel.font = .bloomoraRounded(size: 17, weight: .medium)
        placeholderLabel.textColor = UIColor(red: 0.45, green: 0.48, blue: 0.52)
        placeholderLabel.text = "Awaiting Blossoms"
        placeholderLabel.textAlignment = .center

        addSubview(placeholderLabel)
        addSubview(sceneView)

        NSLayoutConstraint.activate([
            placeholderLabel.topAnchor.constraint(equalTo: topAnchor, constant: 22),
            placeholderLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            sceneView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            sceneView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            sceneView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            sceneView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
    }
}

final class BloomoraSpeciesPosterCell: UICollectionViewCell {
    static let reuseIdentifier = "BloomoraSpeciesPosterCell"

    private let posterCardView = BloomoraSpeciesPosterCardView().useAutoLayout()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(posterCardView)
        posterCardView.pinEdges(to: contentView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(species: FlowerSpecies) {
        posterCardView.update(species: species)
    }
}

final class BloomoraRecordsSummaryView: UIView {
    private let gradientLayer = CAGradientLayer()
    private let accentCircle = UIView().useAutoLayout()
    private let titleLabel = UILabel().useAutoLayout()
    private let totalLabel = UILabel().useAutoLayout()
    private let unitLabel = UILabel().useAutoLayout()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }

    func update(total: Int) {
        totalLabel.text = "\(total)"
    }

    private func configure() {
        layer.cornerRadius = 20
        clipsToBounds = true

        gradientLayer.colors = [
            UIColor(red: 0.90, green: 0.93, blue: 0.97).cgColor,
            UIColor(red: 0.86, green: 0.92, blue: 0.97).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        layer.insertSublayer(gradientLayer, at: 0)

        accentCircle.layer.cornerRadius = 70
        accentCircle.layer.borderWidth = 16
        accentCircle.layer.borderColor = UIColor.white.withAlphaComponent(0.75).cgColor

        titleLabel.font = .bloomoraRounded(size: 16, weight: .medium)
        titleLabel.text = "Total Water Intake:"

        totalLabel.font = .bloomoraSerifItalic(size: 30)
        totalLabel.textColor = .black

        unitLabel.font = .bloomoraSerifItalic(size: 18)
        unitLabel.textColor = .black
        unitLabel.text = "ml"

        let valueStack = UIStackView(arrangedSubviews: [titleLabel, UIView(), totalLabel, unitLabel]).useAutoLayout()
        valueStack.axis = .horizontal
        valueStack.alignment = .center
        valueStack.spacing = 4

        addSubview(accentCircle)
        addSubview(valueStack)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 88),

            accentCircle.widthAnchor.constraint(equalToConstant: 140),
            accentCircle.heightAnchor.constraint(equalToConstant: 140),
            accentCircle.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -14),
            accentCircle.centerXAnchor.constraint(equalTo: trailingAnchor, constant: -78),

            valueStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            valueStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -18),
            valueStack.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

final class BloomoraRecordBreakdownRowView: UIView {
    private let iconView = UIImageView().useAutoLayout()
    private let titleLabel = UILabel().useAutoLayout()
    private let amountLabel = UILabel().useAutoLayout()
    private let divider = UIView().useAutoLayout()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(kind: DrinkKind, amount: Int, showsDivider: Bool) {
        iconView.image = UIImage(named: kind.assetName)
        titleLabel.text = kind.title
        amountLabel.text = "\(amount) ml"
        divider.isHidden = !showsDivider
    }

    private func configure() {
        iconView.contentMode = .scaleAspectFit

        titleLabel.font = .bloomoraRounded(size: 17, weight: .medium)
        amountLabel.font = .bloomoraRounded(size: 17, weight: .medium)

        divider.backgroundColor = UIColor.separator

        addSubview(iconView)
        addSubview(titleLabel)
        addSubview(amountLabel)
        addSubview(divider)

        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            iconView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            iconView.widthAnchor.constraint(equalToConstant: 34),
            iconView.heightAnchor.constraint(equalToConstant: 34),

            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 14),
            titleLabel.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),

            amountLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            amountLabel.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 12),
            amountLabel.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),

            divider.leadingAnchor.constraint(equalTo: leadingAnchor),
            divider.trailingAnchor.constraint(equalTo: trailingAnchor),
            divider.bottomAnchor.constraint(equalTo: bottomAnchor),
            divider.heightAnchor.constraint(equalToConstant: 0.5),

            bottomAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 12)
        ])
    }
}

final class BloomoraDateButton: UIButton {
    var representedDate: Date?

    var isBloomoraSelected: Bool = false {
        didSet {
            backgroundColor = isBloomoraSelected ? UIColor(red: 0.44, green: 0.75, blue: 0.35) : .clear
            setTitleColor(isBloomoraSelected ? .white : .label, for: .normal)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        titleLabel?.font = .bloomoraRounded(size: 16, weight: .medium)
        layer.cornerRadius = 20
        setTitleColor(.label, for: .normal)
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class BloomoraCalendarGridView: UIView {
    private let stackView = UIStackView().useAutoLayout()
    private var dateButtons: [BloomoraDateButton] = []

    var weekdaySymbols: [String] = [] {
        didSet { rebuild() }
    }

    var dates: [Date?] = [] {
        didSet { rebuild() }
    }

    var selectedDate: Date = .now {
        didSet { updateSelection() }
    }

    var onSelectDate: ((Date) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        stackView.axis = .vertical
        stackView.spacing = 14
        addSubview(stackView)
        stackView.pinEdges(to: self)
    }

    private func rebuild() {
        stackView.arrangedSubviews.forEach { arranged in
            stackView.removeArrangedSubview(arranged)
            arranged.removeFromSuperview()
        }
        dateButtons.removeAll()

        guard !weekdaySymbols.isEmpty else { return }

        let weekdayRow = UIStackView().useAutoLayout()
        weekdayRow.axis = .horizontal
        weekdayRow.distribution = .fillEqually

        for symbol in weekdaySymbols {
            let label = UILabel().useAutoLayout()
            label.text = symbol
            label.font = .bloomoraRounded(size: 15, weight: .medium)
            label.textColor = .secondaryLabel
            label.textAlignment = .center
            weekdayRow.addArrangedSubview(label)
        }
        stackView.addArrangedSubview(weekdayRow)

        for week in stride(from: 0, to: dates.count, by: 7) {
            let row = UIStackView().useAutoLayout()
            row.axis = .horizontal
            row.distribution = .fillEqually
            row.alignment = .fill

            for date in dates[week..<min(week + 7, dates.count)] {
                let container = UIView().useAutoLayout()
                container.heightAnchor.constraint(equalToConstant: 40).isActive = true

                if let date {
                    let button = BloomoraDateButton().useAutoLayout()
                    button.representedDate = date
                    button.setTitle(BloomoraFormatters.dayNumber.string(from: date), for: .normal)
                    button.addTarget(self, action: #selector(handleDateTap(_:)), for: .touchUpInside)
                    container.addSubview(button)
                    NSLayoutConstraint.activate([
                        button.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                        button.centerYAnchor.constraint(equalTo: container.centerYAnchor),
                        button.widthAnchor.constraint(equalToConstant: 40),
                        button.heightAnchor.constraint(equalToConstant: 40)
                    ])
                    dateButtons.append(button)
                }

                row.addArrangedSubview(container)
            }

            stackView.addArrangedSubview(row)
        }

        updateSelection()
    }

    private func updateSelection() {
        let calendar = Calendar(identifier: .gregorian)
        dateButtons.forEach { button in
            guard let date = button.representedDate else {
                button.isBloomoraSelected = false
                return
            }
            button.isBloomoraSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        }
    }

    @objc private func handleDateTap(_ sender: BloomoraDateButton) {
        guard let date = sender.representedDate else { return }
        onSelectDate?(date)
    }
}

final class BloomoraWallpaperCanvasView: UIView {
    private let quoteLabel = UILabel().useAutoLayout()
    private let sceneView: BotanicalSceneView

    init(flower: GardenFlower, stage: FlowerStage) {
        sceneView = BotanicalSceneView(species: flower.species, stage: stage)
        super.init(frame: .zero)
        sceneView.useAutoLayout()
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        backgroundColor = .bloomoraBackground

        quoteLabel.font = .bloomoraRounded(size: 17, weight: .medium)
        quoteLabel.textColor = UIColor(red: 0.43, green: 0.47, blue: 0.50)
        quoteLabel.textAlignment = .center
        quoteLabel.numberOfLines = 0
        quoteLabel.text = "Love is the flower you've got to let grow."

        addSubview(quoteLabel)
        addSubview(sceneView)

        NSLayoutConstraint.activate([
            quoteLabel.topAnchor.constraint(equalTo: topAnchor, constant: 18),
            quoteLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
            quoteLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -28),

            sceneView.topAnchor.constraint(equalTo: quoteLabel.bottomAnchor, constant: 20),
            sceneView.leadingAnchor.constraint(equalTo: leadingAnchor),
            sceneView.trailingAnchor.constraint(equalTo: trailingAnchor),
            sceneView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
    }

    func renderedImage(size: CGSize) -> UIImage? {
        let renderView = BloomoraWallpaperCanvasView(
            flower: GardenFlower(plantedOn: .now, species: sceneView.species),
            stage: sceneView.stage
        )
        renderView.frame = CGRect(origin: .zero, size: size)
        renderView.layoutIfNeeded()

        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            renderView.layer.render(in: context.cgContext)
        }
    }
}
