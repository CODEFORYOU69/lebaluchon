//
//  SettingsViewController.swift
//  Le_Baluchon
//
//  Created by younes ouasmi on 16/05/2024.
//

import UIKit

class SettingsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var userLanguageTextField: UITextField!
    
    @IBOutlet var dissMiss: UITapGestureRecognizer!
    @IBOutlet weak var homeLocationTextField: UITextField!
    @IBOutlet weak var travelLocationTextfield: UITextField!
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
        
        homeLocationTextField.text = UserDefaults.standard.string(forKey: "homeLocation")
        travelLocationTextfield.text = UserDefaults.standard.string(forKey: "travelLocation")
    }
    
    @IBAction func homeLocationTextFieldEditingDidEnd(_ sender: UITextField) {
        UserDefaults.standard.set(sender.text, forKey: "homeLocation")
        NotificationCenter.default.post(name: .homeLocationChanged, object: nil)
    }
    
    @IBAction func travelLocationTextFieldEditingDidEnd(_ sender: UITextField) {
        UserDefaults.standard.set(sender.text, forKey: "travelLocation")
        NotificationCenter.default.post(name: .travelLocationChanged, object: nil)
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
        NotificationCenter.default.post(name: .userLanguageChanged, object: nil)
        
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
    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
}
// Notification names
extension Notification.Name {
    static let homeLocationChanged = Notification.Name("homeLocationChanged")
    static let travelLocationChanged = Notification.Name("travelLocationChanged")
    static let userLanguageChanged = Notification.Name("userLanguageChanged")
}
