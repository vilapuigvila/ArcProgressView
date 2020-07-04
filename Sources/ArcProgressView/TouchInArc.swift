//
//  File.swift
//  
//
//  Created by albert vila  on 04/07/2020.
//

import UIKit

public enum TouchInArc {
    case rightUp
    case rightDown
    case leftUp
    case leftDown
    
    public init(dx: CGFloat, dy: CGFloat) {
        if dy > 0 && dx > 0 {
            self = .rightDown
        } else if dy > 0 && dx < 0 {
            self = .leftDown
        } else if dy < 0 && dx > 0 {
            self = .rightUp
        } else  {
            self = .leftUp
        }
    }
    
    public var isInDownSide: Bool {
        switch self {
        case .rightDown, .leftDown: return true
        default: return false
        }
    }
}
