import Photos
import SwiftUI
import UIKit

// MARK: - Profile View (Screenshot 1: "My" screen)
struct BloomoraProfileView: View {
    let store: BloomoraStore
    @State private var isGoalSheetPresented = false

    var body: some View {
        ZStack {
            Color(red: 0.949, green: 0.949, blue: 0.957).ignoresSafeArea()
            AmbientFlowerBackdrop()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    BloomoraHeader(title: "My")

                    // Large flower count
                    VStack(spacing: 4) {
                        Text("\(store.unlockedFlowerCount)")
                            .font(.system(size: 96, weight: .ultraLight, design: .serif))
                            .italic()
                            .foregroundStyle(Color(red: 0.10, green: 0.10, blue: 0.10))

                        Text("My flowers")
                            .font(.system(size: 17, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 14)

                    // Menu rows
                    VStack(spacing: 14) {
                        NavigationLink(value: BloomoraDestination.flowers) {
                            BloomoraMenuRow(icon: "camera.macro", title: "My flowers")
                        }
                        .buttonStyle(.plain)

                        Button {
                            isGoalSheetPresented = true
                        } label: {
                            BloomoraMenuRow(
                                icon: "cup.and.saucer",
                                title: "Daily goal",
                                trailing: "\(store.dailyGoal)ml"
                            )
                        }
                        .buttonStyle(.plain)

                        NavigationLink(value: BloomoraDestination.records) {
                            BloomoraMenuRow(icon: "calendar", title: "Water Intake Records")
                        }
                        .buttonStyle(.plain)

                        NavigationLink(value: BloomoraDestination.reminders) {
                            BloomoraMenuRow(icon: "bell", title: "Reminders")
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.top, 6)
                }
                .padding(.horizontal, 22)
                .padding(.top, 6)
                .padding(.bottom, 40)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $isGoalSheetPresented) {
            BloomoraGoalSheet(store: store)
                .presentationDetents([.height(340)])
                .presentationDragIndicator(.hidden)
        }
    }
}

// MARK: - Flower Gallery View
struct BloomoraFlowerGalleryView: View {
    let store: BloomoraStore

    @State private var selectedFlowerID: GardenFlower.ID?
    @State private var wallpaperFlower: GardenFlower?

    var body: some View {
        let flowers = store.sortedFlowers
        let selectedFlower = flowers.first(where: { $0.id == selectedFlowerID }) ?? flowers.first

        GeometryReader { proxy in
            let cardWidth = min(proxy.size.width - 96, 332.0)
            let sideInset = max((proxy.size.width - cardWidth) / 2, 24)

            VStack(spacing: 0) {
                BloomoraHeader(title: "My flowers")
                    .padding(.horizontal, 22)
                    .padding(.top, 6)

                if flowers.isEmpty {
                    Spacer()
                    Text("Start logging drinks to grow your first flower.")
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    Spacer()
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 18) {
                            ForEach(flowers) { flower in
                                BloomoraFlowerPosterCard(
                                    flower: flower,
                                    stage: store.stage(for: flower.plantedOn),
                                    width: cardWidth
                                )
                                .id(flower.id)
                                .scrollTransition(.interactive, axis: .horizontal) { content, phase in
                                    content.scaleEffect(phase.isIdentity ? 1 : 0.95)
                                }
                            }
                        }
                        .scrollTargetLayout()
                    }
                    .contentMargins(.horizontal, sideInset, for: .scrollContent)
                    .scrollTargetBehavior(.viewAligned)
                    .scrollPosition(id: $selectedFlowerID)
                    .frame(height: 560)
                    .padding(.top, 12)

                    Button {
                        wallpaperFlower = selectedFlower
                    } label: {
                        Text("Make wallpaper")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundStyle(.white)
                            .frame(width: 210, height: 58)
                            .background(
                                Capsule(style: .continuous)
                                    .fill(Color(red: 0.12, green: 0.13, blue: 0.14))
                            )
                    }
                    .buttonStyle(.plain)
                    .disabled(selectedFlower == nil)
                    .padding(.top, 18)

                    Text("Restore purchase")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                        .padding(.top, 34)

                    Spacer(minLength: 24)
                }
            }
            .onAppear {
                if selectedFlowerID == nil {
                    selectedFlowerID = flowers.first?.id
                }
            }
        }
        .background(Color(red: 0.949, green: 0.949, blue: 0.957).ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .fullScreenCover(item: $wallpaperFlower) { flower in
            BloomoraWallpaperPreview(
                flower: flower,
                stage: store.stage(for: flower.plantedOn)
            )
        }
    }
}

// MARK: - Records View (Screenshot 2: calendar + drink breakdown)
struct BloomoraRecordsView: View {
    let store: BloomoraStore
    @State private var displayedMonth: Date

    init(store: BloomoraStore) {
        self.store = store
        _displayedMonth = State(initialValue: store.startOfMonth(for: store.selectedDate))
    }

    var body: some View {
        let selectedDate = store.selectedDate

        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                BloomoraHeader(title: "Water Intake Records")

                // Month navigation
                HStack {
                    Button {
                        displayedMonth = Calendar(identifier: .gregorian)
                            .date(byAdding: .month, value: -1, to: displayedMonth) ?? displayedMonth
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    Text(BloomoraFormatters.monthTitle.string(from: displayedMonth))
                        .font(.system(size: 20, weight: .bold, design: .rounded))

                    Spacer()

                    Button {
                        displayedMonth = Calendar(identifier: .gregorian)
                            .date(byAdding: .month, value: 1, to: displayedMonth) ?? displayedMonth
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 4)

                // Calendar grid
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7),
                    spacing: 14
                ) {
                    ForEach(store.weekdaySymbols, id: \.self) { symbol in
                        Text(symbol)
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                    }

                    ForEach(
                        Array(store.monthGrid(for: displayedMonth).enumerated()),
                        id: \.offset
                    ) { _, date in
                        if let date {
                            Button {
                                store.selectedDate = date
                            } label: {
                                Text(BloomoraFormatters.dayNumber.string(from: date))
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundStyle(store.isSelected(date) ? .white : .primary)
                                    .frame(width: 40, height: 40)
                                    .background(
                                        Circle()
                                            .fill(
                                                store.isSelected(date)
                                                    ? Color(red: 0.44, green: 0.75, blue: 0.35)
                                                    : .clear
                                            )
                                    )
                            }
                            .buttonStyle(.plain)
                        } else {
                            Color.clear.frame(height: 40)
                        }
                    }
                }
                .padding(.top, 4)

                // Total intake card — light blue gradient matching screenshot
                ZStack {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.90, green: 0.93, blue: 0.97),
                                    Color(red: 0.86, green: 0.92, blue: 0.97)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    // Decorative circle (water ripple effect)
                    Circle()
                        .stroke(Color.white.opacity(0.75), lineWidth: 16)
                        .frame(width: 140, height: 140)
                        .offset(x: 78, y: -14)

                    HStack {
                        Text("Total Water Intake:")
                            .font(.system(size: 16, weight: .medium, design: .rounded))

                        Spacer()

                        Text("\(store.totalIntake(on: selectedDate))")
                            .font(.system(size: 30, weight: .light, design: .serif))
                            .italic()

                        Text("ml")
                            .font(.system(size: 18, weight: .light, design: .serif))
                            .italic()
                    }
                    .padding(.horizontal, 18)
                }
                .frame(height: 88)
                .padding(.top, 6)

                // Per-drink breakdown list
                VStack(spacing: 0) {
                    ForEach(Array(DrinkKind.allCases.enumerated()), id: \.element.id) { index, kind in
                        HStack(spacing: 14) {
                            Image(systemName: kind.symbolName)
                                .font(.system(size: 22))
                                .frame(width: 28)

                            Text(kind.title)
                                .font(.system(size: 17, weight: .medium, design: .rounded))

                            Spacer()

                            Text("\(store.amount(of: kind, on: selectedDate)) ml")
                                .font(.system(size: 17, weight: .medium, design: .rounded))
                        }
                        .padding(.vertical, 14)
                        .padding(.horizontal, 4)

                        if index < DrinkKind.allCases.count - 1 {
                            Divider()
                        }
                    }
                }
            }
            .padding(.horizontal, 18)
            .padding(.top, 6)
            .padding(.bottom, 24)
        }
        .background(Color(red: 0.949, green: 0.949, blue: 0.957).ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }
}

// MARK: - Logger View (Screenshot 3: drink cards with + buttons)
struct BloomoraLoggerView: View {
    let store: BloomoraStore

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                BloomoraHeader(title: "Record drinking water")

                ForEach(DrinkKind.allCases) { kind in
                    BloomoraDrinkCard(
                        kind: kind,
                        total: store.amount(of: kind, on: .now)
                    ) {
                        store.addDrink(kind)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 6)
            .padding(.bottom, 24)
        }
        .background(Color(red: 0.949, green: 0.949, blue: 0.957).ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }
}

// MARK: - Reminders View
struct BloomoraRemindersView: View {
    let store: BloomoraStore

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                BloomoraHeader(title: "Reminders")

                VStack(alignment: .leading, spacing: 8) {
                    Text("Flexible hydration rhythm")
                        .font(.system(size: 23, weight: .semibold, design: .serif))

                    Text("Gentle reminders skip your rest window and help space water intake throughout the day.")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 6)

                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(Color(red: 0.92, green: 0.97, blue: 0.93))
                    .overlay(
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Quiet times")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                            Text("No reminders from 10:00 PM to 8:00 AM and during lunch at 1:00 PM.")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundStyle(.secondary)
                        }
                        .padding(18)
                    )
                    .frame(height: 104)

                VStack(spacing: 12) {
                    ForEach(store.reminders) { reminder in
                        HStack(spacing: 14) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(reminder.title)
                                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                                Text(BloomoraFormatters.reminderTime.string(from: reminder.date))
                                    .font(.system(size: 15, weight: .medium, design: .rounded))
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Toggle("", isOn: Binding(
                                get: { reminder.enabled },
                                set: { store.updateReminder(reminder.id, isEnabled: $0) }
                            ))
                            .labelsHidden()
                            .tint(Color(red: 0.40, green: 0.76, blue: 0.30))
                        }
                        .padding(.horizontal, 18)
                        .frame(height: 82)
                        .background(
                            RoundedRectangle(cornerRadius: 26, style: .continuous)
                                .fill(Color(red: 0.97, green: 0.97, blue: 0.98))
                        )
                    }
                }
                .padding(.top, 2)
            }
            .padding(.horizontal, 20)
            .padding(.top, 6)
            .padding(.bottom, 28)
        }
        .background(Color(red: 0.949, green: 0.949, blue: 0.957).ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }
}

// MARK: - Private subviews

private struct BloomoraGoalSheet: View {
    let store: BloomoraStore
    @Environment(\.dismiss) private var dismiss
    @State private var draftValue: String

    init(store: BloomoraStore) {
        self.store = store
        _draftValue = State(initialValue: "\(store.dailyGoal)")
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()

                Text("Daily goal")
                    .font(.system(size: 19, weight: .medium, design: .rounded))

                Spacer()

                Button("Confirm") {
                    if let amount = Int(draftValue) {
                        store.updateDailyGoal(to: amount)
                    }
                    dismiss()
                }
                .font(.system(size: 17, weight: .medium, design: .rounded))
                .foregroundStyle(Color(red: 0.25, green: 0.76, blue: 0.40))
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 18)

            TextField("", text: $draftValue)
                .keyboardType(.numberPad)
                .font(.system(size: 22, weight: .medium, design: .rounded))
                .padding(.horizontal, 16)
                .frame(height: 46)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(Color.black.opacity(0.18), lineWidth: 1)
                )
                .padding(.horizontal, 20)

            Spacer()
        }
        .background(Color(red: 0.949, green: 0.949, blue: 0.957))
    }
}

private struct BloomoraWallpaperPreview: View {
    let flower: GardenFlower
    let stage: FlowerStage
    @Environment(\.dismiss) private var dismiss
    @State private var sharePayload: BloomoraSharePayload?
    @State private var alertMessage: String?

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 23, weight: .medium))
                        .frame(width: 40, height: 40)
                }
                .buttonStyle(.plain)

                Spacer()

                Text("Make Wallpaper")
                    .font(.system(size: 19, weight: .medium, design: .rounded))

                Spacer()

                Button("Download") {
                    Task { await downloadAndShareWallpaper() }
                }
                .font(.system(size: 19, weight: .medium, design: .rounded))
                .foregroundStyle(Color(red: 0.23, green: 0.74, blue: 0.40))
            }
            .padding(.horizontal, 18)
            .padding(.top, 8)

            BloomoraWallpaperCanvas(flower: flower, stage: stage)
                .padding(.top, 18)
                .padding(.bottom, 12)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color(red: 0.949, green: 0.949, blue: 0.957).ignoresSafeArea())
        .sheet(item: $sharePayload) { payload in
            BloomoraShareSheet(items: payload.items)
        }
        .alert("Download", isPresented: Binding(
            get: { alertMessage != nil },
            set: { if !$0 { alertMessage = nil } }
        )) {
            Button("OK", role: .cancel) { alertMessage = nil }
        } message: {
            Text(alertMessage ?? "")
        }
    }

    @MainActor
    private func downloadAndShareWallpaper() async {
        guard let image = wallpaperImage() else {
            alertMessage = "Couldn't create the wallpaper image."
            return
        }

        do {
            try await BloomoraWallpaperSaver.save(image: image)
            sharePayload = BloomoraSharePayload(items: [image])
        } catch {
            alertMessage = "Couldn't save to Photos. Please allow photo access and try again."
        }
    }

    @MainActor
    private func wallpaperImage() -> UIImage? {
        let content = BloomoraWallpaperCanvas(flower: flower, stage: stage)
            .frame(width: 1179, height: 2556)
            .background(Color(red: 0.949, green: 0.949, blue: 0.957))

        let renderer = ImageRenderer(content: content)
        renderer.scale = 1
        return renderer.uiImage
    }
}

private struct BloomoraFlowerPosterCard: View {
    let flower: GardenFlower
    let stage: FlowerStage
    let width: CGFloat

    var body: some View {
        RoundedRectangle(cornerRadius: 34, style: .continuous)
            .fill(Color(red: 0.93, green: 0.93, blue: 0.94))
            .overlay {
                BotanicalSceneView(species: flower.species, stage: stage)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
            }
            .frame(width: width, height: 486)
            .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))
    }
}

private struct BloomoraWallpaperCanvas: View {
    let flower: GardenFlower
    let stage: FlowerStage

    var body: some View {
        VStack(spacing: 0) {
            Text("Love is the flower you've got to let grow.")
                .font(.system(size: 17, weight: .medium, design: .rounded))
                .foregroundStyle(Color(red: 0.43, green: 0.47, blue: 0.50))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 28)
                .padding(.top, 18)

            BotanicalSceneView(species: flower.species, stage: stage)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top, 20)
                .padding(.bottom, 10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(red: 0.949, green: 0.949, blue: 0.957))
    }
}

private struct BloomoraSharePayload: Identifiable {
    let id = UUID()
    let items: [Any]
}

private struct BloomoraShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ controller: UIActivityViewController, context: Context) {
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

private enum BloomoraWallpaperError: Error {
    case photosPermissionDenied
    case saveFailed
}

// MARK: - Shared Header
struct BloomoraHeader: View {
    let title: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 21, weight: .medium))
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)

            Spacer()

            Text(title)
                .font(.system(size: 19, weight: .medium, design: .rounded))

            Spacer()

            Color.clear.frame(width: 32, height: 32)
        }
    }
}

// MARK: - Menu Row
private struct BloomoraMenuRow: View {
    let icon: String
    let title: String
    var trailing: String? = nil

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 21, weight: .medium))
                .frame(width: 28)

            Text(title)
                .font(.system(size: 17, weight: .medium, design: .rounded))

            Spacer()

            if let trailing {
                Text(trailing)
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color(red: 0.65, green: 0.65, blue: 0.65))
        }
        .padding(.horizontal, 22)
        .frame(height: 84)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(.white)
        )
    }
}

// MARK: - Drink Card (Screenshot 3: colored cards with + button)
private struct BloomoraDrinkCard: View {
    let kind: DrinkKind
    let total: Int
    let addAction: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: kind.symbolName)
                .font(.system(size: 30))
                .frame(width: 36)

            Text(kind.title)
                .font(.system(size: 19, weight: .medium, design: .rounded))

            Spacer()

            Text("\(total)ml")
                .font(.system(size: 19, weight: .medium, design: .rounded))

            Button(action: addAction) {
                Image(systemName: "plus")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Color(red: 0.45, green: 0.45, blue: 0.45))
                    .frame(width: 34, height: 34)
                    .background(Color(red: 0.949, green: 0.949, blue: 0.957))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .frame(height: 92)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(kind.cardTint)
        )
        // Milk card gets a subtle border since background is white
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(
                    kind == .milk ? Color.black.opacity(0.06) : Color.clear,
                    lineWidth: 1
                )
        )
    }
}
