//
//  StartViewController.swift
//  arm
//
//  Created by Ekaterina Lapkovskaya on 18.08.17.
//  Copyright © 2017 Ekaterina Lapkovskaya. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftMessageBar
import Material
import SwiftyButton
import Crashlytics

class StartViewController: ViewController {

    @IBOutlet weak var appVersionLabel: UILabel!
    @IBOutlet weak var startWorkRaisedButton: SwiftyButton.FlatButton!
    @IBOutlet weak var syncRaisedButton: SwiftyButton.FlatButton!
    @IBOutlet weak var lastSyncDateLabel: UILabel!
    @IBOutlet weak var exitRaisedButton: SwiftyButton.FlatButton!
    @IBOutlet weak var progressLabel: ProgressLabel!
    
    var isExit = false
    
    var syncSession: SyncSession?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appVersionLabel.text = "v \(Utils.appVersion)"
        
        self.view.backgroundColor = ColorsHelper.blue().lighter(by: 10)
        
        self.startWorkRaisedButton.color = ColorsHelper.blue()
        self.startWorkRaisedButton.highlightedColor = ColorsHelper.blue().darker(by: 10)!
        self.startWorkRaisedButton.setTitleColor(.white, for: .normal)
        
        self.syncRaisedButton.color = ColorsHelper.blue()
        self.syncRaisedButton.highlightedColor = ColorsHelper.blue().darker(by: 10)!
        self.syncRaisedButton.setTitleColor(.white, for: .normal)
        
        self.exitRaisedButton.color = Color.red.accent1
        self.exitRaisedButton.highlightedColor = Color.red.accent1.darker(by: 10)!
        self.exitRaisedButton.setTitleColor(.white, for: .normal)
        
        self.updateButtons(enabled: true)
        let defaults = UserDefaults.standard
        if let lastSyncDate = defaults.object(forKey: "lastSyncDate") {
            self.lastSyncDateLabel.text = Utils.lastSyncDateString(from: lastSyncDate as! Date)
        }
        else {
            self.lastSyncDateLabel.text = "Синхронизации еще не было"
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func startSync() {
        BaseContext.reset()
        
        self.progressLabel.isHidden = false
        self.updateButtons(enabled: false)
        self.progressLabel.updateWithText(text: "Выполняю вход")
        let defaults = UserDefaults.standard
        if let login = defaults.string(forKey: "login"), let password = defaults.string(forKey: "password") {
            
            self.syncSession = SyncSession(login: login, password: password)
            self.syncSession?.run(completion: {[weak self] (result) in
                
                if(result){
                    self?.lastSyncDateLabel.text = Utils.lastSyncDateString(from: Date())
                    let defaults = UserDefaults.standard
                    defaults.set(Date(), forKey: "lastSyncDate")
                    BaseContext.reset()
                    self?.allLessonsDidSync()
                    
                    self?.progressLabel.isHidden = true
                    self?.updateButtons(enabled: true)
                }
                else{
                    SwiftMessageBar.showMessageWithTitle("Ошибка", message: "Произошла ошибка", type: .error)
                    self?.progressLabel.isHidden = true
                    self?.updateButtons(enabled: true)
                }
            })
            
//            APIClient.sharedClient.login(userName: login, password: password) {
//                statusCode in
//                let success:Bool = statusCode == StatusCodes.ok.rawValue
//                if !success {
//                    _ = StatusCodeManager.getStatusCodeDescription(statusCode: statusCode!)
//                   // SwiftMessageBar.showMessageWithTitle("Ошибка", message: message, type: .error)
//                    /*self.enterRaisedButton.isEnabled = true
//                    self.enterRaisedButton.backgroundColor = Color.white
//                    self.isValid = false*/
//                    self.progressLabel.isHidden = true
//                    self.updateButtons(enabled: true)
//                }
//                else {
////                    self.getBaseContext()
//
//
//
//                }
//            }
        }
    }
    
    func getBaseContext() {
        self.progressLabel.updateWithText(text: "Получаю базовый контекст пользователя")
//        APIClient.sharedClient.delegate = self
//        APIClient.sharedClient.getBaseContext() {
//            statusCode in
//            let success:Bool = statusCode == StatusCodes.ok.rawValue
//            if !success {
//                _ = StatusCodeManager.getStatusCodeDescription(statusCode: statusCode!)
//                //SwiftMessageBar.showMessageWithTitle("Ошибка", message: message, type: .error)
//                /*self.enterRaisedButton.isEnabled = true
//                self.enterRaisedButton.backgroundColor = Color.white*/
//                self.updateButtons(enabled: true)
//                self.progressLabel.isHidden = true
//            }
//            else {
//                //SwiftMessageBar.showMessageWithTitle("Успешно", message: " ", type: .success)
//                if self.isExit {
//                    let appDomain = Bundle.main.bundleIdentifier!
//                    UserDefaults.standard.removePersistentDomain(forName: appDomain)
//
//                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                    let loginViewController = storyboard.instantiateViewController(withIdentifier :"LoginViewController") as! LoginViewController
//                    let navigation = UINavigationController(rootViewController: loginViewController)
//                    self.present(navigation, animated: true, completion: nil)
//                }
//                let defaults = UserDefaults.standard
//                defaults.set(Date(), forKey: "lastSyncDate")
//                let dateFormatter = DateFormatter()
//                dateFormatter.dateFormat = "yyyy-MM-dd' 'HH:mm:ss"
//                self.lastSyncDateLabel.text = dateFormatter.string(from: Date())
//                self.updateButtons(enabled: true)
//                self.progressLabel.isHidden = true
//            }
//        }
    }
    
    func updateButtons(enabled: Bool) {
//        syncRaisedButton.pulseColor = ColorsHelper.buttonPulseColor()
//        syncRaisedButton.backgroundColor = enabled ? Color.white : Color.blueGrey.lighten3
//        startWorkRaisedButton.pulseColor = ColorsHelper.buttonPulseColor()
//        startWorkRaisedButton.backgroundColor = enabled ? Color.white : Color.blueGrey.lighten3
//        exitRaisedButton.pulseColor = ColorsHelper.buttonPulseColor()
//        exitRaisedButton.backgroundColor = enabled ? Color.red.accent1 : Color.blueGrey.lighten3
        syncRaisedButton.isEnabled = enabled
        startWorkRaisedButton.isEnabled = enabled
        exitRaisedButton.isEnabled = enabled
    }
    
    @IBAction func startWorkButtonPressed(_ sender: SwiftyButton.FlatButton) {
    }
    
    @IBAction func syncButtonPressed(_ sender: SwiftyButton.FlatButton) {
        if Connection.isConnectedToInternet() {
            self.startSync()
        }
        else {
            SwiftMessageBar.showMessageWithTitle("Ошибка", message: "Проверьте соединение с Интернетом", type: .error)
        }
    }

    @IBAction func exitButtonPressed(_ sender: SwiftyButton.FlatButton) {
        let alert = UIAlertController(title: "Внимание", message: "Несинхронизированные данные будут утеряны", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Синхронизировать", comment: ""), style: .default, handler: { _ in
           /* let appDomain = Bundle.main.bundleIdentifier!
            UserDefaults.standard.removePersistentDomain(forName: appDomain)
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginViewController = storyboard.instantiateViewController(withIdentifier :"LoginViewController") as! LoginViewController
            let navigation = UINavigationController(rootViewController: loginViewController)
            self.present(navigation, animated: true, completion: nil)*/
            if Connection.isConnectedToInternet() {
                self.isExit = true
                self.startSync()
            }
            else {
                SwiftMessageBar.showMessageWithTitle("Ошибка", message: "Проверьте соединение с Интернетом", type: .error)
            }
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Все равно выйти", comment: ""), style: .destructive, handler: { _ in
            let appDomain = Bundle.main.bundleIdentifier!
            UserDefaults.standard.removePersistentDomain(forName: appDomain)
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginViewController = storyboard.instantiateViewController(withIdentifier :"LoginViewController") as! LoginViewController
            let navigation = UINavigationController(rootViewController: loginViewController)
            self.present(navigation, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Отмена", comment: ""), style: .cancel, handler: { _ in
            alert.dismiss(animated: true, completion: nil)
        }))
        if let popoverPresentationController = alert.popoverPresentationController {
            popoverPresentationController.sourceView = self.view
            popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirection.init(rawValue: 0)
            popoverPresentationController.sourceRect = CGRect(x: self.view.bounds.size.width / 2.0, y: self.view.bounds.size.height / 2.0, width: 1.0, height: 1.0)
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    func updateStatus(status: String) {
        self.progressLabel.text = status
    }
    
    func allLessonsDidSync() {
        
    }
}
