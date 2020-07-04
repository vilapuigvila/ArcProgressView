//
//  File.swift
//  
//
//  Created by albert vila  on 04/07/2020.
//

import UIKit

extension CGFloat {
    func toRadians() -> CGFloat {
        return self * CGFloat(Double.pi) / 180.0
    }
}

extension CGPoint {
    
    static func pointOnCircle(center: CGPoint, radius: CGFloat, angle: Double) -> CGPoint {
        let x = center.x + radius * cos(CGFloat(angle))
        let y = center.y + radius * sin(CGFloat(angle))
        
        return CGPoint(x: x, y: y)
    }
}

extension Double {
    func toRadians() -> Double {
        return self * Double.pi / 180.0
    }
    
    func round(places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
