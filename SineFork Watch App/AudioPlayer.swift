//
//  AudioPlayer.swift
//  SineFork Watch App
//
//

import Foundation
import AVFoundation

// Temperament definition
protocol Temperament {
    var name: String { get } // the name of the temperament
    var baseFrequencyA: Double { get } // base frequency. Concert A
    
    /// update changed base frequency
    mutating func setBaseFrequencyA(_ baseFrequencyA: Double)
    /// Return user-facing note labels
    func getNotes() -> [String]
    /// Return user facing note of octave
    func getNoteName(noteIndex: Int, octave: Int) -> String
    /// Compute frequency in Hz for a note index and octave
    func frequency(noteIndex: Int, octave: Int) -> Double
}


class EqualTemperament: Temperament {
    let name = "Equal"
    var baseFrequencyA: Double

    private let semitoneOffsets: [Double] = Array(-9...2).map(Double.init)
    private let semitoneNotesName: [String] = ["C","C#","D","D#","E","F","F#","G","G#","A","A#","B"]
    
    func getNotes() -> [String] {
        return semitoneNotesName
    }
    
    func getNoteName(noteIndex: Int, octave: Int) -> String {
        return String(semitoneNotesName[noteIndex]) + "\(octave)"
    }
    
    init(baseFrequencyA : Double) {
        self.baseFrequencyA = baseFrequencyA
    }
    
    func setBaseFrequencyA(_ baseFrequencyA: Double) {
        self.baseFrequencyA = baseFrequencyA
    }
    
    func frequency(noteIndex: Int, octave: Int = 4) -> Double {
        let semitone = semitoneOffsets[noteIndex] + Double(octave - 4) * Double(semitoneOffsets.count)
        return baseFrequencyA * pow(2.0, semitone / Double(semitoneOffsets.count))
    }
}


// play sine note from frequency
final class SineWavePlayer {
    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    private let format: AVAudioFormat

    init() {
        engine.attach(player)
        format = engine.mainMixerNode.outputFormat(forBus: 0)
        engine.connect(player, to: engine.mainMixerNode, format: format)
        try? engine.start()
    }

    func play(frequency: Double, duration: Double, amplitude: Double = 0.5) {
        let sampleRate = format.sampleRate
        let frameCount = AVAudioFrameCount(duration * sampleRate)

        guard let buffer = AVAudioPCMBuffer(
            pcmFormat: format,
            frameCapacity: frameCount
        ) else { return }

        buffer.frameLength = frameCount
        guard let channelData = buffer.floatChannelData else { return }
        let channelCount = Int(format.channelCount)

        let attackTime: Double = 0.02   // 20 ms
        let releaseTime: Double = 0.02  // 20 ms
        let attackFrames = Int(sampleRate * attackTime)
        let releaseFrames = Int(sampleRate * releaseTime)

        for frame in 0..<Int(frameCount) {
            let t = Double(frame) / sampleRate
            let sample = sin(2.0 * .pi * frequency * t)

            // Exponential attack & release
            let amp: Double
            if frame < attackFrames {
                // Attack: quadratic exponential
                let x = Double(frame) / Double(attackFrames)
                amp = amplitude * pow(x, 2)
            } else if frame >= Int(frameCount) - releaseFrames {
                // Release: quadratic fade out
                let x = Double(Int(frameCount) - frame) / Double(releaseFrames)
                amp = amplitude * pow(x,2)
            } else {
                amp = amplitude
            }

            for channel in 0..<channelCount {
                channelData[channel][frame] = Float(sample * amp)
            }
        }

        player.stop()
        player.scheduleBuffer(buffer, at: nil, options: .interrupts)
        player.play()
    }
}

