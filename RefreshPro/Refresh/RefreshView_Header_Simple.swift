//
//  RefreshView_Header_Simple.swift
//  RefreshPro
//
//  Created by Myron on 2017/6/7.
//  Copyright © 2017年 Myron. All rights reserved.
//

import UIKit

// MARK: - Extension ScrollView

extension UIScrollView {
    
    func header_simple(tag: Int = 501) -> RefreshView_Header_Simple? {
        return viewWithTag(tag) as? RefreshView_Header_Simple
    }
    
}

// MARK: - RefreshView_Header_Simple

class RefreshView_Header_Simple: RefreshView_Header {
    
    // MARK: - Sub Views
    
    var info_text = UILabel()
    var time_text = UILabel()
    var hint_image = UIImageView()
    var hint_activity = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
    
    // MARK: - View Datas
    
    var time: Date = Date() {
        didSet {
            time_text.text = "\(text_time_prefix): \(time_format.string(from: time))"
            time_text.sizeToFit()
        }
    }
    var time_format: DateFormatter = {
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return format
    }()

    // MARK: - Init Deploy
    
    /** 初始化完毕时调用，用于配置视图属性 */
    override func deploy_at_init() {
        super.deploy_at_init()
        
        identifier = "RefreshView_Header_Simple"
        
        addSubview(info_text)
        addSubview(time_text)
        addSubview(hint_image)
        addSubview(hint_activity)
        
        info_text.text = text_normal
        
        time_text.font = UIFont.boldSystemFont(ofSize: UIFont.systemFontSize - 2)
        time_text.textColor = UIColor.darkGray
        time_text.text = "---"
        
        hint_image.image = image_draging
        hint_image.contentMode = .scaleAspectFit
        hint_image.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        hint_activity.color = UIColor.black
    }
    
    // MARK: - Status Actions
    
    override func status_fully() {
        self.hint_image.isHidden = true
        self.info_text.text = self.text_fully
        self.frame_subviews_update(size: self.frame)
    }
    
    override func status_normal(complete: (() -> Void)?) {
        super.status_normal(complete: {
            self.hint_image.isHidden    = false
            self.hint_image.image       = self.image_draging
            self.hint_image.transform = CGAffineTransform(rotationAngle: 0)
            
            self.info_text.text = self.text_normal
            
            self.frame_subviews_update(size: self.bounds)
        })
    }
    
    override func status_draging(value: CGFloat) {
        super.status_draging(value: value)
        if value >= 1 {
            let text = text_draging
            if info_text.text != text {
                self.info_text.text = text
                self.frame_subviews_update(size: self.frame)
                UIView.animate(withDuration: 0.25, animations: {
                    self.hint_image.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
                })
            }
        }
        else {
            let text = text_normal
            if info_text.text != text {
                self.info_text.text = text
                self.frame_subviews_update(size: self.frame)
                UIView.animate(withDuration: 0.25, animations: {
                    self.hint_image.transform = CGAffineTransform(rotationAngle: 0)
                })
            }
        }
    }
    
    override func status_refreshing() {
        hint_image.isHidden = true
        hint_activity.isHidden = false
        hint_activity.startAnimating()
        info_text.text = text_refreshing
        frame_subviews_update(size: bounds)
    }
    
    override func status_refreshed(result: Bool, data: Any?) {
        hint_activity.isHidden = true
        hint_activity.stopAnimating()
        
        hint_image.isHidden    = false
        hint_image.image = result ? image_success : image_error
        hint_image.transform = CGAffineTransform(rotationAngle: 0)
        
        info_text.text = result ? text_success : text_error
        
        time = Date()
        
        frame_subviews_update(size: bounds)
        
        super.status_refreshed(result: result, data: data)
    }
    
    // MARK: - Self and Sub Size Update
    
    /** 更新子视图的尺寸 */
    override func frame_subviews_update(size: CGRect) {
        super.frame_subviews_update(size: size)
        info_text.sizeToFit()
        time_text.sizeToFit()
        let center = CGPoint(
            x: bounds.width / 2,
            y: bounds.height / 2
        )
        let size = CGSize(
            width: info_text.frame.width > time_text.frame.width ? info_text.frame.width : time_text.frame.width,
            height: info_text.frame.height + time_text.frame.height + 8
        )
        info_text.center = CGPoint(
            x: center.x,
            y: center.y - size.height / 2 + info_text.frame.height / 2
        )
        time_text.center = CGPoint(
            x: center.x,
            y: center.y + size.height / 2 - time_text.frame.height / 2
        )
        hint_image.center = CGPoint(
            x: center.x - size.width / 2 - 23,
            y: center.y
        )
        hint_activity.center = hint_image.center
    }
    
}
