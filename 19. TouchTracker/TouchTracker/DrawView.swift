//
//  DrawView.swift
//  TouchTracker
//
//  Created by Tim Miller on 7/29/19.
//  Copyright © 2019 Tim Miller. All rights reserved.
//

import UIKit

enum ObjectType {
    case circle
    case line
}

class DrawView: UIView {
    
    var circlePoints = [NSValue:CGPoint]()
    var currentCircle: Circle?
    var finishedCircles = [Circle]()
    var currentLines = [NSValue:Line]()
    var finishedLines = [Line]()
    var currentVelocity: CGFloat = 0
    var selectedObject: (index: Int, objectType: ObjectType)? {
        didSet {
            if selectedObject == nil {
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
        path.lineWidth = line.width
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
    
    func indexOfClosestObject(at point: CGPoint) -> (index: Int, objectType: ObjectType)? {
        let lineIndex = indexOfLine(at: point)
        let circleIndex = indexOfCircle(at: point)
        
        if let lineIndex = lineIndex, let circleIndex = circleIndex {
            if lineIndex.distance <= circleIndex.distance {
                return (index: lineIndex.index, objectType: .line)
            }
            
            return (index: circleIndex.index, objectType: .circle)
        } else if let lineIndex = lineIndex {
            return (index: lineIndex.index, objectType: .line)
        } else if let circleIndex = circleIndex {
            return (index: circleIndex.index, objectType: .circle)
        }
        
        return nil
    }
    
    func indexOfLine(at point: CGPoint) -> (index: Int, distance: CGFloat)? {
        // Find a line close to point
        for (index, line) in finishedLines.enumerated() {
            let begin = line.begin
            let end = line.end
            
            // Check a few points on the line
            for t in stride(from: CGFloat(0), to: 1.0, by: 0.05) {
                let x = begin.x + ((end.x - begin.x) * t)
                let y = begin.y + ((end.y - begin.y) * t)
                
                // If the tapped point is within 20 points, let's return this line
                let h = hypot(x - point.x, y - point.y)
                if h < 20.0 {
                    return (index: index, distance: h)
                }
            }
        }
        
        // If nothing is close enough to the tapped point, then we did not select a line
        return nil
    }
    
    func indexOfCircle(at point: CGPoint) -> (index: Int, distance: CGFloat)? {
        // Find a circle close to point
        for (index, circle) in finishedCircles.enumerated() {
            let begin = circle.begin
            let end = circle.end
            let circleRect = circle.circleRect
            
            let circleCenter = CGPoint(x: (begin.x + end.x) / 2, y: (begin.y + end.y) / 2)
            let radius = circleRect.width / 2
            
            for t in stride(from: CGFloat(0), to: 360, by: 5) {
                let x = radius * sin(t) + circleCenter.x
                let y = radius * cos(t) + circleCenter.y
                
                let h = hypot(x - point.x, y - point.y)
                if h < 20.0 {
                    return (index: index, distance: h)
                }
            }
        }
        
        return nil
    }
    
    @objc func deleteObject(_ sender: UIMenuController) {
        // Remove the selected line from the list of finishedLines
        if let selectedObject = selectedObject {
            if selectedObject.objectType == .line {
                finishedLines.remove(at: selectedObject.index)
            } else if selectedObject.objectType == .circle {
                finishedCircles.remove(at: selectedObject.index)
            }
            
            self.selectedObject = nil
            
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
        
        currentLineColor.setStroke()
        if let currentCircle = currentCircle {
            stroke(currentCircle)
        }
        
        if let selectedObject = selectedObject {
            UIColor.green.setStroke()
            if selectedObject.objectType == .line {
                let selectedLine = finishedLines[selectedObject.index]
                stroke(selectedLine)
            } else if selectedObject.objectType == .circle {
                let selectedCircle = finishedCircles[selectedObject.index]
                stroke(selectedCircle)
            }
        }
    }
    
    // MARK: - UIResponder Actions
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Log statement to see the order of events
        print(#function)
        
        selectedObject = nil
        
        if touches.count == 2 && currentCircle == nil {
            for touch in touches {
                let key = NSValue(nonretainedObject: touch)
                let location = touch.location(in: self)
                
                circlePoints[key] = location
            }
            
            currentCircle = Circle(begin: CGPoint.zero, end: CGPoint.zero)
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
                currentLines[key]?.currentVelocity = currentVelocity
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
                line.currentVelocity = currentVelocity
                
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
        
        selectedObject = nil
        currentLines.removeAll()
        finishedLines.removeAll()
        circlePoints.removeAll()
        currentCircle = nil
        finishedCircles.removeAll()
        
        setNeedsDisplay()
    }
    
    @objc func tap(_ gestureRecognizer: UIGestureRecognizer) {
        print("Recognized a tap")
        
        let point = gestureRecognizer.location(in: self)
        selectedObject = indexOfClosestObject(at: point)
        
        // Grab the menu controller
        let menu = UIMenuController.shared
        
        if selectedObject != nil {
            
            // Make DrawView the target of menu item action messages
            becomeFirstResponder()
            
            // Create a new "Delete" UIMenuItem
            let deleteItem = UIMenuItem(title: "Delete", action: #selector(DrawView.deleteObject(_:)))
            
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
            selectedObject = indexOfClosestObject(at: point)
            
            if selectedObject != nil {
                currentLines.removeAll()
                currentCircle = nil
                circlePoints.removeAll()
            }
        } else if gestureRecognizer.state == .ended {
            selectedObject = nil
        }
        
        setNeedsDisplay()
    }
    
    @objc func moveObject(_ gestureRecognizer: UIPanGestureRecognizer) {
        print("Recognized a pan")
        
        let velocity = gestureRecognizer.velocity(in: self)
        print("Raw velocity: \(velocity)")
        
        let computedVelocity = hypot(velocity.x, velocity.y)
        print("Computed velocity: \(computedVelocity)")
        
        currentVelocity = computedVelocity
        
        guard longPressRecognizer.state == .changed else { return }
        
        // If an object is selected...
        if let selectedObject = selectedObject {
            // When the pan recognizer changes its position...
            if gestureRecognizer.state == .changed {
                // How far has the pan moved?
                let translation = gestureRecognizer.translation(in: self)
                
                // Add the translation to the current beginning and end points of the line
                // Make sure there are no copy and paste types!
                if selectedObject.objectType == .line {
                    finishedLines[selectedObject.index].begin.x += translation.x
                    finishedLines[selectedObject.index].begin.y += translation.y
                    finishedLines[selectedObject.index].end.x += translation.x
                    finishedLines[selectedObject.index].end.y += translation.y
                } else if selectedObject.objectType == .circle {
                    finishedCircles[selectedObject.index].begin.x += translation.x
                    finishedCircles[selectedObject.index].begin.y += translation.y
                    finishedCircles[selectedObject.index].end.x += translation.x
                    finishedCircles[selectedObject.index].end.y += translation.y
                }
                
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
        
        moveRecognizer = UIPanGestureRecognizer(target: self, action: #selector(DrawView.moveObject))
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
