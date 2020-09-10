//
//  Parser.swift
//  neccParser
//
//  Created by RSK on 9/9/20.
//  Copyright © 2020 Roy Klein. All rights reserved.
//

import Foundation

class Parser {
    
    // represents the JSON struct
    struct System: Codable {
        let identifier: String
        let subviews: [Subview]?
    }
    struct Subview : Codable {
        var subviewClass: String?
        var classNames: [String]?
        var subviews: [Subview]?
        var identifier: String?
        var title: Title?
        var label: Label?
        var control: Control?
        var contentView: ContentView?
        
        private enum CodingKeys: String, CodingKey {
            case subviewClass = "class", classNames, subviews, identifier, title, label, control, contentView
        }
    }
    
    struct ContentView : Codable {
        var subviews: [Subview]
    }
    
    struct Control: Codable {
        let controlClass: ControlClass
        let identifier, controlVar: String?
        let min: Double?
        let max, step: Int?
        let expectsStringValue: Bool?
        
        enum CodingKeys: String, CodingKey {
            case controlClass = "class", identifier, controlVar, min, max, step, expectsStringValue
        }
    }
    
    enum ControlClass: String, Codable {
        case cvarCheckbox = "CvarCheckbox"
        case cvarSelect = "CvarSelect"
        case cvarSlider = "CvarSlider"
        case videoModeSelect = "VideoModeSelect"
    }
    
    struct Label: Codable {
        let text: Title
    }
    
    struct Title: Codable {
        let text: String
    }
    
    // parse the json file into JSON structs that we can use
    func parse(data: Data) -> System? {
        do {
            let decoder = JSONDecoder()
            let jsonData = try decoder.decode(System.self, from: data)
            return jsonData
            
        } catch {
            print("Error - unable to parse JSON file: \(error)")
        }
        return nil
    }
    
    // parse the user query into components
    // eg
    // query = "StackView.container#videoMode", components = ["StackView"]
    // query = "StackView.container#videoMode", components = ["StackView", ".container", "#videoMode"]
    
    func parseUserQuery(input:String, components:inout [String]) {
        var pattern = "([^\\.\\#]*)"
        if components.count > 0 {
            pattern = "([\\.\\#][^\\.\\#]*)"
        }
        
        guard let result = input.range(of: pattern, options:.regularExpression) else { return }
        let nextString = String(input[result.upperBound...])
        if nextString == input {
            components.append(nextString)
            return
        } else {
            components.append(String(input[result]))
            if nextString.count > 0 {
                parseUserQuery(input: nextString, components: &components)
            }
        }
    }
    
}
