//
//  IO.swift
//  neccParser
//
//  Created by RSK on 9/9/20.
//  Copyright © 2020 Roy Klein. All rights reserved.
//

import Foundation

enum OutputType {
    case stderr
    case stdout
}

class IO {
    // read input from the keyboard
    func getInput() -> String {
        let userInput = FileHandle.standardInput
        let userData = userInput.availableData
        let stringData = String(data: userData, encoding: String.Encoding.utf8)!
        return stringData.trimmingCharacters(in: CharacterSet.newlines)
    }
    
    // convenience method to write to stdout/stderr
    func writeToOutput(_ mesg: String, to: OutputType = .stdout) {
        switch to {
        case .stdout:
            print("\(mesg)")
        case .stderr:
            fputs("Error: \(mesg)\n", stderr)
        }
    }
    
    // display commandline usage
    func commandLineUsage() {
        let executableName = (CommandLine.arguments[0] as NSString).lastPathComponent
        
        writeToOutput("usage:")
        writeToOutput("\(executableName) -u URL")
    }
    
    // display runtime usage
    func runtimeUsage() {
        writeToOutput(" ")
        writeToOutput(" ")
        writeToOutput("Enter query term:")
        writeToOutput("    [name] for View Class name")
        writeToOutput("    [.classname] for CSS Class names")
        writeToOutput("    [#identifier] for view identifier")
        writeToOutput(" ")
        writeToOutput("h to show this usage method")
        writeToOutput("s to toggle silent mode -  print the count of matching views, not the JSON")
        writeToOutput("q to quit")
    }
}
