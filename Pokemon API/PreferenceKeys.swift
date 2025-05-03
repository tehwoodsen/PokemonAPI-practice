//
//  PreferenceKeys.swift
//  Pokemon API
//
//  Created by frank on 5/3/25.
//

import Foundation
import SwiftUICore

//this is for the scrolling of the app incase there is too much data on screen
struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
