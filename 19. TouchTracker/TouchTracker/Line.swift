//
//  Line.swift
//  TouchTracker
//
//  Created by Tim Miller on 7/29/19.
//  Copyright © 2019 Tim Miller. All rights reserved.
//

import UIKit
import CoreGraphics

struct Line {
    var begin = CGPoint.zero
    var end = CGPoint.zero
    
    var color: UIColor {
        var angle: CGFloat = 0
        
        if begin != end {
            let dX = end.x - begin.x
            let dY = end.y - begin.y
            
            angle = atan2(dX, dY) * 180 / CGFloat(Double.pi)
            
            if angle < 0 {
                angle = angle + 360
            }
        }
        
        let hue = angle / 360
        return UIColor(hue: hue, saturation: 1, brightness: 1, alpha: 1)
    }
}
