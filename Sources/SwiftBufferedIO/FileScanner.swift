//
//  FileScanner.swift
//  
//
//  Created by Luis Abraham on 2023-06-17.
//

import Foundation

/// `FileScanner` provides a convenient interface for reading a file containing lines of text.
/// By default, `FileScanner` reads a line up to the new line delimiter (`\n`) but this can be changed using the `setDelimiter(_:)` method.
///
/// This class wraps a`BufferedReader`, providing improved memory performance when reading large files
/// compared to `FileHandle` which forces uses to read the entire file contents into memory.
///
/// `FileScanner` conforms to the `Sequence` protocol allowing files to be scanned through the use of a `for-in` loop.
/// ```
/// let fileHandle = ...
/// let fileScanner = FileScanner(fileHandle: fileHandle)
///
/// for line in fileScanner {
///    // Do something with `line`
///    process(line)
///}
/// ```
public class FileScanner: IteratorProtocol, Sequence {
    private let bufferedReader: BufferedReader
    private var delimiter: Character
    
    public init(fileHandle: FileHandle, delimiter: Character = "\n") {
        self.bufferedReader = BufferedReader(fileHandle: fileHandle)
        self.delimiter = delimiter
    }
    
    /// Returns the next line in the file up to the delimiter.
    public func next() -> String? {
        return bufferedReader.readString(upToDelimiter: delimiter)
    }
    
    /// Updates the delimiter the `FileScanner` will scan up to for each line.
    /// The delimiter must be a valid ASCII character otherwise scanning lines of text will return `nil`.
    public func setDelimiter(_ delimiter: Character) {
        self.delimiter = delimiter
    }
    
    /// Resets internal state. This method clears the internal buffer and resets the `FileHandle` position to the top of the file.
    /// Use this when you want to scan through the same file again from the top.
    public func reset() {
        bufferedReader.reset()
    }
}
