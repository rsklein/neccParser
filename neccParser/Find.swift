//
//  Find.swift
//  neccParser
//
//  Created by RSK on 9/9/20.
//  Copyright © 2020 Roy Klein. All rights reserved.
//

import Foundation


class Find {
    
    var quiet = false
    let io = IO()
    
    // Starting with the first querycomponent, figure out if it's a class,
    // classname, or identifier based on the first char of the component. Then start
    // the appropriate treewalk to find that type of component.  Note: I could have
    // used the same treewalk for all types, however, it would have been very difficult
    // to read the code and/or modify if the structure of the JSON changed for one type.
    
    func find(jsonData: Parser.System, queryComponents: [String]) {
        var query = queryComponents[0]
        
        switch queryComponents[0].first {
        case "#":
            query.remove(at: query.startIndex)
            print ("Count of Matching Identifiers: ", findIdentifiers(jsonData: jsonData, queryComponents: queryComponents))
        case ".":
            query.remove(at: query.startIndex)
            print ("Count of Matching Classnames: ", findClassNames(jsonData: jsonData, queryComponents: queryComponents))
        default:
            print ("Count of Matching Classes: ", findClass(jsonData: jsonData, queryComponents: queryComponents))
        }
    }
    
    // Assert that there are 26 Input classes. Use the quiet flag to keep from printing
    // the JSON elements for this assertion case.
    func assertInputCount (jsonData: Parser.System) {
        quiet = true
        assert(findClass(jsonData: jsonData, queryComponents: ["Input"]) == 26, "Warning, didn't find correct count of Input classes")
        io.writeToOutput("Assert: Found 26 instances of Input views")
        quiet = false
    }
    
    // Starts the treewalk by finding the top level subviews
    func findClass(jsonData: Parser.System, queryComponents: [String]) -> Int {
        var total:Int = 0
        if let subviews = jsonData.subviews {
            for subview in subviews {
                treeWalkClass(subview: subview, queryComponents:queryComponents, total: &total)
            }
        }
        return total
    }
    
    // walks the tree, looking for subviews with the matching classname.  If one is found,
    // we check to see if this is a compound query (i.e. there are more items in the query
    // components list.  If no, then we increase the count, print the node, and continue
    // walking the tree.  If yes, then we figure out what type of query the next component is,
    // and start a tree walk for that type.   NOTE: This is the same for all 3 types of queries.
    
    func treeWalkClass(subview: Parser.Subview, queryComponents: [String], total:inout Int) {
        var className = queryComponents[0]
        if subview.subviewClass == className {
            if queryComponents.count > 1 {
                className = queryComponents[1]
                var qc = queryComponents
                qc.removeFirst()
                if className.starts(with: ".") {
                    treeWalkClassNames(subview: subview, queryComponents: qc, total: &total)
                } else {
                    treeWalkIdentifiers(subview: subview, queryComponents: qc, total: &total)
                    
                }
            } else {
                total+=1
                printJson(subview: subview)
            }
        }
        if let subviews = subview.contentView?.subviews {
            for sbview in subviews {
                treeWalkClass(subview: sbview, queryComponents:queryComponents, total: &total)
            }
        }
        if let subviews = subview.subviews {
            for sbview in subviews {
                treeWalkClass(subview: sbview, queryComponents:queryComponents, total: &total)
            }
        }
    }
    
    // see comments above
    func findClassNames(jsonData: Parser.System, queryComponents: [String]) -> Int {
        var total:Int = 0
        if let subviews = jsonData.subviews {
            for subview in subviews {
                treeWalkClassNames(subview: subview, queryComponents:queryComponents, total: &total)
            }
        }
        return total
    }
    
    // see comments above
    func treeWalkClassNames(subview: Parser.Subview, queryComponents:[String], total:inout Int) {
        var className = queryComponents[0]
        className.remove(at: className.startIndex)
        if let classNames = subview.classNames {
            if classNames.contains(className) {
                if queryComponents.count > 1 {
                    className = queryComponents[1]
                    var qc = queryComponents
                    qc.removeFirst()
                    if className.starts(with: ".") {
                        treeWalkClassNames(subview: subview, queryComponents: qc, total: &total)
                    } else {
                        treeWalkIdentifiers(subview: subview, queryComponents: qc, total: &total)
                    }
                } else {
                    total += 1
                    printJson(subview: subview)
                }
            }
        }
        if let subviews = subview.contentView?.subviews {
            for sbview in subviews {
                treeWalkClassNames(subview: sbview, queryComponents:queryComponents, total: &total)
            }
        }
        if let subviews = subview.subviews {
            for sbview in subviews {
                treeWalkClassNames(subview: sbview, queryComponents:queryComponents, total: &total)
            }
        }
    }
    
    // see comments above
    func findIdentifiers(jsonData: Parser.System, queryComponents:[String]) -> Int {
        var total:Int = 0
        var identifierName = queryComponents[0]
        identifierName.remove(at: identifierName.startIndex)
        if let subviews = jsonData.subviews {
            for subview in subviews {
                treeWalkIdentifiers(subview: subview, queryComponents:queryComponents, total: &total)
            }
        }
        return total
    }
    
    // see comments above
    func treeWalkIdentifiers(subview: Parser.Subview, queryComponents:[String], total:inout Int) {
        var identifierName = queryComponents[0]
        identifierName.remove(at: identifierName.startIndex)
        
        if subview.control?.identifier == identifierName {
            if queryComponents.count > 1 {
                identifierName = queryComponents[1]
                var qc = queryComponents
                qc.removeFirst()
                if identifierName.starts(with: ".") {
                    treeWalkClassNames(subview: subview, queryComponents: qc, total: &total)
                } else {
                    treeWalkIdentifiers(subview: subview, queryComponents: qc, total: &total)
                }
            } else {
                total+=1
                printJson(subview: subview)
            }
        }
        if let subviews = subview.contentView?.subviews {
            for sbview in subviews {
                treeWalkIdentifiers(subview: sbview, queryComponents:queryComponents, total: &total)
            }
        }
        if let subviews = subview.subviews {
            for sbview in subviews {
                treeWalkIdentifiers(subview: sbview, queryComponents:queryComponents, total: &total)
            }
        }
    }
    
    // print matching subviews
    func printJson(subview: Parser.Subview) {
        // Serialize to JSON
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(subview)
            let string = String(data: data, encoding: .utf8)!
            if !quiet {
                print(string)
            }
        } catch {
            print("Error with Json: \(error)")
        }
    }
}
