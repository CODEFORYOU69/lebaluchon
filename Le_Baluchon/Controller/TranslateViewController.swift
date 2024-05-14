//
//  TranslateViewController.swift
//  Le_Baluchon
//
//  Created by younes ouasmi on 09/05/2024.
//

import UIKit

class TranslateViewController: UIViewController {


    @IBOutlet weak var translatedText: UITextView!
    @IBOutlet weak var originTranslate: UITextView!
    @IBOutlet weak var translateButton: UIButton!
    @IBOutlet weak var swapButton: UIButton!
    @IBOutlet weak var resultLabel: UILabel!
    
    var sourceLanguage = "fr"
    var targetLanguage = "en"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTapGesture()

        // Do any additional setup after loading the view.
    }
    
   
        
    
    @IBAction func translateButtonAction(_ sender: UIButton) {
        guard let text = originTranslate.text, !text.isEmpty else {
               resultLabel.text = "Input text is empty"
               return
           }
           TranslationService.translate(text: text, from: sourceLanguage, to: targetLanguage) { [weak self] translatedText, error in
               DispatchQueue.main.async {
                   if let translatedTexts = translatedText {
                       self?.translatedText.text = translatedTexts
                   } else {
                       self?.resultLabel.text = error?.localizedDescription ?? "Failed to translate"
                   }
               }
           }
    }

    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
