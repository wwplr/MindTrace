//
//  MindTrace.swift
//  MindTrace
//
//  Created by Warintorn on 20/02/2024.
//

import DeviceActivity
import SwiftUI

@main
struct MindTrace: DeviceActivityReportExtension {
    var body: some DeviceActivityReportScene {
        // Create a report for each DeviceActivityReport.Context that your app supports.
        TotalActivityReport { totalActivity in
            TotalActivityView(totalActivity: totalActivity)
        }
        // Add more reports here...
    }
}
