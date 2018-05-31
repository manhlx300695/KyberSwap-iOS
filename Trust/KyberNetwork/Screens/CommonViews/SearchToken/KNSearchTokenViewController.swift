// Copyright SIX DAY LLC. All rights reserved.

import UIKit

protocol KNSearchTokenViewControllerDelegate: class {
  func searchTokenViewControllerDidCancel()
  func searchTokenViewControllerDidSelect(token: TokenObject)
}

class KNSearchTokenViewModel {

  var supportedTokens: [TokenObject] = []
  var searchedText: String = "" {
    didSet {
      self.updateDisplayedTokens()
    }
  }
  var displayedTokens: [TokenObject] = []

  init(supportedTokens: [TokenObject]) {
    self.supportedTokens = supportedTokens.sorted(by: { return $0.symbol < $1.symbol })
    self.searchedText = ""
    self.displayedTokens = self.supportedTokens
  }

  func updateDisplayedTokens() {
    if self.searchedText == "" {
      self.displayedTokens = self.supportedTokens
      return
    }
    self.displayedTokens = self.supportedTokens.filter({ ($0.symbol + " " + $0.name).lowercased().contains(self.searchedText.lowercased()) })
    self.displayedTokens.sort(by: { return $0.symbol < $1.symbol })
  }

  func updateListSupportedTokens(_ tokens: [TokenObject]) {
    self.supportedTokens = tokens.sorted(by: { return $0.symbol < $1.symbol })
    self.updateDisplayedTokens()
  }
}

class KNSearchTokenViewController: KNBaseViewController {

  fileprivate let kSearchTokenTableViewCellID: String = "CellID"

  @IBOutlet weak var searchBar: UISearchBar!
  @IBOutlet weak var tokensTableView: UITableView!

  fileprivate var viewModel: KNSearchTokenViewModel
  weak var delegate: KNSearchTokenViewControllerDelegate?

  init(viewModel: KNSearchTokenViewModel) {
    self.viewModel = viewModel
    super.init(nibName: KNSearchTokenViewController.className, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.setupUI()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.searchBar.text = ""
    self.viewModel.searchedText = ""
    self.tokensTableView.reloadData()
    self.searchBar.becomeFirstResponder()
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    self.searchBar.resignFirstResponder()
  }

  fileprivate func setupUI() {
    self.searchBar.isTranslucent = true
    self.searchBar.delegate = self
    searchBar.backgroundImage = UIImage()
    let nib = UINib(nibName: KNSearchTokenTableViewCell.className, bundle: nil)
    self.tokensTableView.register(nib, forCellReuseIdentifier: kSearchTokenTableViewCellID)
    self.tokensTableView.rowHeight = 46
    self.tokensTableView.delegate = self
    self.tokensTableView.dataSource = self
  }

  fileprivate func searchTextDidChange(_ newText: String) {
    self.viewModel.searchedText = newText
    self.tokensTableView.reloadData()
  }

  func updateListSupportedTokens(_ tokens: [TokenObject]) {
    self.viewModel.updateListSupportedTokens(tokens)
    self.tokensTableView.reloadData()
  }

  @IBAction func screenEdgePanAction(_ sender: Any) {
    self.delegate?.searchTokenViewControllerDidCancel()
  }

  @IBAction func cancelButtonPressed(_ sender: Any) {
    self.delegate?.searchTokenViewControllerDidCancel()
  }
}

extension KNSearchTokenViewController: UISearchBarDelegate {
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    searchBar.text = searchText
    self.searchTextDidChange(searchText)
  }

  func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    let text = ((searchBar.text ?? "") as NSString).replacingCharacters(in: range, with: text)
    searchBar.text = text
    self.searchTextDidChange(text)
    return false
  }
}

extension KNSearchTokenViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    if indexPath.row < self.viewModel.displayedTokens.count {
      let token = self.viewModel.displayedTokens[indexPath.row]
      self.delegate?.searchTokenViewControllerDidSelect(token: token)
    }
  }
}

extension KNSearchTokenViewController: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.viewModel.displayedTokens.count
  }

  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    return UIView()
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: kSearchTokenTableViewCellID, for: indexPath) as! KNSearchTokenTableViewCell
    let token = self.viewModel.displayedTokens[indexPath.row]
    cell.updateCell(with: token)
    return cell
  }
}
