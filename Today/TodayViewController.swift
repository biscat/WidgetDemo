//
//  TodayViewController.swift
//  Today
//
//  Created by William Wong on 22/12/2015.
//  Copyright © 2015 Fleetmatics. All rights reserved.
//

import UIKit
import NotificationCenter
import WTimerKit

class TodayViewController: UIViewController, NCWidgetProviding {
        
    @IBOutlet weak var timeLabel: UILabel!
    
    var timer : Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        let userDefaults = NSUserDefaults(suiteName: "group.com.fleetmatics.manager")
        let leftTimeWhenQuit = userDefaults?.integerForKey("com.fleetmatics.timer.lefttime")
        let quitDate = userDefaults?.integerForKey("com.fleetmatics.timer.quitdate")
        
        
        let passedTimeFromQuit = NSDate().timeIntervalSinceDate(NSDate(timeIntervalSince1970: NSTimeInterval(quitDate!)))
        let leftTime = leftTimeWhenQuit! - Int(passedTimeFromQuit)
        timeLabel.text = "\(leftTime)"
        
        if (leftTime > 0) {
            timer = Timer(timeInterval: NSTimeInterval(leftTime))
            timer.start(updateTick:  {
                    [weak self]
                    leftTick in self!.updateLabel()
                }, stopHandler: {
                    [weak self] finished in self!.showOpenAppButton()
            })
        } else {
            print("it's below 0")
            showOpenAppButton()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData

        completionHandler(NCUpdateResult.NewData)
    }
    
    func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsetsZero
    }
    
    //helper method
    private func updateLabel() {
        timeLabel.text = timer.leftTimeString
    }
    
    private func showOpenAppButton() {
        timeLabel.text = "Finished"
        preferredContentSize = CGSizeMake(0, 100)
        
        let button = UIButton(frame: CGRectMake(0, 50, 50, 63))
        button.setTitle("Open", forState: UIControlState.Normal)
        button.addTarget(self, action: "buttonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        
        view.addSubview(button)
    }
    
    @objc private func buttonPressed(sender: AnyObject!) {
        extensionContext!.openURL(NSURL(string: "simpleTimer://finished")!, completionHandler: nil)
    }
}
