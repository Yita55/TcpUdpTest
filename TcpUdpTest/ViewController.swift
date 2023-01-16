//
//  ViewController.swift
//  TcpUdpTest
//
//  Created by KennethWu on 2023/1/13.
//

import UIKit
import CocoaAsyncSocket

class ViewController: UIViewController, GCDAsyncSocketDelegate {
    
    @IBOutlet weak var bindButton: UIButton!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var portTextField: UITextField!
    @IBOutlet weak var dataTextField: UITextField!
    @IBOutlet weak var messageTextView: UITextView!
    
    var socket: GCDAsyncSocket!

    override func viewDidLoad() {
        super.viewDidLoad()
        // 建立 TCP socket
        socket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
    }

    @IBAction func connectAction(_ sender: UIButton) {
        bindButton.isSelected = !bindButton.isSelected
        bindButton.isSelected ? connect() : stopConnect()
        
        if bindButton.isSelected {
            self.bindButton.tintColor = .gray
        } else {
            self.bindButton.tintColor = .systemBlue
        }
    }
    
    func connect() {
        bindButton.setTitle("Unbind", for: .normal)
        
        do {
            try socket.connect(toHost: addressTextField.text!,
                               onPort: UInt16(portTextField.text!)!,
                               withTimeout: -1)
        } catch {
            showMessage(message: "連線失敗！")
        }
        
        view.endEditing(true)
    }
    
    func stopConnect() {
        bindButton.setTitle("Bind", for: .normal)
        socket.disconnect()
    }
    
    @IBAction func sendMessageAction(_ sender: UIButton) {
        let data = dataTextField.text?.data(using: .unicode)
        
        showMessage(message: "Client: " + dataTextField.text! + "\n")
        socket.write(data!, withTimeout: -1, tag: 0)
        
        view.endEditing(true)
        dataTextField.text = ""
    }
    
    func showMessage(message: String) {
        messageTextView.text = messageTextView.text.appendingFormat("%@\n", message)
    }
    
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        showMessage(message: "連線成功！")
        
        let address = "Server IP:" + "\(host)"
        showMessage(message: address)
        showMessage(message: "---------------------")
        socket.readData(withTimeout: -1, tag: 0)
    }
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        let text = String(data: data, encoding: .unicode)
        
        showMessage(message: "Server: " + text! + "\n")
        socket.readData(withTimeout: -1, tag: 0)
    }
    
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        showMessage(message: "斷開連接！")
    }
}
