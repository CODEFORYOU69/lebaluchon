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
    
    @IBOutlet weak var toCurrencyFlagImageView: UIImageView!
    @IBOutlet weak var fromCurrencyFlagImageView: UIImageView!
    @IBOutlet weak var swapCurrencyButton: UIButton!
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
        styleButton(convertbutton)
        fetchExchangeRates()
        amountTextField.textColor = UIColor.black
        amountTextField.layer.borderColor = UIColor.darkGray.cgColor
        view.bringSubviewToFront(toCurrencyFlagImageView)
        view.bringSubviewToFront(fromCurrencyFlagImageView)
        
        setFlagImageViewSize(imageView: fromCurrencyFlagImageView, size: CGSize(width: 40, height: 40))
            setFlagImageViewSize(imageView: toCurrencyFlagImageView, size: CGSize(width: 40, height: 40))
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
            resultLabel.text = String(format: "Result: %.2f \(toCurrency.code)", convertedAmount)
            print("Conversion succeeded: \(convertedAmount) \(toCurrency.code)")
            
        } else {
            resultLabel.text = "Conversion failed"
            print("Conversion failed")
            
        }
    }
    
    @IBAction func swapButtonTapped(_ sender: UIButton) {
        swap(&selectedFromCurrency, &selectedToCurrency)
        if let fromCurrencyIndex = currencies.firstIndex(where: { $0.code == selectedFromCurrency?.code }),
           let toCurrencyIndex = currencies.firstIndex(where: { $0.code == selectedToCurrency?.code }) {
            fromCurrencyPicker.selectRow(fromCurrencyIndex, inComponent: 0, animated: true)
            toCurrencyPicker.selectRow(toCurrencyIndex, inComponent: 0, animated: true)
        }
        updateCurrencyLabelsAndFlags()
        fetchExchangeRates()
    }

    private func fetchExchangeRates() {
        guard let fromCode = selectedFromCurrency?.code, let toCode = selectedToCurrency?.code else {
            print("Currency codes not selected")
            return
        }
        let requiredCurrencies = [fromCode, toCode]
        conversionService.fetchExchangeRates(for: requiredCurrencies) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let rates):
                    self?.exchangeRates = rates
                    self?.fromCurrencyPicker.reloadAllComponents()
                    self?.toCurrencyPicker.reloadAllComponents()
                case .failure(let error):
                    self?.resultLabel.text = "Failed to fetch exchange rates: \(error.localizedDescription)"
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
            label?.textColor = UIColor.black
            label?.layer.shadowColor = UIColor.black.cgColor
            label?.layer.shadowOpacity = 0.7
            label?.layer.shadowOffset = CGSize(width: 1, height: 1)
            label?.layer.shadowRadius = 2
            
        }
    }
    
    private func styleButtons() {
        convertbutton.layer.cornerRadius = 10
        convertbutton.layer.shadowColor = UIColor.black.cgColor
        convertbutton.layer.shadowOpacity = 0.2
        convertbutton.layer.shadowOffset = CGSize(width: 0, height: 2)
        convertbutton.layer.shadowRadius = 4
        convertbutton.layer.borderWidth = 1
        convertbutton.layer.borderColor = UIColor.darkGray.cgColor
    }
    private func setFlagImageViewSize(imageView: UIImageView, size: CGSize) {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: size.width),
            imageView.heightAnchor.constraint(equalToConstant: size.height)
        ])
    }
    private func updateCurrencyLabelsAndFlags() {
        if let fromCurrency = selectedFromCurrency {
            fromCurrencyFlagImageView.image = UIImage(named: fromCurrency.flag)
            fromLabel.text = "From: \(fromCurrency.country)"
        }
        
        if let toCurrency = selectedToCurrency {
            toCurrencyFlagImageView.image = UIImage(named: toCurrency.flag)
            toLabel.text = "To: \(toCurrency.country)"
        }
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
        
        // Create container for lines
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 180, height: 40))
        
        // Configure flag
        let flag = UIImage(named: currency.flag)
        let flagImageView = UIImageView(image: flag)
        flagImageView.contentMode = .scaleAspectFit
        flagImageView.frame = CGRect(x: 10, y: 5, width: 30, height: 30)
        
        // Configure contry code label and currency
        let label = UILabel()
        label.text = "\(currency.code) - \(currency.country)"
        label.frame = CGRect(x: 60, y: 0, width: 180, height: 40)
        label.font = UIFont(name: "SFPro-CompressedMedium", size: 15)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.textAlignment = .left
        label.textColor = UIColor.black
        
        // add subview to container
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
        updateCurrencyLabelsAndFlags()
        fetchExchangeRates()  // Fetch rates again if currency selection changes
    }
}
