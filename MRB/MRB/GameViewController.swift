//
//  GameViewController.swift
//  MRB
//
//  Created by Ethan Look on 12/13/14.
//  Copyright (c) 2014 Ethan Look. All rights reserved.
//

import UIKit
import SpriteKit
import iAd

class GameViewController: UIViewController, ADBannerViewDelegate, ADInterstitialAdDelegate {
    
    var bannerView: ADBannerView!
    var interstitialAd:ADInterstitialAd!
    var interstitialAdView: UIView = UIView()
    var requestingAd:Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scene = MenuScene(size: view.bounds.size)
        let skView = view as! SKView
        skView.showsFPS = false
        skView.showsNodeCount = false
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .ResizeFill
        skView.presentScene(scene)
        
        loadAds()
        
        requestingAd = false
        loadInterstitialAd()
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "removeAd:", name: "hideAd", object: nil)
        notificationCenter.addObserver(self, selector: "addAd:", name: "showAd", object: nil)
        notificationCenter.addObserver(self, selector: "addInterstitialAd:", name: "addInterstitialAd", object: nil)
    }
    
    //iAd
    
    //ADBannerAd
    func loadAds() {
        bannerView = ADBannerView(frame: CGRectZero)
        bannerView.delegate = self
        bannerView.hidden = true
        view.addSubview(bannerView)
    }
    
    func removeAd(sender: AnyObject) {
        bannerView.removeFromSuperview()
    }
    
    func addAd(sender: AnyObject) {
        view.addSubview(bannerView)
    }
    
    func bannerViewWillLoadAd(banner: ADBannerView!) {
        
        
        //println("Ad about to load")
        
    }
    
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        
        bannerView.center = CGPoint(x: bannerView.center.x, y: view.bounds.size.height - bannerView.frame.size.height / 2)
        
        bannerView.hidden = false
        //println("Displaying the Ad")
        
    }
    
    func bannerViewActionDidFinish(banner: ADBannerView!) {
        print("Close the Ad")
    }
    
    func bannerViewActionShouldBegin(banner: ADBannerView!, willLeaveApplication willLeave: Bool) -> Bool {
        print("Leave the application to the Ad")
        return true
    }
    
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        
        bannerView.center = CGPoint(x: bannerView.center.x, y: view.bounds.size.height + view.bounds.size.height)
        
        print("Ad is not available")
        
    }
    
    //ADInterstitialAd
    func loadInterstitialAd() {
        if requestingAd == false {
            
            interstitialAd = ADInterstitialAd()
            interstitialAd!.delegate = self
            
            requestingAd = true
            
        }
    }
    
    func interstitialAdWillLoad(interstitialAd: ADInterstitialAd!) {
        print("About to load Interstitial AD")
    }
    
    func interstitialAdDidLoad(interstitialAd: ADInterstitialAd!) {
        if interstitialAd != nil && self.interstitialAd != nil && requestingAd == true {
            interstitialAdView = UIView()
            interstitialAdView.frame = self.view.bounds
            
            print("Displaying the Interstitial AD")
            interstitialAd.presentInView(interstitialAdView)
            requestingAd = false
        }
        UIViewController.prepareInterstitialAds()
    }
    
    func addInterstitialAd(sender: AnyObject){
        if interstitialAd != nil {
            view.addSubview(interstitialAdView)
        }
    }
    
    func interstitialAdActionDidFinish(interstitialAd: ADInterstitialAd!) {
        self.interstitialAd = nil
        requestingAd = false
        self.interstitialAdView.removeFromSuperview()
    }
    
    func interstitialAdDidUnload(interstitialAd: ADInterstitialAd!) {
        self.interstitialAd = nil
        requestingAd = false
        self.interstitialAdView.removeFromSuperview()
    }
    
    func interstitialAd(interstitialAd: ADInterstitialAd!, didFailWithError error: NSError!) {
        self.interstitialAd = nil
        requestingAd = false
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
