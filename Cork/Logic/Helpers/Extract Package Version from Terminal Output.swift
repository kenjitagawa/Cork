//
//  Extract Package Version from Terminal Output.swift
//  Cork
//
//  Created by David Bureš on 13.02.2023.
//

import Foundation

#warning("This has to exist because I don't yet have the system to dynamically get versions from newly-installed packages. Make that whole system more elegant, then remove this")
func extractPackageVersionFromTerminalOutput(terminalOutput: TerminalOutput, packageBeingInstalled: BrewPackage) throws -> String
{
    var regex: String
    
    switch packageBeingInstalled.isCask
    {
    case false:
        regex = "(?<=Cellar\\/\(packageBeingInstalled.name)\\/).*?(?=\\:)"
    case true:
        regex = "(?<=Caskroom\\/\(packageBeingInstalled.name)\\/).*?(?=\\:)"
    }
    
    let matchedString = try regexMatch(from: terminalOutput.standardOutput, regex: regex)
    
    return "I don't work yet"
}
