//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by RGP_KOREA on 2016. 10. 8..
//  Copyright © 2016년 DDRG. All rights reserved.
//UI와는 전혀 상관없고 계산만 하는 코드들

import Foundation //Model이기 때문에 UIKit 아님

/*enum Optional<T> {
    case None //nil이 되는 경우
    case Some(T) //연관값 T(어느 타입이든 올 수 있음)
    
} */

//closure때문에 필요없어진 함수 func multiply  //multiply라는 함수는 직접 만들어줘야함(전역변수로 만듬)

class CalculatorBrain
{
    private var accumulator = 0.0
    private var internalProgram = [AnyObject] () //program을 코드 내부적으로 저장하기 위해 internalProgram을 만듬(AnyObject배열로)
                                                //피연산자들은 더블, 연산자들은 스트링. 애니옵젝트의 강력한 기능
    
    func setOperand(operand: Double) {
        accumulator = operand
        internalProgram.append(operand) //internalProgram을 구현하기 위해 append. 오브젝티브씨 브리징 때문에 작동함
                                                    //UI의 모든곳에서 호환이되고 필요한곳에 자동으로 연결이 됨(호환, 선언 필요 없음)
    }
    
    private var operations: Dictionary<String, Operation> = [//아래의 코드가 일반화된 상수연산, 단항연산, 이항연산만하게 하고 다른 연산을 추가, 삭제하기 쉽고 코드양도 적어지도록 table 생성
        "π" : Operation.Constant(M_PI), //key & value
        "e" : Operation.Constant(M_E), //자연상수
        "±" : Operation.UnaryOperation({ -$0 }),
        "√" : Operation.UnaryOperation(sqrt),
        "cos" : Operation.UnaryOperation(cos),
        "×" : Operation.BinaryOperation({ $0 * $1 }), //closure : 환경상태를 캡쳐하는 인라인 함수. 입력인자 앞에 '{'가 오고 뒤에는 in이 오는 것만 빼면 함수를 만드는 법과 같음
        "÷" : Operation.BinaryOperation({ $0 / $1 }),
        "+" : Operation.BinaryOperation({ $0 + $1 }),
        "−" : Operation.BinaryOperation({ $0 - $1 }),
        "=" : Operation.Equlas
    ]//확장하기 매우 좋음
    
    private enum Operation { //class랑 비슷하며 별개의 값을 모아놓은 세트. 메소드를 가질 수 있으나 변수를 가질 수는 없음
        case Constant(Double) //옵셔널이 하는 것과 똑같이 Constant에 값을 연결. 상수는 Double이 필요함
        case UnaryOperation((Double) -> Double) //단항연산. Double을 받아서 Double을 반환하는 함수(연관값)
        case BinaryOperation((Double, Double) -> Double) //이항연산
        case Equlas
    }
    
    func performOperation(symbol: String) { //model의 심장같은 부분. 실질적인 계산을 함
        /* switch symbol { //symbol은 String
        case "π": accumulator = M_PI
        case "√": accumulator = sqrt(accumulator)
        default: break
        } */
        
        /* if let constant = operations[symbol] {//Dictionary에 있는 무언가를 찾는 방법(constant라는 상수를 만들어서 operations의 symbol키에 해당하는 값으로 set)
            accumulator = constant
        }//if를 써서 내가 이해하지 못하는 연산은 무시해버림(crash방지) */
        
        internalProgram.append(symbol) //symbol은 스트링이고 스트럭트지만 자동으로 NSString으로 호환 지원이 됨
        if let operation = operations[symbol]{
            switch operation {
            case .Constant(let value):
                accumulator = value //.앞에 Operation생략됨. 지역변수 value가 연관값을 빼옴(패턴매칭)
            case .UnaryOperation(let function):
                accumulator = function(accumulator)
            case .BinaryOperation(let function):
                executePendingBianryOperation()
                pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator) //생성자
            case .Equlas:
                executePendingBianryOperation()
            }
        }
    }
    
    private func executePendingBianryOperation() { //대기중인 이항연산 실행
        if pending != nil { //현재 대기중인 연산이 있다면
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            pending = nil
        }
        //default하지 않아도 됨
    }
    
    private var pending: PendingBinaryOperationInfo? //optional struct
    
    private struct PendingBinaryOperationInfo { //대기중인 이항연산 정보
        var binaryFunction: (Double, Double) -> Double  //class와 다르게 초기화하라고 하지 않음
        var firstOperand: Double
    }
    
    typealias PropertyList = AnyObject //type을 만들 수 있게 해줌(PropertyList라는 타입을 만듬)
    
    var program: PropertyList {//AnyObject //program의 타입을 PropertyList로 바꿈
        get {
            return internalProgram //내부의 데이터구조를 외부의 호출자에게 리턴해주고 있음
                                    //배열은 Value type이며 그것을 리턴하면 복사됨(포인터가 아닌 복사된 값을 전달)
        }
        set {
            clear() //이미 들어있는 값을 초기화
            if let arrayOfOps = newValue as? [AnyObject] {
                for op in arrayOfOps {
                    if let operand = op as? Double { //op이 더블인지 as로 캐스팅 해봄
                        setOperand(operand)
                    } else if let operation = op as? String {
                        performOperation(operation)
                    }
                    //AnyObject로는 아무것도 할 수 없기 때문에 다른걸로 바꿀 수 있는지 확인
                } //iterate
            }
        }
        //get과 set으로 computed variable로 만듬
    }
    
    func clear() {
        accumulator = 0.0
        pending = nil //남은 이항연산이 없다
        internalProgram.removeAll()
    }
    
    var result: Double { //결과값
        get {
            return accumulator
        }
        //set은 없는 readonly ex> Button에서 currentTitle
    }
}