//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Luis Domingues on 13/08/19.
//  Copyright © 2019 Luis Domingues. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {

    let realm = try! Realm()
    
    var categories: Results<Category>?
    //the type should be set to results because it is the response from realm load data
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
        
        tableView.rowHeight = 80
        tableView.separatorStyle = .none
        
    }
    
    //MARK: tableview data source methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.text = categories?[indexPath.row].name ?? "No categories added yet"
        //cell.delegate = self
        cell.backgroundColor = UIColor(hexString: categories?[indexPath.row].bgColor ?? "000000")
        
        return cell
    }
    
    //MARK: - TableView delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
        //after making destinationVC as the next window, we can grab values from ToDoListViewController
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
    
    //MARK: data manipulation methods - save and load data
    
    func save(category: Category){
        
        do{
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("An error ocurred while trying to load - \(error)")
        }
        
        tableView.reloadData()
    }
    
    func loadCategories(){
        
        categories = realm.objects(Category.self)
        tableView.reloadData()
    }
    
    //MARK: - Delete action
    
    override func updateModel(at indexPath: IndexPath) {
        if let categoryForDel = self.categories?[indexPath.row]{
            do{
                try self.realm.write {
                    self.realm.delete(categoryForDel)
                }
            } catch{
                print(error)
            }
        }
    }
    
    //MARK - add new category
    
    @IBAction func addBtn(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        let alert = UIAlertController(title: "Add new category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
           let newCategory = Category()
            newCategory.name = textField.text!
            newCategory.bgColor = UIColor.randomFlat.hexValue()
            
            self.save(category: newCategory)
            
        }
        
        alert.addAction(action)
        alert.addTextField { (field) in
            textField = field
            textField.placeholder = "Add a new category"
        }
        present(alert, animated: true, completion: nil)
    }
}

