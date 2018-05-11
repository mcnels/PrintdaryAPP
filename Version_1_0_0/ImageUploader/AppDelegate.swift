//
//  AppDelegate.swift
//  ImageUploader
//
//  Created by Armen Nikodhosyan on 15.03.2018.
//  Copyright © 2018 Armen Nikodhosyan. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var imageSuccessfulyDetected:(()-> Void)?
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
         FirebaseApp.configure()
        if Auth.auth().currentUser != nil {
            getUserInfo(userID: (Auth.auth().currentUser?.uid)!)
            let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
            let vc = storyboard.instantiateViewController(withIdentifier: "userB")
            self.window?.rootViewController = vc
           // try! Auth.auth().signOut()
        }
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    
    
    func getUserInfo(userID: String){
         Database.database().reference().child("User").child(userID).observe(.value) { (snapshot) in
            if let infoDict = snapshot.value as? [String : AnyObject]{
                UserModel.currentUser.name  = infoDict["Name"] as! String
                UserModel.currentUser.city  = infoDict["city"] as! String
                UserModel.currentUser.country  = infoDict["country"] as! String
                UserModel.currentUser.dateOfBirth  = infoDict["dateOfBirth"] as! String
                UserModel.currentUser.favoriteSubject  = infoDict["favoriteSubject"] as! String
                UserModel.currentUser.email  = infoDict["userEmailAddress"] as! String
                UserModel.currentUser.userID = infoDict["userID"] as! String
                do{
                    if let imageURL = URL.init(string: infoDict["imageURL"] as! String) {
                       let imageData = try Data.init(contentsOf: imageURL)
                        UserModel.currentUser.image = UIImage.init(data: imageData)
                    }
                    
                }catch _ {
                    
                }
                
            }
        }
    }

}

