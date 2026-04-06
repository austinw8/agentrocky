//
//  RockyState.swift
//  agentrocky
//

import SwiftUI
import Combine

/// Shared observable state between AppDelegate (walk logic) and RockyView (display).
class RockyState: ObservableObject {
    @Published var walkFrameIndex: Int = 0      // 0 or 1 → walkleft1/2
    @Published var direction: CGFloat = 1        // 1 = right, -1 = left
    @Published var isChatOpen: Bool = false
    @Published var positionX: CGFloat = 0
    var screenBounds: CGRect = .zero
    var dockY: CGFloat = 0
}
