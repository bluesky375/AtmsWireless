//
//  ViewController.swift
//  AtmsWireless
//
//  Created by Big Sur on 3/9/21.
//

import UIKit
import PopupDialog

class DetailViewController: UIViewController {

    var data: [String: Any] = [:]
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnPing: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        btnPing.clipsToBounds = true
        btnPing.layer.cornerRadius = 10
        print(data)
        navigationItem.title = "Detail"
        
        // Customize dialog appearance
        let pv = PopupDialogDefaultView.appearance()
        pv.titleFont    = UIFont(name: "HelveticaNeue-Light", size: 16)!
        pv.titleColor   = .white
        pv.messageFont  = UIFont(name: "HelveticaNeue", size: 14)!
        pv.messageColor = UIColor(white: 0.8, alpha: 1)

        // Customize the container view appearance
        let pcv = PopupDialogContainerView.appearance()
        pcv.backgroundColor = UIColor(red:0.23, green:0.23, blue:0.27, alpha:1.00)
        pcv.cornerRadius    = 5
        pcv.shadowEnabled   = true
        pcv.shadowColor     = .black

        // Customize overlay appearance
        let ov = PopupDialogOverlayView.appearance()
        ov.blurEnabled     = true
        ov.blurRadius      = 30
        ov.liveBlurEnabled = true
        ov.opacity         = 0.7
        ov.color           = .black

        // Customize default button appearance
        let db = DefaultButton.appearance()
        db.titleFont      = UIFont(name: "HelveticaNeue-Medium", size: 14)!
        db.titleColor     = .white
        db.buttonColor    = UIColor(red:0.25, green:0.25, blue:0.29, alpha:1.00)
        db.separatorColor = UIColor(red:0.20, green:0.20, blue:0.25, alpha:1.00)

        // Customize cancel button appearance
        let cb = CancelButton.appearance()
        cb.titleFont      = UIFont(name: "HelveticaNeue-Medium", size: 14)!
        cb.titleColor     = UIColor(white: 0.6, alpha: 1)
        cb.buttonColor    = UIColor(red:0.25, green:0.25, blue:0.29, alpha:1.00)
        cb.separatorColor = UIColor(red:0.20, green:0.20, blue:0.25, alpha:1.00)
        
    }

    @IBAction func btnPingAction(_ sender: UIButton) {
        let sn = data["RI_Serial_Number"] as! String
        APIManager.sharedInstance.getRouterInfo(username: "atmsth", password: "Anil", sn: sn) { response, error  in
            if let error = error {
                self.fail()
            } else {
                self.success()
                print("response", response)
                self.data = response![0]
                self.tableView.reloadData()
            }
        }
    }
    
    func success() {
        let title = ""
        let message = "Good ping to \(data["RI_WAN_IP"] as! String)!"
        let popup = PopupDialog(title: title, message: message)
        let cancel = CancelButton(title: "CANCEL") {
            print("HERE")
        }
        let ok = DefaultButton(title: "OK", dismissOnTap: true) {
            print("HERE")
        }
        popup.buttonAlignment = .horizontal
        popup.addButtons([cancel, ok])
        self.present(popup, animated: true, completion: nil)
    }
    
    func fail() {
        let title = ""
        let message = "This device is currently not reachable."
        let popup = PopupDialog(title: title, message: message)
        let cancel = CancelButton(title: "CANCEL") {
            print("HERE")
        }
        let ok = DefaultButton(title: "OK", dismissOnTap: true) {
            print("HERE")
        }
        popup.buttonAlignment = .horizontal
        popup.addButtons([cancel, ok])
        self.present(popup, animated: true, completion: nil)
    }
    
    func PST_to_CTZ_String(dateString: String) -> String {
        let pstDateFormatter = DateFormatter()
        pstDateFormatter.timeZone = TimeZone(abbreviation: "PST")
        pstDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let date = pstDateFormatter.date(from: dateString)
        let pstDate = pstDateFormatter.date(from: pstDateFormatter.string(from: date!))
        
        let CTZDateFormatter = DateFormatter()
        CTZDateFormatter.timeZone = TimeZone(abbreviation: "CTZ")
        CTZDateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        let CTZDate = CTZDateFormatter.date(from: CTZDateFormatter.string(from: date!))
        return CTZDateFormatter.string(from: date!)
    }
    
}

extension DetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 14
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath)
        switch indexPath.row {
        case 1:
            cell.textLabel?.text = "Account:"
            cell.detailTextLabel?.text = data["RI_Account"] as? String
        case 2:
            cell.textLabel?.text = "Description:"
            cell.detailTextLabel?.text = data["RI_Description"] as? String
        case 3:
            cell.textLabel?.text = "Model:"
            cell.detailTextLabel?.text = data["RI_Model"] as? String
        case 4:
            cell.textLabel?.text = "Firmware:"
            cell.detailTextLabel?.text = data["RI_Firmware"] as? String
        case 5:
            cell.textLabel?.text = "Current Billing Month Usage:"
            cell.detailTextLabel?.text = String(format: "%f", data["RI_Data_Usage"] as! Double)
        case 6:
            cell.textLabel?.text = "Data Plan:"
            cell.detailTextLabel?.text = data["SIM_Data_Plan"] as? String
        case 7:
            cell.textLabel?.text = "Last Check-in Time:"
            cell.detailTextLabel?.text = PST_to_CTZ_String(dateString: data["RI_Last_Time"] as! String)
        case 8:
            cell.textLabel?.text = "Serial Number:"
            cell.detailTextLabel?.text = data["RI_Serial_Number"] as? String
        case 9:
            cell.textLabel?.text = "SIM Number:"
            cell.detailTextLabel?.text = data["SIM_Number"] as? String
        case 10:
            cell.textLabel?.text = "MAC Address:"
            cell.detailTextLabel?.text = data["RI_MAC_Address"] as? String
        case 11:
            cell.textLabel?.text = "IMEI Number:"
            cell.detailTextLabel?.text = data["RI_IMEI_Number"] as? String
        case 12:
            cell.textLabel?.text = "Router IP:"
            cell.detailTextLabel?.text = data["RI_WAN_IP"] as? String
        default:
            cell.textLabel?.text = ""
            cell.detailTextLabel?.text = ""
        }
        return cell
    }
    
    
}

