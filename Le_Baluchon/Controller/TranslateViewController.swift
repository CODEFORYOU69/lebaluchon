//
//  TranslateViewController.swift
//  Le_Baluchon
//
//  Created by younes ouasmi on 09/05/2024.
//

import UIKit

class CardView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        // Ajout des coins arrondis
        self.layer.cornerRadius = 10
        
        // Ajout d'une ombre
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.2
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 4
        
        // Ajout d'une bordure optionnelle
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 0.5
        
    }
}


class TranslateViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var translatedText: UITextView!
    @IBOutlet weak var originTranslate: UITextView!
    @IBOutlet weak var translateButton: UIButton!
    @IBOutlet weak var resultLabel: UILabel!
    
    @IBOutlet weak var translateTitle: UILabel!
    @IBOutlet weak var targetLanguageLabel: UILabel!
    @IBOutlet weak var sourceLanguageLabel: UILabel!
    @IBOutlet weak var swapLanguagesButtonTapped: UIButton!
    @IBOutlet weak var sourceLanguageTextField: UITextField!
    @IBOutlet weak var targetLanguageTextField: UITextField!
    
    var sourceLanguage = "en"
    var targetLanguage = "fr"
    
    let languages = ["en", "fr", "es", "de", "it", "pt", "zh", "ja"]
    let languageNames = [
        "en": "English",
        "fr": "Français",
        "es": "Español",
        "de": "Deutsch",
        "it": "Italiano",
        "pt": "Português",
        "zh": "中文",
        "ja": "日本語"
    ]
    
    let languagePicker = UIPickerView()
    var activeTextField: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTapGesture()
        setupLanguagePicker()
        loadUserLanguage()
        updateLanguageDisplay()
        
        styleTextField(sourceLanguageTextField)
        styleTextField(targetLanguageTextField)
        styleTextView(translatedText)
        styleTextView(originTranslate)
        
        styleButton(translateButton)
        styleLabel(translateTitle)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadUserLanguage()
        updateLanguageDisplay()
    }
    
    func loadUserLanguage() {
        if let userLanguage = UserDefaults.standard.string(forKey: "userLanguage") {
            sourceLanguage = userLanguage
            sourceLanguageTextField.text = languageNames[userLanguage]
        } else {
            // Définir une langue par défaut si aucune langue n'est définie
            sourceLanguage = "en"
            sourceLanguageTextField.text = languageNames["en"]
        }
    }
    
    
    
    
    func setupLanguagePicker() {
        languagePicker.delegate = self
        languagePicker.dataSource = self
        sourceLanguageTextField.inputView = languagePicker
        targetLanguageTextField.inputView = languagePicker
        sourceLanguageTextField.delegate = self
        targetLanguageTextField.delegate = self
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        toolbar.setItems([doneButton], animated: true)
        sourceLanguageTextField.inputAccessoryView = toolbar
        targetLanguageTextField.inputAccessoryView = toolbar
    }
    
    @objc func doneButtonTapped() {
        activeTextField?.resignFirstResponder()
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return languages.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return translateLanguageName(language: languages[row], to: sourceLanguage)
    }
    
    func translateLanguageName(language: String, to userLanguage: String) -> String {
        let translations = [
            "en": ["fr": "Anglais", "es": "Inglés", "de": "Englisch", "it": "Inglese", "pt": "Inglês", "zh": "英语", "ja": "英語"],
            "fr": ["en": "Français", "es": "Francés", "de": "Französisch", "it": "Francese", "pt": "Francês", "zh": "法语", "ja": "フランス語"],
            "es": ["en": "Español", "fr": "Espagnol", "de": "Spanisch", "it": "Spagnolo", "pt": "Espanhol", "zh": "西班牙语", "ja": "スペイン語"],
            "de": ["en": "Deutsch", "fr": "Allemand", "es": "Alemán", "it": "Tedesco", "pt": "Alemão", "zh": "德语", "ja": "ドイツ語"],
        ]
        return translations[language]?[userLanguage] ?? languageNames[language] ?? language
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedLanguage = languages[row]
        if activeTextField == sourceLanguageTextField {
            sourceLanguage = selectedLanguage
            sourceLanguageTextField.text = translateLanguageName(language: selectedLanguage, to: sourceLanguage)
        } else if activeTextField == targetLanguageTextField {
            targetLanguage = selectedLanguage
            targetLanguageTextField.text = translateLanguageName(language: selectedLanguage, to: sourceLanguage)
        }
        updateLanguageDisplay()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
        
        if let currentLanguage = textField.text, let index = languages.firstIndex(of: currentLanguage) {
            languagePicker.selectRow(index, inComponent: 0, animated: false)
        }
    }
    
    @IBAction func swapLanguagesButtonTapped(_ sender: UIButton) {
        print("Bouton de changement de langue appuyé")
        print("Langue source avant échange : \(sourceLanguage)")
        print("Langue cible avant échange : \(targetLanguage)")
        
        (sourceLanguage, targetLanguage) = (targetLanguage, sourceLanguage)
        
        print("Langue source après échange : \(sourceLanguage)")
        print("Langue cible après échange : \(targetLanguage)")
        
        updateLanguageDisplay()
        
        print("Texte original avant échange : \(originTranslate.text ?? "")")
        print("Texte traduit avant échange : \(translatedText.text ?? "")")
        
        (originTranslate.text, translatedText.text) = (translatedText.text, originTranslate.text)
        
        print("Texte original après échange : \(originTranslate.text ?? "")")
        print("Texte traduit après échange : \(translatedText.text ?? "")")
    }
    
    func updateLanguageDisplay() {
        sourceLanguageLabel.text = translateLanguageName(language: sourceLanguage, to: sourceLanguage)
        targetLanguageLabel.text = translateLanguageName(language: targetLanguage, to: sourceLanguage)
        sourceLanguageTextField.text = translateLanguageName(language: sourceLanguage, to: sourceLanguage)
        targetLanguageTextField.text = translateLanguageName(language: targetLanguage, to: sourceLanguage)
        
        print("Affichage des langues mis à jour :")
        print("Label de la langue source : \(sourceLanguageLabel.text ?? "")")
        print("Label de la langue cible : \(targetLanguageLabel.text ?? "")")
    }
    
    @IBAction func translateButtonAction(_ sender: UIButton) {
        guard let text = originTranslate.text, !text.isEmpty else {
            resultLabel.text = "Input text is empty"
            return
        }
        
        TranslationService.detectLanguage(for: text) { [weak self] (detectedLanguage: String?, error: Error?) in
            DispatchQueue.main.async {
                if let detectedLanguage = detectedLanguage {
                    self?.sourceLanguage = detectedLanguage
                    self?.sourceLanguageTextField.text = self?.translateLanguageName(language: detectedLanguage, to: detectedLanguage)
                    self?.updateLanguageDisplay()
                    
                    TranslationService.translate(text: text, from: detectedLanguage, to: self?.targetLanguage ?? "en") { (translatedText: String?, error: Error?) in
                        DispatchQueue.main.async {
                            if let translatedText = translatedText {
                                self?.translatedText.text = translatedText
                            } else {
                                self?.resultLabel.text = error?.localizedDescription ?? "Failed to translate"
                            }
                        }
                    }
                } else {
                    self?.resultLabel.text = error?.localizedDescription ?? "Failed to detect language"
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

