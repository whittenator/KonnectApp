//
//  SwiftProfileVC.swift
//  Konnect
//
//  Created by Travis Whitten on 7/20/18.
//  Copyright © 2018 Balraj Randhawa. All rights reserved.
//

import Foundation
import AWSS3
import AWSLambda
import AVFoundation
import AVKit



class SwiftProfileVC: UIViewController {
    
    
    @IBOutlet weak var recentsTableView: UITableView!
    @IBOutlet weak var userProfileImg: UIImageView!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var userBioLbl: UILabel!
    @IBOutlet weak var followersLbl: UILabel!
    @IBOutlet weak var followingLbl: UILabel!
    @IBOutlet weak var konnectsLbl: UILabel!
    
    var dictSelfProfile = [String: AnyObject?]()
    
    @IBAction func messageBtnClicked(_ sender: Any) {
    }
    
    
   
    @IBAction func addBtnClicked(_ sender: Any) {
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func getProfileImage() {
        if(dictSelfProfile["UserImage"] as? String != "NA") {
            if(dictSelfProfile["fblogin"] as? String == "YES") {
                if(dictSelfProfile["FBProfilePicChanged"] as? String == "YES") {
                    if(UserDefaults.standard.string(forKey: "localUserImage") != nil) {
                        let imgUserLocalString = UserDefaults.standard.object(forKey: "localUserData")
                        let imageProfile = UIImage(data: imgUserLocalString as! Data)
                        userProfileImg = UIImageView(image: imageProfile)
                        
                    } else {
                        print("TRAVIS:IMAGE DIDN'T LOAD PROPERLY");
                        
                    }
                }
            }
            
        }
    }
    
    
    
}


