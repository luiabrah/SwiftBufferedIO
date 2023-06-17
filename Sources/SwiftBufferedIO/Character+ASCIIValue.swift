//
//  File.swift
//  
//
//  Created by Luis Abraham on 2023-06-17.
//

import Foundation

internal extension Character {
    var asciiValueData: Data? {
        guard let asciiValue = self.asciiValue else {
            return nil
        }
        
        return Data([asciiValue])
    }
}
