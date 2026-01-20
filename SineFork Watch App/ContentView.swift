//
//  ContentView.swift
//  SineFork Watch App
//
//

import SwiftUI

struct ContentView: View {
    @StateObject private var settings = TunerSettings()

    var body: some View {
        TabView {
            TunerPage(settings: settings)
                .tag(0)
            
            SettingsPage(settings: settings)
                .tag(1)
        }
        .tabViewStyle(.page) // Enables swipe left/right
    }
}


struct TunerPage: View {
    @ObservedObject var settings: TunerSettings // settings defining the app

    @State private var sinePlayer = SineWavePlayer()
    @State private var currentNoteIndex: Int = 0
    @State private var octave: Int = 4
    
    var body: some View {
        
        VStack {
            Button(String(format: "%.2f \("Hz")", settings.temperament.frequency(noteIndex: currentNoteIndex, octave: octave))) {
                let hz = settings.temperament.frequency(noteIndex: currentNoteIndex, octave: octave)
                sinePlayer.play(frequency: hz, duration: 1)
            }

            Picker("Note", selection: $currentNoteIndex) {
                let noteNames = settings.temperament.getNotes()
                let numNotes = noteNames.count
                ForEach(0..<numNotes, id: \.self) { index in
                    Text(settings.temperament.getNoteName(noteIndex: index, octave: octave))
                        .tag(index)
                }
            }
            .pickerStyle(.wheel)
            
            HStack(spacing: 20) {
                Button("- oct") {
                    guard octave > 2 else { return }
                    octave -= 1
                }
                .buttonStyle(.borderless)
                .disabled(octave <= 2)
                Button("+ oct") {
                    guard octave < 9 else { return }
                    octave += 1
                }
                .buttonStyle(.borderless)
                .disabled(octave >= 9)
            }

        }
    }
}

struct SettingsPage: View {
    @ObservedObject var settings: TunerSettings

    
    var body: some View {
        VStack(spacing: 10) {
            Text("Settings")
                .font(.headline)
            Picker("Base Frequency", selection: $settings.baseFrequencyA) {
                ForEach(430...450, id: \.self) { hz in
                    Text("\(hz) Hz").tag(Double(hz))
                }
            }.pickerStyle(.wheel)
        }
        .padding()
    }
}


#Preview {
    ContentView()
}
