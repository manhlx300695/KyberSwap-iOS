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

  var displayedAmountColor: UIColor {
    if self.isSwap { return UIColor.Kyber.merigold }
    return self.isSent ? UIColor.Kyber.merigold : UIColor.Kyber.shamrock
  }

  lazy var textAttachment: NSTextAttachment = {
    let attachment = NSTextAttachment()
    attachment.image = UIImage(named: "copy_icon")
    return attachment
  }()

  lazy var textAttributes: [NSAttributedStringKey: Any] = [
    NSAttributedStringKey.foregroundColor: UIColor.Kyber.gray,
    NSAttributedStringKey.font: UIFont.Kyber.medium(with: 16),
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
