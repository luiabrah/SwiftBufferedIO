//
//  BufferedReader.swift
//
//
//  Created by Luis Abraham on 2023-06-17.
//

import Foundation

/// `BufferedReader` provides buffering functionality for reading files on top of `FileHandle`.
public class BufferedReader {
    private let fileHandle: FileHandle
    private var buffer: Data
    private let bufferSize: Int
    
    public init(fileHandle: FileHandle, bufferSize: Int = 4096) {
        self.fileHandle = fileHandle
        self.bufferSize = bufferSize
        self.buffer = Data(capacity: bufferSize)
    }
    
    deinit {
        // Attempt to close the `FileHandle` when deallocated, ignore failures which likely mean it has already closed
        try? self.fileHandle.close()
        self.buffer.removeAll()
    }
    
    /// Reads data synchronously from the file up to the specified number of bytes, `length`.
    /// Returns `nil` if there is no data in the file.
    /// File data is buffered into an internal buffer and returned when `length` bytes have been read from the file.
    public func readData(ofLength length: Int) -> Data? {
        guard length > 0 else {
            return nil
        }
        
        // Allocate buffer for reading data from file
        var bufferedData = Data(capacity: min(bufferSize, length))
        var remainingLength = length

        // While there is still data to be read
        while remainingLength > 0 {
            // Ensure we don't read more than the remaining length
            let bytesToRead = min(bufferSize, remainingLength)
            
            // After the read operation, the file handle's position is automatically moved forward by the number of bytes read.
            // This allows us to not have to manage our own pointer
            guard let dataRead = try? fileHandle.read(upToCount: bytesToRead) else {
                break
            }
            
            bufferedData.append(dataRead)
            // Update how many bytes we have to read by how many were read
            remainingLength -= dataRead.count
        }
        
        return bufferedData.isEmpty ? nil : bufferedData
    }
    
    /// Reads a line of `Data` up to and including the specified delimiter from the file handle, utilizing buffering for improved performance.
    /// `ReadLine` is a low-level line-reading primitive. Most users should use `FileScanner` to scan a file line by line.
    ///
    /// The delimiter should be a valid ASCII character.
    /// The `readLine()` method utilizes buffering to improve performance by minimizing the number of actual read operations from the file handle.
    /// It reads data in chunks into an internal buffer and extracts a line of data from the buffer. If the line is not fully available in the buffer, it will read additional data from the file handle to complete the line.
    public func readLine(upToDelimiter delimiter: Character) -> Data? {
        while true {
            guard let delimiterASCIIValueData = delimiter.asciiValueData else {
                return nil
            }
            
            // Search in the entire buffer
            let bufferSearchRange = buffer.startIndex..<buffer.endIndex
            if let delimiterRange = buffer.range(of: delimiterASCIIValueData, options: [], in: bufferSearchRange) {
                // Found the delimiter in the buffer, fetch data from buffer up to the delimiter
                let delimiterData = buffer.prefix(delimiterRange.lowerBound)
                
                // Remove data from buffer including delimiter
                let upToDelimiterRange = buffer.startIndex..<delimiterRange.upperBound
                buffer.removeSubrange(upToDelimiterRange)
                return delimiterData
            }
            
            // Delimiter not found in the buffer, read from file and add to the buffer
            if let dataRead = readData(ofLength: bufferSize), !dataRead.isEmpty {
                buffer.append(dataRead)
            } else {
                // No more data to be read, file is empty
                // Return any data remaining in the buffer
                if !buffer.isEmpty {
                    let data = buffer
                    buffer.removeAll()
                    return data
                }
                
                return nil
            }
        }
    }
    
    /// Reads a line of a UTF-8 encoded`String` up to and including the specified delimiter from the file handle, utilizing buffering for improved performance.
    /// Returns `nil` if the `String` cannot be UTF-8 encoded
    ///
    ///`ReadString` is a low-level line-reading primitive. For simpler usecases, `FileScanner` may be more convenient.
    public func readString(upToDelimiter delimiter: Character) -> String? {
        guard let lineData = readLine(upToDelimiter: delimiter) else {
            return nil
        }
        
        return String(data: lineData, encoding: .utf8)
    }
    
    /// Discards any buffered data and resets `FileHandle` pointer to top of the file.
    /// `Reset` reinitializes the internal buffer to its default size.
    public func reset() {
        fileHandle.seek(toFileOffset: 0)
        buffer = Data(capacity: bufferSize)
    }
}
