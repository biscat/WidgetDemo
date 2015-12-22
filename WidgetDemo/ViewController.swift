//
//  ViewController.swift
//  WidgetDemo
//
//  Created by William Wong on 08/12/2015.
//  Copyright © 2015 Fleetmatics. All rights reserved.
//

import UIKit
import WTimerKit

let defaultTimeInterval : NSTimeInterval = 50
let taskDidFinishedInWidgetNotification: String = "com.williamwong.taskDidFinishedInWidgetNotification"

class ViewController: UIViewController {

    @IBOutlet weak var timerLabel: UILabel!
    var timer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationWillResignActive", name: UIApplicationWillResignActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "taskFinishedInWidget", name: taskDidFinishedInWidgetNotification, object: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func updateTimerLabel() {
        timerLabel.text = timer.leftTimeString
    }
    
    private func showAlertView(finished: Bool) {
        let alert = UIAlertController(title: "Alert", message: finished ? "Finished" : "Stopped", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {[weak alert] action in alert!.dismissViewControllerAnimated(true, completion: nil)}))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    dynamic private func applicationWillResignActive() {
        if timer == nil {
            clearDefaults()
        } else {
            if timer.running {
                saveDefaults()
            } else {
                clearDefaults()
            }
        }
    }
    
    dynamic private func taskFinishedInWidget() {
        if let realTimer = timer {
            let (stopped, error) = realTimer.stop()
            if !stopped {
                if let realError = error {
                    print("error: \(realError.code)")
                }
            }
        }
    }

    @IBAction func startButtonAction(sender: AnyObject) {
        if timer == nil {
            timer = Timer(timeInterval: defaultTimeInterval)
        }
        
        let (started,error) = timer.start(updateTick: {
                [weak self]
                leftTick in self!.updateTimerLabel()
            }, stopHandler: {
                [weak self]
                finished in
                self!.showAlertView(finished)
                self!.timer = nil
            })
        
        if started {
            updateTimerLabel()
        } else {
            if let realError = error {
                print("error: \(realError.code)")
            }
        }
    }
    
    @IBAction func stopButtonAction(sender: AnyObject) {
        if let realTimer = timer {
            let (stopped, error) = realTimer.stop()
            
            if !stopped {
                if let realError = error {
                    print("error: \(realError.code)")
                }
            }
        }
    }
    
    
    //helper method to create and clear defaults
    private func saveDefaults() {
        let userDefaults = NSUserDefaults(suiteName: "group.com.fleetmatics.manager")
        userDefaults?.setInteger(Int(timer.leftTime), forKey: "com.fleetmatics.timer.lefttime")
        userDefaults?.setInteger(Int(NSDate().timeIntervalSince1970), forKey: "com.fleetmatics.timer.quitdate")
        
        userDefaults?.synchronize()
    }
    
    private func clearDefaults() {
        let userDefaults = NSUserDefaults(suiteName: "group.com.fleetmatics.manager")
        userDefaults?.removeObjectForKey("com.fleetmatics.timer.lefttime")
        userDefaults?.removeObjectForKey("com.fleetmatics.timer.quitdate")
        
        userDefaults?.synchronize()
    }
}

