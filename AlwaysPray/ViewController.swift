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
        
        let prayDate = prayItem.added!
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/d, a hh:mm"
        
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
        observerSetting()
        loadData()
    }
    
    func observerSetting(){
        let center = NotificationCenter.default
        let mainQueue = OperationQueue.main
        let _ = center.addObserver(forName: Notification.Name("tableReload"), object: nil, queue: mainQueue, using: {_ in
            print("reload table view")
        })
    }
    
    func loadData(){
        let prayRequest:NSFetchRequest<Pray> = Pray.fetchRequest()
        
        let sortDescriptor = NSSortDescriptor(key: "added", ascending: false)
        prayRequest.sortDescriptors = [sortDescriptor]
        
        do {
            try prayItems = moc.fetch(prayRequest)
            self.tableView.reloadData()
        } catch {
            print("Could not load data.")
        }
        
    }
    
    @IBAction func startReminding(_ sender: Any) {
        appDelegate?.scheduleNotification(timeArray[selectRow])
        let time = timeArray[selectRow]
        let sparklingHeart = "\u{1F496}"
        Output_Alert(title: "알림 설정 성공\(sparklingHeart)", message: "이제 \(time)시간마다 알림이 와요 !", text: "확인")
        
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
    func Output_Alert(title : String, message : String, text : String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: text, style: UIAlertAction.Style.cancel, handler: nil)

        alertController.addAction(okButton)

        return self.present(alertController, animated: true, completion: nil)
    }

}

