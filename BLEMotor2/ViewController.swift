//
//  ViewController.swift
//  BLEMotor2
//
//  Created by Teruya on 2017/03/29.
//  Copyright © 2017年 Teruya. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController,CBCentralManagerDelegate,CBPeripheralDelegate{
    
    var myCentralManager: CBCentralManager!
    var myTargetPeripheral: CBPeripheral!
    var myTargetService: CBService!
    var myTargetCharacteristic: CBCharacteristic!
    let serviceUuids = [CBUUID(string: "abcd")]
    let characteristicUuids = [CBUUID(string: "12ab")]

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //startボタンを押下した時の処理
    @IBAction func tapStartBtn(_ sender: Any) {
        self.myCentralManager = CBCentralManager(delegate: self, queue: nil, options: nil)
    }
    
    //CBCentralManagerDelegateプロトコルで指定されているメソッド
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("state:\(central.state)")
        switch central.state{
        case .poweredOff:
            print("Bluetooth-Off")
            //BluetoothがOffの時にアラートを出して知らせる
            let bleOffAlert=UIAlertController(title: "警告", message: "bluettothをONにしてください", preferredStyle: .alert)
            bleOffAlert.addAction(
                UIAlertAction(
                    title: "OK",
                    style: .default,
                    handler: nil
                )
            )
            self.present(bleOffAlert, animated: true, completion:nil )
        case .poweredOn:
            print("Bluetooth-On")
            //指定UUIDでPeripheralを検索する
            self.myCentralManager.scanForPeripherals(withServices: self.serviceUuids, options: nil)
        default:
            print("bluetoothが準備中又は無効")
        }
    }
    //peripheralが見つかると呼び出される。
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber)
    {
        self.myTargetPeripheral = peripheral
        //アラートを出してユーザーの接続許可を得る
        let bleOnAlert = UIAlertController(title: "Peripheralを発見",message: "接続します",preferredStyle:.alert)
        bleOnAlert.addAction(
            UIAlertAction(
                title: "OK",
                style: .default,
                //Peripheralへの接続命令
                handler: {(action)->Void in self.myCentralManager.connect(self.myTargetPeripheral, options: nil)}
            )
        )
        bleOnAlert.addAction(
            UIAlertAction(
                title: "cencel",
                style: UIAlertActionStyle.cancel,
                handler: {(action)->Void in
                    print("canceled")
                    self.myCentralManager.stopScan()}
            )
        )
        self.present(bleOnAlert, animated: true, completion: nil)
    }
    
    //Peripheralへの接続が成功した時呼ばれる
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("connected")
        peripheral.delegate = self
        //指定されたUUIDでサービスを検索
        peripheral.discoverServices(serviceUuids)
    }
    //サービスを検索した時に呼び出される
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        peripheral.delegate = self
        self.myTargetService = peripheral.services![0]
        //指定のUUIDでcharacteristicを検索する
        peripheral.discoverCharacteristics(characteristicUuids, for:self.myTargetService)
    }
    //characteristicを検索した時に呼び出される
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let e = error{
            print("error:\(e.localizedDescription)")
        }else{
            myTargetCharacteristic = service.characteristics![0]
            segueToSecondViewController()
        }
    }
    //segueを用いて次のビューへ遷移
    func segueToSecondViewController() {
        //次のビューへ渡すプロパティ
        let targetTuple = (myTargetPeripheral,myTargetCharacteristic)
        self.performSegue(withIdentifier: "mySegue", sender: targetTuple)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mySegue" {
            let secondViewController = segue.destination as! SecondViewController
            secondViewController.targetTuple = sender as! (CBPeripheral,CBCharacteristic)
        }
    }

}

