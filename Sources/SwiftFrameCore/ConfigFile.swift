//
//  File.swift
//  
//
//  Created by Henrik Panhans on 04.12.19.
//

import Foundation

public struct Debug {

    public init(test: String) {
        print(test)
    }

}

public struct ConfigFile: Codable {
    let deviceData: [String: DeviceData]
    let textFilesPath: URL
}

public struct DeviceData: Codable {
    
}
