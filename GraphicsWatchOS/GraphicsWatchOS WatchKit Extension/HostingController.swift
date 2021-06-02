//
//  HostingController.swift
//  GraphicsWatchOS WatchKit Extension
//
//  Created by Juliano Vaz on 01/06/21.
//

import WatchKit
import Foundation
import SwiftUI

class HostingController: WKHostingController<BarChart> {
    override var body: BarChart {
        return  BarChart(title: "Monthly Sales", legend: "EUR", barColor: .blue, data: chartDataSet)
    }
}
