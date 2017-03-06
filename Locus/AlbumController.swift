//
//  AlbumController.swift
//  
//
//  Created by Nabil K on 2017-01-14.
//
//

import UIKit
import Firebase

class AlbumController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var tableView: UITableView!
    var albumData: [(id: String, name:String)] = []
    var selectedAlbumId: String?
    var selectedAlbumName: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func closeButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pickedAlbum"{
            if let build = segue.destination as? BuildPinViewController{
                build.selectedAlbumId = selectedAlbumId
//                build.albumTextField.text! = selectedAlbumName!
            }
        }
    }
        
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albumData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell") as! AlbumCell
        cell.albumLabel.text! = albumData[indexPath.row].name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedAlbumId = albumData[indexPath.row].id
        selectedAlbumName = albumData[indexPath.row].name
        performSegue(withIdentifier: "pickedAlbum", sender: self)
    }
    



}
