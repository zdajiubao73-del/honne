import AVFoundation
import Combine
import SwiftUI

struct SituationSelectionView: View {
    @EnvironmentObject var appState: AppState
    @Environment(SubscriptionManager.self) var subscriptionManager
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Binding var showSettings: Bool
    @State private var selectedCategory: SituationCategory = .nature
    @State private var searchText = ""
    @State private var animateCards = false
    @State private var showPaywall = false

    private var gridColumns: [GridItem] {
        let columns = horizontalSizeClass == .regular ? 3 : 2
        return Array(repeating: GridItem(.flexible(), spacing: 16), count: columns)
    }

    private var horizontalPadding: CGFloat {
        horizontalSizeClass == .regular ? 24 : 16
    }

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
                    LazyVGrid(columns: gridColumns, spacing: 16) {
                        ForEach(Array(filteredSituations.enumerated()), id: \.element.id) { index, situation in
                            let isLocked = !situation.isFree && !subscriptionManager.isPremium
                            SituationCard(
                                situation: situation,
                                isLocked: isLocked,
                                onTap: {
                                    if isLocked {
                                        showPaywall = true
                                    } else {
                                        selectSituation(situation)
                                    }
                                }
                            )
                            .offset(y: animateCards ? 0 : 50)
                            .opacity(animateCards ? 1 : 0)
                            .animation(
                                .spring(response: 0.6, dampingFraction: 0.8)
                                .delay(Double(index) * 0.05),
                                value: animateCards
                            )
                        }
                    }
                    .padding(.horizontal, horizontalPadding)
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
        .onChange(of: selectedCategory) {
            animateCards = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation {
                    animateCards = true
                }
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
                .environment(subscriptionManager)
        }
    }

    // MARK: - Header

    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Honne")
                    .font(.system(size: horizontalSizeClass == .regular ? 40 : 32, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, Color(hex: "a0a0ff")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                Text("本音で話せる場所へ")
                    .font(horizontalSizeClass == .regular ? .body : .subheadline)
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
        .padding(.horizontal, horizontalPadding)
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
    var isLocked: Bool = false
    var onTap: () -> Void = {}
    @State private var floatOffset: CGFloat = 0
    @State private var glowOpacity: Double = 0.08
    @State private var floatDuration: Double = Double.random(in: 2.2...3.8)
    @State private var floatDelay: Double = Double.random(in: 0...2.5)
    @State private var floatAmount: CGFloat = CGFloat.random(in: 4...8)
    @State private var sketchImage: UIImage?

    private var backgroundGradient: some View {
        let colors = situation.gradientColors.map { $0.opacity(0.9) }
        return LinearGradient(
            gradient: Gradient(colors: colors),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var body: some View {
        Button(action: onTap) {
            // Color.clear でカードサイズを先に確定させる（横向き動画がサイズを広げるのを防ぐ）
            Color.clear
                .frame(maxWidth: .infinity)
                .aspectRatio(0.72, contentMode: .fit)
                .overlay(
                    ZStack(alignment: .bottomLeading) {
                        backgroundGradient

                        // 鉛筆スケッチ画像（動画フレームから生成）
                        if let sketchImage {
                            Image(uiImage: sketchImage)
                                .resizable()
                                .scaledToFill()
                                .clipped()
                                .blendMode(.screen)
                                .opacity(isLocked ? 0.3 : 0.65)
                        }

                        // Lock overlay for non-free situations
                        if isLocked {
                            Rectangle()
                                .fill(.ultraThinMaterial.opacity(0.6))
                            VStack(spacing: 6) {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(.white.opacity(0.9))
                                Text("Premium")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: 28))
            // ふわふわ雲ボーダー
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(Color.white.opacity(0.4), lineWidth: 2.5)
                    .blur(radius: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(Color.white.opacity(0.18), lineWidth: 1)
            )
            .shadow(color: Color.white.opacity(glowOpacity), radius: 14, x: 0, y: -2)
            .shadow(color: (situation.gradientColors.first ?? .purple).opacity(0.4), radius: 18, x: 0, y: 10)
            .shadow(color: Color.black.opacity(0.25), radius: 6, x: 0, y: 4)
        }
        .buttonStyle(SituationCardButtonStyle())
        .offset(y: floatOffset)
        .contentShape(Rectangle())
        .onAppear {
            loadSketchThumbnail()
            withAnimation(
                .easeInOut(duration: floatDuration)
                .repeatForever(autoreverses: true)
                .delay(floatDelay)
            ) {
                floatOffset = -floatAmount
                glowOpacity = 0.22
            }
        }
    }

    // MARK: - Sketch thumbnail generation

    private func loadSketchThumbnail() {
        guard let videoFileName = situation.videoFileName,
              let url = Bundle.main.url(forResource: videoFileName, withExtension: "mp4") else { return }

        let isIPad = UIDevice.current.userInterfaceIdiom == .pad
        let screenScale = UIScreen.main.scale
        Task.detached(priority: .userInitiated) {
            let asset = AVURLAsset(url: url)
            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true
            let thumbSize: CGFloat = isIPad ? 700 : 400
            generator.maximumSize = CGSize(width: thumbSize * screenScale, height: thumbSize * screenScale)

            let time = CMTime(seconds: 1.5, preferredTimescale: 600)
            guard let cgImage = try? generator.copyCGImage(at: time, actualTime: nil) else { return }

            guard let sketch = SituationCard.sketchFilter(UIImage(cgImage: cgImage)) else { return }
            await MainActor.run { sketchImage = sketch }
        }
    }

    /// 動画フレームに鉛筆スケッチフィルターを適用する
    /// 手法: カラードッジブレンドでスケッチ生成 → 反転してwhite lines on black
    static func sketchFilter(_ image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        let ciImage = CIImage(cgImage: cgImage)
        let extent = ciImage.extent

        // 1. グレースケール化
        guard let monoFilter = CIFilter(name: "CIPhotoEffectMono") else { return nil }
        monoFilter.setValue(ciImage, forKey: kCIInputImageKey)
        guard let monoOutput = monoFilter.outputImage else { return nil }

        // 2. 反転
        guard let invertFilter = CIFilter(name: "CIColorInvert") else { return nil }
        invertFilter.setValue(monoOutput, forKey: kCIInputImageKey)
        guard let invertOutput = invertFilter.outputImage else { return nil }

        // 3. ガウスぼかし（鉛筆線の太さに影響）
        guard let blurFilter = CIFilter(name: "CIGaussianBlur") else { return nil }
        blurFilter.setValue(invertOutput, forKey: kCIInputImageKey)
        blurFilter.setValue(5.0, forKey: kCIInputRadiusKey)
        guard let blurOutput = blurFilter.outputImage else { return nil }

        // 4. カラードッジブレンドでスケッチ生成（黒線・白背景）
        guard let dodgeFilter = CIFilter(name: "CIColorDodgeBlendMode") else { return nil }
        dodgeFilter.setValue(monoOutput, forKey: kCIInputBackgroundImageKey)
        dodgeFilter.setValue(blurOutput.cropped(to: extent), forKey: kCIInputImageKey)
        guard let sketchOutput = dodgeFilter.outputImage else { return nil }

        // 5. コントラスト強調
        guard let contrastFilter = CIFilter(name: "CIColorControls") else { return nil }
        contrastFilter.setValue(sketchOutput, forKey: kCIInputImageKey)
        contrastFilter.setValue(1.8, forKey: kCIInputContrastKey)
        contrastFilter.setValue(-0.05, forKey: kCIInputBrightnessKey)
        guard let contrastOutput = contrastFilter.outputImage else { return nil }

        // 6. 反転して白線・黒背景に（.screenブレンドで暗い背景に白線が浮き出る）
        guard let finalInvert = CIFilter(name: "CIColorInvert") else { return nil }
        finalInvert.setValue(contrastOutput, forKey: kCIInputImageKey)
        guard let finalOutput = finalInvert.outputImage else { return nil }

        let context = CIContext(options: [.useSoftwareRenderer: false])
        guard let outCGImage = context.createCGImage(finalOutput, from: extent) else { return nil }
        return UIImage(cgImage: outCGImage)
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

// MARK: - Situation Card Button Style

struct SituationCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3), value: configuration.isPressed)
    }
}
