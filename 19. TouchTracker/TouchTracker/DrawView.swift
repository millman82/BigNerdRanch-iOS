//
//  DrawView.swift
//  TouchTracker
//
//  Created by Tim Miller on 7/29/19.
//  Copyright © 2019 Tim Miller. All rights reserved.
//

import UIKit

class DrawView: UIView {
    
    var circlePoints = [NSValue:CGPoint]()
    var currentCircle: Circle?
    var finishedCircles = [Circle]()
    var currentLines = [NSValue:Line]()
    var finishedLines = [Line]()
    
    @IBInspectable var finishedLineColor: UIColor = UIColor.black {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var currentLineColor: UIColor = UIColor.red {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var lineThickness: CGFloat = 10 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    func stroke(_ line: Line) {
        let path = UIBezierPath()
        path.lineWidth = lineThickness
        path.lineCapStyle = .round
        
        path.move(to: line.begin)
        path.addLine(to: line.end)
        path.stroke()
    }
    
    override func draw(_ rect: CGRect) {
        finishedLineColor.setStroke()
        for line in finishedLines {
            stroke(line)
        }
        finishedLineColor.setFill()
        for finishedCircle in finishedCircles {
            let circle = UIBezierPath(ovalIn: finishedCircle.circleRect)
            circle.stroke()
        }
        
        for (_, line) in currentLines {
            line.color.setStroke()
            
            stroke(line)
        }
        
        currentLineColor.setStroke()
        if let currentCircle = currentCircle {
            let circle = UIBezierPath(ovalIn: currentCircle.circleRect)
            circle.stroke()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Log statement to see the order of events
        print(#function)
        
        if touches.count == 2 && currentCircle == nil {
            for touch in touches {
                let key = NSValue(nonretainedObject: touch)
                let location = touch.location(in: self)
                
                circlePoints[key] = location
            }
            
            currentCircle = Circle()
            updateCurrentCircle()
        } else {
            for touch in touches {
                let key = NSValue(nonretainedObject: touch)
                let location = touch.location(in: self)
                
                let newLine = Line(begin: location, end: location)
                currentLines[key] = newLine
            }
        }
        
        setNeedsDisplay()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Log statement to see the order of events
        print(#function)
        
        for touch in touches {
            let key = NSValue(nonretainedObject: touch)
            
            if let _ = circlePoints[key] {
                circlePoints[key] = touch.location(in: self)
            } else {
                currentLines[key]?.end = touch.location(in: self)
            }
        }
        
        updateCurrentCircle()
        
        setNeedsDisplay()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Log statemetn to see the order of events
        print(#function)
        
        for touch in touches {
            let key = NSValue(nonretainedObject: touch)
            
            if let _ = circlePoints[key] {
                circlePoints[key] = touch.location(in: self)
                updateCurrentCircle()
                circlePoints.removeValue(forKey: key)
                
                if circlePoints.count == 0, let circle = currentCircle {
                    finishedCircles.append(circle)
                    currentCircle = nil
                }
            }
            
            if var line = currentLines[key] {
                line.end = touch.location(in: self)
                
                finishedLines.append(line)
                currentLines.removeValue(forKey: key)
            }
        }
        
        setNeedsDisplay()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Log statement to see the order of events
        print(#function)
        
        currentLines.removeAll()
        
        setNeedsDisplay()
    }
    
    @objc func doubleTap(_ gestureRecognizer: UIGestureRecognizer) {
        print("Recognized a double tap")
        
        currentLines.removeAll()
        finishedLines.removeAll()
        circlePoints.removeAll()
        currentCircle = nil
        finishedCircles.removeAll()
        
        setNeedsDisplay()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(DrawView.doubleTap(_:)))
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.delaysTouchesBegan = true
        addGestureRecognizer(doubleTapRecognizer)
    }
    
    private func updateCurrentCircle() {
        let points = Array(circlePoints)
        
        if points.count == 2 {
            currentCircle?.begin = points[0].value
            currentCircle?.end = points[1].value
        } else if points.count == 1 {
            currentCircle?.end = points[0].value
        }
    }
}
