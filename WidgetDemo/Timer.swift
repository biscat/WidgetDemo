//
//  Timer.swift
//  WidgetDemo
//
//  Created by William Wong on 22/12/2015.
//  Copyright © 2015 Fleetmatics. All rights reserved.
//

import UIKit

let timerErrorDomain = "SimpleTimerError"

public enum SimplerTimerError: Int {
    case AlreadyRunning = 1001
    case NegativeLeftTime = 1002
    case NotRunning = 1003
}

extension NSTimeInterval {
    func toString() -> String {
        let totalSecond = Int(self)
        let minute = totalSecond / 60
        let second = totalSecond % 60
        
        switch (minute, second) {
        case (0...9, 0...9):
            return "0\(minute):0\(second)"
        case (0...9, _):
            return "0\(minute):\(second)"
        case (_, 0...9):
            return "\(minute):0\(second)"
        default:
            return "\(minute):\(second)"
        }
    }
}

public class Timer: NSObject {
    public var running: Bool = false
    
    public var leftTime: NSTimeInterval {
        didSet {
            if leftTime < 0 {
                leftTime = 0
            }
        }
    }
    
    public var leftTimeString : String {
        get {
            return leftTime.toString()
        }
    }
    
    private var timerTickHandler: (NSTimeInterval -> ())? = nil
    private var timerStopHandler: (Bool->())? = nil
    private var timer: NSTimer!
    
    public init(timeInterval : NSTimeInterval) {
        leftTime = timeInterval
    }
    
    public func start(updateTick updateTick: (NSTimeInterval -> Void)?, stopHandler: (Bool->Void)?) -> (start: Bool, error: NSError?) {
        if running {
            return (false, NSError(domain: timerErrorDomain, code: SimplerTimerError.AlreadyRunning.rawValue, userInfo: nil))
        }
        
        if leftTime < 0 {
            return (false, NSError(domain: timerErrorDomain, code: SimplerTimerError.NegativeLeftTime.rawValue, userInfo: nil))
        }
        
        timerTickHandler = updateTick
        timerStopHandler = stopHandler
        
        running = true
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "countTick", userInfo: nil, repeats: true)
        
        return (true, nil)
    }
    
    public func stop() -> (stopped: Bool, error: NSError?) {
        if !running {
            return(false, NSError(domain: timerErrorDomain, code: SimplerTimerError.NotRunning.rawValue, userInfo: nil))
        }
        
        running = false
        timer.invalidate()
        timer = nil
        
        if let stopHandler = timerStopHandler {
            stopHandler(leftTime <= 0)
        }
        
        timerTickHandler = nil
        timerStopHandler = nil
        
        return (true, nil)
    }
    
    dynamic private func countTick() {
        leftTime -= 1
        if let tickHandler = timerTickHandler {
            tickHandler(leftTime)
        }
        
        if leftTime <= 0 {
            stop()
        }
    }
}
