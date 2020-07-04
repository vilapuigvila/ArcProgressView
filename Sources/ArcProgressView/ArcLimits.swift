//
//  File.swift
//  
//
//  Created by albert vila  on 04/07/2020.
//

import UIKit
    
public struct ArcLimits: Equatable {
    private(set) var startPoint: CGPoint
    private(set) var endPoint: CGPoint
    
    private(set) var leftBoundsRange: ClosedRange<Double> = 0...0
    private(set) var rightBoundsRange: ClosedRange<Double> = 0...0
    
    public static var `default`: Self {
        .init(startPoint: .zero, endPoint: .zero)
    }
    
    public mutating func setupVaues<T: BinaryFloatingPoint>(_ center: CGPoint, radius: T, startAngle: T, endAngle: T) {
        startPoint = CGPoint.pointOnCircle(center: center, radius: CGFloat(radius), angle: Double(startAngle).toRadians())
        endPoint   = CGPoint.pointOnCircle(center: center, radius: CGFloat(radius), angle: Double(endAngle).toRadians())
        
        leftBoundsRange = Double(startAngle)...0.0
        rightBoundsRange = -180.0...Double(endAngle)
    }
}

public struct ArcAngle: Equatable {
    let start: CGFloat
    let end: CGFloat
    
    public static var `default`: Self {
        .init(start: 0, end: 0)
    }
}
