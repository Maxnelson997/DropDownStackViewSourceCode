//
//  ViewController.swift
//  DropDownCells
//
//  Created by Max on 2/15/17.
//  Copyright © 2017 Max Nelson. All rights reserved.
//

import UIKit
import CoreData

struct JobStruct {
    var title:String!
    var description:String!
    var salary:String!
    var color:UIColor!
}


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var tableView:UITableView!
    var jobs:[JobStruct] = []
    let appleTheme:[UIColor] =  [UIColor.init(red: 166/255, green: 63/255, blue: 149/255, alpha: 1), UIColor.init(red: 122/255, green: 131/255, blue: 156/255, alpha: 1), UIColor.init(red: 78/255, green: 166/255, blue: 157/255, alpha: 1), UIColor.init(red: 119/255, green: 191/255, blue: 99/255, alpha: 1), UIColor.init(red: 217/255, green: 67/255, blue: 67/255, alpha: 1)]
    let background_color = UIColor.init(red: 50/255, green: 54/255, blue: 64/255, alpha: 1)
 
    var t_count:Int = 0
    var lastCell: StackViewCell = StackViewCell()
    var button_tag:Int = -1
    
    var managedObjectContext:NSManagedObjectContext!
    var coreDataJobs = [Job]()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = background_color

        jobs.append(JobStruct(title: "Web Developer", description: "Designs and or develops websites", salary: "$78,257", color: appleTheme[0]))
        jobs.append(JobStruct(title: "Back End Developer", description: "Designs structure backends and API's", salary: "$117,230", color: appleTheme[1]))
        jobs.append(JobStruct(title: "iOS Developer", description: "Develops and or designs iOS applications for iPhones and iPads", salary: "$117,774", color: appleTheme[2]))
        jobs.append(JobStruct(title: "Android Developer", description: "Develops and or designs Android applications for Android devices", salary: "$115,332", color: appleTheme[3]))
        jobs.append(JobStruct(title: "Software Engineer", description: "Develops and Designs Software", salary: "$100,143", color: appleTheme[4]))
        
        
        tableView = UITableView(frame: view.frame)
        tableView.layer.frame.size.height = view.frame.height * 1.5
        tableView.frame.origin.y += 125
        tableView.register(UINib(nibName: "StackViewCell", bundle: nil), forCellReuseIdentifier: "StackViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        tableView.backgroundColor = background_color
        view.addSubview(tableView)
        

        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 0))
        toolBar.sizeToFit()
        toolBar.frame.origin.y = view.frame.height - toolBar.frame.size.height
        let addItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(self.addJob))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        toolBar.setItems([flexSpace, addItem, flexSpace], animated: true)
        view.addSubview(toolBar)
        
        
        managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        loadData()
    }
    
    func addJob() {
        //create core data object
        let jobItem = Job(context: managedObjectContext)
        
        
        let inputAlert = UIAlertController(title: "Add Job", message: "Create a new job core data object", preferredStyle: .alert)
        inputAlert.addTextField(configurationHandler: {(textfield:UITextField!) in
            textfield.placeholder = "Job Title"
        })
        
        inputAlert.addTextField(configurationHandler: {(textfield:UITextField!) in
            textfield.placeholder = "Job Salary"
        })
        
        inputAlert.addTextField(configurationHandler: {(textfield:UITextField!) in
            textfield.placeholder = "Job Description"
        })
        inputAlert.addAction(UIAlertAction(title: "Save", style: .default, handler: { (action:UIAlertAction) in
            let titleField = inputAlert.textFields?[0]
            let salaryField = inputAlert.textFields?[1]
            let infoField = inputAlert.textFields?[2]
            
            if titleField?.text != "" {
                jobItem.title = titleField?.text
                
            }
            if salaryField?.text != "" {
                jobItem.salary = salaryField?.text
            }
            if infoField?.text != "" {
                jobItem.info = infoField?.text
            }
            
            do {
                try self.managedObjectContext.save()
                self.loadData()
            } catch  {
                print("Could not load data \(error.localizedDescription)")
            }
            
            
        }))
        
        inputAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(inputAlert, animated: true, completion: nil)
    }
    
    func loadData(){
        let jobRequest:NSFetchRequest<Job> = Job.fetchRequest()
        
        do {
            coreDataJobs = try managedObjectContext.fetch(jobRequest)

            self.tableView.reloadData()
        } catch {
            print("Could not load data from database \(error.localizedDescription)")
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == button_tag {
            return 320
        } else {
            return 60
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coreDataJobs.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StackViewCell", for: indexPath) as! StackViewCell
        let job = coreDataJobs[indexPath.row]
        if !cell.cellExists {
            cell.textView.text = job.info
            cell.salary.text = "Salary: \(job.salary!)"
            cell.name.text = "Title: \(job.title!)"
            cell.open.setTitle(job.title!, for: .normal)
            cell.openView.backgroundColor = jobs[indexPath.row].color
            cell.stuffView.backgroundColor = jobs[indexPath.row].color
            cell.open.tag = t_count
            cell.open.addTarget(self, action: #selector(cellOpened(sender:)), for: .touchUpInside)
            t_count += 1
            cell.cellExists = true
        }
        

        
        UIView.animate(withDuration: 0) {
            cell.contentView.layoutIfNeeded()
        }
        
        return cell
    }
    
    func cellOpened(sender:UIButton) {
        self.tableView.beginUpdates()
        
        let previousCellTag = button_tag
        
        if lastCell.cellExists {
            self.lastCell.animate(duration: 0.2, c: {
                self.view.layoutIfNeeded()
            })
            
            if sender.tag == button_tag {
                button_tag = -1
                lastCell = StackViewCell()
            }
        }
        
        if sender.tag != previousCellTag {
            button_tag = sender.tag
            
            lastCell = tableView.cellForRow(at: IndexPath(row: button_tag, section: 0)) as! StackViewCell
            self.lastCell.animate(duration: 0.2, c: {
                self.view.layoutIfNeeded()
            })
        
        }
        self.tableView.endUpdates()
    }
    

    
    
    
    

}

