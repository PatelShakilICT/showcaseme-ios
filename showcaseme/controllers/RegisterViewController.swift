//
//  RegisterViewController.swift
//  showcaseme
//
//  Created by MuhammadShakil Patel on 06/04/25.
//

import UIKit

class RegisterViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func registerBtn(_ sender: Any) {
        let main = storyboard?.instantiateViewController(withIdentifier: "main") as! ViewController
        navigationController?.pushViewController(main, animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
