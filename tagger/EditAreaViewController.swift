//
//  EditAreaViewController.swift
//  tagger
//
//  Created by Paolo Longato on 27/07/2015.
//  Copyright (c) 2015 Paolo Longato. All rights reserved.
//

import UIKit

class EditAreaViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var des: UITextView!
    @IBOutlet weak var picture: UIImageView!
    var area:Area?
    var updateTable:(()->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if let a = area {
            name.text = area!.name
            des.text = area!.des
            picture.image = area!.picture
            
            name.delegate = self
            des.delegate = self
            
            let tap = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
            self.view.addGestureRecognizer(tap)
        }
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        area!.name = name.text
        if let a = updateTable {a()}
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        area!.des = des.text
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
