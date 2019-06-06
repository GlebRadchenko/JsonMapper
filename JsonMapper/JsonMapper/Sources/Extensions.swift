//
//  Extensions.swift
//  JsonMapper
//
//  Created by Gleb Radchenko on 4/1/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation

public extension Data {
    func json() throws -> AnyObject {
        return try JSONSerialization.jsonObject(with: self, options: .mutableLeaves) as AnyObject
    }
}
