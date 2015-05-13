//
//  ProfileViewController.swift
//  ExchangeAGram
//
//  Created by Sónia Rosa on 29/04/15.
//  Copyright (c) 2015 Sónia Rosa. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, FBLoginViewDelegate {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var fbLoginView: FBLoginView!
    
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backgrounImage = UIImage(named: "OceanBackGround")
        self.view.backgroundColor = UIColor(patternImage: backgrounImage!)
        
        self.fbLoginView.delegate = self
        self.fbLoginView.readPermissions = ["public_profile", "publish_actions"]
    }
    
     // MARK: - IBAction
    
    @IBAction func mapViewButtonPressed(sender: UIButton) {
        
      performSegueWithIdentifier("mapSegue", sender: nil)
    }
    
    // MARK: - FBLoginViewDelegate
    
    func loginViewShowingLoggedInUser(loginView: FBLoginView!) {
        
        profileImageView.hidden = false
        nameLabel.hidden = false
    }
    
    func loginViewFetchedUserInfo(loginView: FBLoginView!, user: FBGraphUser!) {
        
        println(user)
        
        nameLabel.text = user.name
        
        let userImageURL = "http://graph.facebook.com/\(user.objectID)/picture?type=small"
        let url = NSURL(string: userImageURL)
        let imageData = NSData(contentsOfURL: url!)
        let image = UIImage(data: imageData!)
        profileImageView.image = image
        
    }
    
    func loginViewShowingLoggedOutUser(loginView: FBLoginView!) {
        
        profileImageView.hidden = true
        nameLabel.hidden = true
    }
    
    func loginView(loginView: FBLoginView!, handleError error: NSError!) {
        
        println("Error: \(error.localizedDescription)")
        
    }
    
    
    


}
