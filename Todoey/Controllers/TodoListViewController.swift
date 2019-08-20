//
//  ViewController.swift
//  Todoey
//
//  Created by Luis Domingues on 02/08/19.
//  Copyright © 2019 Luis Domingues. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    
    var itemArray = [Item]()
    var selectedCategory : Category? {
        didSet{
            loadItems()
            
            //load items here will make sure that selected category has already a category
            //retrieved from Categoryvc
        }
    }
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    //this will make an instance of an Appdelegate object to give access to persistent container
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        self.searchBar.delegate = self
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //setting the number of rows in table view
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = itemArray[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        cell.textLabel?.text = item.title
        cell.accessoryType = item.done ? .checkmark : .none
        
        if item.done == true{
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        //print(itemArray[indexPath.row])
        //reversing the state between true and false
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        saveItems()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK - Add new items
    
    @IBAction func addBtnPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        let alert = UIAlertController(title: "Add a new todoey", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add item", style: .default) { (action) in
         
        //creating a new obj from the DataBase model
        let newItem = Item(context: self.context)
            newItem.title = textField.text!
            newItem.done = false
            newItem.parentCategory = self.selectedCategory
            //.parentCategory is the relationship between the classes - set on DataModel
            

            //what happens when the btn is clicked
            self.itemArray.append(newItem)
            self.saveItems()
           
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func saveItems () {

        do{
            try context.save()
        } catch {
            print(error)
        }
        
        
        self.tableView.reloadData()        
    }

    //the equal signs give the first argument a default parameter
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
        
       let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }

        do{
            itemArray = try context.fetch(request) //we always use context to make something on the DataModel
        } catch{
            print(error)
        }
        
        tableView.reloadData()
    }
    
}


//MARK: searchbar delegate methods
extension TodoListViewController : UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        
        //use this to check if the title contains the value retrieved from searchbar.text
        //the %@ will indicate what need to substitute with the args - searchbar.text
        //nspredicate comes from objc code. Is basically a fundation class that specifies how data
        //should be query
        //it is like a sql select
        //to retrieve data from the database
        
        //the [cd] is used to eliminate the case and diacritic sensitive
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        //title is the atribute of the item fetched from the request
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]

        loadItems(with: request, predicate: predicate)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //use this function to return the value before the search starts
        if searchBar.text?.count == 0{
            loadItems()
            
            
            DispatchQueue.main.async { //this will set the resign to the main thread
                searchBar.resignFirstResponder()//will take off the search bar from the main thread
                //means that when the user clicks on "x", the keyboard will disappear - also the words.
            }
            
        }
    }
}
