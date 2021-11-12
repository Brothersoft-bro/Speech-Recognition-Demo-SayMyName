//
//  Animals.swift
//  SayMyName
//
//  Created by Brothersoft on 10/25/21.
//

import Foundation

struct Animal: Hashable, CustomStringConvertible {

    private var name: String = ""
    private var id: Int
    
    //MARK: - LifeCycle method
    
    init(name: String, id: Int) {
        self.name = name
        self.id = id
    }
    
    //MARK: - Public methods
    
    func getName() -> String {
        self.name
    }
    
    func getId() -> Int {
        self.id
    }
    
    var description: String {
        return "\(name), id: \(id)"
    }
}
