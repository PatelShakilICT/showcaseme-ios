//
//  LoginViewController.swift
//  showcaseme
//
//  Created by MuhammadShakil Patel on 06/04/25.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var email: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        checkUserExists()
        // Do any additional setup after loading the view.
    }
    
    func checkUserExists() {
        let def = UserDefaults.standard
        if let token = def.string(forKey: "token") {
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let sceneDelegate = scene.delegate as? SceneDelegate {
                
                let homeVC = self.storyboard?.instantiateViewController(identifier: "main") as! ViewController
                
                let navController = UINavigationController(rootViewController: homeVC)
                
                // Optional: Add transition animation
                UIView.transition(with: sceneDelegate.window!, duration: 0.3, options: [.transitionFlipFromRight], animations: {
                    sceneDelegate.window?.rootViewController = navController
                })
            }
        }

    }
    
    @IBAction func loginBtn(_ sender: Any) {
        
        if(email.text != nil && password.text != nil){
            loginUser()
        }else{
            showAlert(title: "Failed", msg: "Enter Valid Credentials",handler:{_ in})
        }
    }
    
    func showAlert(title : String, msg : String?,handler: @escaping ((UIAlertAction)->Void)){
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default,handler: handler))
        
        self.present(alert,animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func loginUser() {
        guard let url = URL(string: API_URL + "Auth/login") else { return }

        let login = LoginRequest(email: email.text!, password: password.text!)

        guard let body = try? JSONEncoder().encode(login) else { return }
        var obj = UserDefaults.standard

        NetworkManager.shared.request(
            url: url,
            method: .POST,
            body: body,
            type: LoginResponse<UserData>.self
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.status{
                        
                        print(response.data.token)
                        obj.set(response.data.token, forKey: "token")
                        self.showAlert(title: "Login Success", msg: response.message, handler:{ _ in
                            self.navigate()
                                                })
                    }else{
                        print(response.message)
                    }
                case .failure(let error):
                    print("Login failed:", error.localizedDescription)
                    self.showAlert(title: "Login failed", msg: error.localizedDescription,handler: {_ in})
                }
            }
        }
    }
    
    func navigate(){
        let main = storyboard?.instantiateViewController(withIdentifier: "main") as! ViewController
        navigationController?.pushViewController(main, animated: true)
        print("navigation ended")
    }


}
