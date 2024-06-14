//
//  SettingsViewController.swift
//  Le_Baluchon
//
//  Created by younes ouasmi on 16/05/2024.
//

import UIKit

class SettingsViewController: UIViewController, LanguageSelectionDelegate {
    
    @IBOutlet weak var userLanguageTextField: UITextField!
    @IBOutlet weak var homeLocationTextField: UITextField!
    @IBOutlet weak var travelLocationTextField: UITextField!
    
    let settingsService = SettingsService()
    var languages: [String: String] = [:] // Store fetched languages
    
    @IBOutlet weak var settingsTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        userLanguageTextField.text = settingsService.getUserLanguage()
        homeLocationTextField.text = settingsService.getHomeLocation()
        travelLocationTextField.text = settingsService.getTravelLocation()
        
        fetchLanguages()
    }
    
    @IBAction func homeLocationTextFieldEditingDidEnd(_ sender: UITextField) {
        settingsService.setHomeLocation(sender.text ?? "")
    }
    
    @IBAction func travelLocationTextFieldEditingDidEnd(_ sender: UITextField) {
        settingsService.setTravelLocation(sender.text ?? "")
    }
    
    private func setupUI() {
        setupTapGesture()
        
        let userLanguageTapGesture = UITapGestureRecognizer(target: self, action: #selector(userLanguageTextFieldTapped))
        userLanguageTextField.addGestureRecognizer(userLanguageTapGesture)
    }
    
    @objc private func userLanguageTextFieldTapped() {
        performSegue(withIdentifier: "showLanguageSelection", sender: userLanguageTextField)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showLanguageSelection",
           let languageSelectionVC = segue.destination as? LanguageSelectionViewController,
           let textField = sender as? UITextField {
            languageSelectionVC.languages = self.languages
            languageSelectionVC.textField = textField
            languageSelectionVC.delegate = self
        }
    }
    
    func didSelectLanguage(_ languageCode: String, languageName: String, for textField: UITextField) {
        textField.text = languageName
        if textField == userLanguageTextField {
            settingsService.setUserLanguage(languageCode)
        }
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // Fetch the available languages
    private func fetchLanguages() {
        let translationService = TranslationService()
        
        translationService.fetchSupportedLanguages(targetLanguage: settingsService.getUserLanguage()) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedLanguages):
                    self?.languages = fetchedLanguages
                case .failure(let error):
                    print("Failed to fetch languages: \(error)")
                }
            }
        }
    }
}
