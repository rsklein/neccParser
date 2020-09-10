//
//  main.swift
//  neccParser
//
//  Created by RSK on 9/9/20.
//  Copyright © 2020 Roy Klein. All rights reserved.
//

import Foundation

let loadAndParse = LoadAndParse()
let io = IO()

if CommandLine.argc < 2 {
    io.commandLineUsage()
} else {
    loadAndParse.load()
}
