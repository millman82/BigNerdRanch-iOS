//
//  CrosshairView.swift
//  Homepwner
//
//  Created by Tim Miller on 7/27/19.
//  Copyright © 2019 Big Nerd Ranch. All rights reserved.
//

import UIKit

class CrosshairView: UIView {
    
    let crosshairColor = UIColor.white.withAlphaComponent(0.8)
    let crosshairWidth: CGFloat = 3.0
    
    override func draw(_ rect: CGRect) {
        
        let centerX: CGFloat = rect.width / 2.0
        let centerY: CGFloat = rect.height / 2.0
        
        crosshairColor.set()
        
        let horizontalLine = UIBezierPath()
        horizontalLine.lineWidth = self.crosshairWidth
        horizontalLine.move(to: CGPoint(x: centerX - 7.0, y: centerY))
        horizontalLine.addLine(to: CGPoint(x: centerX - 2.0, y: centerY))
        horizontalLine.move(to: CGPoint(x: centerX + 2.0, y: centerY))
        horizontalLine.addLine(to: CGPoint(x: centerX + 7.0, y: centerY))
        horizontalLine.stroke()
        
        let verticalLine = UIBezierPath()
        verticalLine.lineWidth = self.crosshairWidth
        verticalLine.move(to: CGPoint(x: centerX, y: centerY - 7.0))
        verticalLine.addLine(to: CGPoint(x: centerX, y: centerY - 2.0))
        verticalLine.move(to: CGPoint(x: centerX, y: centerY + 2.0))
        verticalLine.addLine(to: CGPoint(x: centerX, y: centerY + 7.0))
        verticalLine.stroke()
    }
}
