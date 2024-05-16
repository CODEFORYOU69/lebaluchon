//
//  CurrencyViewController.swift
//  Le_Baluchon
//
//  Created by younes ouasmi on 09/05/2024.
//


import UIKit



class CurrencyViewController: UIViewController {
    private let conversionService = CurrencyConversionService()
        private var exchangeRates: [String: Double]?
        private var selectedFromCurrency: Currency?
        private var selectedToCurrency: Currency?
    
    private var currencies: [Currency] = []

    @IBOutlet weak var convertCurrencyLabel: UILabel!
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var convertbutton: UIButton!
    @IBOutlet weak var fromCurrencyPicker: UIPickerView!
    @IBOutlet weak var toCurrencyPicker: UIPickerView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Currency Converter"
        setupTapGesture()
        currencies = conversionService.currencies
        fromCurrencyPicker.reloadAllComponents()
        toCurrencyPicker.reloadAllComponents()
        styleButtons()
        fetchExchangeRates()
        styleLabels()

        for family in UIFont.familyNames {
               print("\(family)")
               for name in UIFont.fontNames(forFamilyName: family) {
                   print("  \(name)")
               }
           }

       
    }
    
    

    @IBAction func convertButtonTapped(_ sender: UIButton) {
        guard let amountText = amountTextField.text,
              let amount = Double(amountText),
              let rates = exchangeRates,
              let fromCurrency = selectedFromCurrency,
              let toCurrency = selectedToCurrency else {
            resultLabel.text = "Invalid input or exchange rates not available"
            print("Invalid input or exchange rates not available")
            return
        }
        
        print("Amount: \(amount)")
        print("From Currency: \(fromCurrency.code)")
        print("To Currency: \(toCurrency.code)")
        print("Stored Rates: \(rates)")
            if let convertedAmount = conversionService.convert(amount: amount, from: fromCurrency.code, to: toCurrency.code, rates: rates) {
                resultLabel.text = String(format: "Converted amount: %.2f \(toCurrency.code)", convertedAmount)
                print("Conversion succeeded: \(convertedAmount) \(toCurrency.code)")

            } else {
                resultLabel.text = "Conversion failed"
                print("Conversion failed")

            }
        }
    
    private func fetchExchangeRates() {
        guard let fromCode = selectedFromCurrency?.code, let toCode = selectedToCurrency?.code else {
            print("Currency codes not selected")
            return
        }
        let requiredCurrencies = [fromCode, toCode]
        conversionService.fetchExchangeRates(for: requiredCurrencies) { [weak self] rates in
            DispatchQueue.main.async {
                if let rates = rates {
                    self?.exchangeRates = rates
                    self?.fromCurrencyPicker.reloadAllComponents()
                    self?.toCurrencyPicker.reloadAllComponents()
                } else {
                    self?.resultLabel.text = "Failed to fetch exchange rates"

                }
            }
        }
    }
    private func setupTapGesture() {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
            view.addGestureRecognizer(tapGesture)
        }
    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    private func styleLabels() {
           let labels = [fromLabel, toLabel, convertCurrencyLabel]
           for label in labels {
               label?.textColor = UIColor.white
               label?.layer.shadowColor = UIColor.black.cgColor
               label?.layer.shadowOpacity = 0.7
               label?.layer.shadowOffset = CGSize(width: 1, height: 1)
               label?.layer.shadowRadius = 2
           }
       }
    private func styleButtons() {
           convertbutton.setTitleColor(UIColor.white, for: .normal)
        convertbutton.layer.cornerRadius = 10
        convertbutton.layer.shadowColor = UIColor.black.cgColor
        convertbutton.layer.shadowOpacity = 0.2
        convertbutton.layer.shadowOffset = CGSize(width: 0, height: 2)
        convertbutton.layer.shadowRadius = 4
       }
}
extension CurrencyViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
           return currencies.count
       }


    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let currency = currencies[row]
        
        // Créer un conteneur pour la ligne
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 250, height: 40))

        // Configuration de l'image du drapeau
        let flag = UIImage(named: currency.flag)
        let flagImageView = UIImageView(image: flag)
        flagImageView.contentMode = .scaleAspectFit
        flagImageView.frame = CGRect(x: 5, y: 5, width: 30, height: 30)

        // Configuration du label pour le code et le pays de la devise
        let label = UILabel()
        label.text = "\(currency.code) - \(currency.country)"
        label.frame = CGRect(x: 60, y: 0, width: 250, height: 40)
        label.font = UIFont(name: "SF-Pro", size: 15)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.textAlignment = .left
       

        // Ajout des sous-vues au conteneur
        container.addSubview(flagImageView)
        container.addSubview(label)
        
        return container
    }


    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            let selectedCurrency = currencies[row]
            if pickerView == fromCurrencyPicker {
                selectedFromCurrency = selectedCurrency
            } else if pickerView == toCurrencyPicker {
                selectedToCurrency = selectedCurrency
            }
        fetchExchangeRates()  // Fetch rates again if currency selection changes
}
    
    
    }
