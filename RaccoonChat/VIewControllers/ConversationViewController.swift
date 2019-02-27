//
//  ConversationViewController.swift
//  RaccoonChat
//
//  Created by Анна Якусевич on 25/02/2019.
//  Copyright © 2019 Hanna Yakusevych. All rights reserved.
//

import UIKit

class ConversationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  
  
  @IBOutlet weak var tableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.tableView.delegate = self
    self.tableView.dataSource = self
    
    self.tableView.reloadData()
    
    
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
  }

  // MARK: - Table view data source

  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return messages.count
  }

  // MARK: - Some messages
  struct Message {
    var text: String? = nil
    var isInput = false
  }
  let messages = [Message(text: """
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed pretium in risus et posuere. Vestibulum venenatis, nunc sit amet finibus dignissim, nisl mauris malesuada metus, id fringilla neque arcu ultrices odio. Maecenas maximus turpis ut augue rutrum venenatis. Suspendisse tincidunt, libero quis ultricies egestas, quam velit viverra velit, a auctor ligula magna a elit. Quisque id libero sodales arcu convallis malesuada. Vestibulum mattis ipsum felis, rhoncus iaculis dui viverra at. Donec lacinia, risus in finibus mattis, leo libero molestie urna, at pellentesque turpis ligula gravida lorem. Praesent eu consectetur neque, ac tincidunt ipsum. Curabitur faucibus enim mi, fringilla tempus justo volutpat non. Nunc vel lectus mollis, bibendum purus sed, finibus metus.
""", isInput: true), Message(text: "Hi! How are you", isInput: false),
                  Message(text: "Good, thanks. How are you?", isInput: true), Message(text: """
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque nunc dui, vehicula sit amet urna in, mattis consectetur risus. Cras at sodales odio. Sed tristique nisl vitae efficitur ullamcorper. Interdum et malesuada fames ac ante ipsum primis id.
""", isInput: false)]
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let identifier = messages[indexPath.row].isInput ? "InputMessageCell" : "OutputMessageCell"
    let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! MessageCell
    cell.textMessage = messages[indexPath.row].text
    cell.sizeToFit()

    return cell
  }
  
  
  
  // MARK: - Table view delegate
  /*
  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let header = UILabel(frame: CGRect(x: 16, y: 16, width: 100, height: 100))
    header.text = "Name"
    header.textAlignment = .center
    header.font = UIFont.boldSystemFont(ofSize: 20)
    header.backgroundColor = #colorLiteral(red: 0.9994240403, green: 0.9855536819, blue: 0, alpha: 1)
    return header
  }
 */
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
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

}
