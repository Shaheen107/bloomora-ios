import SwiftUI

enum BloomoraDestination: Hashable {
    case mySpace
    case flowers
    case records
    case logger
    case reminders
}

struct ContentView: View {
    @State private var store = BloomoraStore()

    var body: some View {
        NavigationStack {
            BloomoraHomeView(store: store)
                .navigationDestination(for: BloomoraDestination.self) { destination in
                    switch destination {
                    case .mySpace:
                        BloomoraProfileView(store: store)
                    case .flowers:
                        BloomoraFlowerGalleryView(store: store)
                    case .records:
                        BloomoraRecordsView(store: store)
                    case .logger:
                        BloomoraLoggerView(store: store)
                    case .reminders:
                        BloomoraRemindersView(store: store)
                    }
                }
        }
        .tint(.black)
    }
}

private struct BloomoraHomeView: View {
    let store: BloomoraStore

    var body: some View {
        let today = Date()
        let total = store.totalIntake(on: today)
        let goal = store.dailyGoal
        let stage = store.stage(for: today)
        GeometryReader { proxy in
            ZStack {
                Color(red: 0.949, green: 0.949, blue: 0.957)
                    .ignoresSafeArea()

                if store.hasLoggedEntries {
                    BotanicalSceneView(species: .sunflower, stage: stage, style: .rooted)
                        .frame(width: proxy.size.width, height: proxy.size.height * 0.72, alignment: .bottom)
                        .ignoresSafeArea(edges: .bottom)
                        .allowsHitTesting(false)
                } else {
                    BloomoraEmptyHomeArtwork()
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .ignoresSafeArea(edges: .bottom)
                        .allowsHitTesting(false)
                }

                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(BloomoraFormatters.homeDate.string(from: today))
                                .font(.system(size: 18, weight: .medium, design: .rounded))
                                .foregroundStyle(.secondary)

                            Text("DRINKBLOOM")
                                .font(.system(size: 27, weight: .medium, design: .serif))
                        }

                        Spacer()

                        NavigationLink(value: BloomoraDestination.mySpace) {
                            Image(systemName: "line.3.horizontal")
                                .font(.system(size: 24, weight: .medium))
                                .frame(width: 42, height: 42)
                        }
                        .buttonStyle(.plain)
                    }

                    BloomoraProgressTrack(stage: stage)
                        .frame(height: 30)
                        .padding(.top, 18)

                    NavigationLink(value: BloomoraDestination.logger) {
                        HStack(alignment: .firstTextBaseline, spacing: 6) {
                            Text("\(total)/\(goal)")
                                .font(.system(size: 60, weight: .light, design: .serif))
                                .italic()
                                .lineLimit(1)
                                .minimumScaleFactor(0.4)

                            Text("ml")
                                .font(.system(size: 28, weight: .light, design: .serif))
                                .italic()
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 14)
                    }
                    .buttonStyle(.plain)

                    if !store.hasLoggedEntries {
                        VStack(spacing: 18) {
                            Image("FlowerSeed")
                                .resizable()
                                .interpolation(.high)
                                .scaledToFit()
                                .frame(width: 92, height: 92)

                            VStack(spacing: 10) {
                                Text("Flowers have been sown today")
                                    .font(.system(size: 19, weight: .medium, design: .rounded))
                                    .foregroundStyle(Color(red: 0.47, green: 0.50, blue: 0.52))

                                Text("Click on the number above to complete your water drinking goal and harvest your flowers.")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundStyle(Color(red: 0.56, green: 0.58, blue: 0.60))
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(6)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 26)
                    }

                    Spacer()
                }
                .padding(.horizontal, 28)
                .padding(.top, 10)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

private struct BloomoraEmptyHomeArtwork: View {
    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
                Spacer()

                Image("RootImg")
                    .resizable()
                    .interpolation(.high)
                    .scaledToFit()
                    .frame(width: proxy.size.width)
                    .offset(y: proxy.size.width * (12.0 / 600.0))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
    }
}

#Preview {
    ContentView()
}
