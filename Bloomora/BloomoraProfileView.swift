import Photos
import UIKit

final class BloomoraProfileViewController: BloomoraBaseViewController {
    private let backgroundImageView = UIImageView(image: UIImage(named: "backgroundFlowers")).useAutoLayout()
    private let headerView = BloomoraHeaderView().useAutoLayout()
    private let flowerCountLabel = UILabel().useAutoLayout()
    private let flowersTitleLabel = UILabel().useAutoLayout()
    private let flowersRow = BloomoraMenuRowView(icon: "myFlowers", title: "My flowers").useAutoLayout()
    private let goalRow = BloomoraMenuRowView(icon: "dailyGoal", title: "Daily goal").useAutoLayout()
    private let recordsRow = BloomoraMenuRowView(icon: "Water Intake Records", title: "Water Intake Records").useAutoLayout()
    private let remindersRow = BloomoraMenuRowView(icon: "Reminders", title: "Reminders").useAutoLayout()

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        refresh()
    }

    override func storeDidUpdate() {
        refresh()
    }

    private func configure() {
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true

        view.addSubview(backgroundImageView)
        backgroundImageView.pinEdges(to: view)

        let scrollView = UIScrollView().useAutoLayout()
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        scrollView.pinEdges(to: view)

        let contentView = UIView().useAutoLayout()
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])

        let contentStack = UIStackView().useAutoLayout()
        contentStack.axis = .vertical
        contentStack.spacing = 24
        contentStack.alignment = .fill
        contentView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 6),
            contentStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            contentStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            contentStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])

        headerView.title = "My"
        headerView.onBack = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }

        flowerCountLabel.font = .bloomoraSerifItalic(size: 96)
        flowerCountLabel.textColor = .bloomoraPrimaryText
        flowerCountLabel.textAlignment = .center

        flowersTitleLabel.font = .bloomoraRounded(size: 17, weight: .medium)
        flowersTitleLabel.textColor = .secondaryLabel
        flowersTitleLabel.textAlignment = .center
        flowersTitleLabel.text = "My flowers"

        let countStack = UIStackView(arrangedSubviews: [flowerCountLabel, flowersTitleLabel]).useAutoLayout()
        countStack.axis = .vertical
        countStack.spacing = 4
        countStack.alignment = .center

        let menuStack = UIStackView(arrangedSubviews: [flowersRow, goalRow, recordsRow, remindersRow]).useAutoLayout()
        menuStack.axis = .vertical
        menuStack.spacing = 14

        flowersRow.addTarget(self, action: #selector(openFlowers), for: .touchUpInside)
        goalRow.addTarget(self, action: #selector(openGoalSheet), for: .touchUpInside)
        recordsRow.addTarget(self, action: #selector(openRecords), for: .touchUpInside)
        remindersRow.addTarget(self, action: #selector(openReminders), for: .touchUpInside)

        contentStack.addArrangedSubviews([headerView, countStack, menuStack])
        countStack.setCustomSpacing(14, after: flowersTitleLabel)
        contentStack.setCustomSpacing(6, after: countStack)
    }

    private func refresh() {
        flowerCountLabel.text = "\(store.unlockedFlowerCount)"
        goalRow.update(icon: "dailyGoal", title: "Daily goal", trailing: "\(store.dailyGoal)ml")
    }

    @objc private func openFlowers() {
        navigationController?.pushViewController(BloomoraFlowerGalleryViewController(store: store), animated: true)
    }

    @objc private func openGoalSheet() {
        let controller = BloomoraGoalSheetViewController(store: store)
        controller.modalPresentationStyle = .pageSheet
        configureBloomoraSheet(controller, height: 360, identifier: "BloomoraGoalSheet")
        present(controller, animated: true)
    }

    @objc private func openRecords() {
        navigationController?.pushViewController(BloomoraRecordsViewController(store: store), animated: true)
    }

    @objc private func openReminders() {
        navigationController?.pushViewController(BloomoraRemindersViewController(store: store), animated: true)
    }
}

final class BloomoraFlowerGalleryViewController: BloomoraBaseViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private let galleryOrder: [FlowerSpecies] = [.sunflower, .blueBloom, .lily, .rose]

    private let headerView = BloomoraHeaderView().useAutoLayout()
    private let layout = UICollectionViewFlowLayout()
    private lazy var collectionView: UICollectionView = {
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 18

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout).useAutoLayout()
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.decelerationRate = .fast
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(BloomoraSpeciesPosterCell.self, forCellWithReuseIdentifier: BloomoraSpeciesPosterCell.reuseIdentifier)
        return collectionView
    }()
    private let sideFlowerImageView = UIImageView(image: UIImage(named: "sideFlower")).useAutoLayout()
    private let makeWallpaperButton = UIButton(type: .system).useAutoLayout()
    private let restorePurchaseLabel = UILabel().useAutoLayout()

    private var selectedSpeciesIndex = 0
    private var hasAppliedInitialScroll = false

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateCollectionLayout()
        if !hasAppliedInitialScroll {
            hasAppliedInitialScroll = true
            scrollToSelectedIndex(animated: false)
        }
    }

    private func configure() {
        let scrollView = UIScrollView().useAutoLayout()
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        scrollView.pinEdges(to: view)

        let contentView = UIView().useAutoLayout()
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])

        headerView.title = "My flowers"
        headerView.onBack = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }

        let contentStack = UIStackView().useAutoLayout()
        contentStack.axis = .vertical
        contentStack.spacing = 0
        contentStack.alignment = .fill
        contentView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 6),
            contentStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])

        let headerContainer = UIView().useAutoLayout()
        headerContainer.addSubview(headerView)
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: headerContainer.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor, constant: 22),
            headerView.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor, constant: -22),
            headerView.bottomAnchor.constraint(equalTo: headerContainer.bottomAnchor)
        ])

        let galleryContainer = UIView().useAutoLayout()
        galleryContainer.addSubview(collectionView)
        galleryContainer.addSubview(sideFlowerImageView)

        sideFlowerImageView.contentMode = .scaleAspectFit
        sideFlowerImageView.clipsToBounds = false

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: galleryContainer.topAnchor, constant: 12),
            collectionView.leadingAnchor.constraint(equalTo: galleryContainer.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: galleryContainer.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 560),
            collectionView.bottomAnchor.constraint(equalTo: galleryContainer.bottomAnchor),

            sideFlowerImageView.widthAnchor.constraint(equalToConstant: 150),
            sideFlowerImageView.heightAnchor.constraint(equalTo: sideFlowerImageView.widthAnchor, multiplier: 1056.0 / 1008.0),
            sideFlowerImageView.trailingAnchor.constraint(equalTo: galleryContainer.trailingAnchor, constant: 34),
            sideFlowerImageView.bottomAnchor.constraint(equalTo: galleryContainer.bottomAnchor, constant: 18)
        ])

        makeWallpaperButton.setTitle("Make wallpaper", for: .normal)
        makeWallpaperButton.titleLabel?.font = .bloomoraRounded(size: 18, weight: .medium)
        makeWallpaperButton.setTitleColor(.white, for: .normal)
        makeWallpaperButton.backgroundColor = UIColor(red: 0.12, green: 0.13, blue: 0.14)
        makeWallpaperButton.layer.cornerRadius = 29
        makeWallpaperButton.addTarget(self, action: #selector(makeWallpaper), for: .touchUpInside)

        restorePurchaseLabel.font = .bloomoraRounded(size: 15, weight: .medium)
        restorePurchaseLabel.textColor = .secondaryLabel
        restorePurchaseLabel.textAlignment = .center
        restorePurchaseLabel.text = "Restore purchase"

        let buttonContainer = UIView().useAutoLayout()
        buttonContainer.addSubview(makeWallpaperButton)
        NSLayoutConstraint.activate([
            makeWallpaperButton.topAnchor.constraint(equalTo: buttonContainer.topAnchor, constant: 18),
            makeWallpaperButton.centerXAnchor.constraint(equalTo: buttonContainer.centerXAnchor),
            makeWallpaperButton.widthAnchor.constraint(equalToConstant: 210),
            makeWallpaperButton.heightAnchor.constraint(equalToConstant: 58),
            makeWallpaperButton.bottomAnchor.constraint(equalTo: buttonContainer.bottomAnchor)
        ])

        let restoreContainer = UIView().useAutoLayout()
        restoreContainer.addSubview(restorePurchaseLabel)
        NSLayoutConstraint.activate([
            restorePurchaseLabel.topAnchor.constraint(equalTo: restoreContainer.topAnchor, constant: 34),
            restorePurchaseLabel.centerXAnchor.constraint(equalTo: restoreContainer.centerXAnchor),
            restorePurchaseLabel.bottomAnchor.constraint(equalTo: restoreContainer.bottomAnchor)
        ])

        contentStack.addArrangedSubviews([headerContainer, galleryContainer, buttonContainer, restoreContainer])
    }

    private func updateCollectionLayout() {
        let cardWidth = min(view.bounds.width - 96, 332.0)
        let sideInset = max((view.bounds.width - cardWidth) / 2, 24)
        layout.itemSize = CGSize(width: cardWidth, height: 486)
        layout.sectionInset = UIEdgeInsets(top: 0, left: sideInset, bottom: 0, right: sideInset)
        layout.invalidateLayout()
    }

    private func scrollToSelectedIndex(animated: Bool) {
        guard galleryOrder.indices.contains(selectedSpeciesIndex) else { return }
        collectionView.layoutIfNeeded()
        collectionView.scrollToItem(
            at: IndexPath(item: selectedSpeciesIndex, section: 0),
            at: .centeredHorizontally,
            animated: animated
        )
    }

    private func updateSelectedSpeciesFromCenter() {
        let centerPoint = view.convert(collectionView.center, to: collectionView)
        guard let indexPath = collectionView.indexPathForItem(at: centerPoint) else { return }
        selectedSpeciesIndex = indexPath.item
    }

    @objc private func makeWallpaper() {
        let species = galleryOrder[selectedSpeciesIndex]
        let controller = BloomoraWallpaperPreviewViewController(
            flower: GardenFlower(plantedOn: .now, species: species),
            stage: .bloom
        )
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        galleryOrder.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: BloomoraSpeciesPosterCell.reuseIdentifier,
            for: indexPath
        )
        if let cell = cell as? BloomoraSpeciesPosterCell {
            cell.update(species: galleryOrder[indexPath.item])
        }
        return cell
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            updateSelectedSpeciesFromCenter()
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateSelectedSpeciesFromCenter()
    }
}

final class BloomoraRecordsViewController: BloomoraBaseViewController {
    private let headerView = BloomoraHeaderView().useAutoLayout()
    private let previousMonthButton = UIButton(type: .system).useAutoLayout()
    private let nextMonthButton = UIButton(type: .system).useAutoLayout()
    private let monthLabel = UILabel().useAutoLayout()
    private let calendarView = BloomoraCalendarGridView().useAutoLayout()
    private let summaryView = BloomoraRecordsSummaryView().useAutoLayout()
    private let breakdownStack = UIStackView().useAutoLayout()

    private var displayedMonth: Date
    private var breakdownRows: [DrinkKind: BloomoraRecordBreakdownRowView] = [:]

    override init(store: BloomoraStore) {
        displayedMonth = store.startOfMonth(for: store.selectedDate)
        super.init(store: store)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        refresh()
    }

    override func storeDidUpdate() {
        refresh()
    }

    private func configure() {
        let scrollView = UIScrollView().useAutoLayout()
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        scrollView.pinEdges(to: view)

        let contentView = UIView().useAutoLayout()
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])

        let contentStack = UIStackView().useAutoLayout()
        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.alignment = .fill
        contentView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 6),
            contentStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            contentStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            contentStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])

        headerView.title = "Water Intake Records"
        headerView.onBack = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }

        let leftConfig = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        previousMonthButton.setImage(UIImage(systemName: "chevron.left", withConfiguration: leftConfig), for: .normal)
        previousMonthButton.tintColor = .black
        previousMonthButton.addTarget(self, action: #selector(showPreviousMonth), for: .touchUpInside)

        let rightConfig = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        nextMonthButton.setImage(UIImage(systemName: "chevron.right", withConfiguration: rightConfig), for: .normal)
        nextMonthButton.tintColor = .black
        nextMonthButton.addTarget(self, action: #selector(showNextMonth), for: .touchUpInside)

        monthLabel.font = .bloomoraRounded(size: 20, weight: .bold)
        monthLabel.textAlignment = .center

        let monthRow = UIStackView(arrangedSubviews: [previousMonthButton, UIView(), monthLabel, UIView(), nextMonthButton]).useAutoLayout()
        monthRow.axis = .horizontal
        monthRow.alignment = .center

        calendarView.weekdaySymbols = store.weekdaySymbols
        calendarView.onSelectDate = { [weak self] date in
            self?.store.selectedDate = date
        }

        breakdownStack.axis = .vertical
        breakdownStack.spacing = 0

        for (index, kind) in DrinkKind.allCases.enumerated() {
            let row = BloomoraRecordBreakdownRowView().useAutoLayout()
            row.update(kind: kind, amount: 0, showsDivider: index < DrinkKind.allCases.count - 1)
            breakdownStack.addArrangedSubview(row)
            breakdownRows[kind] = row
        }

        contentStack.addArrangedSubviews([headerView, monthRow, calendarView, summaryView, breakdownStack])
    }

    private func refresh() {
        monthLabel.text = BloomoraFormatters.monthTitle.string(from: displayedMonth)
        calendarView.dates = store.monthGrid(for: displayedMonth)
        calendarView.selectedDate = store.selectedDate
        summaryView.update(total: store.totalIntake(on: store.selectedDate))

        for (index, kind) in DrinkKind.allCases.enumerated() {
            breakdownRows[kind]?.update(
                kind: kind,
                amount: store.amount(of: kind, on: store.selectedDate),
                showsDivider: index < DrinkKind.allCases.count - 1
            )
        }
    }

    @objc private func showPreviousMonth() {
        displayedMonth = Calendar(identifier: .gregorian).date(byAdding: .month, value: -1, to: displayedMonth) ?? displayedMonth
        refresh()
    }

    @objc private func showNextMonth() {
        displayedMonth = Calendar(identifier: .gregorian).date(byAdding: .month, value: 1, to: displayedMonth) ?? displayedMonth
        refresh()
    }
}

final class BloomoraLoggerViewController: BloomoraBaseViewController {
    private let headerView = BloomoraHeaderView().useAutoLayout()
    private let cardStack = UIStackView().useAutoLayout()
    private var drinkCards: [DrinkKind: BloomoraDrinkCardView] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        refresh()
    }

    override func storeDidUpdate() {
        refresh()
    }

    private func configure() {
        let scrollView = UIScrollView().useAutoLayout()
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        scrollView.pinEdges(to: view)

        let contentView = UIView().useAutoLayout()
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])

        headerView.title = "Record drinking water"
        headerView.onBack = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }

        cardStack.axis = .vertical
        cardStack.spacing = 16

        let contentStack = UIStackView(arrangedSubviews: [headerView, cardStack]).useAutoLayout()
        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 6),
            contentStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])

        for kind in DrinkKind.allCases {
            let card = BloomoraDrinkCardView(kind: kind).useAutoLayout()
            card.addAction = { [weak self] in
                self?.presentAmountSheet(for: kind)
            }
            cardStack.addArrangedSubview(card)
            drinkCards[kind] = card
        }
    }

    private func refresh() {
        for kind in DrinkKind.allCases {
            drinkCards[kind]?.update(total: store.amount(of: kind, on: .now))
        }
    }

    private func presentAmountSheet(for kind: DrinkKind) {
        let controller = BloomoraDrinkAmountSheetViewController(store: store, kind: kind)
        controller.modalPresentationStyle = .pageSheet
        configureBloomoraSheet(controller, height: 360, identifier: "BloomoraDrinkAmountSheet")
        present(controller, animated: true)
    }
}

final class BloomoraRemindersViewController: BloomoraBaseViewController {
    private let headerView = BloomoraHeaderView().useAutoLayout()
    private let reminderStack = UIStackView().useAutoLayout()
    private var reminderRows: [UUID: BloomoraReminderRowView] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        refresh()
    }

    override func storeDidUpdate() {
        refresh()
    }

    private func configure() {
        let scrollView = UIScrollView().useAutoLayout()
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        scrollView.pinEdges(to: view)

        let contentView = UIView().useAutoLayout()
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])

        headerView.title = "Reminders"
        headerView.onBack = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }

        let introTitleLabel = UILabel().useAutoLayout()
        introTitleLabel.font = .bloomoraSerif(size: 23, weight: .semibold)
        introTitleLabel.textColor = .black
        introTitleLabel.text = "Flexible hydration rhythm"
        introTitleLabel.numberOfLines = 0

        let introBodyLabel = UILabel().useAutoLayout()
        introBodyLabel.font = .bloomoraRounded(size: 16, weight: .medium)
        introBodyLabel.textColor = .secondaryLabel
        introBodyLabel.numberOfLines = 0
        introBodyLabel.text = "Gentle reminders skip your rest window and help space water intake throughout the day."

        let introStack = UIStackView(arrangedSubviews: [introTitleLabel, introBodyLabel]).useAutoLayout()
        introStack.axis = .vertical
        introStack.spacing = 8

        let quietTimesCard = UIView().useAutoLayout()
        quietTimesCard.backgroundColor = UIColor(red: 0.92, green: 0.97, blue: 0.93)
        quietTimesCard.layer.cornerRadius = 26

        let quietTitleLabel = UILabel().useAutoLayout()
        quietTitleLabel.font = .bloomoraRounded(size: 16, weight: .semibold)
        quietTitleLabel.textColor = .black
        quietTitleLabel.text = "Quiet times"

        let quietBodyLabel = UILabel().useAutoLayout()
        quietBodyLabel.font = .bloomoraRounded(size: 15, weight: .medium)
        quietBodyLabel.textColor = .secondaryLabel
        quietBodyLabel.numberOfLines = 0
        quietBodyLabel.text = "No reminders from 10:00 PM to 8:00 AM and during lunch at 1:00 PM."

        let quietStack = UIStackView(arrangedSubviews: [quietTitleLabel, quietBodyLabel]).useAutoLayout()
        quietStack.axis = .vertical
        quietStack.spacing = 6
        quietTimesCard.addSubview(quietStack)

        NSLayoutConstraint.activate([
            quietTimesCard.heightAnchor.constraint(equalToConstant: 104),
            quietStack.topAnchor.constraint(equalTo: quietTimesCard.topAnchor, constant: 18),
            quietStack.leadingAnchor.constraint(equalTo: quietTimesCard.leadingAnchor, constant: 18),
            quietStack.trailingAnchor.constraint(equalTo: quietTimesCard.trailingAnchor, constant: -18),
            quietStack.bottomAnchor.constraint(lessThanOrEqualTo: quietTimesCard.bottomAnchor, constant: -18)
        ])

        reminderStack.axis = .vertical
        reminderStack.spacing = 12

        let contentStack = UIStackView(arrangedSubviews: [headerView, introStack, quietTimesCard, reminderStack]).useAutoLayout()
        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 6),
            contentStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -28)
        ])

        for reminder in store.reminders {
            let row = BloomoraReminderRowView().useAutoLayout()
            row.toggleAction = { [weak self] id, isEnabled in
                self?.store.updateReminder(id, isEnabled: isEnabled)
            }
            reminderStack.addArrangedSubview(row)
            reminderRows[reminder.id] = row
        }
    }

    private func refresh() {
        for reminder in store.reminders {
            reminderRows[reminder.id]?.update(reminder: reminder)
        }
    }
}

final class BloomoraGoalSheetViewController: UIViewController, UITextFieldDelegate {
    private let store: BloomoraStore
    private let valueTextField = UITextField().useAutoLayout()

    init(store: BloomoraStore) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .bloomoraBackground
        preferredContentSize = CGSize(width: 0, height: 360)
        configure()
    }

    private func configure() {
        let titleLabel = UILabel().useAutoLayout()
        titleLabel.font = .bloomoraRounded(size: 19, weight: .medium)
        titleLabel.textColor = .black
        titleLabel.text = "Daily goal"
        titleLabel.textAlignment = .center

        let confirmButton = UIButton(type: .system).useAutoLayout()
        confirmButton.setTitle("Confirm", for: .normal)
        confirmButton.titleLabel?.font = .bloomoraRounded(size: 17, weight: .medium)
        confirmButton.setTitleColor(.bloomoraGoalGreen, for: .normal)
        confirmButton.addTarget(self, action: #selector(confirmGoal), for: .touchUpInside)

        let topRow = UIView().useAutoLayout()
        topRow.addSubview(titleLabel)
        topRow.addSubview(confirmButton)
        view.addSubview(topRow)

        valueTextField.font = .bloomoraRounded(size: 22, weight: .medium)
        valueTextField.textColor = .black
        valueTextField.keyboardType = .numberPad
        valueTextField.text = "\(store.dailyGoal)"
        valueTextField.delegate = self
        valueTextField.borderStyle = .none

        let textFieldContainer = UIView().useAutoLayout()
        textFieldContainer.layer.cornerRadius = 8
        textFieldContainer.layer.borderWidth = 1
        textFieldContainer.layer.borderColor = UIColor.black.withAlphaComponent(0.18).cgColor
        textFieldContainer.addSubview(valueTextField)
        view.addSubview(textFieldContainer)

        NSLayoutConstraint.activate([
            topRow.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 28),
            topRow.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            topRow.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            topRow.heightAnchor.constraint(equalToConstant: 40),

            titleLabel.centerXAnchor.constraint(equalTo: topRow.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: topRow.centerYAnchor),

            confirmButton.trailingAnchor.constraint(equalTo: topRow.trailingAnchor),
            confirmButton.centerYAnchor.constraint(equalTo: topRow.centerYAnchor),

            textFieldContainer.topAnchor.constraint(equalTo: topRow.bottomAnchor, constant: 28),
            textFieldContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textFieldContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            textFieldContainer.heightAnchor.constraint(equalToConstant: 46),

            valueTextField.topAnchor.constraint(equalTo: textFieldContainer.topAnchor),
            valueTextField.leadingAnchor.constraint(equalTo: textFieldContainer.leadingAnchor, constant: 16),
            valueTextField.trailingAnchor.constraint(equalTo: textFieldContainer.trailingAnchor, constant: -16),
            valueTextField.bottomAnchor.constraint(equalTo: textFieldContainer.bottomAnchor)
        ])
    }

    @objc private func confirmGoal() {
        if let amount = Int(valueTextField.text ?? "") {
            store.updateDailyGoal(to: amount)
        }
        dismiss(animated: true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        confirmGoal()
        return true
    }
}

final class BloomoraDrinkAmountSheetViewController: UIViewController, UITextFieldDelegate {
    private let store: BloomoraStore
    private let kind: DrinkKind
    private let valueTextField = UITextField().useAutoLayout()

    init(store: BloomoraStore, kind: DrinkKind) {
        self.store = store
        self.kind = kind
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .bloomoraBackground
        preferredContentSize = CGSize(width: 0, height: 360)
        configure()
    }

    private func configure() {
        let titleLabel = UILabel().useAutoLayout()
        titleLabel.font = .bloomoraRounded(size: 19, weight: .medium)
        titleLabel.textColor = .black
        titleLabel.text = "\(kind.title) amount"
        titleLabel.textAlignment = .center

        let confirmButton = UIButton(type: .system).useAutoLayout()
        confirmButton.setTitle("Confirm", for: .normal)
        confirmButton.titleLabel?.font = .bloomoraRounded(size: 17, weight: .medium)
        confirmButton.setTitleColor(.bloomoraGoalGreen, for: .normal)
        confirmButton.addTarget(self, action: #selector(confirmAmount), for: .touchUpInside)

        let topRow = UIView().useAutoLayout()
        topRow.addSubview(titleLabel)
        topRow.addSubview(confirmButton)
        view.addSubview(topRow)

        valueTextField.font = .bloomoraRounded(size: 22, weight: .medium)
        valueTextField.textColor = .black
        valueTextField.keyboardType = .numberPad
        valueTextField.text = "\(kind.stepAmount)"
        valueTextField.delegate = self
        valueTextField.borderStyle = .none

        let unitLabel = UILabel().useAutoLayout()
        unitLabel.font = .bloomoraRounded(size: 18, weight: .medium)
        unitLabel.textColor = .secondaryLabel
        unitLabel.text = "ml"

        let textFieldContainer = UIView().useAutoLayout()
        textFieldContainer.layer.cornerRadius = 8
        textFieldContainer.layer.borderWidth = 1
        textFieldContainer.layer.borderColor = UIColor.black.withAlphaComponent(0.18).cgColor
        textFieldContainer.addSubview(valueTextField)
        textFieldContainer.addSubview(unitLabel)
        view.addSubview(textFieldContainer)

        NSLayoutConstraint.activate([
            topRow.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 28),
            topRow.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            topRow.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            topRow.heightAnchor.constraint(equalToConstant: 40),

            titleLabel.centerXAnchor.constraint(equalTo: topRow.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: topRow.centerYAnchor),

            confirmButton.trailingAnchor.constraint(equalTo: topRow.trailingAnchor),
            confirmButton.centerYAnchor.constraint(equalTo: topRow.centerYAnchor),

            textFieldContainer.topAnchor.constraint(equalTo: topRow.bottomAnchor, constant: 28),
            textFieldContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textFieldContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            textFieldContainer.heightAnchor.constraint(equalToConstant: 46),

            unitLabel.trailingAnchor.constraint(equalTo: textFieldContainer.trailingAnchor, constant: -16),
            unitLabel.centerYAnchor.constraint(equalTo: textFieldContainer.centerYAnchor),

            valueTextField.topAnchor.constraint(equalTo: textFieldContainer.topAnchor),
            valueTextField.leadingAnchor.constraint(equalTo: textFieldContainer.leadingAnchor, constant: 16),
            valueTextField.trailingAnchor.constraint(equalTo: unitLabel.leadingAnchor, constant: -12),
            valueTextField.bottomAnchor.constraint(equalTo: textFieldContainer.bottomAnchor)
        ])
    }

    @objc private func confirmAmount() {
        guard let amount = Int(valueTextField.text ?? ""), amount > 0 else { return }
        store.addDrink(kind, amount: amount)
        dismiss(animated: true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        confirmAmount()
        return true
    }
}

final class BloomoraWallpaperPreviewViewController: UIViewController {
    private let flower: GardenFlower
    private let stage: FlowerStage

    private let canvasView: BloomoraWallpaperCanvasView
    private let downloadButton = UIButton(type: .system).useAutoLayout()

    init(flower: GardenFlower, stage: FlowerStage) {
        self.flower = flower
        self.stage = stage
        canvasView = BloomoraWallpaperCanvasView(flower: flower, stage: stage).useAutoLayout()
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .bloomoraBackground
        configure()
    }

    private func configure() {
        let backButton = UIButton(type: .system).useAutoLayout()
        let backConfig = UIImage.SymbolConfiguration(pointSize: 23, weight: .medium)
        backButton.setImage(UIImage(systemName: "arrow.left", withConfiguration: backConfig), for: .normal)
        backButton.tintColor = .black
        backButton.addTarget(self, action: #selector(closePreview), for: .touchUpInside)

        let titleLabel = UILabel().useAutoLayout()
        titleLabel.font = .bloomoraRounded(size: 19, weight: .medium)
        titleLabel.text = "Make Wallpaper"
        titleLabel.textAlignment = .center

        downloadButton.setTitle("Download", for: .normal)
        downloadButton.titleLabel?.font = .bloomoraRounded(size: 19, weight: .medium)
        downloadButton.setTitleColor(.bloomoraGoalGreen, for: .normal)
        downloadButton.addTarget(self, action: #selector(startDownloadFlow), for: .touchUpInside)

        let topBar = UIView().useAutoLayout()
        view.addSubview(topBar)
        topBar.addSubview(backButton)
        topBar.addSubview(titleLabel)
        topBar.addSubview(downloadButton)
        view.addSubview(canvasView)

        NSLayoutConstraint.activate([
            topBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            topBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            topBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            topBar.heightAnchor.constraint(equalToConstant: 40),

            backButton.leadingAnchor.constraint(equalTo: topBar.leadingAnchor),
            backButton.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 40),
            backButton.heightAnchor.constraint(equalToConstant: 40),

            titleLabel.centerXAnchor.constraint(equalTo: topBar.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),

            downloadButton.trailingAnchor.constraint(equalTo: topBar.trailingAnchor),
            downloadButton.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),

            canvasView.topAnchor.constraint(equalTo: topBar.bottomAnchor, constant: 18),
            canvasView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            canvasView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            canvasView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -12)
        ])
    }

    @objc private func closePreview() {
        dismiss(animated: true)
    }

    @objc private func startDownloadFlow() {
        downloadButton.isEnabled = false
        Task { [weak self] in
            await self?.downloadAndShareWallpaper()
        }
    }

    @MainActor
    private func downloadAndShareWallpaper() async {
        defer { downloadButton.isEnabled = true }

        guard let image = wallpaperImage() else {
            showAlert(message: "Couldn't create the wallpaper image.")
            return
        }

        do {
            try await BloomoraWallpaperSaver.save(image: image)
            let shareSheet = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            if let popover = shareSheet.popoverPresentationController {
                popover.sourceView = downloadButton
                popover.sourceRect = downloadButton.bounds
            }
            present(shareSheet, animated: true)
        } catch {
            showAlert(message: "Couldn't save to Photos. Please allow photo access and try again.")
        }
    }

    private func wallpaperImage() -> UIImage? {
        canvasView.renderedImage(size: CGSize(width: 1179, height: 2556))
    }

    @MainActor
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Download", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(alert, animated: true)
    }
}

private enum BloomoraWallpaperSaver {
    static func save(image: UIImage) async throws {
        let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        guard status == .authorized || status == .limited else {
            throw BloomoraWallpaperError.photosPermissionDenied
        }

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }) { success, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if success {
                    continuation.resume()
                } else {
                    continuation.resume(throwing: BloomoraWallpaperError.saveFailed)
                }
            }
        }
    }
}

private func configureBloomoraSheet(
    _ controller: UIViewController,
    height: CGFloat,
    identifier: String
) {
    if let sheet = controller.sheetPresentationController {
        let detentIdentifier = UISheetPresentationController.Detent.Identifier(identifier)
        sheet.detents = [
            .custom(identifier: detentIdentifier) { _ in height }
        ]
        sheet.prefersGrabberVisible = false
    }
}

private enum BloomoraWallpaperError: Error {
    case photosPermissionDenied
    case saveFailed
}
