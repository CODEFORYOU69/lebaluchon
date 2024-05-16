//
//  SettingsViewController.swift
//  Le_Baluchon
//
//  Created by younes ouasmi on 16/05/2024.
//

import UIKit

class SettingsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var userLanguageTextField: UITextField!
    
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
    
    @IBOutlet weak var settingsTitle: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLanguagePicker()
        
        if let userLanguage = UserDefaults.standard.string(forKey: "userLanguage") {
            userLanguageTextField.text = languageNames[userLanguage]
        } else {
            userLanguageTextField.text = languageNames["en"]
        }
    }
    
    func setupLanguagePicker() {
        languagePicker.delegate = self
        languagePicker.dataSource = self
        userLanguageTextField.inputView = languagePicker

        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        toolbar.setItems([doneButton], animated: true)
        userLanguageTextField.inputAccessoryView = toolbar
    }
    
    @objc func doneButtonTapped() {
        userLanguageTextField.resignFirstResponder()
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return languages.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return languageNames[languages[row]]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedLanguage = languages[row]
        userLanguageTextField.text = languageNames[selectedLanguage]
        
        UserDefaults.standard.set(selectedLanguage, forKey: "userLanguage")
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let currentLanguage = textField.text, let index = languages.firstIndex(of: currentLanguage) {
            languagePicker.selectRow(index, inComponent: 0, animated: false)
        } else {
            languagePicker.selectRow(0, inComponent: 0, animated: false)
        }
    }
}

