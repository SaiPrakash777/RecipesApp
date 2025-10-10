//
//  UIExtensions.swift
//  RecipeApp
//
//  Created by SaiPrakash Cheera on 10/10/25.
//

import Foundation
import SwiftUI

extension Text {
    static func updatedText(
        _ text: String,
        color: Color = .black,
        weight: Font.Weight = .bold,
        fontSize: CGFloat? = nil,
        multilineTextAlignment: TextAlignment? = nil,
        lineLimit: Int? = nil
    ) -> some View {
        
        var base = Text(text)
            .foregroundColor(color)
            .fontWeight(weight)
        
        if let fontSize = fontSize {
            base = base.font(.system(size: fontSize))
        }
        
        // Instead of assigning, wrap in a conditional view
        return Group {
            if let alignment = multilineTextAlignment {
                base.multilineTextAlignment(alignment)
            } else {
                base
            }
        }
        .lineLimit(lineLimit)
    }
}
