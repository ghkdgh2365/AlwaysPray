//
//  CalendarViewController.swift
//  AlwaysPray
//
//  Created by Ho Hwang on 2020/08/01.
//  Copyright © 2020 hohwang. All rights reserved.
//
import UIKit
import CoreData
import Foundation
import FSCalendar

class CalendarViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance {
    
    @IBOutlet var calendar: FSCalendar!
    
    var prayItems = [Pray]()
    
    var moc:NSManagedObjectContext!
    
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    lazy var dateFormatter1: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }()
    
    var fillDefaultColors = Dictionary<String, UIColor>();
    var titleDefaultColors : Array = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        moc = appDelegate?.persistentContainer.viewContext
        
        calendar.dataSource = self
        calendar.delegate = self
        
        loadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let weekDayLabel = calendar.calendarWeekdayView.weekdayLabels
        for (index, weekDay) in weekDayLabel.enumerated() {
            if (index == 0){
                weekDay.textColor = UIColor.red
            } else if (index > 0 && index < 6){
                weekDay.textColor = UIColor.black
            }
        }
        calendar.reloadData()
        loadData()
    }
    
    func loadData(){
        let prayRequest:NSFetchRequest<Pray> = Pray.fetchRequest()
        
        let sortDescriptor = NSSortDescriptor(key: "added", ascending: false)
        prayRequest.sortDescriptors = [sortDescriptor]
        let currentDate = NSDate.now
        self.fillDefaultColors[self.dateFormatter1.string(from: currentDate)] = UIColor.orange
        
        do {
            try prayItems = moc.fetch(prayRequest)
            prayItems.forEach { (pray) in
                self.fillDefaultColors[self.dateFormatter1.string(from: pray.added!)] = UIColor(red: 187/255, green: 10/255, blue: 30/255, alpha: 1)
                self.titleDefaultColors.append(self.dateFormatter1.string(from: pray.added!))
            }
        } catch {
            print("Could not load data.")
        }
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print("selected")
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
        let key = self.dateFormatter1.string(from: date)
        if let color = self.fillDefaultColors[key] {
            return color
        }
        return nil 
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        calendar.appearance.headerDateFormat = "yyyy-MM"
        let dateString : String = dateFormatter1.string(from:date)
        if self.titleDefaultColors.contains(dateString) {
            return .white
        } else {
            return nil
        }
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, borderDefaultColorFor date: Date) -> UIColor? {
        var borderDefaultColors = Dictionary<String, UIColor>();
        borderDefaultColors[self.dateFormatter1.string(from: Date())] = UIColor.blue
        let key = self.dateFormatter1.string(from: date)
        if let color = borderDefaultColors[key] {
            return color
        }
        return appearance.borderDefaultColor
    }
    
    
    
}
