//
//  TranslateViewController.swift
//  Le_Baluchon
//
//  Created by younes ouasmi on 09/05/2024.
//

import UIKit



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
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadUserLanguage()
        updateLanguageDisplay()
    }
    
    // Configuration de l'interface utilisateur
    private func setupUI() {
        setupTapGesture()
        setupLanguagePicker()
        loadUserLanguage()
        updateLanguageDisplay()
        
        styleTextField(sourceLanguageTextField)
        styleTextField(targetLanguageTextField)
        styleTextView(translatedText)
        styleTextView(originTranslate)
        styleButton(translateButton)
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func setupLanguagePicker() {
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
    
    @objc private func doneButtonTapped() {
        activeTextField?.resignFirstResponder()
    }
    
    private func loadUserLanguage() {
        if let userLanguage = UserDefaults.standard.string(forKey: "userLanguage") {
            sourceLanguage = userLanguage
            sourceLanguageTextField.text = languageNames[userLanguage]
        } else {
            sourceLanguage = "en"
            sourceLanguageTextField.text = languageNames["en"]
        }
    }
    
    @IBAction private func swapLanguagesButtonTapped(_ sender: UIButton) {
        (sourceLanguage, targetLanguage) = (targetLanguage, sourceLanguage)
        updateLanguageDisplay()
        (originTranslate.text, translatedText.text) = (translatedText.text, originTranslate.text)
    }
    
    @IBAction private func translateButtonAction(_ sender: UIButton) {
        guard let text = originTranslate.text, !text.isEmpty else {
            resultLabel.text = "Le texte d'entrée est vide"
            return
        }
        
        TranslationService.detectLanguage(for: text) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let detectedLanguage):
                    self?.sourceLanguage = detectedLanguage
                    self?.sourceLanguageTextField.text = self?.translateLanguageName(language: detectedLanguage, to: detectedLanguage)
                    self?.updateLanguageDisplay()
                    
                    TranslationService.translate(text: text, from: detectedLanguage, to: self?.targetLanguage ?? "en") { result in
                        DispatchQueue.main.async {
                            switch result {
                            case .success(let translatedText):
                                self?.translatedText.text = translatedText
                            case .failure(let error):
                                self?.resultLabel.text = error.localizedDescription
                            }
                        }
                    }
                    
                case .failure(let error):
                    self?.resultLabel.text = error.localizedDescription
                }
            }
        }
    }
    
    private func updateLanguageDisplay() {
        sourceLanguageLabel.text = translateLanguageName(language: sourceLanguage, to: sourceLanguage)
        targetLanguageLabel.text = translateLanguageName(language: targetLanguage, to: sourceLanguage)
        sourceLanguageTextField.text = translateLanguageName(language: sourceLanguage, to: sourceLanguage)
        targetLanguageTextField.text = translateLanguageName(language: targetLanguage, to: sourceLanguage)
    }
    
    private func translateLanguageName(language: String, to userLanguage: String) -> String {
        let translations = [
            "en": ["fr": "Anglais", "es": "Inglés", "de": "Englisch", "it": "Inglese", "pt": "Inglês", "zh": "英语", "ja": "英語"],
            "fr": ["en": "Français", "es": "Francés", "de": "Französisch", "it": "Francese", "pt": "Francês", "zh": "法语", "ja": "フランス語"],
            "es": ["en": "Español", "fr": "Espagnol", "de": "Spanisch", "it": "Spagnolo", "pt": "Espanhol", "zh": "西班牙语", "ja": "スペイン語"],
            "de": ["en": "Deutsch", "fr": "Allemand", "es": "Alemán", "it": "Tedesco", "pt": "Alemão", "zh": "德语", "ja": "ドイツ語"],
        ]
        return translations[language]?[userLanguage] ?? languageNames[language] ?? language
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return languages.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
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
    
    private func styleTextField(_ textField: UITextField) {
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.borderWidth = 0.5
        textField.layer.cornerRadius = 5
    }
    
    private func styleTextView(_ textView: UITextView) {
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 0.5
        textView.layer.cornerRadius = 5
    }
    
    private func styleButton(_ button: UIButton) {
        button.layer.cornerRadius = 10
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.2
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
    }
}
