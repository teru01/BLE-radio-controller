//
//  SecondViewController.swift
//  BLEMotor2
//
//  Created by Teruya on 2017/03/29.
//  Copyright © 2017年 Teruya All rights reserved.
//

import UIKit
import CoreBluetooth
import CoreMotion

class SecondViewController: UIViewController,CBPeripheralDelegate{
    var targetTuple: (CBPeripheral,CBCharacteristic)!
    var myTargetPeripheral: CBPeripheral!
    var myTargetService: CBService!
    var myTargetCharacteristic: CBCharacteristic!
    var sliderValue: UInt8 = 4
    var angleValue: UInt8 = 70
    var centralData: Data!
    var tempPitch: Int!
    var prevPitch: Int = 40
    var tempSlider: Int = 4
    var prevSlider: Int = 4
    
    
    @IBOutlet weak var pitchLabel: UILabel!
    @IBOutlet weak var accelLabel: UILabel!
    @IBOutlet weak var mySlider: UISlider!{
        //スライダーを縦表示する
        didSet{
            mySlider.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / -2))
        }
    }
    
    let cmManager = CMMotionManager()
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myTargetPeripheral = targetTuple.0
        myTargetCharacteristic = targetTuple.1
        //モーションセンサが発行するキューの実行間隔(秒)
        cmManager.deviceMotionUpdateInterval = 0.3
        //キューで実行するクロージャを定義
        let handler: CMDeviceMotionHandler = {
            (motionData: CMDeviceMotion?,error: Error?) -> Void in self.motionAnimation(motionData,error)
        }
        //更新で実行するキューを登録してモーションセンサをスタート
        cmManager.startDeviceMotionUpdates(to: OperationQueue.main, withHandler: handler)

    }
    //クロージャの中で実行される
    func motionAnimation(_ motionData:CMDeviceMotion?,_ error:Error?){
        if let motion = motionData{
            //pitchはradで渡されるので度に変換
            var pitch = motion.attitude.pitch/Double.pi*180
            //pitchを-40から40に抑える
            pitch = (pitch < -40) ? -40 : pitch
            pitch = (pitch > 40) ? 40 : pitch
            var predif = 1000
            for i in 0..<40{
                let dif = abs((i*2)-Int(pitch+40))
                if predif-dif > 0{
                    predif = dif
                    tempPitch = i*2
                }
            }
            if (tempPitch != prevPitch){
                //データを送信
                pitchLabel.text = String(tempPitch-40)
                print(tempPitch)
                angleValue = UInt8(tempPitch)
                sendData(sliderValue,angleValue)
            }
            prevPitch = tempPitch
        }
    }
    //スライダーの変化を検知
    @IBAction func changeSlider(_ sender: UISlider) {
        let q = Int(sender.value)
        //tempSliderが0〜8までの値になるよう四捨五入する
        tempSlider = (sender.value-Float(q)) > 0.5 ? q+1 : q
        if tempSlider != prevSlider{
             accelLabel.text = String(tempSlider-4)
             print("slider:\(tempSlider)")
             sliderValue = UInt8(tempSlider)
             sendData(sliderValue,angleValue)
        }
        prevSlider = tempSlider
    }
    
    //データの送信用関数
    func sendData(_ senderSlider:UInt8,_ senderAngle:UInt8){
        if self.myTargetCharacteristic != nil{
            let uintAry = [senderSlider,senderAngle]
            centralData = Data(uintAry)
            myTargetPeripheral.writeValue(centralData, for: myTargetCharacteristic,type:CBCharacteristicWriteType.withResponse)
            print("complete")
        }
    }
    
    
}
