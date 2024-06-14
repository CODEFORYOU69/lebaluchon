//
//  TranslateViewController.swift
//  Le_Baluchon
//
//  Created by younes ouasmi on 09/05/2024.
//

import UIKit

class TranslateViewController: UIViewController, LanguageSelectionDelegate {

    @IBOutlet weak var translatedText: UITextView!
    @IBOutlet weak var originTranslate: UITextView!
    @IBOutlet weak var translateButton: UIButton!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var translateTitle: UILabel!
    @IBOutlet weak var targetLanguageLabel: UILabel!
    @IBOutlet weak var sourceLanguageLabel: UILabel!
    @IBOutlet weak var swapLanguagesButton: UIButton!
    @IBOutlet weak var sourceLanguageTextField: UITextField!
    @IBOutlet weak var targetLanguageTextField: UITextField!
    
    
    
    var sourceLanguage = "en"
    var targetLanguage = "fr"
    
    var languages: [String: String] = [:] // Dictionary to store language codes and names
    
    var translationService: TranslationService!
    var settingsService: SettingsService!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize settingsService before any usage
        settingsService = SettingsService()
        
        setupUI()
        translationService = TranslationService()
        fetchLanguages()
        
        // Observe changes in user language settings
        NotificationCenter.default.addObserver(self, selector: #selector(userLanguageChanged), name: .userLanguageChanged, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateLanguageDisplay()
    }
    
    // Called when user language changes
    @objc private func userLanguageChanged() {
        fetchLanguages()
    }
    
    // Configuration user interface
    private func setupUI() {
        loadUserLanguage()
        updateLanguageDisplay()
        
        styleTextField(sourceLanguageTextField)
        styleTextField(targetLanguageTextField)
        styleTextView(translatedText)
        styleTextView(originTranslate)
        styleButton(translateButton)
        
        let sourceTapGesture = UITapGestureRecognizer(target: self, action: #selector(sourceLanguageTextFieldTapped))
        sourceLanguageTextField.addGestureRecognizer(sourceTapGesture)
        
        let targetTapGesture = UITapGestureRecognizer(target: self, action: #selector(targetLanguageTextFieldTapped))
        targetLanguageTextField.addGestureRecognizer(targetTapGesture)
    }
    
    // Handle tap on source language text field
    @objc private func sourceLanguageTextFieldTapped() {
        performSegue(withIdentifier: "showLanguageSelection", sender: sourceLanguageTextField)
    }
    
    // Handle tap on target language text field
    @objc private func targetLanguageTextFieldTapped() {
        performSegue(withIdentifier: "showLanguageSelection", sender: targetLanguageTextField)
    }
    
    // Prepare for segue to LanguageSelectionViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showLanguageSelection",
           let languageSelectionVC = segue.destination as? LanguageSelectionViewController,
           let textField = sender as? UITextField {
            languageSelectionVC.languages = self.languages
            languageSelectionVC.textField = textField
            languageSelectionVC.delegate = self
        }
    }
    
    // Handle language selection
    func didSelectLanguage(_ languageCode: String, languageName: String, for textField: UITextField) {
        if textField == sourceLanguageTextField {
            sourceLanguage = languageCode
        } else if textField == targetLanguageTextField {
            targetLanguage = languageCode
        }
        updateLanguageDisplay()
    }

    // Load user language from settings
    private func loadUserLanguage() {
        let userLanguage = settingsService.getUserLanguage()
        sourceLanguage = userLanguage
        sourceLanguageTextField.text = languages[userLanguage] ?? ""
    }
    
    // Swap source and target languages
    @IBAction private func swapLanguagesButtonTapped(_ sender: UIButton) {
        (sourceLanguage, targetLanguage) = (targetLanguage, sourceLanguage)
        updateLanguageDisplay()
        (originTranslate.text, translatedText.text) = (translatedText.text, originTranslate.text)
    }
    
    // Handle translate button action
    @IBAction private func translateButtonAction(_ sender: UIButton) {
        guard let text = originTranslate.text, !text.isEmpty else {
            resultLabel.text = "Le texte d'entrée est vide"
            return
        }
        
        // Detect the language of the input text
        translationService.detectLanguage(for: text) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let detectedLanguage):
                    self?.sourceLanguage = detectedLanguage
                    self?.sourceLanguageTextField.text = self?.languages[detectedLanguage] ?? detectedLanguage
                    self?.updateLanguageDisplay()
                    
                    // Translate the text to the target language
                    self?.translationService.translate(text: text, from: detectedLanguage, to: self?.targetLanguage ?? "en") { result in
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
    
    // Update language labels and text fields
    private func updateLanguageDisplay() {
        sourceLanguageLabel.text = languages[sourceLanguage]
        targetLanguageLabel.text = languages[targetLanguage]
        sourceLanguageTextField.text = languages[sourceLanguage]
        targetLanguageTextField.text = languages[targetLanguage]
    }
    
    // Fetch supported languages from the translation service
    private func fetchLanguages() {
        let userLanguage = settingsService.getUserLanguage()
        translationService.fetchSupportedLanguages(targetLanguage: userLanguage) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let languages):
                    self?.languages = languages
                    self?.updateLanguageDisplay()
                case .failure(let error):
                    print("Failed to fetch languages: \(error)")
                }
            }
        }
    }
    
}
