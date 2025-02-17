//
//  Upgrade Packages.swift
//  Cork
//
//  Created by David Bureš on 04.07.2022.
//

import Foundation
import SwiftUI

@MainActor
func updatePackages(updateProgressTracker: UpdateProgressTracker, appState _: AppState, outdatedPackageTracker _: OutdatedPackageTracker, detailStage: UpdatingProcessDetails) async
{
    let showRealTimeTerminalOutputs = UserDefaults.standard.bool(forKey: "showRealTimeTerminalOutputOfOperations")

    for await output in shell(AppConstants.brewExecutablePath, ["upgrade"])
    {
        switch output
        {
        case let .standardOutput(outputLine):
            print("Upgrade function output: \(outputLine)")

            if showRealTimeTerminalOutputs
            {
                updateProgressTracker.realTimeOutput.append(RealTimeTerminalLine(line: outputLine))
            }

            if outputLine.contains("Downloading")
            {
                detailStage.currentStage = .downloading
            }
            else if outputLine.contains("Pouring")
            {
                detailStage.currentStage = .pouring
            }
            else if outputLine.contains("cleanup")
            {
                detailStage.currentStage = .cleanup
            }
            else if outputLine.contains("Backing App")
            {
                detailStage.currentStage = .backingUp
            }
            else if outputLine.contains("Moving App") || outputLine.contains("Linking")
            {
                detailStage.currentStage = .linking
            }
            else
            {
                detailStage.currentStage = .cleanup
            }

            print("Current updating stage: \(detailStage.currentStage)")

            updateProgressTracker.updateProgress = updateProgressTracker.updateProgress + 0.1

        case let .standardError(errorLine):

            if showRealTimeTerminalOutputs
            {
                updateProgressTracker.realTimeOutput.append(RealTimeTerminalLine(line: errorLine))
            }

            if errorLine.contains("tap") || errorLine.contains("No checksum defined for")
            {
                updateProgressTracker.updateProgress = updateProgressTracker.updateProgress + 0.1

                print("Ignorable upgrade function error: \(errorLine)")
            }
            else
            {
                print("Upgrade function error: \(errorLine)")
                updateProgressTracker.errors.append("Upgrade error: \(errorLine)")
            }
        }
    }

    updateProgressTracker.updateProgress = 9
}
