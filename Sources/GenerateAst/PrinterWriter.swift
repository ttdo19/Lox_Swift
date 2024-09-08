//
//  PrintWriter.swift
//  GenerateAst
//
//  Created by Trang Do on 9/8/24.
//

import Foundation

class PrintWriter {
    private let fileManager = FileManager.default
    private let fileHandle: FileHandle
    private let encoding: String.Encoding
    
    init(url: URL, encoding: String.Encoding) {
        fileManager.createFile(atPath: url.path, contents: nil)
        self.fileHandle = FileHandle(forWritingAtPath: url.path)!
        self.encoding = encoding
    }
    
    func println(_ data: String = "") {
        if let data = "\(data)\n".data(using: encoding) {
            fileHandle.write(data)
        }
    }
}
