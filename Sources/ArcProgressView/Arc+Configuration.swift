//
//  File.swift
//  
//
//  Created by albert vila  on 04/07/2020.
//

import UIKit

public struct Configuration {
    let fillColor: UIColor
    let strokeColor: UIColor
    let lineWidth: CGFloat
    
    let thumbRadius: CGFloat
    let thumbColor: UIColor
    
    let startAngle: CGFloat
    let endAngle: CGFloat
    
    public static var `default`: Self {
        .init(
            fillColor: .clear,
            strokeColor: .gray,
            lineWidth: 1.5,
            thumbRadius: 25.0,
            thumbColor: .orange,
            startAngle: -CGFloat(225.0),
            endAngle: CGFloat(45)
        )
    }
}
