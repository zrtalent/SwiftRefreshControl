//
//  RefreshControl.swift
//  SwiftRefreshControl
//
//  Created by Zr on 15/3/9.
//  Copyright (c) 2015年 Tarol. All rights reserved.
//

import UIKit

/**
如果下拉幅度不够，只是显示控件，不会真正刷新数据
如果下拉幅度够大，会自动进入刷新状态，控件不会自动消失

下一步的目标：实际测试中发现，如果想要更改内部视图的显示，首先需要解决一个问题：
- 需要知道用户到底向下拉了多少！
思路：KVO 可以观察内部属性的变化
*/
class RefreshControl: UIRefreshControl {
    
    lazy var refreshView: RefreshView = {
        let v = NSBundle.mainBundle().loadNibNamed("RefreshView", owner: nil, options: nil).last as! RefreshView
        return v
        }()
    
    ///  提示：refresh control 中不要重写 layoutSubviews，本方法调用非常频繁
    override func layoutSubviews() {
        super.layoutSubviews()
        
        println("\(__FUNCTION__)")
    }
    
    /**
    视图的生命周期函数
    
    1. willMoveToSuperview - 与界面无关的
    2. didMoveToSuperview - 与界面无关的
    3. awakeFromNib - 从 xib 加载子视图内部细节，视图的层次结构
    4. willMoveToWindow - 就要显示了
    5. didMoveToWindow - 已经显示了
    6. layoutSubviews - 布局
    */
    override func willMoveToSuperview(newSuperview: UIView?) {
        super.willMoveToSuperview(newSuperview)
        
        println("\(__FUNCTION__)")
    }
    
    override func willMoveToWindow(newWindow: UIWindow?) {
        super.willMoveToWindow(newWindow)
        
        println("\(__FUNCTION__) \(self.frame)")
        
        // 设置刷新视图的大小
        refreshView.frame = self.bounds
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        println("\(__FUNCTION__)")
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        println("\(__FUNCTION__) \(self.frame)")
    }
    
    // MARK: - KVO
    override func awakeFromNib() {
        println("!!!!!!!! \(__FUNCTION__) \(self.frame)")
        self.addSubview(refreshView)
        
        // 添加观察者，观察控件自身位置的变化
        self.addObserver(self, forKeyPath: "frame", options: NSKeyValueObservingOptions.New, context: nil)
    }
    
    deinit {
        // 销毁观察者
        self.removeObserver(self, forKeyPath: "frame")
    }
    
    /**
    观察结果
    1. 向下拉：y 值，逐渐变小
    2. 当 y 值足够小的时候，自动进入刷新状态
    3. 当表格向上滚动，刷新控件是一只存在的，不会被销毁，而且位置会和表格一起运动
    */
    // 正在显示加载的动画效果
    var isLoading = false
    /// 旋转提示图标标记
    var isRotateTip = false
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        
        //        println("\(change) \(self.frame)")
        if self.frame.origin.y > 0 {
            return
        }
        
        // 正在刷新
        if refreshing && !isLoading {
            // 显示记载视图，同时播放旋转动画效果
            refreshView.showLoading()
            
            isLoading = true
            
            return
        }
        
        if self.frame.origin.y < -50 && !isRotateTip {
            //            println("该转身了")
            isRotateTip = true
            refreshView.rotateTipIcon(isRotateTip)
        } else if self.frame.origin.y > -50 && isRotateTip {
            //            println("转回去")
            isRotateTip = false
            refreshView.rotateTipIcon(isRotateTip)
        }
    }
    
    override func endRefreshing() {
        
        // 调用父类方法
        super.endRefreshing()
        
        // 停止动画
        refreshView.stopLoading()
        
        // 修改正在加载标记
        isLoading = false
    }
}

///  刷新控件内部视图
class RefreshView: UIView {
    ///  提示视图
    @IBOutlet weak var tipView: UIView!
    ///  提示图标
    @IBOutlet weak var tipIcon: UIImageView!
    ///  加载视图
    @IBOutlet weak var loadingView: UIView!
    ///  加载图标
    @IBOutlet weak var loadingIcon: UIImageView!
    
    ///  显示加载状态，转轮
    func showLoading() {
        tipView.hidden = true
        loadingView.hidden = false
        
        // 添加动画
        loadingAnimation()
    }
    
    // 加载动画
    /**
    核心动画 - 属性动画 =>
    - 基础动画： fromValue toValue
    - 关键帧动画：values, path
    * 将动画添加到图层
    */
    func loadingAnimation() {
        let anim = CABasicAnimation(keyPath: "transform.rotation")
        
        anim.toValue = 2 * M_PI
        // 重复次数 OC MAX_FLOAT
        anim.repeatCount = MAXFLOAT
        // 转一圈的时间
        anim.duration = 0.5
        
        // 将动画添加到涂层
        loadingIcon.layer.addAnimation(anim, forKey: nil)
    }
    
    ///  停止加载动画
    func stopLoading() {
        // 将动画从涂层中删除
        loadingIcon.layer.removeAllAnimations()
        
        // 恢复视图的显示
        tipView.hidden = false
        loadingView.hidden = true
    }
    
    ///  旋转提示图标
    func rotateTipIcon(clockWise: Bool) {
        
        var angel = CGFloat(M_PI + 0.01)
        if clockWise {
            angel = CGFloat(M_PI - 0.01)
        }
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            // 旋转提示图标 180
            self.tipIcon.transform = CGAffineTransformRotate(self.tipIcon.transform, angel)
        })
    }
}