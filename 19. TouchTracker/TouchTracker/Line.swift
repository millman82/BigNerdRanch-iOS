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
    private var maxVelocity = CGFloat.leastNonzeroMagnitude
    private var minVelocity = CGFloat.greatestFiniteMagnitude
    private var recordedVelocities = [CGFloat]()
    
    var begin = CGPoint.zero
    var end = CGPoint.zero
    var currentVelocity: CGFloat = 0 {
        didSet {
            maxVelocity = max(maxVelocity, currentVelocity)
            minVelocity = min(minVelocity, currentVelocity)
            recordedVelocities.append(currentVelocity)
        }
    }
    
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
    
    var width: CGFloat {
        let velocitySum = recordedVelocities.reduce(0, +)
        let avgVelocity = velocitySum / CGFloat(recordedVelocities.count)
        
        let velocityMultiplier = 0.1 / (avgVelocity / (maxVelocity - minVelocity))
        
        let width = velocityMultiplier * 20
        
        return width
    }
    
    init(begin: CGPoint, end: CGPoint) {
        self.begin = begin
        self.end = end
    }
}
