//
//  ViewController.swift
//  RandomizerApp
//
//  Created by reqwwiem on 24.10.2025.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var attributesStackView: UIStackView!
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    
    
    struct Item{
        let title: String
        let imageName: String
        let description: String
        let attributes:[String]
    }
    
    let items: [Item] = [
        Item(title: "Colorful Bouqet", imageName: "bouqet color", description: "Bright and cheerful flower.", attributes: ["Origin: USA", "Year: 2020", "Category: Bouqet"]),
        Item(title: "Blue flowers", imageName: "blue", description: "Blue flowers stebel'", attributes: ["Origin: Canada", "Year: 2023", "Category: Flower"]),
        Item(title: "Orange Bouqet", imageName: "bouqet orange", description: "Orangish flowers", attributes: ["Origin: Sweden", "Year: 2020", "Category: Bouqet"]),
        Item(title: "Pink Bouqet", imageName: "bouqet pink", description: "Pink and pretty flowers.", attributes: ["Origin: Japan", "Year: 2022", "Category: Bouqet"]),
        Item(title: "Neon Blue flowers", imageName: "neon blue", description: "Neon Blue flowers", attributes: ["Origin: Canada", "Year: 2022", "Category: Flower"]),
        Item(title: "Pink Gold flowers", imageName: "pink-gold", description: "Pinkish Gold flowers", attributes: ["Origin: Kazakhstan", "Year: 2011", "Category: Flower"]),
        Item(title: "Purple petals flower", imageName: "purple petals", description: "Purple Petals flower", attributes: ["Origin: Germany", "Year: 2022", "Category: Flower"]),
        Item(title: "Purple flowers", imageName: "purple petals", description: "Purple flowers", attributes: ["Origin: Russia", "Year: 2023", "Category: Flower"]),
        Item(title: "Red Pink flowers", imageName: "red pink", description: "Red Pink flowers", attributes: ["Origin: USA", "Year: 2024", "Category: Flower"]),
        Item(title: "Reddish white flowers", imageName: "red-white", description: "Red White flowers", attributes: ["Origin: Hungary", "Year: 2025", "Category: Flower"]),
        
    ]
    
    override func viewDidLoad() {
           super.viewDidLoad()
        attributesStackView.isLayoutMarginsRelativeArrangement=true
        attributesStackView.layoutMargins=UIEdgeInsets(top:8,left:8,bottom:8,right:8)
           if let firstItem = items.first {
               updateUI(with: firstItem)
           }
       }
    func updateUI(with item: Item) {
           itemImageView.image = UIImage(named: item.imageName)
           titleLabel.text = item.title
           descriptionTextView.text = item.description

           attributesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
           item.attributes.forEach { attr in
               let label = UILabel()
               label.text = attr
               label.font = UIFont.systemFont(ofSize: 14)
               label.backgroundColor = UIColor.systemGray5
               label.layer.cornerRadius = 8
               label.clipsToBounds = true
               label.textAlignment = .center
               label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
               attributesStackView.addArrangedSubview(label)
           }
       }

       @IBAction func randomizeTapped(_ sender: Any) {
           let randomItem = items.randomElement()!
           updateUI(with: randomItem)
       }
   }
