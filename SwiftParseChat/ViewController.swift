//
//  TableViewController.swift
//  ega
//
//  Created by Runa Alam on 16/06/2015.
//  Copyright (c) 2015 Jesse Hu. All rights reserved.
//

import UIKit

/*class ViewController: UITableViewController {
    
    /* type to represent table items
    `section` stores a `UITableView` section */
    class User: NSObject {
        let name: String
        var section: Int?
        
        init(name: String) {
            self.name = name
        }
    }
    
    // custom type to represent table sections
    class Section {
        var users: [User] = []
        
        func addUser(_ user: User) {
            self.users.append(user)
        }
    }

    // raw user data
    let names = [
        "Clementine",
        "Bessie",
        "Yolande",
        "Tynisha",
        "Ellyn",
        "Trudy",
        "Fredrick",
        "Letisha",
        "Ariel",
        "Bong",
        "Jacinto",
        "Dorinda",
        "Aiko",
        "Loma",
        "Augustina",
        "Margarita",
        "Jesenia",
        "Kellee",
        "Annis",
        "Charlena"]

    // `UIKit` convenience class for sectioning a table
    let collation = UILocalizedIndexedCollation.current()
        

    // table sections
    var sections: [Section] {
        // return if already initialized
        if self._sections != nil {
            return self._sections!
        }
        
        // create users from the name list
        let users: [User] = names.map { name in
            let user = User(name: name)
            user.section = self.collation.section(for: user, collationStringSelector: #selector(getter: FBGraphPerson.n#selector(getter: User.ame))
            return user
        }
        
        // create empty sections
        var sections = [Section]()
        for i in 0..<self.collation.sectionIndexTitles.count {
            sections.append(Section())
        }
        
        // put each user in a section
        for user in users {
            sections[user.section!].addUser(user)
        }
        
        // sort each section
        for section in sections {
            section.users = self.collation.sortedArray(from: section.users, collationStringSelector: #selector(getter: FBGraphPerson.n#selector(getter: User.ame)) as! [User]
        }
        
        self._sections = sections
        return self._sections!
        
    }

    var _sections: [Section]?
    
    // table view data source
    
    override func numberOfSections(in tableView: UITableView)
        -> Int {
            return self.sections.count
    }
    
    override func tableView(_ tableView: UITableView,
        numberOfRowsInSection section: Int)
        -> Int {
            return self.sections[section].users.count
    }
    
    override func tableView(_ tableView: UITableView,
        cellForRowAt indexPath: IndexPath)
        -> UITableViewCell {
            let user = self.sections[indexPath.section].users[indexPath.row]
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath) 
            cell.textLabel!.text = user.name
            return cell
    }

    /* section headers
    appear above each `UITableView` section */
    override func tableView(_ tableView: UITableView,
        titleForHeaderInSection section: Int)
        -> String {
            // do not display empty `Section`s
            if !self.sections[section].users.isEmpty {
                return self.collation.sectionTitles[section] 
            }
            return ""
    }
    
    /* section index titles
    displayed to the right of the `UITableView` */
    func sectionIndexTitlesForTableView(_ tableView: UITableView)
        -> [AnyObject] {
            return self.collation.sectionIndexTitles as [AnyObject]
    }
    
    override func tableView(_ tableView: UITableView,
        sectionForSectionIndexTitle title: String,
        at index: Int)
        -> Int {
            return self.collation.section(forSectionIndexTitle: index)
    }
}
*/
