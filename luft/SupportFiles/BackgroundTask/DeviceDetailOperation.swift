//
//  AppDelegate.swift
//  DeviceDetailOperation
//
//  Created by Tamilarasu on 14/04/19.
//  Copyright © 2019 Tamilarasu. All rights reserved.
//

import Foundation


class DeviceDetailsOperation: AsynchronousOperation {
    let deviceId: String
    
    init(with deviceId: String) {
        self.deviceId = deviceId
    }
    
    override func main() {
        super.main()
        print("main -- is main thread: \(Thread.isMainThread)")
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: .main)
        let url = URL(string: "google.com")!
        let task = session.dataTask(with: url, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            // Parse the data in the response and use it
            
            // Save the fetched details herer
            print("is main thread: \(Thread.isMainThread)")
            print("Device detail fetched for : \(self.deviceId)")
            //Make this state finished only when device id is fetched
            self.state = .finished
        })
        task.resume()
    }
    
}
