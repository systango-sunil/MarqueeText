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
            self.onChange(of: value, initial: initial, perform: action)
        } else if #available(iOS 14.0, *) {
            self.onChange(of: value) { newValue in
                action(value, newValue) // ⚠️ oldValue isn’t available pre-iOS 17
            }
        } else {
            self.onReceive(Just(value)) { newValue in
                action(value, newValue) // again, oldValue isn’t tracked here
            }
        }
    }
}
