import Foundation
import AVFoundation

final class CelebrationSoundPlayer {
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
        let channels = Int(mixerFormat.channelCount)

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
            let buffer = Self.makeToneBuffer(tone: tone, sampleRate: sampleRate, channels: channels)
            player.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
            totalDuration += tone.duration
        }

        // Final bright C major chord (C5-E5-G5)
        let chord = Self.makeChordBuffer(frequencies: [523.25, 659.25, 783.99], duration: 0.9, sampleRate: sampleRate, channels: channels)
        player.scheduleBuffer(chord, at: nil, options: [], completionHandler: nil)
        totalDuration += 0.9

        // Skitter FX track (low-level noise bursts under the melody)
        let skitter = Self.makeSkitterTrackBuffer(totalDuration: totalDuration, sampleRate: sampleRate, channels: channels)
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
