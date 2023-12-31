//
//  BufferedReaderTests.swift
//  
//
//  Created by Luis Abraham on 2023-06-17.
//

import XCTest
import Foundation
@testable import SwiftBufferedIO

final class BufferedReaderTests: XCTestCase {
    private let testFileURL = URL(string: "\(FileManager.default.temporaryDirectory)testfile.txt")!
    
    override func tearDown() {
        TestFileUtils.deleteFile(self.testFileURL)
    }
    
    func test_readData_readLengthSmallerThanFileContents_returnsExpectedFileContent() throws {
        let string1 = "12345678"
        let string2 = "87645321"
        // 16 byte string in file
        let fileContents = "\(string1)\(string2)"
        FileManager.default.createFile(atPath: self.testFileURL.path,
                                       contents: fileContents.data(using: .utf8))
        
        let fileHandle = try FileHandle(forReadingFrom: self.testFileURL)
        let bufferedReader = BufferedReader(fileHandle: fileHandle)
        
        guard let dataRead1 = bufferedReader.readData(ofLength: 8) else {
            XCTFail("Should be able to read data from file")
            return
        }
        
        XCTAssertEqual(8, dataRead1.count)
        XCTAssertEqual(string1, String(data: dataRead1, encoding: .utf8)!)
        
        // Read another 8 bytes
        guard let dataRead2 = bufferedReader.readData(ofLength: 8) else {
            XCTFail("Should be able to read data from file")
            return
        }
        
        XCTAssertEqual(8, dataRead2.count)
        XCTAssertEqual(string2, String(data: dataRead2, encoding: .utf8)!)
        
        // Reading data again should return nil
        XCTAssertNil(bufferedReader.readData(ofLength: 1))
    }
    
    func test_readData_readlengthGreaterThanFileContents_returnsExpectedFileContent() throws {
        // 16 byte string in file
        let fileContents = "1234567812345678"
        FileManager.default.createFile(atPath: self.testFileURL.path,
                                       contents: fileContents.data(using: .utf8))
        
        let fileHandle = try FileHandle(forReadingFrom: self.testFileURL)
        let bufferedReader = BufferedReader(fileHandle: fileHandle)
        
        guard let dataRead = bufferedReader.readData(ofLength: 20) else {
            XCTFail("Should be able to read data from file")
            return
        }
        
        XCTAssertEqual(16, dataRead.count)
        XCTAssertEqual(fileContents, String(data: dataRead, encoding: .utf8)!)
        
        // Reading data again should return nil
        XCTAssertNil(bufferedReader.readData(ofLength: 1))
    }
    
    func test_readData_reset_happyPath() throws {
        // 16 byte string in file
        let fileContents = "1234567812345678"
        FileManager.default.createFile(atPath: self.testFileURL.path,
                                       contents: fileContents.data(using: .utf8))
        
        let fileHandle = try FileHandle(forReadingFrom: self.testFileURL)
        let bufferedReader = BufferedReader(fileHandle: fileHandle)
        
        guard let dataRead1 = bufferedReader.readData(ofLength: 20) else {
            XCTFail("Should be able to read data from file")
            return
        }
        
        XCTAssertEqual(16, dataRead1.count)
        XCTAssertEqual(fileContents, String(data: dataRead1, encoding: .utf8)!)
        
        // Reading data again should return nil
        XCTAssertNil(bufferedReader.readData(ofLength: 1))
        
        // Reset state
        bufferedReader.reset()
        guard let dataRead2 = bufferedReader.readData(ofLength: 20) else {
            XCTFail("Should be able to read data from file")
            return
        }
        
        XCTAssertEqual(16, dataRead2.count)
        XCTAssertEqual(fileContents, String(data: dataRead2, encoding: .utf8)!)
        
        // Reading data again should return nil
        XCTAssertNil(bufferedReader.readData(ofLength: 1))
    }
    
    func test_readData_emptyFile_returnsNil() throws {
        FileManager.default.createFile(atPath: self.testFileURL.path,
                                       contents: nil)
        
        let fileHandle = try FileHandle(forReadingFrom: self.testFileURL)
        let bufferedReader = BufferedReader(fileHandle: fileHandle)
        
        XCTAssertNil(bufferedReader.readData(ofLength: 20))
    }
    
    func test_readData_invalidLength_returnsNil() throws {
        let fileContents = "1234567812345678"
        FileManager.default.createFile(atPath: self.testFileURL.path,
                                       contents: fileContents.data(using: .utf8))
        
        let fileHandle = try FileHandle(forReadingFrom: self.testFileURL)
        let bufferedReader = BufferedReader(fileHandle: fileHandle)
        
        XCTAssertNil(bufferedReader.readData(ofLength: -1))
    }
    
    func test_readString_happyPath() throws {
        let numberOfLines = 10
        let fileContents = TestFileUtils.createFileWithMultipleLines(numberOfLines: numberOfLines,
                                                                     fileURL: self.testFileURL)
        
        let fileHandle = try FileHandle(forReadingFrom: self.testFileURL)
        let bufferedReader = BufferedReader(fileHandle: fileHandle)
        
        for i in 0..<numberOfLines {
            let expectedString = fileContents[i]
            let readString = bufferedReader.readString(upToDelimiter: "\n")
            XCTAssertEqual(expectedString, readString)
        }
        
        // There should be no more data to read
        XCTAssertNil(bufferedReader.readString(upToDelimiter: "\n"))
    }
    
    func test_readString_delimiterNotInFile_returnsEntireFileContents() throws {
        let numberOfLines = 10
        let fileContents = TestFileUtils.createFileWithMultipleLines(numberOfLines: numberOfLines,
                                                                     fileURL: self.testFileURL)
        
        let fileHandle = try FileHandle(forReadingFrom: self.testFileURL)
        let bufferedReader = BufferedReader(fileHandle: fileHandle)
        
        guard let readString = bufferedReader.readString(upToDelimiter: ",") else {
            XCTFail("There should be data read")
            return
        }
        
        XCTAssertEqual(fileContents.joined(separator: "\n"), readString)
        
        // There should be no more data to read
        XCTAssertNil(bufferedReader.readString(upToDelimiter: "\n"))
    }
    
    func test_readString_reset_happyPath() throws {
        let numberOfLines = 10
        let fileContents = TestFileUtils.createFileWithMultipleLines(numberOfLines: numberOfLines,
                                                                     fileURL: self.testFileURL)
        
        let fileHandle = try FileHandle(forReadingFrom: self.testFileURL)
        let bufferedReader = BufferedReader(fileHandle: fileHandle)
        
        for i in 0..<numberOfLines {
            let expectedString = fileContents[i]
            let readString = bufferedReader.readString(upToDelimiter: "\n")
            XCTAssertEqual(expectedString, readString)
        }
        
        // There should be no more data to read
        XCTAssertNil(bufferedReader.readString(upToDelimiter: "\n"))
        
        bufferedReader.reset()
        
        for i in 0..<numberOfLines {
            let expectedString = fileContents[i]
            let readString = bufferedReader.readString(upToDelimiter: "\n")
            XCTAssertEqual(expectedString, readString)
        }
        
        // There should be no more data to read
        XCTAssertNil(bufferedReader.readString(upToDelimiter: "\n"))
    }
    
    func test_readDataAndReadLine_returnsExpectedFileContent() throws {
        let string1 = "12345678"
        let string2 = "87645321"
        let string3 = "13579321"
        
        let fileContents = "\(string1)\n\(string2)\n\(string3)\n"
        FileManager.default.createFile(atPath: self.testFileURL.path,
                                       contents: fileContents.data(using: .utf8))
        
        let fileHandle = try FileHandle(forReadingFrom: self.testFileURL)
        let bufferedReader = BufferedReader(fileHandle: fileHandle, bufferSize: 10)
        
        guard let dataRead1 = bufferedReader.readData(ofLength: 9) else {
            XCTFail("Should be able to read data from file")
            return
        }
        
        // In this case, we read the delimiter explicitly
        XCTAssertEqual(9, dataRead1.count)
        XCTAssertEqual("\(string1)\n", String(data: dataRead1, encoding: .utf8)!)
        
        guard let stringRead = bufferedReader.readString(upToDelimiter: "\n") else {
            XCTFail("Should be able to read data from file")
            return
        }
        
        // Delimiter not returned
        XCTAssertEqual(8, stringRead.count)
        XCTAssertEqual(string2, stringRead)
        
        // Read another 9 bytes
        guard let dataRead2 = bufferedReader.readData(ofLength: 9) else {
            XCTFail("Should be able to read data from file")
            return
        }
        
        XCTAssertEqual(9, dataRead2.count)
        XCTAssertEqual("\(string3)\n", String(data: dataRead2, encoding: .utf8)!)
   
        // Reading data again should return nil
        XCTAssertNil(bufferedReader.readData(ofLength: 1))
    }
    
    func test_readDataAndReadLine_reset_returnsExpectedFileContent() throws {
        let string1 = "12345678"
        let string2 = "87645321"
        let string3 = "13579321"
        
        let fileContents = "\(string1)\n\(string2)\n\(string3)\n"
        FileManager.default.createFile(atPath: self.testFileURL.path,
                                       contents: fileContents.data(using: .utf8))
        
        let fileHandle = try FileHandle(forReadingFrom: self.testFileURL)
        let bufferedReader = BufferedReader(fileHandle: fileHandle, bufferSize: 10)
        
        guard let dataRead1 = bufferedReader.readData(ofLength: 9) else {
            XCTFail("Should be able to read data from file")
            return
        }
        
        // In this case, we read the delimiter explicitly
        XCTAssertEqual(9, dataRead1.count)
        XCTAssertEqual("\(string1)\n", String(data: dataRead1, encoding: .utf8)!)
        
        // Reset
        bufferedReader.reset()
        
        guard let stringRead1 = bufferedReader.readString(upToDelimiter: "\n") else {
            XCTFail("Should be able to read data from file")
            return
        }
        
        // Delimiter not returned
        XCTAssertEqual(8, stringRead1.count)
        XCTAssertEqual(string1, stringRead1)
        
        guard let stringRead2 = bufferedReader.readString(upToDelimiter: "\n") else {
            XCTFail("Should be able to read data from file")
            return
        }
        
        // Delimiter not returned
        XCTAssertEqual(8, stringRead2.count)
        XCTAssertEqual(string2, stringRead2)
        
        guard let stringRead3 = bufferedReader.readString(upToDelimiter: "\n") else {
            XCTFail("Should be able to read data from file")
            return
        }
        
        // Delimiter not returned
        XCTAssertEqual(8, stringRead3.count)
        XCTAssertEqual(string3, stringRead3)
        
        // Reading data again should return nil
        XCTAssertNil(bufferedReader.readData(ofLength: 1))
    }
}
