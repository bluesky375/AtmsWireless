//
//  OverViewController.swift
//  AtmsWireless
//
//  Created by Big Sur on 3/9/21.
//

import UIKit
import Charts

class OverViewController: UIViewController {
    
    var data: [[String: Any]] = []
    var up_data: [[String: Any]] = []
    var down_data: [[String: Any]] = []

    @IBOutlet weak var pieChartView: PieChartView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationItem.title = "Overview"
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        APIManager.sharedInstance.getLists(username: "atmsth", password: "Anil", type: "all") { response in
            self.data = response
            self.up_data = self.data.filter { d in
                let last_check_in = d["RI_Last_Time"] as! String
                let date = self.PST_to_UTC(dateString: last_check_in)
                let diff = self.diff_from_current(last_check_in: date)
                return diff < 120
            }
            self.down_data = self.data.filter { d in
                let last_check_in = d["RI_Last_Time"] as! String
                let date = self.PST_to_UTC(dateString: last_check_in)
                let diff = self.diff_from_current(last_check_in: date)
                return diff > 120
            }
            self.setupPieChart()
        }
    }
    
    func setupPieChart() {
        pieChartView.chartDescription?.enabled = true
        pieChartView.drawHoleEnabled = false
        pieChartView.rotationAngle = 0
//        pieChartView.rotationEnabled = false
//        pieChartView.isUserInteractionEnabled = false
        
//        pieChartView.legend.enabled = false
        
        var entries: [PieChartDataEntry] = Array()
        entries.append(PieChartDataEntry(value: Double(self.up_data.count), label: "UP \(self.up_data.count)"))
        entries.append(PieChartDataEntry(value: Double(self.down_data.count), label: "DOWN \(self.down_data.count)"))
        
        let dataSet = PieChartDataSet(entries: entries, label: "")
        let c1 = UIColor.green
        let c2 = UIColor.red
        dataSet.colors = [c1, c2]
        dataSet.drawValuesEnabled = false
        dataSet.sliceSpace = 2
        
        let data = PieChartData(dataSet: dataSet)
        
        let pFormatter = NumberFormatter()
        pFormatter.numberStyle = .decimal
        pFormatter.maximumFractionDigits = 1
        pFormatter.multiplier = 1
        data.setValueFormatter(DefaultValueFormatter(formatter: pFormatter))
        
        data.setValueFont(.systemFont(ofSize: 11, weight: .light))
        data.setValueTextColor(.white)
        
        pieChartView.data = data
        pieChartView.highlightValues(nil)
    }
    
    func diff_from_current(last_check_in: Date) -> Double {
        let date = Date()
        let utcDateFormatter = DateFormatter()
        utcDateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        utcDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let utcDate = utcDateFormatter.date(from: utcDateFormatter.string(from: date))
        let u = utcDate!.timeIntervalSince1970
        let l = last_check_in.timeIntervalSince1970
        return (utcDate!.timeIntervalSince1970 - last_check_in.timeIntervalSince1970) / 60
    }
    
    func PST_to_UTC(dateString: String) -> Date {
        let pstDateFormatter = DateFormatter()
        pstDateFormatter.timeZone = TimeZone(abbreviation: "PST")
        pstDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let date = pstDateFormatter.date(from: dateString)
        let pstDate = pstDateFormatter.date(from: pstDateFormatter.string(from: date!))
        
        let utcDateFormatter = DateFormatter()
        utcDateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        utcDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let utcDate = utcDateFormatter.date(from: utcDateFormatter.string(from: date!))
        return utcDate!
    }

}
