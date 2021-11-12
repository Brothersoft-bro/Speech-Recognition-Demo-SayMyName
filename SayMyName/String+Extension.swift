//
//  String+Extension.swift
//  SayMyName
//
//  Created by Brothersoft on 10/25/21.
//

import Foundation

extension String {
    func lastWord() -> String? {
        return self.components(separatedBy: " ").last
    }
}

