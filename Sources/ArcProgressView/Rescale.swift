//
//  Helpers.swift
//  Path
//
//  Created by albert vila on 26/06/2020.
//  Copyright © 2020 albert vila. All rights reserved.
//

import Foundation
import UIKit



struct Rescale<Type : BinaryFloatingPoint> {
    typealias RescaleDomain = (lowerBound: Type, upperBound: Type)

    var fromDomain: RescaleDomain
    var toDomain: RescaleDomain

    init(from: RescaleDomain, to: RescaleDomain) {
        self.fromDomain = from
        self.toDomain = to
    }

    private func interpolate(_ x: Type ) -> Type {
        return toDomain.lowerBound * (1 - x) + toDomain.upperBound * x;
    }

    private func uninterpolate(_ x: Type) -> Type {
        let b = (fromDomain.upperBound - fromDomain.lowerBound) != 0 ?
                fromDomain.upperBound - fromDomain.lowerBound :
                1 / fromDomain.upperBound
        
        return (x - fromDomain.lowerBound) / b
    }

    func rescale(_ x: Type)  -> Type {
        return interpolate( uninterpolate(x) )
    }
    
    func rescaleAndClamp(_ x: Type)  -> Type {
        let value = rescale(x)
        let clampMin = max(toDomain.lowerBound, value)
        return min(toDomain.upperBound, clampMin)
    }
}
