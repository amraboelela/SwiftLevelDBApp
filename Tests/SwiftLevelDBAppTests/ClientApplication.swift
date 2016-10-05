//
//  ClientApplication.swift
//
//  Created by Amr on 9/2/16.
//  Copyright © 2016 Amr Aboelela. All rights reserved.
//

import RengoFoundation
import Foundation
import CoreFoundation
import Dispatch

class ClientApplication {

    var deviceID: String
    var name: String
    var bio: String
    var latitude: Float
    var longitude: Float
    
    init(deviceID: String, name: String, bio: String, latitude: Float, longitude: Float) {
        self.deviceID = deviceID
        self.name = name
        self.bio = bio
        self.latitude = latitude
        self.longitude = longitude
    }
    
    func run() {
        
        MyNode.deviceID = deviceID
        let myNode = MyNode.myNode()
        myNode.setDictionaryValue(name, forKey: NodeName)
        myNode.setDictionaryValue(bio, forKey: NodeBio)
        myNode.setDictionaryValue(latitude, forKey: NodeLatitude)
        myNode.setDictionaryValue(longitude, forKey: NodeLongitude)
        print("myNode: \(myNode.description)")
        var server: TCPServer?
        
        #if os(Linux)
            let aTime: UnsafeMutablePointer<time_t>? = nil
            srand(UInt32(time(aTime)))
        #else
            arc4random_stir()
        #endif
        while true {
            #if os(Linux)
                let displacement = Int(rand() % 1313)
            #else
                let displacement = Int(arc4random_uniform(1313))
            #endif
            let port = 1313 + displacement
            do {
                server = try TCPServer(port: port)
            } catch {
                print("error: \(error)")
                continue
            }
            break
        }
        print("server: \(server!.description)")
        NodeProxiesController.sharedController().start()
        //print("ClientApplication.run CFRunLoopGetCurrent: \(CFRunLoopGetCurrent())")
        CFRunLoopRun()
    }
}
