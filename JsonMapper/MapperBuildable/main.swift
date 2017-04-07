//
//  main.swift
//  MapperBuildable
//
//  Created by Gleb Radchenko on 3/25/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation

let json = ["test": ["hello world"]] as AnyObject

let string: [String] = try Mapper.map(for: "test", json)

print(string)
