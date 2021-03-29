//
//  HomeTableViewController.swift
//  AtmsWireless
//
//  Created by Big Sur on 3/9/21.
//

import UIKit

class HomeTableViewController: UITableViewController {
    
    var sections: [(letter: Character, datas: [[String: Any]])] = []
    var filtered_sections : [(letter: Character, datas: [[String: Any]])] = []
    var sectionTitles: [String] = []
    var data: [[String: Any]] = []
    var up_data: [[String: Any]] = []
    var down_data: [[String: Any]] = []
    
    var searchController: UISearchController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        APIManager.sharedInstance.getLists(username: "atmsth", password: "Anil", type: "all") { response in
            self.data = response
            self.up_data = self.data.filter { d in
                let last_check_in = d["RI_Last_Time"] as! String
                let date = self.PST_to_CTZ(dateString: last_check_in)
                let diff = self.diff_from_current(last_check_in: date)
                return diff < 120
            }
            self.down_data = self.data.filter { d in
                let last_check_in = d["RI_Last_Time"] as! String
                let date = self.PST_to_CTZ(dateString: last_check_in)
                let diff = self.diff_from_current(last_check_in: date)
                return diff > 120
            }
            self.sections = Dictionary(grouping: self.up_data) { data -> Character in
                if let name = data["RI_Description"] as? String, name.count > 0 {
                        let index = name.index(name.startIndex, offsetBy: 7)
                        return name[index]
                    } else {
                        return "~"
                    }
                
                }
                .map { (key: Character, value: [[String: Any]]) -> (letter: Character, datas: [[String: Any]]) in
                    (letter: key, datas: value)
                }
                .sorted { (left, right) -> Bool in
                    left.letter < right.letter
                }
            
            self.filtered_sections = self.sections
            self.sectionTitles = self.sections.map { section in
                return String(section.letter)
            }
            let howManyUp = UIBarButtonItem(title: "\(self.up_data.count) UP", style: .plain, target: self, action: #selector(self.onHowManyUp))
            self.navigationItem.leftBarButtonItem = howManyUp
            
            let howManyDown = UIBarButtonItem(title: "\(self.down_data.count) DOWN", style: .plain, target: self, action: #selector(self.onHowManyDown))
            self.navigationItem.rightBarButtonItem = howManyDown
            self.tableView.reloadData()
            
        }
    }

    // MARK: - Table view data source

    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return self.sectionTitles
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return String(filtered_sections[section].letter)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return self.filtered_sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.filtered_sections[section].datas.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeCell", for: indexPath)

        let sectionsData = self.filtered_sections[indexPath.section].datas
        // Configure the cell...
        cell.textLabel?.text = sectionsData[indexPath.row]["RI_Description"] as? String
//        let last_time = sectionsData[indexPath.row]["RI_Last_Time"] as! String
        let last_time = PST_to_CTZ_String(dateString: sectionsData[indexPath.row]["RI_Last_Time"] as! String)
        let serial_number = sectionsData[indexPath.row]["RI_Serial_Number"] as! String
        let signal_Strength = sectionsData[indexPath.row]["RI_Signal_Strength"] as! String
        cell.detailTextLabel?.text = last_time + "          " + serial_number + "          " + signal_Strength + "%"

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let sectionsData = self.filtered_sections[indexPath.section].datas
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        vc.hidesBottomBarWhenPushed = true
        vc.data = sectionsData[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
        searchController.isActive = false
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func onRefresh(_ sender: UIRefreshControl) {
        sender.endRefreshing()
        APIManager.sharedInstance.getLists(username: "atmsth", password: "Anil", type: "all") { response in
            self.data = response
            self.up_data = self.data.filter { d in
                let last_check_in = d["RI_Last_Time"] as! String
                let date = self.PST_to_CTZ(dateString: last_check_in)
                let diff = self.diff_from_current(last_check_in: date)
                return diff < 120
            }
            self.down_data = self.data.filter { d in
                let last_check_in = d["RI_Last_Time"] as! String
                let date = self.PST_to_CTZ(dateString: last_check_in)
                let diff = self.diff_from_current(last_check_in: date)
                return diff > 120
            }
            self.sections = Dictionary(grouping: self.up_data) { data -> Character in
                if let name = data["RI_Description"] as? String, name.count > 0 {
                        let index = name.index(name.startIndex, offsetBy: 7)
                        return name[index]
                    } else {
                        return "~"
                    }
                
                }
                .map { (key: Character, value: [[String: Any]]) -> (letter: Character, datas: [[String: Any]]) in
                    (letter: key, datas: value)
                }
                .sorted { (left, right) -> Bool in
                    left.letter < right.letter
                }
            
            self.filtered_sections = self.sections
            self.sectionTitles = self.sections.map { section in
                return String(section.letter)
            }
            let howManyUp = UIBarButtonItem(title: "\(self.up_data.count) UP", style: .plain, target: self, action: #selector(self.onHowManyUp))
            self.navigationItem.leftBarButtonItem = howManyUp
            
            let howManyDown = UIBarButtonItem(title: "\(self.down_data.count) DOWN", style: .plain, target: self, action: #selector(self.onHowManyDown))
            self.navigationItem.rightBarButtonItem = howManyDown
            self.tableView.reloadData()
            
        }
    }
    
    
    
    @objc func onHowManyUp() {
        
    }
    
    @objc func onHowManyDown() {
        let offlineVC = self.storyboard?.instantiateViewController(withIdentifier: "OfflineTableViewController") as! OfflineTableViewController
        self.tabBarController?.selectedIndex = 2
    }
    
    func diff_from_current(last_check_in: Date) -> Double {
        let date = Date()
        let CTZDateFormatter = DateFormatter()
        CTZDateFormatter.timeZone = TimeZone(abbreviation: "CTZ")
        CTZDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let CTZDate = CTZDateFormatter.date(from: CTZDateFormatter.string(from: date))
        let u = CTZDate!.timeIntervalSince1970
        let l = last_check_in.timeIntervalSince1970
        return (CTZDate!.timeIntervalSince1970 - last_check_in.timeIntervalSince1970) / 60
    }
    
    func PST_to_CTZ(dateString: String) -> Date {
        let pstDateFormatter = DateFormatter()
        pstDateFormatter.timeZone = TimeZone(abbreviation: "PST")
        pstDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let date = pstDateFormatter.date(from: dateString)
        let pstDate = pstDateFormatter.date(from: pstDateFormatter.string(from: date!))
        
        let CTZDateFormatter = DateFormatter()
        CTZDateFormatter.timeZone = TimeZone(abbreviation: "CTZ")
        CTZDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let CTZDate = CTZDateFormatter.date(from: CTZDateFormatter.string(from: date!))
        return CTZDate!
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

extension HomeTableViewController: UISearchBarDelegate, UISearchResultsUpdating, UISearchControllerDelegate {
    
    func didDismissSearchController(_ searchController: UISearchController) {
//        self.filtered_sections = self.sections
//        tableView.reloadData()
    }

    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
//        if searchText == "" {
//            filtered_sections = []
//            self.sections.map {
//                let filtered = $0.datas.filter {
//                    let description = $0["RI_Description"] as! String
//                    let serial_number = $0["RI_Serial_Number"] as! String
//                    return description.lowercased().contains(searchText.lowercased()) || serial_number.lowercased().contains(searchText.lowercased())
//                }
//                if filtered.count > 0 {
//                    filtered_sections.append((letter: $0.letter, datas: filtered))
//                }
//            }
//        } else {
//            self.filtered_sections = self.sections
//        }
//
//        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        if let searchText = searchBar.text {
            filtered_sections = []
            self.sections.map {
                let filtered = $0.datas.filter {
                    let description = $0["RI_Description"] as! String
                    let serial_number = $0["RI_Serial_Number"] as! String
                    return description.lowercased().contains(searchText.lowercased()) || serial_number.lowercased().contains(searchText.lowercased())
                }
                if filtered.count > 0 {
                    filtered_sections.append((letter: $0.letter, datas: filtered))
                }
            }
        }
        else {
            self.filtered_sections = self.sections
        }
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText != "" {
            filtered_sections = []
            self.sections.map {
                let filtered = $0.datas.filter {
                    let description = $0["RI_Description"] as! String
                    let serial_number = $0["RI_Serial_Number"] as! String
                    return description.lowercased().contains(searchText.lowercased()) || serial_number.lowercased().contains(searchText.lowercased())
                }
                if filtered.count > 0 {
                    filtered_sections.append((letter: $0.letter, datas: filtered))
                }
            }
        }
        else {
            self.filtered_sections = self.sections
        }
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchController.isActive = false
        self.filtered_sections = self.sections
        tableView.reloadData()
    }
}

