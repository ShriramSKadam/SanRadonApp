//
//  DeviceDetailManager.swift
//  BackgroundExecution
//
//  Created by Tamilarasu on 01/11/19.
//  Copyright © 2019 Tamilarasu. All rights reserved.
//

import Foundation

class DeviceDetailManager {
    static let shared = DeviceDetailManager()
    
    private lazy var queue: CompletionOperationQueue = {
        let operationQueue = CompletionOperationQueue()
        operationQueue.qualityOfService = QualityOfService.background
        operationQueue.maxConcurrentOperationCount = 1
        return operationQueue
    }()
    
    var isFetching = false
    
    
    func fetch(_ deviceIds: [String]) {
        if isFetching {
            // already fetching the device detail
            return
        } else {
            isFetching = true
            addAsynOperations(deviceIds)
        }
    }
    
    private func addAsynOperations(_ deviceIds: [String]) {
        for deviceID in deviceIds {
            let asyncOperation = DeviceDetailsOperation(with: deviceID)
            queue.addOperation(asyncOperation)
        }
        queue.completionBlock = {
            print("is main thread: \(Thread.isMainThread)")
            print("All device details are fetched")
            self.isFetching = false
        }
        print("is main thread: \(Thread.isMainThread)")
        print("operations are added and started executing")
    }
}
