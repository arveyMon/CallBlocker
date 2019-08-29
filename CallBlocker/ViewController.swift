//
//  ViewController.swift
//  CallBlocker
//
//  Created by Agasthyam on 29/08/19.
//  Copyright © 2019 Agasthyam. All rights reserved.
//

import UIKit
import ContactsUI
import CallKit

extension Array where Element: Hashable {
    func difference(from other: [Element]) -> [Element] {
        let thisSet = Set(self)
        let otherSet = Set(other)
        return Array(thisSet.symmetricDifference(otherSet))
    }
}



class ViewController: UITableViewController, CNContactPickerDelegate{
    
    
    var contacts = [CNContact]()
    var selectContacts = [CNContact]()
    var PhoneNumberString = [String]()
    var whiteListString = [String]()
    var blockStrings = [String]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
            contacts = self.getContactFromCNContact()
            for contact in contacts {
                let userPhoneNumbers:[CNLabeledValue<CNPhoneNumber>] = contact.phoneNumbers
                let firstPhoneNumber:CNPhoneNumber = userPhoneNumbers[0].value
                let primaryPhoneNumberStr:String = firstPhoneNumber.stringValue
                self.PhoneNumberString.append(primaryPhoneNumberStr)
                
            
        }
        
        print(PhoneNumberString)
    }
    
    

    
    func getContactFromCNContact() -> [CNContact] {
        
        let contactStore = CNContactStore()
        let keysToFetch = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactGivenNameKey,
            CNContactPhoneNumbersKey
            ] as [Any]
        
        //Get all the containers
        var allContainers: [CNContainer] = []
        do {
            allContainers = try contactStore.containers(matching: nil)
        } catch {
            print("Error fetching containers")
        }
        
        var results: [CNContact] = []
        
        // Iterate all containers and append their contacts to our results array
        for container in allContainers {
            
            let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
            
            do {
                let containerResults = try contactStore.unifiedContacts(matching: fetchPredicate, keysToFetch: keysToFetch as! [CNKeyDescriptor])
                results.append(contentsOf: containerResults)
                
            } catch {
                print("Error fetching results for container")
            }
        }
        
        
        
        return results
    }

    
    
    
    
    
    @IBAction func AddContacts(_ sender: Any) {
        
        onClickPickContact()
        
    }
    
    
    //MARK:- contact picker
    func onClickPickContact(){

        let contactPicker = CNContactPickerViewController()
        contactPicker.delegate = self
        contactPicker.displayedPropertyKeys = [CNContactGivenNameKey, CNContactPhoneNumbersKey]
        
        self.present(contactPicker, animated: true, completion: nil)
        
    }
    
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelectContactProperties contactProperties: [CNContactProperty]) {
        
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contacts: [CNContact]) {
        
        selectContacts = contacts
        for contact in contacts
        {
            let userPhoneNumbers:[CNLabeledValue<CNPhoneNumber>] = contact.phoneNumbers
            let firstPhoneNumber:CNPhoneNumber = userPhoneNumbers[0].value
            let primaryPhoneNumberStr:String = firstPhoneNumber.stringValue
            self.whiteListString.append(primaryPhoneNumberStr)
        }
        blockStrings = PhoneNumberString.difference(from: whiteListString)
        //print(PhoneNumberString)
        //print(whiteListString)
        print(blockStrings)
        self.tableView.reloadData()
     
        
    }
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        
    }
    
    //MARK:- TableView DataSource and Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectContacts.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReuseId", for: indexPath)
        cell.textLabel?.text = selectContacts[indexPath.row].givenName
        return cell
    }
    
    
    

}

