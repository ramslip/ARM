//
//  ViewController.swift
//  arm
//
//  Created by Ekaterina Lapkovskaya on 17.08.17.
//  Copyright © 2017 Ekaterina Lapkovskaya. All rights reserved.
//

import UIKit
import Material
import SwiftMessageBar
import NVActivityIndicatorView
import RealmSwift
class LoginViewController: ViewController, UITextFieldDelegate, UIGestureRecognizerDelegate, SyncStatusDelegate {
    
    @IBOutlet weak var appVersionLabel: UILabel!
    @IBOutlet weak var enterRaisedButton: RaisedButton!
    @IBOutlet weak var passwordTextField: TextField!
    @IBOutlet weak var loginTextField: TextField!
    @IBOutlet weak var indicatorView: NVActivityIndicatorView!
    
    @IBOutlet weak var progressLabel: ProgressLabel!
    var isValid: Bool = false
    
    var syncSesson : SyncSession?
    
    override func viewDidLoad() {
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
        }
        
        appVersionLabel.text = "v \(Utils.appVersion)"
        
//        print (Realm.Configuration.defaultConfiguration.fileURL!)
        indicatorView.type = .lineSpinFadeLoader
        loginTextField.placeholder = "Логин"
        loginTextField.isClearIconButtonEnabled = true
        loginTextField.clearButtonMode = .whileEditing
        loginTextField.clearIconButton?.tintColor = Color.white
        loginTextField.placeholderActiveColor = Color.white
        loginTextField.placeholderNormalColor = Color.white
        loginTextField.dividerNormalColor = Color.white
        loginTextField.dividerActiveColor = Color.white
        loginTextField.autocorrectionType = .no
        loginTextField.textColor = Color.white
        
        passwordTextField.placeholder = "Пароль"
        passwordTextField.isVisibilityIconButtonEnabled = true
        passwordTextField.visibilityIconButton?.tintColor = Color.white
        passwordTextField.placeholderActiveColor = Color.white
        passwordTextField.placeholderNormalColor = Color.white
        passwordTextField.dividerNormalColor = Color.white
        passwordTextField.dividerActiveColor = Color.white
        passwordTextField.textColor = Color.white
        passwordTextField.autocorrectionType = .no
        enterRaisedButton.pulseColor = ColorsHelper.buttonPulseColor()
        enterRaisedButton.isEnabled = false
        enterRaisedButton.backgroundColor = Color.blueGrey.lighten3
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(LoginViewController.dismissKeyboard))
        tap.delegate = self
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    @IBAction func enterButtonPressed(_ sender: RaisedButton) {
        self.progressLabel.isHidden = false
        loginTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        indicatorView.startAnimating()
        enterRaisedButton.isEnabled = false
        enterRaisedButton.backgroundColor = Color.blueGrey.lighten3
        self.progressLabel.updateWithText(text: "Выполняю вход")
        
        let login = self.loginTextField.text!
        let password = self.passwordTextField.text!
        
        APIClient.sharedClient.login(userName: login, password: password) {
            statusCode in
            let success:Bool = statusCode == StatusCodes.ok.rawValue
            if !success {
                self.indicatorView.stopAnimating()
                let message = StatusCodeManager.getStatusCodeDescription(statusCode: statusCode!)
                SwiftMessageBar.showMessageWithTitle("Ошибка", message: message, type: .error)
                self.enterRaisedButton.isEnabled = true
                self.enterRaisedButton.backgroundColor = Color.white
                self.isValid = false
                self.progressLabel.isHidden = true
            }
            else {
                self.progressLabel.updateWithText(text: "Успешно")
                
                let defaults = UserDefaults.standard
                defaults.set(login, forKey: "login")
                defaults.set(password, forKey: "password")

                //TODO: прогресс синхронизации
                self.syncSesson = SyncSession(login: login, password: password)
                self.syncSesson?.run(completion: {[weak self] (result) in
                    
                    if(result){
                        BaseContext.reset()
                        self?.allLessonsDidSync()
                    }
                    else{
                        let message = StatusCodeManager.getStatusCodeDescription(statusCode: statusCode!)
                        SwiftMessageBar.showMessageWithTitle("Ошибка", message: message, type: .error)
                    }
                })
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return self.isValid
    }
    
//    func getBaseContext() {
//        self.progressLabel.updateWithText(text: "Получаю базовый контекст пользователя")
//        APIClient.sharedClient.delegate = self
//        APIClient.sharedClient.getBaseContext() {
//            statusCode in
//            let success:Bool = statusCode == StatusCodes.ok.rawValue
//            if !success {
//                self.indicatorView.stopAnimating()
//                let message = StatusCodeManager.getStatusCodeDescription(statusCode: statusCode!)
//                SwiftMessageBar.showMessageWithTitle("Ошибка", message: message, type: .error)
//                self.enterRaisedButton.isEnabled = true
//                self.enterRaisedButton.backgroundColor = Color.white
//                self.isValid = false
//                self.progressLabel.isHidden = true
//            }
//            else {
//                self.isValid = true
//            }
//        }
//    }

    func openStartWorkViewController() {
        self.performSegue(withIdentifier: "loginSegue", sender:self)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        enterRaisedButton.isEnabled = false
        enterRaisedButton.backgroundColor = Color.blueGrey.lighten3
        validateInput()
        
        return true
    }
    
    func validateInput() {
        if (passwordTextField.text?.isEmpty)! || (loginTextField.text?.isEmpty)! {
            enterRaisedButton.isEnabled = false
            enterRaisedButton.backgroundColor = Color.blueGrey.lighten3
        }
        else {
            enterRaisedButton.isEnabled = true
            enterRaisedButton.backgroundColor = Color.white
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == loginTextField {
            _ = self.passwordTextField.becomeFirstResponder()
        }
        else {
            self.enterButtonPressed(self.enterRaisedButton)
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        validateInput()
    }
    
    func dismissKeyboard() {
        loginTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    func updateStatus(status: String) {
        self.progressLabel.text = status
    }
    
    func allLessonsDidSync() {
        self.indicatorView.stopAnimating()
        self.openStartWorkViewController()
    }
}
