// Copyright SIX DAY LLC. All rights reserved.

import UIKit

protocol KNPasscodeCoordinatorDelegate: class {
  func passcodeCoordinatorDidCancel()
  func passcodeCoordinatorDidCreatePasscode()
}

class KNPasscodeCoordinator: NSObject, Coordinator {

  let navigationController: UINavigationController
  let window: UIWindow = UIWindow()
  let type: KNPasscodeViewType
  var coordinators: [Coordinator] = []

  weak var delegate: KNPasscodeCoordinatorDelegate?

  lazy var passcodeViewController: KNPasscodeViewController = {
    let controller = KNPasscodeViewController(viewType: self.type, delegate: self)
    controller.loadViewIfNeeded()
    return controller
  }()

  init(
    navigationController: UINavigationController = UINavigationController(),
    type: KNPasscodeViewType
    ) {
    self.navigationController = navigationController
    self.type = type
    super.init()
    if self.type == .authenticate {
      self.window.windowLevel = UIWindowLevelStatusBar + 1.0
      self.window.rootViewController = self.passcodeViewController
      self.window.isHidden = true
    }
  }

  func start() {
    if KNPasscodeUtil.shared.currentPasscode() == nil && self.type == .authenticate { return }
    self.passcodeViewController.resetUI()
    if self.type == .authenticate {
      self.window.makeKeyAndVisible()
      self.window.isHidden = false
      self.passcodeViewController.showBioAuthenticationIfNeeded()
    } else {
      self.navigationController.pushViewController(self.passcodeViewController, animated: true)
    }
  }

  func stop(completion: @escaping () -> Void) {
    DispatchQueue.main.async {
      if self.type == .authenticate {
        self.window.isHidden = true
        completion()
      } else {
        self.navigationController.popViewController(animated: true, completion: completion)
      }
    }
  }
}

extension KNPasscodeCoordinator: KNPasscodeViewControllerDelegate {
  func passcodeViewController(_ controller: KNPasscodeViewController, run event: KNPasscodeViewEvent) {
    switch event {
    case .cancel:
      self.delegate?.passcodeCoordinatorDidCancel()
    case .evaluatedPolicyWithBio:
      self.didFinishEvaluatingWithBio()
    case .enterPasscode(let passcode):
      self.didFinishEnterPasscode(passcode)
    case .createNewPasscode(let passcode):
      self.didCreateNewPasscode(passcode)
    }
  }

  fileprivate func didFinishEvaluatingWithBio() {
    KNPasscodeUtil.shared.deleteNumberAttempts()
    KNPasscodeUtil.shared.deleteCurrentMaxAttemptTime()
    self.stop { }
  }

  fileprivate func didFinishEnterPasscode(_ passcode: String) {
    guard let currentPasscode = KNPasscodeUtil.shared.currentPasscode() else {
      self.stop {}
      return
    }
    if currentPasscode == passcode {
      KNPasscodeUtil.shared.deleteNumberAttempts()
      KNPasscodeUtil.shared.deleteCurrentMaxAttemptTime()
      self.stop {}
    } else {
      KNPasscodeUtil.shared.recordNewAttempt()
      if KNPasscodeUtil.shared.numberAttemptsLeft() == 0 {
        KNPasscodeUtil.shared.recordNewMaxAttemptTime()
      }
      self.passcodeViewController.userDidTypeWrongPasscode()
    }
  }

  fileprivate func didCreateNewPasscode(_ passcode: String) {
    KNPasscodeUtil.shared.setNewPasscode(passcode)
    self.delegate?.passcodeCoordinatorDidCreatePasscode()
  }
}
