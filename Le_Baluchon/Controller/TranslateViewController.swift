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
    
    var languages: [String: String] = [:] // Dictionary to store language codes and names
    var languageCodes: [String] = [] // Array to store the language codes for pickerView
    var filteredLanguageCodes: [String] = [] // Array to store filtered language codes
    
    let languagePicker = UIPickerView()
    var activeTextField: UITextField?
    
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
        loadUserLanguage()
        updateLanguageDisplay()
    }
    
    @objc private func userLanguageChanged() {
        fetchLanguages()
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
        let userLanguage = settingsService.getUserLanguage()
        sourceLanguage = userLanguage
        sourceLanguageTextField.text = languages[userLanguage] ?? ""
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
        
        translationService.detectLanguage(for: text) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let detectedLanguage):
                    self?.sourceLanguage = detectedLanguage
                    self?.sourceLanguageTextField.text = self?.languages[detectedLanguage] ?? detectedLanguage
                    self?.updateLanguageDisplay()
                    
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
    
    private func updateLanguageDisplay() {
        sourceLanguageLabel.text = languages[sourceLanguage]
        targetLanguageLabel.text = languages[targetLanguage]
        sourceLanguageTextField.text = languages[sourceLanguage]
        targetLanguageTextField.text = languages[targetLanguage]
    }
    
    private func fetchLanguages() {
        let userLanguage = settingsService.getUserLanguage()
        translationService.fetchSupportedLanguages(targetLanguage: userLanguage) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let languages):
                    self?.languages = languages
                    self?.languageCodes = Array(languages.keys).sorted()
                    self?.filteredLanguageCodes = self?.languageCodes ?? []
                    self?.languagePicker.reloadAllComponents()
                case .failure(let error):
                    print("Failed to fetch languages: \(error)")
                }
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return filteredLanguageCodes.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedLanguage = filteredLanguageCodes[row]
        if activeTextField == sourceLanguageTextField {
            sourceLanguage = selectedLanguage
            sourceLanguageTextField.text = languages[selectedLanguage]
        } else if activeTextField == targetLanguageTextField {
            targetLanguage = selectedLanguage
            targetLanguageTextField.text = languages[selectedLanguage]
        }
        updateLanguageDisplay()
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let languageCode = filteredLanguageCodes[row]
        return languages[languageCode]
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
        
        if let currentLanguage = textField.text, let index = languageCodes.firstIndex(of: currentLanguage) {
            languagePicker.selectRow(index, inComponent: 0, animated: false)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let searchText = (text as NSString).replacingCharacters(in: range, with: string)
        filterLanguages(searchText: searchText)
        return true
    }
    
    private func filterLanguages(searchText: String) {
        if searchText.isEmpty {
            filteredLanguageCodes = languageCodes
        } else {
            filteredLanguageCodes = languageCodes.filter { languageCode in
                guard let languageName = languages[languageCode] else { return false }
                return languageName.lowercased().contains(searchText.lowercased())
            }
        }
        languagePicker.reloadAllComponents()
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
