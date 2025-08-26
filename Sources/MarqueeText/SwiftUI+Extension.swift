//
//  File.swift
//  
//
//  Created by Marek Zvara on 26/08/2022.
//

import Foundation

import SwiftUI
import Combine

extension View {
    /// A backwards compatible wrapper for iOS 14+ `onChange(of:)` and iOS 17+ `onChange(of:initial:)`
    @ViewBuilder func onValueChanged<T: Equatable>(
        of value: T,
        initial: Bool = false,
        perform action: @escaping (_ oldValue: T, _ newValue: T) -> Void
    ) -> some View {
        if #available(iOS 17.0, *) {
            // iOS 17+: closure takes (oldValue, newValue)
            self.onChange(of: value, initial: initial, action)
        } else if #available(iOS 14.0, *) {
            // iOS 14–16: closure only gives newValue
            self.onChange(of: value) { newValue in
                action(value, newValue) // you’ll have to fake oldValue here
            }
        } else {
            // Fallback (pre-iOS 14): observe via Combine
            self.onReceive(Just(value)) { newValue in
                action(value, newValue)
            }
        }
    }
}

