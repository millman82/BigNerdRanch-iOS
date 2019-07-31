//
//  Circle.swift
//  TouchTracker
//
//  Created by Tim Miller on 7/30/19.
//  Copyright © 2019 Tim Miller. All rights reserved.
//

import Foundation
import CoreGraphics

struct Circle {
    var begin: CGPoint?
    var end: CGPoint?
    
    var circleRect: CGRect {
        if let begin = begin, let end = end {
            let x = CGFloat(abs(Int32(end.x - begin.x)))
            let y = CGFloat(abs(Int32(end.y - begin.y)))
            let side = min(x, y)
            let size = CGSize(width: side, height: side)
            let center = CGPoint(x: (begin.x + end.x) / 2, y: (begin.y + end.y) / 2)
            let origin = CGPoint(x: center.x - side / 2, y: center.y - side / 2)
            
            return CGRect(origin: origin, size: size)
        }
        
        return CGRect()
    }
}
