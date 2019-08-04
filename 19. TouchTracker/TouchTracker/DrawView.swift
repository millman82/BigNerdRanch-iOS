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
    var selectedCircleIndex: Int?
    var currentLines = [NSValue:Line]()
    var finishedLines = [Line]()
    var selectedLineIndex: Int? {
        didSet {
            if selectedLineIndex == nil {
                let menu = UIMenuController.shared
                menu.setMenuVisible(false, animated: true)
            }
        }
    }
    var longPressRecognizer: UILongPressGestureRecognizer!
    var moveRecognizer: UIPanGestureRecognizer!
    
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
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    // MARK: - Drawing Methods
    
    func stroke(_ line: Line) {
        let path = UIBezierPath()
        path.lineWidth = lineThickness
        path.lineCapStyle = .round
        
        path.move(to: line.begin)
        path.addLine(to: line.end)
        path.stroke()
    }
    
    func stroke(_ circle: Circle) {
        let path = UIBezierPath(ovalIn: circle.circleRect)
        path.lineWidth = lineThickness
        path.stroke()
    }
    
    func indexOfLine(at point: CGPoint) -> Int? {
        // Find a line close to point
        for (index, line) in finishedLines.enumerated() {
            let begin = line.begin
            let end = line.end
            
            // Check a few points on the line
            for t in stride(from: CGFloat(0), to: 1.0, by: 0.05) {
                let x = begin.x + ((end.x - begin.x) * t)
                let y = begin.y + ((end.y - begin.y) * t)
                
                // If the tapped point is within 20 points, let's return this line
                if hypot(x - point.x, y - point.y) < 20.0 {
                    return index
                }
            }
        }
        
        // If nothing is close enough to the tapped point, then we did not select a line
        return nil
    }
    
    @objc func deleteLine(_ sender: UIMenuController) {
        // Remove the selected line from the list of finishedLines
        if let index = selectedLineIndex {
            finishedLines.remove(at: index)
            selectedLineIndex = nil
            
            // Redraw everything
            setNeedsDisplay()
        }
    }
    
    // MARK: - View Methods
    
    override func draw(_ rect: CGRect) {
        finishedLineColor.setStroke()
        for line in finishedLines {
            stroke(line)
        }
        finishedLineColor.setFill()
        for finishedCircle in finishedCircles {
            stroke(finishedCircle)
        }
        
        for (_, line) in currentLines {
            line.color.setStroke()
            
            stroke(line)
        }
        
        if let index = selectedLineIndex {
            UIColor.green.setStroke()
            let selectedLine = finishedLines[index]
            stroke(selectedLine)
        }
        
        currentLineColor.setStroke()
        if let currentCircle = currentCircle {
            stroke(currentCircle)
        }
        
        if let index = selectedCircleIndex {
            UIColor.green.setStroke()
            let selectedCircle = finishedCircles[index]
            stroke(selectedCircle)
        }
    }
    
    // MARK: - UIResponder Actions
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Log statement to see the order of events
        print(#function)
        
        selectedLineIndex = nil
        
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
        
        selectedLineIndex = nil
        currentLines.removeAll()
        finishedLines.removeAll()
        selectedCircleIndex = nil
        circlePoints.removeAll()
        currentCircle = nil
        finishedCircles.removeAll()
        
        setNeedsDisplay()
    }
    
    @objc func tap(_ gestureRecognizer: UIGestureRecognizer) {
        print("Recognized a tap")
        
        let point = gestureRecognizer.location(in: self)
        selectedLineIndex = indexOfLine(at: point)
        
        // Grab the menu controller
        let menu = UIMenuController.shared
        
        if selectedLineIndex != nil {
            
            // Make DrawView the target of menu item action messages
            becomeFirstResponder()
            
            // Create a new "Delete" UIMenuItem
            let deleteItem = UIMenuItem(title: "Delete", action: #selector(DrawView.deleteLine(_:)))
            
            menu.menuItems = [deleteItem]
            
            // Tell the menu where it should come from and show it
            let targetRect = CGRect(x: point.x, y: point.y, width: 2, height: 2)
            menu.setTargetRect(targetRect, in: self)
            menu.setMenuVisible(true, animated: true)
        } else {
            // Hide the menu if no line is selected
            menu.setMenuVisible(false, animated: true)
        }
        
        setNeedsDisplay()
    }
    
    @objc func longPress(_ gestureRecognizer: UIGestureRecognizer) {
        print("Recognized a long press")
        
        if gestureRecognizer.state == .began {
            let point = gestureRecognizer.location(in: self)
            selectedLineIndex = indexOfLine(at: point)
            
            if selectedLineIndex != nil {
                currentLines.removeAll()
            }
        } else if gestureRecognizer.state == .ended {
            selectedLineIndex = nil
        }
        
        setNeedsDisplay()
    }
    
    @objc func moveLine(_ gestureRecognizer: UIPanGestureRecognizer) {
        print("Recognized a pan")
        
        guard longPressRecognizer.state == .changed else { return }
        
        // If a line is selected...
        if let index = selectedLineIndex {
            // When the pan recognizer changes its position...
            if gestureRecognizer.state == .changed {
                // How far has the pan moved?
                let translation = gestureRecognizer.translation(in: self)
                
                // Add the translation to the current beginning and end points of the line
                // Make sure there are no copy and paste types!
                finishedLines[index].begin.x += translation.x
                finishedLines[index].begin.y += translation.y
                finishedLines[index].end.x += translation.x
                finishedLines[index].end.y += translation.y
                
                gestureRecognizer.setTranslation(CGPoint.zero, in: self)
                
                // Redraw the screen
                setNeedsDisplay()
            }
        } else {
            // If no line is selected, do not do anything
            return
        }
    }
    
    // MARK: - Initializer
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(DrawView.doubleTap(_:)))
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.delaysTouchesBegan = true
        addGestureRecognizer(doubleTapRecognizer)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(DrawView.tap(_:)))
        tapRecognizer.delaysTouchesBegan = true
        tapRecognizer.require(toFail: doubleTapRecognizer)
        addGestureRecognizer(tapRecognizer)
        
        longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(DrawView.longPress(_:)))
        addGestureRecognizer(longPressRecognizer)
        
        moveRecognizer = UIPanGestureRecognizer(target: self, action: #selector(DrawView.moveLine(_:)))
        moveRecognizer.delegate = self
        moveRecognizer.cancelsTouchesInView = false
        addGestureRecognizer(moveRecognizer)
    }
    
    // MARK: - Helper Methods
    
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

extension DrawView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
