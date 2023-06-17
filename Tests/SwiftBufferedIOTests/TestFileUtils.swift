//
//  TestFileUtils.swift
//  
//
//  Created by Luis Abraham on 2023-06-17.
//

import Foundation

struct TestFileUtils {
    
    static func createFileWithMultipleLines(numberOfLines: Int, fileURL: URL, delimiter: String = "\n") -> [String] {
        
        let fileContentsArray = (1...numberOfLines).map {
            "Line number: \($0)"
        }

        let fileContents = fileContentsArray.joined(separator: delimiter)
        
        FileManager.default.createFile(atPath: fileURL.path,
                                       contents: fileContents.data(using: .utf8))
        
        return fileContentsArray
    }
    
    
    
    static func deleteFile(_ fileURL: URL) {
        do {
            try FileManager.default.removeItem(at: fileURL)
        } catch {
            print("Error deleting \(fileURL) due to \(error)")
        }
    }
}
