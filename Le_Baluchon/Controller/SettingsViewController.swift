//
//  SettingsViewController.swift
//  Le_Baluchon
//
//  Created by younes ouasmi on 16/05/2024.
//

import UIKit

class SettingsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var userLanguageTextField: UITextField!
    @IBOutlet weak var homeLocationTextField: UITextField!
    @IBOutlet weak var travelLocationTextField: UITextField!
    
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
    let settingsService = SettingsService()

    @IBOutlet weak var settingsTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLanguagePicker()
        
        userLanguageTextField.text = languageNames[settingsService.getUserLanguage()]
        homeLocationTextField.text = settingsService.getHomeLocation()
        travelLocationTextField.text = settingsService.getTravelLocation()
    }
    
    @IBAction func homeLocationTextFieldEditingDidEnd(_ sender: UITextField) {
        settingsService.setHomeLocation(sender.text ?? "")
    }
    
    @IBAction func travelLocationTextFieldEditingDidEnd(_ sender: UITextField) {
        settingsService.setTravelLocation(sender.text ?? "")
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
        settingsService.setUserLanguage(selectedLanguage)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let currentLanguage = textField.text, let index = languages.firstIndex(of: currentLanguage) {
            languagePicker.selectRow(index, inComponent: 0, animated: false)
        } else {
            languagePicker.selectRow(0, inComponent: 0, animated: false)
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
