import UIKit
import AVFoundation

// Inline fallback implementation to avoid target-membership issues.
// If you later add Audio/CelebrationSoundPlayer.swift to the target, remove this inline type.
final class CelebrationSoundPlayerInline {
    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()     // melody
    private let fxPlayer = AVAudioPlayerNode()   // skitter FX
    private var isSetup = false

    private(set) var currentCueDuration: TimeInterval = 0

    enum Waveform { case sine, square, triangle }

    struct Tone {
        let frequency: Float   // Hz, 0 for rest
        let duration: Double   // seconds
        let waveform: Waveform
        let tremoloDepth: Float // 0..1, amplitude modulation amount
        let tremoloRate: Float  // Hz
    }

    func playCelebration() {
        setupIfNeeded()

        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, options: [.mixWithOthers])
        try? session.setActive(true, options: [])

        let mixerFormat = engine.mainMixerNode.outputFormat(forBus: 0)
        let sampleRate = mixerFormat.sampleRate
        let channelCount = Int(mixerFormat.channelCount)

        // ~6 seconds of varying tones: melody + rests + final chord
        let tones: [Tone] = [
            // Intro arpeggio
            .init(frequency: 523.25, duration: 0.25, waveform: .sine,     tremoloDepth: 0.1, tremoloRate: 6), // C5
            .init(frequency: 659.25, duration: 0.25, waveform: .triangle, tremoloDepth: 0.1, tremoloRate: 6), // E5
            .init(frequency: 783.99, duration: 0.25, waveform: .square,   tremoloDepth: 0.05, tremoloRate: 8), // G5
            .init(frequency: 0,       duration: 0.05, waveform: .sine,     tremoloDepth: 0,   tremoloRate: 0), // rest
            .init(frequency: 1046.5, duration: 0.40, waveform: .sine,     tremoloDepth: 0.15, tremoloRate: 5), // C6

            // Little melody
            .init(frequency: 987.77, duration: 0.28, waveform: .triangle, tremoloDepth: 0.1, tremoloRate: 7), // B5
            .init(frequency: 880.00, duration: 0.22, waveform: .square,   tremoloDepth: 0.05, tremoloRate: 9), // A5
            .init(frequency: 783.99, duration: 0.24, waveform: .sine,     tremoloDepth: 0.12, tremoloRate: 6), // G5
            .init(frequency: 659.25, duration: 0.26, waveform: .triangle, tremoloDepth: 0.08, tremoloRate: 7), // E5
            .init(frequency: 0,       duration: 0.06, waveform: .sine,     tremoloDepth: 0,   tremoloRate: 0), // rest
            .init(frequency: 783.99, duration: 0.24, waveform: .square,   tremoloDepth: 0.05, tremoloRate: 9), // G5
            .init(frequency: 880.00, duration: 0.20, waveform: .triangle, tremoloDepth: 0.1, tremoloRate: 6), // A5
            .init(frequency: 987.77, duration: 0.32, waveform: .sine,     tremoloDepth: 0.15, tremoloRate: 5), // B5
            .init(frequency: 0,       duration: 0.08, waveform: .sine,     tremoloDepth: 0,   tremoloRate: 0), // rest

            // Descend and cadence
            .init(frequency: 880.00, duration: 0.22, waveform: .triangle, tremoloDepth: 0.12, tremoloRate: 6), // A5
            .init(frequency: 783.99, duration: 0.22, waveform: .sine,     tremoloDepth: 0.1, tremoloRate: 6),  // G5
            .init(frequency: 659.25, duration: 0.28, waveform: .square,   tremoloDepth: 0.06, tremoloRate: 8), // E5
            .init(frequency: 587.33, duration: 0.26, waveform: .triangle, tremoloDepth: 0.08, tremoloRate: 7), // D5
            .init(frequency: 523.25, duration: 0.34, waveform: .sine,     tremoloDepth: 0.12, tremoloRate: 5), // C5
        ]

        var totalDuration = 0.0

        for tone in tones {
            let buffer = Self.makeToneBuffer(tone: tone, sampleRate: sampleRate, channels: channelCount)
            player.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
            totalDuration += tone.duration
        }

        // Final bright C major chord (C5-E5-G5)
        let chord = Self.makeChordBuffer(frequencies: [523.25, 659.25, 783.99], duration: 0.9, sampleRate: sampleRate, channels: channelCount)
        player.scheduleBuffer(chord, at: nil, options: [], completionHandler: nil)
        totalDuration += 0.9

        // Skitter FX track (low-level noise bursts under the melody)
        let skitter = Self.makeSkitterTrackBuffer(totalDuration: totalDuration, sampleRate: sampleRate, channels: channelCount)
        fxPlayer.scheduleBuffer(skitter, at: nil, options: [], completionHandler: nil)

        if !engine.isRunning {
            engine.prepare()
            try? engine.start()
        }
        currentCueDuration = totalDuration
        player.play()
        fxPlayer.play()

        // Auto-stop after the full cue
        DispatchQueue.main.asyncAfter(deadline: .now() + totalDuration + 0.1) { [weak self] in
            self?.stop()
        }
    }

    func stop() {
        player.stop()
        fxPlayer.stop()
        if engine.isRunning {
            engine.pause()
        }
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    private func setupIfNeeded() {
        guard !isSetup else { return }
        engine.attach(player)
        engine.attach(fxPlayer)
        // Allow automatic format conversion to the mixer format to avoid channel mismatch crashes
        engine.connect(player, to: engine.mainMixerNode, format: nil)
        engine.connect(fxPlayer, to: engine.mainMixerNode, format: nil)
        engine.prepare()
        isSetup = true
    }

    private static func makeToneBuffer(tone: Tone, sampleRate: Double, channels: Int) -> AVAudioPCMBuffer {
        return makeToneBuffer(frequency: tone.frequency,
                              duration: tone.duration,
                              sampleRate: sampleRate,
                              channels: channels,
                              waveform: tone.waveform,
                              tremoloDepth: tone.tremoloDepth,
                              tremoloRate: tone.tremoloRate)
    }

    private static func makeToneBuffer(frequency: Float, duration: Double, sampleRate: Double, channels: Int, waveform: Waveform, tremoloDepth: Float, tremoloRate: Float) -> AVAudioPCMBuffer {
        let frameCount = AVAudioFrameCount(max(1, Int(duration * sampleRate)))
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: AVAudioChannelCount(max(1, channels)))!
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount)!
        buffer.frameLength = frameCount

        let totalFrames = Int(frameCount)
        let twoPi = Float.pi * 2

        // Envelope to avoid clicks
        let attackFrames = max(1, Int(0.01 * sampleRate))
        let releaseFrames = max(1, Int(0.03 * sampleRate))

        // Generate for each channel (duplicate mono signal)
        for ch in 0..<Int(format.channelCount) {
            let channel = buffer.floatChannelData![ch]
            var phase: Float = 0
            var t: Float = 0
            let dt: Float = 1.0 / Float(sampleRate)
            let phaseInc: Float = twoPi * max(0, frequency) / Float(sampleRate)

            for n in 0..<totalFrames {
                // Base waveform sample
                let raw: Float
                if frequency <= 0 { // rest
                    raw = 0
                } else {
                    switch waveform {
                    case .sine:
                        raw = sin(phase)
                    case .square:
                        raw = sin(phase) >= 0 ? 1 : -1
                    case .triangle:
                        // Triangle from sine phase
                        let v = (phase / Float.pi).truncatingRemainder(dividingBy: 2)
                        raw = (v < 1 ? (2 * v - 1) : (1 - 2 * (v - 1)))
                    }
                }

                // Tremolo: bounded 0..1 around (1 - depth) .. 1
                let trem = (1 - tremoloDepth) + tremoloDepth * 0.5 * (1 + sin(twoPi * tremoloRate * t))

                // Simple envelope
                var env: Float = 1.0
                if n < attackFrames {
                    env = Float(n) / Float(attackFrames)
                } else if n > totalFrames - releaseFrames {
                    env = Float(totalFrames - n) / Float(releaseFrames)
                }

                // Final sample with conservative gain to avoid clipping
                channel[n] = raw * env * trem * 0.22

                // Advance time/phase
                t += dt
                phase += phaseInc
                if phase > twoPi { phase -= twoPi }
            }
        }

        return buffer
    }

    private static func makeChordBuffer(frequencies: [Float], duration: Double, sampleRate: Double, channels: Int) -> AVAudioPCMBuffer {
        let frameCount = AVAudioFrameCount(max(1, Int(duration * sampleRate)))
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: AVAudioChannelCount(max(1, channels)))!
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount)!
        buffer.frameLength = frameCount

        let totalFrames = Int(frameCount)
        let twoPi = Float.pi * 2
        var phases = frequencies.map { _ in Float(0) }
        let phaseIncs = frequencies.map { twoPi * $0 / Float(sampleRate) }

        let attackFrames = max(1, Int(0.02 * sampleRate))
        let releaseFrames = max(1, Int(0.06 * sampleRate))

        for ch in 0..<Int(format.channelCount) {
            let channel = buffer.floatChannelData![ch]
            for n in 0..<totalFrames {
                var sum: Float = 0
                for i in 0..<frequencies.count {
                    sum += sin(phases[i])
                    phases[i] += phaseIncs[i]
                    if phases[i] > twoPi { phases[i] -= twoPi }
                }
                // Normalize by number of voices and apply envelope
                var env: Float = 1.0
                if n < attackFrames {
                    env = Float(n) / Float(attackFrames)
                } else if n > totalFrames - releaseFrames {
                    env = Float(totalFrames - n) / Float(releaseFrames)
                }
                channel[n] = (sum / Float(max(1, frequencies.count))) * env * 0.28
            }
        }

        return buffer
    }

    private static func makeSkitterTrackBuffer(totalDuration: Double, sampleRate: Double, channels: Int) -> AVAudioPCMBuffer {
        let frameCount = AVAudioFrameCount(max(1, Int(totalDuration * sampleRate)))
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: AVAudioChannelCount(max(1, channels)))!
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount)!
        buffer.frameLength = frameCount

        let totalFrames = Int(frameCount)
        var n = 0
        while n < totalFrames {
            let gapFrames = Int(Double.random(in: 0.015...0.085) * sampleRate)
            n = min(totalFrames, n + gapFrames)
            if n >= totalFrames { break }

            let burstFrames = Int(Double.random(in: 0.02...0.06) * sampleRate)
            let attack = max(1, Int(0.003 * sampleRate))
            let release = max(1, Int(0.015 * sampleRate))

            for ch in 0..<Int(format.channelCount) {
                let channel = buffer.floatChannelData![ch]
                for i in 0..<burstFrames {
                    let idx = n + i
                    if idx >= totalFrames { break }
                    let noise = Float.random(in: -1...1)
                    var env: Float = 1.0
                    if i < attack { env = Float(i) / Float(attack) }
                    else if i > burstFrames - release { env = Float(burstFrames - i) / Float(release) }
                    channel[idx] += noise * env * 0.08
                }
            }
            n = min(totalFrames, n + burstFrames)
        }

        return buffer
    }
}

// Overlay view for spiders crawling across the screen
final class SpiderOverlayView: UIView {

    struct Config {
        let spiderCount: Int
        let duration: TimeInterval
        let emoji: String
    }

    private var spiderLabels: [UILabel] = []
    private var removalWorkItem: DispatchWorkItem?

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        backgroundColor = .clear
        accessibilityIgnoresInvertColors = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func start(config: Config) {
        layer.removeAllAnimations()
        spiderLabels.forEach { $0.layer.removeAllAnimations(); $0.removeFromSuperview() }
        spiderLabels.removeAll()

        for _ in 0..<config.spiderCount {
            let label = UILabel()
            label.text = config.emoji
            label.font = UIFont.systemFont(ofSize: CGFloat(Int.random(in: 80...120)))
            label.sizeToFit()
            label.alpha = 0.95
            addSubview(label)

            let start = randomEdgeStart()
            label.center = start

            let path = makeSkitterPath(from: start, in: bounds)

            let move = CAKeyframeAnimation(keyPath: "position")
            move.path = path.cgPath
            move.duration = config.duration * Double.random(in: 0.85...1.05)
            move.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            move.fillMode = .forwards
            move.isRemovedOnCompletion = false

            let wiggle = CAKeyframeAnimation(keyPath: "transform.translation")
            wiggle.values = randomWiggleValues(count: 20, amplitude: 2.0)
            wiggle.duration = 0.6
            wiggle.repeatCount = Float(ceil(move.duration / 0.6))
            wiggle.isAdditive = true

            let rotate = CAKeyframeAnimation(keyPath: "transform.rotation.z")
            rotate.values = randomRotationValues(count: 12, amplitude: .pi / 32)
            rotate.duration = 0.8
            rotate.repeatCount = Float(ceil(move.duration / 0.8))
            rotate.isAdditive = true

            let group = CAAnimationGroup()
            group.animations = [move, wiggle, rotate]
            group.duration = move.duration
            group.fillMode = .forwards
            group.isRemovedOnCompletion = false

            label.layer.add(group, forKey: "spider_move")
            spiderLabels.append(label)
        }

        let work = DispatchWorkItem { [weak self] in
            self?.tearDown()
        }
        removalWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + config.duration + 0.2, execute: work)
    }

    func tearDown() {
        removalWorkItem?.cancel()
        removalWorkItem = nil
        layer.removeAllAnimations()
        UIView.animate(withDuration: 0.25, animations: {
            self.alpha = 0
        }, completion: { _ in
            self.spiderLabels.forEach { $0.layer.removeAllAnimations(); $0.removeFromSuperview() }
            self.spiderLabels.removeAll()
            self.removeFromSuperview()
            self.alpha = 1
        })
    }

    private func randomEdgeStart() -> CGPoint {
        guard bounds.width > 0, bounds.height > 0 else { return .zero }
        let edge = Int.random(in: 0..<4)
        switch edge {
        case 0: // top
            return CGPoint(x: CGFloat.random(in: 0...bounds.width), y: 0)
        case 1: // bottom
            return CGPoint(x: CGFloat.random(in: 0...bounds.width), y: bounds.height)
        case 2: // left
            return CGPoint(x: 0, y: CGFloat.random(in: 0...bounds.height))
        default: // right
            return CGPoint(x: bounds.width, y: CGFloat.random(in: 0...bounds.height))
        }
    }

    private func makeSkitterPath(from start: CGPoint, in rect: CGRect) -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: start)

        let center = CGPoint(x: rect.midX, y: rect.midY)
        var last = start
        var horizontalNext = Bool.random()
        let segments = Int.random(in: 4...6)

        for i in 0..<segments {
            if i == 1 {
                let target = horizontalNext
                    ? CGPoint(x: CGFloat.random(in: max(0, center.x - rect.width * 0.15)...min(rect.width, center.x + rect.width * 0.15)), y: last.y)
                    : CGPoint(x: last.x, y: CGFloat.random(in: max(0, center.y - rect.height * 0.15)...min(rect.height, center.y + rect.height * 0.15)))
                path.addLine(to: target)
                last = target
                horizontalNext.toggle()
                continue
            }

            if horizontalNext {
                let x: CGFloat
                if last.x < rect.midX {
                    x = CGFloat.random(in: rect.midX...(rect.width - 10))
                } else {
                    x = CGFloat.random(in: 10...rect.midX)
                }
                let p = CGPoint(x: x, y: last.y.clamped(10, rect.height - 10))
                path.addLine(to: p)
                last = p
            } else {
                let y: CGFloat
                if last.y < rect.midY {
                    y = CGFloat.random(in: rect.midY...(rect.height - 10))
                } else {
                    y = CGFloat.random(in: 10...rect.midY)
                }
                let p = CGPoint(x: last.x.clamped(10, rect.width - 10), y: y)
                path.addLine(to: p)
                last = p
            }
            horizontalNext.toggle()
        }
        return path
    }

    private func randomWiggleValues(count: Int, amplitude: CGFloat) -> [NSValue] {
        var values: [NSValue] = []
        for _ in 0..<count {
            let dx = CGFloat.random(in: -amplitude...amplitude)
            let dy = CGFloat.random(in: -amplitude...amplitude)
            values.append(NSValue(cgPoint: CGPoint(x: dx, y: dy)))
        }
        return values
    }

    private func randomRotationValues(count: Int, amplitude: CGFloat) -> [NSNumber] {
        var values: [NSNumber] = []
        for _ in 0..<count {
            values.append(NSNumber(value: Float(CGFloat.random(in: -amplitude...amplitude))))
        }
        return values
    }
}

private extension CGFloat {
    func clamped(_ low: CGFloat, _ high: CGFloat) -> CGFloat {
        return Swift.min(Swift.max(self, low), high)
    }
}

class MainViewController: UIViewController {

    private let letterSets: [LetterSet] = WordDataManager.shared.letterSets.shuffled()
    private var currentLetterSetIndex = 0
    private var currentPageIndex = 0
    private var currentLetterSet: LetterSet?
    private var currentPages: [[WordItem]] = []
    private var tracedCount = 0
    private let celebrationSoundPlayer = CelebrationSoundPlayerInline()
    private var spiderOverlay: SpiderOverlayView?
    private var isCelebrating = false

    // UI Components
    private let progressLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let letterTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let gridStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("← Back", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let forwardButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Forward →", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Next Page", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
    }()

    private var wordItemViews: [WordItemView] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        loadLetterSet()
        updateUI()
    }

    private func setupView() {
        view.backgroundColor = .systemBackground
        title = "Letter Tracing"

        view.addSubview(progressLabel)
        view.addSubview(letterTitleLabel)
        view.addSubview(gridStackView)
        view.addSubview(backButton)
        view.addSubview(forwardButton)
        view.addSubview(nextButton)

        // Setup grid (2 rows x 2 columns)
        for _ in 0..<2 {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = 16
            rowStack.distribution = .fillEqually

            for _ in 0..<2 {
                let wordItemView = WordItemView()
                wordItemViews.append(wordItemView)
                rowStack.addArrangedSubview(wordItemView)
            }

            gridStackView.addArrangedSubview(rowStack)
        }

        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        forwardButton.addTarget(self, action: #selector(forwardButtonTapped), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            progressLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            progressLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            letterTitleLabel.topAnchor.constraint(equalTo: progressLabel.bottomAnchor, constant: 12),
            letterTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            gridStackView.topAnchor.constraint(equalTo: letterTitleLabel.bottomAnchor, constant: 24),
            gridStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            gridStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            gridStackView.bottomAnchor.constraint(equalTo: backButton.topAnchor, constant: -24),

            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            backButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            backButton.heightAnchor.constraint(equalToConstant: 50),
            backButton.widthAnchor.constraint(equalToConstant: 120),

            forwardButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            forwardButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            forwardButton.heightAnchor.constraint(equalToConstant: 50),
            forwardButton.widthAnchor.constraint(equalToConstant: 140),

            nextButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            nextButton.heightAnchor.constraint(equalToConstant: 50),
            nextButton.widthAnchor.constraint(equalToConstant: 200)
        ])
    }

    private func loadLetterSet() {
        guard currentLetterSetIndex < letterSets.count else {
            // All letter sets completed
            showCompletionMessage()
            return
        }

        currentLetterSet = letterSets[currentLetterSetIndex]
        if let letterSet = currentLetterSet {
            currentPages = WordDataManager.shared.getPages(for: letterSet)
        }
        currentPageIndex = 0
        tracedCount = 0
    }

    private func updateUI() {
        guard let letterSet = currentLetterSet,
              currentPageIndex < currentPages.count else { return }

        let currentWords = currentPages[currentPageIndex]

        // Update labels
        letterTitleLabel.text = "Letter: \(letterSet.letter.uppercased())"
        progressLabel.text = "Page \(currentPageIndex + 1) of 2 | Set \(currentLetterSetIndex + 1) of \(letterSets.count)"

        // Configure word item views
        for (index, wordItemView) in wordItemViews.enumerated() {
            if index < currentWords.count {
                wordItemView.configure(with: currentWords[index], tracingLetter: letterSet.letter)
                wordItemView.isHidden = false
            } else {
                wordItemView.isHidden = true
            }
        }

        // Update button states
        backButton.isEnabled = currentPageIndex > 0 || currentLetterSetIndex > 0
        backButton.alpha = backButton.isEnabled ? 1.0 : 0.5

        nextButton.isHidden = true
    }

    @objc private func backButtonTapped() {
        if currentPageIndex > 0 {
            currentPageIndex -= 1
            tracedCount = 0
        } else if currentLetterSetIndex > 0 {
            currentLetterSetIndex -= 1
            loadLetterSet()
            currentPageIndex = currentPages.count - 1
        }
        updateUI()
        resetTracingViews()
    }

    @objc private func forwardButtonTapped() {
        tracedCount += 1

        if tracedCount >= 4 {
            // All 4 letters on current page traced
            showCelebration()
        }
    }

    @objc private func nextButtonTapped() {
        nextButton.isHidden = true
        tracedCount = 0

        if currentPageIndex < currentPages.count - 1 {
            currentPageIndex += 1
            updateUI()
            resetTracingViews()
        } else {
            // Move to next letter set
            currentLetterSetIndex += 1
            loadLetterSet()
            updateUI()
            resetTracingViews()
        }
    }

    private func resetTracingViews() {
        for wordItemView in wordItemViews {
            wordItemView.resetTracing()
        }
    }

    private func showCelebration() {
        guard !isCelebrating else { return }
        isCelebrating = true

        // Start celebration music + skitter FX
        celebrationSoundPlayer.playCelebration()

        // Great Job label
        let celebrationLabel = UILabel()
        celebrationLabel.text = "🎉 Great Job! 🎉"
        celebrationLabel.font = UIFont.systemFont(ofSize: 48, weight: .bold)
        celebrationLabel.textAlignment = .center
        celebrationLabel.alpha = 0
        celebrationLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(celebrationLabel)
        NSLayoutConstraint.activate([
            celebrationLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            celebrationLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        // Spider overlay on top of everything
        let overlay = SpiderOverlayView(frame: view.bounds)
        overlay.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(overlay)
        NSLayoutConstraint.activate([
            overlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlay.topAnchor.constraint(equalTo: view.topAnchor),
            overlay.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        spiderOverlay = overlay

        // Start spiders for the duration of the music (fallback to 7s)
        let duration = celebrationSoundPlayer.currentCueDuration > 0 ? celebrationSoundPlayer.currentCueDuration : 7.0
        overlay.start(config: .init(spiderCount: 10, duration: duration, emoji: "🕷️"))

        // Animate label
        UIView.animate(withDuration: 0.5, animations: {
            celebrationLabel.alpha = 1.0
            celebrationLabel.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: 1.0, options: [], animations: {
                celebrationLabel.alpha = 0
                celebrationLabel.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }) { [weak self] _ in
                celebrationLabel.removeFromSuperview()
                self?.nextButton.isHidden = false
                self?.isCelebrating = false
                // Overlay and audio auto-stop on their own timers
            }
        }
    }

    private func showCompletionMessage() {
        let alert = UIAlertController(title: "Congratulations!", message: "You've completed all letter sets!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Restart", style: .default) { _ in
            self.currentLetterSetIndex = 0
            self.loadLetterSet()
            self.updateUI()
            self.resetTracingViews()
        })
        present(alert, animated: true)
    }
}
