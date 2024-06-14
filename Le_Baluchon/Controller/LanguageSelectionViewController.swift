import UIKit

protocol LanguageSelectionDelegate: AnyObject {
    func didSelectLanguage(_ languageCode: String, languageName: String, for textField: UITextField)
}

class LanguageSelectionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var languages: [String: String] = [:] // Dictionary to store language codes and names
    var filteredLanguages: [String] = [] // Array to store filtered language codes
    var textField: UITextField!
    weak var delegate: LanguageSelectionDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        filteredLanguages = Array(languages.keys).sorted()
    }

    // MARK: - TableView DataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredLanguages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LanguageCell", for: indexPath)
        let languageCode = filteredLanguages[indexPath.row]
        cell.textLabel?.text = languages[languageCode]
        return cell
    }
    
    // MARK: - TableView Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let languageCode = filteredLanguages[indexPath.row]
        let languageName = languages[languageCode] ?? ""
        delegate?.didSelectLanguage(languageCode, languageName: languageName, for: textField)
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - SearchBar Delegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredLanguages = Array(languages.keys).sorted()
        } else {
            filteredLanguages = languages.keys.filter { languageCode in
                guard let languageName = languages[languageCode] else { return false }
                return languageName.lowercased().contains(searchText.lowercased())
            }
        }
        tableView.reloadData()
    }
}
