## SwiftBufferedIO
SwiftBufferedIO is a Swift package that provides buffering functionality for reading/writing files and scanning lines of text. It addresses the limitations of `FileHandle` provided by Foundation:
 1. To process a file line by line, you must read all file contents into memory which is inefficient for large files.
 1. All writes to a `FileHandle` write directly to the file on disk which involves a system call. This is inefficient if there are many small writes.

## Installation
Add the package dependency in your `Package.swift`:
```swift
.package(
    url: "https://github.com/luiabrah/SwiftBufferedIO", 
    .upToNextMinor(from: "0.1.0")
),
```

Next, in your target, add SwiftBufferedIO to your dependencies:

```swift
.target(name: "MyTarget", dependencies: [
    .product(name: "SwiftBufferedIO", package: "SwiftBufferedIO"),
],
```

## Roadmap
| Class  | Status |
| ------------- | ------------- |
| BufferedReader  | ✅  |
| FileScanner  | ✅  |
| BufferedWriter | TODO |
| BufferedReadWriter | TODO | 


## Usage
 ### `FileScanner`
`FileScanner` is a Swift class that provides a convenient interface for reading files containing lines of text. It wraps a `BufferedReader` to improve memory performance when reading large files compared to reading the entire file contents into memory. Use this class if you wish to read data from a file line by line.

To use `FileScanner`, instantiate a `FileHandle` for the file you're interested in reading:
```swift
let fileURL: URL = ...

do {
    let fileHandle = try FileHandle(forReadingFrom: fileURL)
} catch {
    // Handle error
}
```
A `FileScanner` is created from the `FileHandle`:
```swift

let fileScanner = FileScanner(fileHandle: fileHandle)

```
You can optionally specify the delimiter character during initialization. By default, the delimiter is set to a new line character (\n).

`FileScanner` conforms to the `Sequence` protocol so it can be used in a `for-in` loop to iterate over the lines of the file:
```swift
for line in fileScanner {
    // Process each line
    process(line)
}
```

Being a `Sequences` gives us access to methods like `.map`, `.filter`, `.forEach`:
```swift
scanner.filter { line in
    line.hasPrefix("...")
}.map { line in
    process(line)
}

    // Close FileScanner when finished with it
fileScanner.close()
```

Call the `reset()` method if you wish to scan through the file again.

### `BufferedReader`
`BufferedReader` is a Swift class that provides buffering functionality for reading files using a `FileHandle`. It allows you to read data from a file in a more efficient manner by minimizing the number of actual read operations from the file.

`BufferedReader` provides low-level operations for reading data from a file. Most users should use `FileScanner` to scan a file line by line.

To use `BufferedReader`, instantiate a `FileHandle` for the file you're interested in reading:
```swift
let fileURL: URL = ...

do {
    let fileHandle = try FileHandle(forReadingFrom: fileURL)
} catch {
    // Handle error
}
```
A `BufferedReader` is created from the `FileHandle`:
```swift

let bufferedReader = BufferedReader(fileHandle: fileHandle)

```
You can optionally specify the buffer size during initialization. The default buffer size is 4096 bytes.

#### Supported methods
* `readData(ofLength:)`: Reads data from the file up to the specified number of bytes.
* `readLine(upToDelimiter:)`: Reads a line of data up to and including the specified delimiter character.
* `readString(upToDelimiter:)`: Reads a line of data as a UTF-8 encoded string up to and including the specified delimiter character.
* `reset()`: Discards any buffered data and resets the file handle pointer to the beginning of the file.
* `close()`: Closes the `BufferedReader` and releases any allocated resources.

#### Example
```swift
// Read 10 bytes of data
if let data = bufferedReader.readData(ofLength: 10) {
    let string = String(data: data, encoding: .utf8)
    print(string ?? "Data could not be decoded as UTF-8.")
}

// Read line from file
if let lineData = bufferedReader.readLine(upToDelimiter: "\n") {
    let lineString = String(data: lineData, encoding: .utf8)
    print(lineString ?? "Line could not be decoded as UTF-8.")
}

// Reset and read again from the beginning
bufferedReader.reset()

if let data = bufferedReader.readData(ofLength: 10) {
    let string = String(data: data, encoding: .utf8)
    print(string ?? "Data could not be decoded as UTF-8.")
}

bufferedReader.close()
```

## Contributing

Contributions to SwiftBufferedIO are welcome! If you find a bug or have a feature request, please open an issue. If you would like to contribute code, please fork the repository, make your changes, and submit a pull request.