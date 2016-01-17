//
//  AppFunctions.swift
//  LOL-helper
//
//  Created by Bill Yu on 1/12/16.
//  Copyright © 2016 Bill Yu. All rights reserved.
//

import Foundation
import Alamofire

func parseJSON(data: NSData) -> [String: AnyObject]? {
    do {
        return try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String: AnyObject]
    }
    catch {
        print("JSON Error: \(error)")
        return nil
    }
}

func delay(seconds seconds: Double, completion:()->()) {
    let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64( Double(NSEC_PER_SEC) * seconds ))
    
    dispatch_after(popTime, dispatch_get_main_queue()) {
        completion()
    }
}
