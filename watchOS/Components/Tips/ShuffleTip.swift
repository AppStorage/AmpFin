//
//  LongPressTip.swift
//  watchOS
//
//  Created by Rasmus Krämer on 13.11.23.
//

import SwiftUI
import TipKit

struct ShuffleTip: Tip {
    var title: Text {
        Text("tip.shuffle.title")
    }
    
    var options: [TipOption] = [
        MaxDisplayCount(5)
    ]
}
