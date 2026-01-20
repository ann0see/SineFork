//
//  Settings.swift
//  SineFork
//
//

import SwiftUI
import Combine

class TunerSettings: ObservableObject {
    @Published var temperament: Temperament = EqualTemperament(baseFrequencyA: 440.0)

    @Published var baseFrequencyA: Double = 440.0 {
        // on change of base frequency, recreate new temperament. This might not be efficient?
        didSet {
            temperament.setBaseFrequencyA(baseFrequencyA)
        }
    }

}
