//
//  ViewController.swift
//  AlwaysPray
//
//  Created by Ho Hwang on 14/01/2020.
//  Copyright © 2020 hohwang. All rights reserved.
//

import UIKit
import CoreData
import Foundation

class ViewController: UIViewController, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var timeArray = ["1", "2", "3", "4", "6", "8", "12"]
    var selectRow = 0
    
    @IBOutlet weak var timePicker: UIPickerView!
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return timeArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return timeArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectRow = row
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return prayItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let prayItem = prayItems[indexPath.row]
        
        let prayType = prayItem.type
        cell.textLabel?.text = prayType
        
        let prayDate = prayItem.added as! Date
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy MMMM d, hh:mm"
        
        cell.detailTextLabel?.text = dateFormatter.string(from: prayDate)
        
        if prayType == "기도했어요" {
            cell.imageView?.image = UIImage(named: "pray")
        }
        
        return cell
    }
    
    var prayItems = [Pray]()
    
    var moc:NSManagedObjectContext!
    
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        moc = appDelegate?.persistentContainer.viewContext
        // Do any additional setup after loading the    view.
        self.timePicker.delegate = self
        self.timePicker.dataSource = self
        
        self.tableView.dataSource = self
        
        loadData()
    }
    
    func loadData(){
        let prayRequest:NSFetchRequest<Pray> = Pray.fetchRequest()
        
        let sortDescriptor = NSSortDescriptor(key: "added", ascending: false)
        prayRequest.sortDescriptors = [sortDescriptor]
        
        do {
            try prayItems = moc.fetch(prayRequest)
        } catch {
            print("Could not load data.")
        }
        
        self.tableView.reloadData()
    }
    
    @IBAction func startReminding(_ sender: Any) {
        appDelegate?.scheduleNotification(timeArray[selectRow])
    }
    @IBAction func addPrayToDatabase(_ sender: UIButton) {
        let prayItem = Pray(context: moc)
        prayItem.added = Date()
        
        if sender.tag == 0 {
            prayItem.type = "기도했어요"
        }
        
        appDelegate?.saveContext()
        
        loadData()
        
    }

}

