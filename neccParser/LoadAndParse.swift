//
//  LoadAndParse.swift
//  neccParser
//
//  Created by RSK on 9/9/20.
//  Copyright © 2020 Roy Klein. All rights reserved.
//

import Foundation

enum OptionType: String {
    case url = "u"
    case file = "f"
    case help = "h"
    case unknown
    
    init(value: String) {
        switch value {
        case "u": self = .url
        case "f": self = .file
        case "h": self = .help
        default: self = .unknown
        }
    }
}

class LoadAndParse {
    
    // Parse the command line and load the JSON
    func load() {
        let io = IO()
        let parser = Parser()
        let find = Find()
        var jsonData: Parser.System?
        var arg: String = ""
        
        let argCount = CommandLine.argc
        arg = CommandLine.arguments[1]
        if arg.starts(with: "-") {
            arg.remove(at: arg.startIndex)
        } else {
            io.commandLineUsage()
            exit(0)
        }
        let option = getOpt(arg)
        switch option {
        case .url:
            if argCount != 3 {
                io.writeToOutput("missing url", to: .stderr)
                io.commandLineUsage()
            }
            let urlString = CommandLine.arguments[2]
            self.loadJson(fromURLString: urlString) { (result) in
                switch result {
                case .success(let data):
                    jsonData = parser.parse(data: data)
                    if let jsonData = jsonData {
                        find.assertInputCount(jsonData: jsonData)
                        io.runtimeUsage()
                        self.runloop(jsonData:jsonData)
                    }
                    
                case .failure(let error):
                    print("Error - unable to load JSON: ", error)
                }
            }
        default:
            io.commandLineUsage()
        }
        dispatchMain()
    }
    
    
    // start the runloop - wait for user input
    func runloop(jsonData: Parser.System?) {
        let parser = Parser()
        let find = Find()
        
        var queryComponents: [String]
        
        while true {
            let userQuery = io.getInput()
            if userQuery == "q" || userQuery == "quit" {
                exit(0)
            } else if userQuery == "s" {
                find.quiet = !find.quiet
            } else if userQuery == "h" {
                io.runtimeUsage()
            } else {
                queryComponents = []
                parser.parseUserQuery(input: userQuery, components: &queryComponents)
                if jsonData != nil && queryComponents.count > 0 {
                    find.find(jsonData: jsonData!, queryComponents: queryComponents)
                }
            }
        }
    }
    
    // load the JSON from a URL
    func loadJson(fromURLString urlString: String,
                  completion: @escaping (Result<Data, Error>) -> Void) {
        if let url = URL(string: urlString) {
            let urlSession = URLSession(configuration: .default).dataTask(with: url) { (data, response, error) in
                if let error = error {
                    completion(.failure(error))
                }
                
                if let data = data {
                    completion(.success(data))
                }
            }
            
            urlSession.resume()
        }
    }
    
    // convenience method to get the commandline options
    func getOpt(_ option: String) -> OptionType {
        return (OptionType(value: option))
    }
    
}
