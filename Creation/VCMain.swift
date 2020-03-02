//
//  ViewController.swift
//  Creation
//
//  Created by Nazar Khatsko on 1/28/20.
//  Copyright © 2020 Nazar Khatsko. All rights reserved.
//

import UIKit

class VCMain: UIViewController {
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var collectionView: UICollectionView!
    
    @IBOutlet var viewCreate: UIView!
    @IBOutlet var textName: UITextField!
    @IBOutlet var buttonCreate: UIButton!
    
    @IBOutlet weak var buttonAdd: UIButton!
    
    var names:[String] = []
    var pictures:[NSData] = []
        
    var edit:Bool = false
    
    var searching:Bool = false
    var searchNames:[String] = []
    var searchPictures:[NSData] = []
    
    var index:Int = 0
        
    @IBAction func buttonEditAction_TouchUp(_ sender: UIButton) {
        if edit {
            edit = false
            sender.setImage(#imageLiteral(resourceName: "edit-off"), for: .normal)
        } else {
            edit = true
            sender.setImage(#imageLiteral(resourceName: "edit-on"), for: .normal)
        }
        collectionView.reloadData()
    }
    
    @IBAction func buttonAddAction_TouchUp(_ sender: UIButton) {
        if sender.transform == .identity {
            viewCreate.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            UIView.animate(withDuration: 0.3, delay: 0, options: [], animations: {
                sender.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 4))
                self.viewCreate.transform = .identity
                self.viewCreate.alpha = 1
            }, completion: nil)
        } else {
            UIView.animate(withDuration: 0.3, delay: 0, options: [], animations: {
                sender.transform = .identity
                self.viewCreate.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                self.viewCreate.alpha = 0
            }, completion: nil)
        }
    }
    
    @IBAction func buttonCreateAction_TouchUp(_ sender: UIButton) {
        if textName.text != "" {
            UIView.animate(withDuration: 0.3, delay: 0, options: [], animations: {
                self.viewCreate.transform = CGAffineTransform(translationX: 0, y: UIScreen.main.bounds.height)
                self.buttonAdd.transform = .identity
            }, completion: nil)
            
            names.append(textName.text!)
            let data:NSData = UIImage(named: "null.png")!.pngData()! as NSData
            pictures.append(data)
            collectionView.reloadData()
            
            UserDefaults.standard.set(names, forKey: "key_names")
            UserDefaults.standard.set(pictures, forKey: "key_pictures")
            UserDefaults.standard.synchronize()
            
            textName.text = ""
            textName.resignFirstResponder()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "id_segue" {
            if let destinationVC = segue.destination as? VCDraw {
                destinationVC.names = names
                destinationVC.pictures = pictures
                destinationVC.index = index
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let data = UserDefaults.standard.object(forKey: "key_names") as? [String] { names = data }
        if let data = UserDefaults.standard.object(forKey: "key_pictures") as? [NSData] { pictures = data }
                
        collectionView.register(UINib.init(nibName: "CVCMain", bundle: nil), forCellWithReuseIdentifier: "id_cell")
    }
}

extension VCMain: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searching ? searchNames.count : names.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "id_cell", for: indexPath) as! CVCMain
        cell.buttonRemove.addTarget(self, action: #selector(buttonRemoveAction_TouchUp(sender:)), for: .touchUpInside)
        cell.buttonSegue.addTarget(self, action: #selector(buttonSegueAction_TouchUp(sender:)), for: .touchUpInside)
        
        cell.labelName.text = searching ? searchNames[indexPath.row] : names[indexPath.row]
        cell.imagePicture.image = searching ? UIImage(data: searchPictures[indexPath.row] as Data)! : UIImage(data: pictures[indexPath.row] as Data)!
        
        cell.buttonRemove.isHidden = edit ? false : true
        cell.buttonSegue.isHidden = edit ? true : false
        cell.buttonRemove.tag = indexPath.row
        cell.buttonSegue.tag = indexPath.row
        
        return(cell)
    }
    
    @objc func buttonRemoveAction_TouchUp(sender: UIButton) {
        let controller = UIAlertController(title: "Remove Cell", message: "You really want to delete the cell", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .default) { (alert) in }
        let remove = UIAlertAction(title: "Remove", style: .destructive) { (alert) in
            self.names.remove(at: sender.tag)
            self.pictures.remove(at: sender.tag)
            self.collectionView.reloadData()
            
            UserDefaults.standard.set(self.names, forKey: "key_names")
            UserDefaults.standard.set(self.pictures, forKey: "key_pictures")
            UserDefaults.standard.synchronize()
        }
        controller.addAction(cancel)
        controller.addAction(remove)
        present(controller, animated: true, completion: nil)
    }
    
    @objc func buttonSegueAction_TouchUp(sender: UIButton) {
        index = sender.tag
        performSegue(withIdentifier: "id_segue", sender: nil)
    }
}

extension VCMain: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchNames = names.filter({$0.prefix(searchText.count) == searchText})
        searching = true
        
        if !searchNames.isEmpty {
            searchPictures.removeAll()
            for i in 0...searchNames.count - 1 {
                for n in 0...names.count - 1 {
                    if searchNames[i] == names[n] {
                        searchPictures.append(pictures[n])
                    }
                }
            }
        }
    
        collectionView.reloadData()
        searchBar.showsCancelButton = true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
        searching = false
        collectionView.reloadData()
    }
}

extension VCMain: UITextFieldDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textName.resignFirstResponder()
        return true
    }
}
