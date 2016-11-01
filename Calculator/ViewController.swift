//
//  ViewController.swift
//  Calculator
//
//  Created by RGP_KOREA on 2016. 9. 18..
//  Copyright © 2016년 DDRG. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet private weak var display: UILabel!
    
    private var userIsInTheMiddleOfTyping = false

    @IBAction private func touchDigit(sender: UIButton) {
        //self.touchDigit(someButton, otherArgument: 5)
        
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display.text!
            display.text = textCurrentlyInDisplay + digit
        } else {
            display.text = digit
        }
        userIsInTheMiddleOfTyping = true
        
        //print("touched \(digit) digit")
    }

    private var displayValue: Double {
        get { //가져옴
            return Double(display.text!)!
        }
        set { //설정함
            display.text = String(newValue)
        }
    }
    
    var savedProgram: CalculatorBrain.PropertyList? //안눌렀을 수도 있으므로 옵셔널(nil로 시작해서 누르는 순간 값을 가지게됨)
    @IBAction func save() {
        savedProgram = brain.program
    }
    
    @IBAction func restore() {
        if savedProgram != nil {
            brain.program = savedProgram!
            displayValue = brain.result
        }
    }
    
    private var brain = CalculatorBrain() //brain변수에게 모든 계산을 시킴, controller가 model에게 접근
    
    @IBAction private func performOperation(sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
        
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
            
            /* if mathematicalSymbol == "π" {
                displayValue = M_PI 계산하는 부분을 모델에서 처리하게 할거임
                //display.text = String(M_PI) 이렇게 타입변환 필요 없음
            } else if mathematicalSymbol == "√" {
                displayValue = sqrt(displayValue)
            } */
        }
        displayValue = brain.result
    }
}

