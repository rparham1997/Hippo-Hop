//
//  GameViewController.swift
//  Hippo Hop
//
//  Created by Ramar Parham on 12/24/19.
//  Copyright © 2019 Ramar Parham. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import GoogleMobileAds

class GameViewController: UIViewController, GADBannerViewDelegate {
    
     var bannerView: GADBannerView!

    override func viewDidLoad() {
        super.viewDidLoad()
        let scene = MainMenu(size: CGSize(width: 2048, height: 1536))
        scene.scaleMode = .aspectFill
        
        let skView = view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.showsPhysics = true
        skView.ignoresSiblingOrder = false
        skView.presentScene(scene)
        
        bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerLandscape)
        addBannerViewToView(bannerView)
        bannerView.adUnitID = "ca-app-pub-7582800558080529/9498568923"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
    
        
        /*bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerLandscape)
        self.view.addSubview(bannerView)
        bannerView.adUnitID = "ca-app-pub-7582800558080529/9498568923"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
        bannerView.center = CGPoint(x: 445, y: 350)
 */
   
    }
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
     bannerView.translatesAutoresizingMaskIntoConstraints = false
     view.addSubview(bannerView)
     view.addConstraints(
       [NSLayoutConstraint(item: bannerView,
                           attribute: .bottom,
                           relatedBy: .equal,
                           toItem: bottomLayoutGuide,
                           attribute: .top,
                           multiplier: 1,
                           constant: 0),
        NSLayoutConstraint(item: bannerView,
                           attribute: .centerX,
                           relatedBy: .equal,
                           toItem: view,
                           attribute: .centerX,
                           multiplier: 1,
                           constant: 0)
       ])
    }

 
  

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
