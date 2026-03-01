import SwiftUI

struct SituationSelectionView: View {
    @EnvironmentObject var appState: AppState
    @Binding var showSettings: Bool
    @State private var selectedCategory: SituationCategory = .nature
    @State private var searchText = ""
    @State private var animateCards = false

    var filteredSituations: [Situation] {
        let categorySituations = Situation.situations(for: selectedCategory)
        if searchText.isEmpty {
            return categorySituations
        }
        return categorySituations.filter {
            $0.name.contains(searchText) || $0.subtitle.contains(searchText) || $0.description.contains(searchText)
        }
    }

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "0a0a0f"),
                    Color(hex: "0f0a1a"),
                    Color(hex: "0a0a0f")
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Ambient particles
            AmbientParticlesView()

            VStack(spacing: 0) {
                // Header
                headerView

                // Category tabs
                categoryTabs

                // Situation grid
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ],
                        spacing: 16
                    ) {
                        ForEach(Array(filteredSituations.enumerated()), id: \.element.id) { index, situation in
                            SituationCard(situation: situation)
                                .offset(y: animateCards ? 0 : 50)
                                .opacity(animateCards ? 1 : 0)
                                .animation(
                                    .spring(response: 0.6, dampingFraction: 0.8)
                                    .delay(Double(index) * 0.05),
                                    value: animateCards
                                )
                                .onTapGesture {
                                    selectSituation(situation)
                                }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear {
            withAnimation {
                animateCards = true
            }
        }
        .onChange(of: selectedCategory) { _ in
            animateCards = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation {
                    animateCards = true
                }
            }
        }
    }

    // MARK: - Header

    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Honne")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, Color(hex: "a0a0ff")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                Text("本音で話せる場所へ")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            Spacer()

            Button(action: { showSettings = true }) {
                Image(systemName: "gearshape.fill")
                    .font(.title3)
                    .foregroundColor(.gray)
                    .padding(10)
                    .background(Color.white.opacity(0.05))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }

    // MARK: - Category Tabs

    private var categoryTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(SituationCategory.allCases, id: \.self) { category in
                    CategoryTab(
                        category: category,
                        isSelected: selectedCategory == category
                    )
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3)) {
                            selectedCategory = category
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
    }

    // MARK: - Actions

    private func selectSituation(_ situation: Situation) {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()

        appState.selectedSituation = situation
        appState.isTransitioning = true
    }
}

// MARK: - Category Tab

struct CategoryTab: View {
    let category: SituationCategory
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: category.icon)
                .font(.caption)
            Text(category.rawValue)
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .foregroundColor(isSelected ? .white : .gray)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(isSelected ? Color.white.opacity(0.15) : Color.clear)
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(isSelected ? 0.3 : 0.1), lineWidth: 1)
                )
        )
    }
}

// MARK: - Situation Card

struct SituationCard: View {
    let situation: Situation
    @State private var isPressed = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Emoji icon
            Text(situation.emoji)
                .font(.system(size: 40))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 8)

            // Title
            Text(situation.name)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .lineLimit(1)

            // Subtitle
            Text(situation.subtitle)
                .font(.caption)
                .foregroundColor(.gray)
                .lineLimit(1)

            // Description
            Text(situation.description)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.5))
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: situation.gradientColors.map { $0.opacity(0.6) }),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.3), value: isPressed)
        .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

// MARK: - Ambient Particles (Home screen background)

struct AmbientParticlesView: View {
    @State private var particles: [AmbientParticle] = (0..<30).map { _ in AmbientParticle() }
    let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()

    var body: some View {
        Canvas { context, size in
            for particle in particles {
                let center = CGPoint(
                    x: particle.x * size.width,
                    y: particle.y * size.height
                )
                context.opacity = particle.opacity
                context.fill(
                    Circle().path(in: CGRect(
                        x: center.x - particle.size / 2,
                        y: center.y - particle.size / 2,
                        width: particle.size,
                        height: particle.size
                    )),
                    with: .color(.white.opacity(0.3))
                )
            }
        }
        .onReceive(timer) { _ in
            for i in particles.indices {
                particles[i].y -= particles[i].speed
                particles[i].x += sin(particles[i].y * 10) * 0.001
                particles[i].opacity = sin(particles[i].y * .pi) * 0.5

                if particles[i].y < -0.05 {
                    particles[i] = AmbientParticle()
                    particles[i].y = 1.05
                }
            }
        }
        .allowsHitTesting(false)
    }
}

struct AmbientParticle {
    var x = Double.random(in: 0...1)
    var y = Double.random(in: 0...1)
    var size = Double.random(in: 1...3)
    var speed = Double.random(in: 0.0005...0.002)
    var opacity = Double.random(in: 0.1...0.4)
}
