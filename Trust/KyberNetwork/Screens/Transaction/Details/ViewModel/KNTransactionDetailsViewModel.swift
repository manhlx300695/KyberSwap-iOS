// Copyright SIX DAY LLC. All rights reserved.

import UIKit

struct KNTransactionDetailsViewModel {

  lazy var dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEEE, MMMM dd yyyy, HH:mm:ss Z"
    return formatter
  }()

  fileprivate(set) var transaction: Transaction?
  fileprivate(set) var currentWallet: KNWalletObject

  init(
    transaction: Transaction?,
    currentWallet: KNWalletObject
    ) {
    self.transaction = transaction
    self.currentWallet = currentWallet
  }

  var isSwap: Bool {
    return self.transaction?.localizedOperations.first?.type == "exchange"
  }

  var isSent: Bool {
    guard let transaction = self.transaction, !self.isSwap else { return false }
    return transaction.from.lowercased() == self.currentWallet.address.lowercased()
  }

  var displayedAmountString: String {
    guard let transaction = self.transaction, let localObject = transaction.localizedOperations.first else { return "" }
    if self.isSwap {
      let amountFrom: String = String(transaction.value.prefix(6))
      let fromText: String = "\(amountFrom) \(localObject.symbol ?? "")"

      let amountTo: String = String(localObject.value.prefix(6))
      let toText = "\(amountTo) \(localObject.name ?? "")"

      return "\(fromText) -> \(toText)"
    }
    let sign: String = self.isSent ? "-" : "+"
    return "\(sign)\(transaction.value.prefix(6)) \(localObject.symbol ?? "")"
  }

  var displayedAmountColorHex: String {
    if self.isSwap { return "f89f50" }
    return self.isSent ? "f87171" : "31cb9e"
  }

  lazy var textAttachment: NSTextAttachment = {
    let attachment = NSTextAttachment()
    attachment.image = UIImage(named: "copy_icon")
    return attachment
  }()

  lazy var textAttributes: [NSAttributedStringKey: Any] = [
    NSAttributedStringKey.foregroundColor: UIColor(hex: "5a5e67"),
    NSAttributedStringKey.font: UIFont(name: "SFProText-Regular", size: 17)!,
  ]

  mutating func fromAttributedString() -> NSAttributedString {
    let attributedString = NSMutableAttributedString()
    attributedString.append(NSAttributedString(string: "\(transaction?.from ?? "")  ", attributes: textAttributes))
    attributedString.append(NSAttributedString(attachment: textAttachment))
    return attributedString
  }

  mutating func toAttributedString() -> NSAttributedString {
    let attributedString = NSMutableAttributedString()
    attributedString.append(NSAttributedString(string: "\(transaction?.to ?? "")  ", attributes: textAttributes))
    attributedString.append(NSAttributedString(attachment: textAttachment))
    return attributedString
  }

  mutating func txHashAttributedString() -> NSAttributedString {
    let attributedString = NSMutableAttributedString()
    attributedString.append(NSAttributedString(string: "\(transaction?.id ?? "")  ", attributes: textAttributes))
    attributedString.append(NSAttributedString(attachment: textAttachment))
    return attributedString
  }

  mutating func dateString() -> String {
    guard let date = self.transaction?.date else { return "" }
    return self.dateFormatter.string(from: date)
  }

  mutating func update(transaction: Transaction, currentWallet: KNWalletObject) {
    self.transaction = transaction
    self.currentWallet = currentWallet
  }
}