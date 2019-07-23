//
//  ViewController.swift
//  Quiz
//
//  Created by Tim Miller on 7/11/19.
//  Copyright © 2019 Big Nerd Ranch. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // MARK: Properties
    @IBOutlet var currentQuestionLabel: UILabel!
    @IBOutlet var currentQuestionLabelCenterXConstraint: NSLayoutConstraint!
    @IBOutlet var nextQuestionLabel: UILabel!
    @IBOutlet var nextQuestionLabelCenterXConstraint: NSLayoutConstraint!
    @IBOutlet var answerLabel: UILabel!
    @IBOutlet var questionView: UIView!
    
    var layoutGuide: UILayoutGuide! = UILayoutGuide()
    
    let questions: [String] = [
        "What is 7+7?",
        "What is the capital of Vermont?",
        "What is cognac made from?"
    ]
    
    let answers: [String] = [
        "14",
        "Montpelier",
        "Grapes"
    ]
    
    var currentQuestionIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentQuestionLabel.text = questions[currentQuestionIndex]
        view.addLayoutGuide(layoutGuide)
        layoutGuide.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        layoutGuide.trailingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        updateOffScreenLabel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Set the label's initial alpha
        nextQuestionLabel.alpha = 0
    }
    
    func updateOffScreenLabel() {
        
        nextQuestionLabelCenterXConstraint.isActive = false
        nextQuestionLabelCenterXConstraint = nextQuestionLabel.centerXAnchor.constraint(equalTo: layoutGuide.centerXAnchor)
        nextQuestionLabelCenterXConstraint.isActive = true
    }
    
    func animateLabelTransitions() {
        
        // Force any outstanding layout changes to occur
        view.layoutIfNeeded()
        
        // Animate the alpha and center the X constraints
        let screenWidth = view.frame.width
        currentQuestionLabelCenterXConstraint.constant += screenWidth
        nextQuestionLabelCenterXConstraint.isActive = false
        nextQuestionLabelCenterXConstraint = nextQuestionLabel.centerXAnchor.constraint(equalTo: questionView.centerXAnchor)
        nextQuestionLabelCenterXConstraint.isActive = true
        
        view.isUserInteractionEnabled = false
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: [.curveLinear], animations: {
            self.currentQuestionLabel.alpha = 0
            self.nextQuestionLabel.alpha = 1
            
            self.view.layoutIfNeeded()
        }, completion: { _ in
            swap(&self.currentQuestionLabel, &self.nextQuestionLabel)
            swap(&self.currentQuestionLabelCenterXConstraint, &self.nextQuestionLabelCenterXConstraint)
            
            self.updateOffScreenLabel()
            self.view.isUserInteractionEnabled = true
        })
    }

    // MARK: Actions
    @IBAction func showNextQuestion(_ sender: UIButton) {
        currentQuestionIndex += 1
        if currentQuestionIndex == questions.count {
            currentQuestionIndex = 0
        }
        
        let question: String = questions[currentQuestionIndex]
        nextQuestionLabel.text = question
        answerLabel.text = "???"
        
        animateLabelTransitions()
    }
    
    @IBAction func showAnswer(_ sender: UIButton) {
        let answer: String = answers[currentQuestionIndex]
        answerLabel.text = answer
    }

}

