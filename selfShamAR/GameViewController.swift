//
//  GameViewController.swift
//  selfShamAR
//
//  Created by 覃子轩 on 2017/6/10.
//  Copyright © 2017年 覃子轩. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit
import AVFoundation


class GameViewController: UIViewController {
    
    fileprivate var scnView:SCNView!

    //视频捕捉会话。它是input和output的桥梁。它协调input到output的数据传输
    let captureSession = AVCaptureSession()
    
    var camera:AVCaptureDevice?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.showCamera(.back)//使用后置摄像头.Back
        self.showShip3D(CGRect.init(x: 100, y: 100, width: 200, height: 200))
        self.showLabel()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

// MARK: - 2D-UI
extension GameViewController {
    
    /// 配置摄像机并显示
    ///
    /// - parameter position:
    fileprivate func showCamera(_ position:AVCaptureDevicePosition) {
        //视频输入设备
        let videoDevice = AVCaptureDeviceDiscoverySession.init(deviceTypes: [.builtInWideAngleCamera],
                                                               mediaType: AVMediaTypeVideo, position: position)
        for item in videoDevice!.devices{
            if item.position == position {
                self.camera = item
            }
        }
        
        //设置视频清晰度(可以默认)
        //captureSession.sessionPreset = AVCaptureSessionPreset640x480
        
        //添加视频输入设备
        if let videoInput = try? AVCaptureDeviceInput(device: self.camera) {
            self.captureSession.addInput(videoInput)
        }
        
        //使用AVCaptureVideoPreviewLayer可以将摄像头的拍摄的实时画面显示在viewController(屏幕)上
        let videoLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        videoLayer?.frame = self.view.bounds
        videoLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.view.layer.addSublayer(videoLayer!)
        
        //启动session会话
        self.captureSession.startRunning()
    }
    
    /// 显示2D的标签
    fileprivate func showLabel() {
        
        let showLabel = UILabel.init(frame: CGRect.init(x: 100, y: 300, width: 100, height: 200))
        showLabel.numberOfLines = 0
        showLabel.text = "这是一个2D的标签"
        showLabel.font = UIFont.boldSystemFont(ofSize: 20)
        showLabel.textColor = UIColor.cyan
        self.view.addSubview(showLabel)
        self.view.bringSubview(toFront: showLabel)
        
    }
}

// MARK: - 3D-UI
extension GameViewController {
    
    fileprivate func showShip3D(_ showFrame:CGRect) {

        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
        
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        let ship = scene.rootNode.childNode(withName: "ship", recursively: true)!
        
        ship.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 2, z: 0, duration: 1)))
        
        self.scnView = SCNView.init(frame: showFrame)//self.view as! SCNView
        
        self.scnView.scene = scene

        self.scnView.allowsCameraControl = true

        self.scnView.backgroundColor = UIColor.clear
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.scnView.addGestureRecognizer(tapGesture)
        
        self.view.addSubview(scnView)
        self.view.bringSubview(toFront: scnView)
    }
    
}

// MARK: - Action
extension GameViewController {
    
    @objc fileprivate func handleTap(_ gestureRecognize: UIGestureRecognizer) {

        let p = gestureRecognize.location(in: self.scnView)
        let hitResults = self.scnView.hitTest(p, options: [:])
        if hitResults.count > 0 {
            let result: AnyObject = hitResults[0]
            
            let material = result.node!.geometry!.firstMaterial!
            
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            SCNTransaction.completionBlock = {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                
                material.emission.contents = UIColor.black
                
                SCNTransaction.commit()
            }
            
            material.emission.contents = UIColor.red
            
            SCNTransaction.commit()
        }
    }
    
}

// MARK: - Override
extension GameViewController {
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
}
