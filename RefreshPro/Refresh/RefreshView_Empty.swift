//
//  RefreshView_Empty.swift
//  RefreshPro
//
//  Created by Myron on 2017/6/12.
//  Copyright © 2017年 Myron. All rights reserved.
//

import UIKit

// MARK: - RefreshView_Empty

class RefreshView_Empty: RefreshView {
    
    /** 是否显示空白视图 */
    @IBInspectable var show: Bool = true {
        didSet {
            if show {
                status_change(to: .normal)
            }
            else {
                status_change(to: .invalid)
            }
        }
    }
    
    // MARK: - Self and Sub Size Update
    
    /** 初始化视图尺寸位置 */
    override func frame_deploy(frame: CGRect, size: CGSize, insert: UIEdgeInsets) {
        self.frame = CGRect(
            x: 0, y: 0,
            width: frame.width,
            height: frame.height
        )
    }
    
    /** 更新视图尺寸位置 */
    override func frame_update(frame: CGRect, size: CGSize, offset: CGPoint, insert: UIEdgeInsets) {
        self.frame = CGRect(
            x: 0, y: 0,
            width: frame.width,
            height: frame.height
        )
        
        if refresh_direction_is_vertical {
            if size.height > 0 && show {
                show = false
            }
            else if size.height == 0 && !show {
                show = true
            }
        }
        else {
            if size.width > 0 && show {
                show = false
            }
            else if size.width == 0 && !show {
                show = true
            }
        }
    }
    
    /** 更新视图偏移位置 */
    override func frame_offset(frame: CGRect, size: CGSize, offset: CGPoint) {
        self.frame.origin.x = offset.x
        self.frame.origin.y = offset.y
    }
    
}
