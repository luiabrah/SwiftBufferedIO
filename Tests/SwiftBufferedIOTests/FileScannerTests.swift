//
//  FileScannerTests.swift
//
//
//  Created by Luis Abraham on 2023-06-17.
//

import XCTest
import Foundation
@testable import SwiftBufferedIO

final class FileScannerTests: XCTestCase {
    private let testFileURL = URL(string: "\(FileManager.default.temporaryDirectory)testfile.txt")!
    
    override func tearDown() {
        TestFileUtils.deleteFile(self.testFileURL)
    }
    
    func test_fileScanner_happyPath() throws {
        let numberOfLines = 10
        let fileContents = TestFileUtils.createFileWithMultipleLines(numberOfLines: numberOfLines,
                                                                     fileURL: self.testFileURL)
        
        let fileHandle = try FileHandle(forReadingFrom: self.testFileURL)
        
        let scanner = FileScanner(fileHandle: fileHandle)
        
        var storedFileContents = [String]()
        for (i, line) in scanner.enumerated() {
            XCTAssertEqual(fileContents[i], line)
            storedFileContents.append(line)
        }
        
        XCTAssertEqual(storedFileContents.count, numberOfLines)
        
        // Ensure more scans don't contain any more data
        storedFileContents.removeAll()
        for line in scanner {
            storedFileContents.append(line)
        }
        
        XCTAssertTrue(storedFileContents.isEmpty)
    }
    
    func test_fileScanner_emptyFileHandledGracefully() throws {
        
        FileManager.default.createFile(atPath: self.testFileURL.path, contents: nil)
        let fileHandle = try FileHandle(forReadingFrom: self.testFileURL)
        
        let scanner = FileScanner(fileHandle: fileHandle)
        
        var storedFileContents = [String]()
        for line in scanner {
            storedFileContents.append(line)
        }
        
        XCTAssertTrue(storedFileContents.isEmpty)
        try fileHandle.close()
    }
    
    func test_fileScanner_reset() throws {
        let numberOfLines = 10
        let fileContents = TestFileUtils.createFileWithMultipleLines(numberOfLines: numberOfLines,
                                                                     fileURL: self.testFileURL)
        
        let fileHandle = try FileHandle(forReadingFrom: self.testFileURL)
        
        let scanner = FileScanner(fileHandle: fileHandle)
        
        var storedFileContents = [String]()
        for (i, line) in scanner.enumerated() {
            XCTAssertEqual(fileContents[i], line)
            storedFileContents.append(line)
        }
        
        XCTAssertEqual(storedFileContents.count, numberOfLines)
        
        // Ensure more scans don't contain any more data
        storedFileContents.removeAll()
        for line in scanner {
            storedFileContents.append(line)
        }
        
        XCTAssertTrue(storedFileContents.isEmpty)
        
        scanner.reset()
        
        for (i, line) in scanner.enumerated() {
            XCTAssertEqual(fileContents[i], line)
            storedFileContents.append(line)
        }
        
        XCTAssertEqual(storedFileContents.count, numberOfLines)
    }
    
    func test_fileScanner_customDelimiter_success() throws {
        let numberOfLines = 10
        let delimiter: Character = ","
        let fileContents = TestFileUtils.createFileWithMultipleLines(numberOfLines: numberOfLines,
                                                                     fileURL: self.testFileURL,
                                                                     delimiter: String(delimiter))
        
        let fileHandle = try FileHandle(forReadingFrom: self.testFileURL)
        
        let scanner = FileScanner(fileHandle: fileHandle, delimiter: delimiter)
        
        var storedFileContents = [String]()
        for (i, line) in scanner.enumerated() {
            XCTAssertEqual(fileContents[i], line)
            storedFileContents.append(line)
        }
        
        XCTAssertEqual(storedFileContents.count, numberOfLines)
    }
    
}
