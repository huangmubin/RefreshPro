//
//  RefreshView_Header.swift
//  RefreshPro
//
//  Created by Myron on 2017/6/7.
//  Copyright © 2017年 Myron. All rights reserved.
//

import UIKit

// MARK: - Extension ScrollView

extension UIScrollView {
    
    func refresh_header(tag: Int = 501) -> RefreshView_Header? {
        return viewWithTag(tag) as? RefreshView_Header
    }
    
}

// MARK: - RefreshView Header

class RefreshView_Header: RefreshView {
    
    // MARK: - Init Deploy
    
    /** 初始化完毕时调用，用于配置视图属性 */
    override func deploy_at_init() {
        super.deploy_at_init()
        self.identifier = "RefreshView_Header"
        self.tag = 501
    }

    // MARK: - Status Actions
    
    /** 设置状态成为 normal */
    override func status_set(normal complete: (() -> Void)?) {
        if var inset = self.scroll_view?.contentInset {
            if self.refresh_direction_is_vertical {
                inset.top -= self.refresh_space
            }
            else {
                inset.left -= self.refresh_space
            }
            UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 10, options: .curveLinear, animations: {
                self.scroll_view?.contentInset = inset
            }, completion: { _ in
                super.status_set(normal: complete)
            })
        }
    }
    
    // MARK: - Self and Sub Size Update
    
    /** 初始化视图尺寸位置 */
    override func frame_deploy(frame: CGRect, size: CGSize, insert: UIEdgeInsets) {
        if refresh_direction_is_vertical {
            self.frame = CGRect(
                x: 0,
                y: 0,
                width: frame.width,
                height: 0
            )
        }
        else {
            self.frame = CGRect(
                x: 0,
                y: 0,
                width: 0,
                height: frame.height
            )
        }
    }
    
    /** 更新视图尺寸位置 */
    override func frame_update(frame: CGRect, size: CGSize, offset: CGPoint) {
        if refresh_direction_is_vertical {
            self.frame = CGRect(
                x: 0,
                y: offset.y,
                width: frame.width,
                height: -offset.y
            )
        }
        else {
            self.frame = CGRect(
                x: offset.x,
                y: 0,
                width: -offset.x,
                height: frame.height
            )
        }
    }
    
    /** 更新视图偏移位置 */
    override func frame_offset(frame: CGRect, size: CGSize, offset: CGPoint) {
        // 更新尺寸
        if refresh_direction_is_vertical {
            self.frame.origin.y    = offset.y
            self.frame.size.height = -offset.y
        }
        else {
            self.frame.origin.x   = offset.x
            self.frame.size.width = -offset.x
        }
        
        if scroll_view?.isDragging == true {
            // 拖动状态: 修改进度
            switch status {
            case .normal, .draging(_):
                if refresh_space == 0 {
                    break
                }
                else {
                    status = .draging(-offset.y / refresh_space)
                }
            default:
                break
            }
        }
        else {
            // 松手状态: 判断是否进入刷新，并弹回
            switch status {
            case .draging(let value):
                if value <= 1 {
                    status = .normal
                }
                else {
                    status = .refresh
                    if refresh_direction_is_vertical {
                        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 10, options: .curveLinear, animations: {
                            if var inset = self.scroll_view?.contentInset {
                                inset.top = inset.top + self.refresh_space
                                self.scroll_view?.contentInset = inset
                            }
                        }, completion: { _ in
                            self.status = .refreshing
                        })
                    }
                    else {
                        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 10, options: .curveLinear, animations: {
                            if var inset = self.scroll_view?.contentInset {
                                inset.left = inset.left + self.refresh_space
                                self.scroll_view?.contentInset = inset
                            }
                        }, completion: { _ in
                            self.status = .refreshing
                        })
                    }
                }
            default:
                break
            }
        }
    }
}
