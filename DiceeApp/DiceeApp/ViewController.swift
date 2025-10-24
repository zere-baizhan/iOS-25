//
//  ViewController.swift
//  DiceeApp
//
//  Created by reqwwiem on 18.10.2025.
//

import UIKit

class ViewController: UIViewController {

    
    @IBOutlet weak var rightDice: UIImageView!
    @IBOutlet weak var leftDice: UIImageView!
    @IBAction func rollButton(_ sender: Any) {
        let diceArray = [
                    UIImage(named: "dice1"),
                    UIImage(named: "dice2"),
                    UIImage(named: "dice3"),
                    UIImage(named: "dice4"),
                    UIImage(named: "dice5"),
                    UIImage(named: "dice6")
                ]
        leftDice.image = diceArray.randomElement()!
        rightDice.image = diceArray.randomElement()!
    }
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            rollButton(UIButton())
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

