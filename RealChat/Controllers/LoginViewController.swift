//
//  LoginViewController.swift
//  RealChat
//
//  Created by Jack Sp@rroW on 11/08/2018.
//  Copyright © 2018 Jack Sp@rroW. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage


class LoginViewController: UIViewController, UITextFieldDelegate{
    
    weak var messagesController: MessagesController?
    
    //окошко для ввода даннных
    let inputsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()

    //кнопка регистрации
    let LoginRegisterButtonView: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Регистрация", for: .normal)
        //btn.setTitleColor(UIColor.white, for: .normal)
        btn.setTitleColor(UIColor(r: 46, g: 163, b: 112), for: .normal)
        btn.titleLabel?.font = UIFont.init(name: "HelveticaNeue-Thin", size: 25)
        btn.translatesAutoresizingMaskIntoConstraints = false
        //btn.backgroundColor = UIColor(r: 46, g: 97, b: 163)
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 5
        btn.layer.masksToBounds = true
        btn.addTarget(self, action: #selector(handleLoginRegister), for: .touchUpInside)
        return btn
    }()
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    func handleLogin(){
        
         guard let email = emailTextField.text, let password = passwordTextField.text else {
            print("form is not valid")
            return
        }
        Auth.auth().signIn(withEmail: email , password: password) { (user, error) in
            if error != nil {
                print(error!)
                return
            }

            //добавим текущего пользователя в navigationItem
                let uid = Auth.auth().currentUser?.uid
            Database.database().reference().child("users").child(uid!).observeSingleEvent(of: .value) { (snapshot) in

               self.messagesController?.fetchUserAndSetupNavBarTitle()
               self.dismiss(animated: true, completion: nil)
                
            }
            
            
            
            
        }
        
    }
    
    @objc func handleLoginRegister() {
        if loginRegisterSegmentedControl.selectedSegmentIndex == 0 {
            handleLogin()
            } else {
            handleRegister()
        }
    }
    

 
    //поле ввода Имени
    let nameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "имя"
        //tf.autocapitalizationType = .none
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    //поле ввода email
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "эл. почта"
        tf.autocapitalizationType = .none
        tf.keyboardType = .emailAddress
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    //поле ввода Имени
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "пароль"
        tf.autocapitalizationType = .none
        tf.isSecureTextEntry = true  
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let nameFieldSeparator: UIView = {
        let sp = UIView()
        sp.backgroundColor = UIColor(r: 220, g: 220, b: 200)
        sp.translatesAutoresizingMaskIntoConstraints = false
        return sp
    }()
    
    let emailFieldSeparator: UIView = {
        let sp = UIView()
        sp.backgroundColor = UIColor(r: 220, g: 220, b: 200)
        sp.translatesAutoresizingMaskIntoConstraints = false
        return sp
    }()
    
   lazy var profileImageView:UIImageView = {
        let pf = UIImageView()
        pf.image = UIImage(named: "profileImage")
        pf.contentMode = .scaleAspectFill
    //print("pf.frame.height\(pf.frame.height)")
       // pf.layer.cornerRadius = 30 //pf.frame.height / 2
        //pf.clipsToBounds = true
        pf.translatesAutoresizingMaskIntoConstraints = false
        pf.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView) ))
        pf.isUserInteractionEnabled = true
        
        
        return pf
    }()
    

    
    lazy var loginRegisterSegmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Войти","Регистрация"])
        let font = UIFont.init(name: "HelveticaNeue-Thin", size: 20)
        sc.setTitleTextAttributes([NSAttributedString.Key.font: font as Any],
                                   for: .normal)
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.tintColor = .white
        sc.selectedSegmentIndex = 1
        sc.addTarget(self, action: #selector(handleLoginRegisterChange), for: .valueChanged)
        return sc
    }()
    
    @objc func handleLoginRegisterChange() {
        let title = loginRegisterSegmentedControl.titleForSegment(at: loginRegisterSegmentedControl.selectedSegmentIndex)
        LoginRegisterButtonView.setTitle(title, for: .normal)
        
        inpuputsContainerViewHeigthAnchor?.constant = loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 100 : 150

        nameTextFieldHeigthAnchor?.isActive = false
        nameTextFieldHeigthAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 0 : 1/3)
        nameTextField.isHidden = loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? true : false
        nameTextFieldHeigthAnchor?.isActive = true

        emailTextFieldHeigthAnchor?.isActive = false
        emailTextFieldHeigthAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        emailTextFieldHeigthAnchor?.isActive = true

        passwordTextFieldHeigthAnchor?.isActive = false
        passwordTextFieldHeigthAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        passwordTextFieldHeigthAnchor?.isActive = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        passwordTextField.delegate = self
        
        
        self.view.addSubview(inputsContainerView)
        self.view.addSubview(LoginRegisterButtonView)
        self.view.addSubview(profileImageView)
        self.view.addSubview(loginRegisterSegmentedControl)
        
        setupInputsContainerViewConstraints()
        setupRegisterButtonViewConstraints()
        setupProfileImageViewConstraint()
        setupLoginRegisterSegmentedControl()
        
        self.view.backgroundColor = UIColor(r: 46, g: 163, b: 112)
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        

    }
    
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
    
    //установка констрейтов для loginRegisterSegmentedControl
    func setupLoginRegisterSegmentedControl() {
        loginRegisterSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterSegmentedControl.bottomAnchor.constraint(equalTo: inputsContainerView.topAnchor, constant: -12).isActive = true
        loginRegisterSegmentedControl.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor, multiplier: 1).isActive = true
        loginRegisterSegmentedControl.heightAnchor.constraint(equalToConstant: 36).isActive = true
   
    }
    
    var inpuputsContainerViewHeigthAnchor: NSLayoutConstraint?
    var nameTextFieldHeigthAnchor: NSLayoutConstraint?
    var emailTextFieldHeigthAnchor: NSLayoutConstraint?
    var passwordTextFieldHeigthAnchor: NSLayoutConstraint?
    
    
    //установка констрейтов для inputsContainerView
    func setupInputsContainerViewConstraints() {
        inputsContainerView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        inputsContainerView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        inputsContainerView.widthAnchor.constraint(equalTo: self.view.widthAnchor, constant: -24).isActive = true
        inpuputsContainerViewHeigthAnchor = inputsContainerView.heightAnchor.constraint(equalToConstant: 150)
        inpuputsContainerViewHeigthAnchor?.isActive = true
        
        
        inputsContainerView.addSubview(nameTextField)
        inputsContainerView.addSubview(emailTextField)
        inputsContainerView.addSubview(passwordTextField)
        
        inputsContainerView.addSubview(nameFieldSeparator)
        inputsContainerView.addSubview(emailFieldSeparator)
        
        nameTextField.topAnchor.constraint(equalTo: inputsContainerView.topAnchor).isActive = true
        nameTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 8).isActive = true
        nameTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        nameTextFieldHeigthAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        nameTextFieldHeigthAnchor?.isActive = true
        
        emailTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        emailTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 8).isActive = true
        emailTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        emailTextFieldHeigthAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        emailTextFieldHeigthAnchor?.isActive = true
        
        passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        passwordTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 8).isActive = true
        passwordTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        passwordTextFieldHeigthAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        passwordTextFieldHeigthAnchor?.isActive = true
        
        nameFieldSeparator.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        nameFieldSeparator.leftAnchor.constraint(equalTo: nameTextField.leftAnchor).isActive = true
        nameFieldSeparator.widthAnchor.constraint(equalTo: nameTextField.widthAnchor, constant: -20).isActive = true
        nameFieldSeparator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        emailFieldSeparator.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        emailFieldSeparator.leftAnchor.constraint(equalTo: emailTextField.leftAnchor).isActive = true
        emailFieldSeparator.widthAnchor.constraint(equalTo: emailTextField.widthAnchor, constant: -20).isActive = true
        emailFieldSeparator.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
    //установка констрейтов для registerButtonView
    func setupRegisterButtonViewConstraints() {
        LoginRegisterButtonView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        LoginRegisterButtonView.topAnchor.constraint(equalTo: inputsContainerView.bottomAnchor, constant: 12).isActive = true
        LoginRegisterButtonView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        LoginRegisterButtonView.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    //установка констрейнтов для профильного риcунка
    func setupProfileImageViewConstraint(){
        let width: CGFloat = 140, heigth: CGFloat = 140
        profileImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: loginRegisterSegmentedControl.topAnchor, constant: -12) .isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: width).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: heigth).isActive = true
        profileImageView.layer.cornerRadius = heigth / 2
        profileImageView.clipsToBounds = true
    }
    
    

    //белый статус бар
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}
