//
//  Environment++.swift
//  SwiftDdit
//
//  Created by Zabir Raihan on 18/06/2025.
//

import Foundation
import SwiftUI

extension EnvironmentValues {
    @Entry var addOptimisticComment: ((String, String) -> Void) = { _, _ in
        print("No optimistic comment handler passed")
    }
    
    @Entry var appendToPath: ((any Hashable) -> Void) = { _ in
        print("No path append handler provided")
    }
}
