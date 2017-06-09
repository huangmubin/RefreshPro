//
//  RefreshView_Footer.swift
//  RefreshPro
//
//  Created by Myron on 2017/6/8.
//  Copyright © 2017年 Myron. All rights reserved.
//

import UIKit

// MARK: - Extension ScrollView

extension UIScrollView {
    
    func refresh_footer(tag: Int = 502) -> RefreshView_Footer? {
        return viewWithTag(tag) as? RefreshView_Footer
    }
    
}

// MARK: - RefreshView Footer

class RefreshView_Footer: RefreshView {
    
    // MARK: - Init Deploy
    
    /** 初始化完毕时调用，用于配置视图属性 */
    override func deploy_at_init() {
        super.deploy_at_init()
        self.identifier = "RefreshView_Footer"
        self.tag = 502
        self.refreshed_animation_time = 0.5
    }
    
    // MARK: - Status Actions
    
    /** 设置状态成为 normal */
    override func status_set(normal complete: (() -> Void)?) {
        if var inset = self.scroll_view?.contentInset {
            if self.refresh_direction_is_vertical {
                inset.bottom -= self.refresh_space
            }
            else {
                inset.right -= self.refresh_space
            }
            UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 10, options: .curveLinear, animations: {
                self.scroll_view?.contentInset = inset
            }, completion: { _ in
                super.status_set(normal: complete)
            })
        }
    }
    
    /** 设置状态成为 refresh，并且进入刷新状态，留给 Footer, Header 视图自己实现 */
    override func status_set(refesh_to_refeshing complete: (() -> Void)?) {
        status = .refresh
        if refresh_direction_is_vertical {
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 10, options: .curveLinear, animations: {
                if var inset = self.scroll_view?.contentInset {
                    inset.bottom = inset.bottom + self.refresh_space
                    self.scroll_view?.contentInset = inset
                }
            }, completion: { _ in
                self.status = .refreshing
            })
        }
        else {
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 10, options: .curveLinear, animations: {
                if var inset = self.scroll_view?.contentInset {
                    inset.right = inset.right + self.refresh_space
                    self.scroll_view?.contentInset = inset
                }
            }, completion: { _ in
                self.status = .refreshing
            })
        }
    }
    
    // MARK: - Self and Sub Size Update
    
    /** 初始化视图尺寸位置 */
    override func frame_deploy(frame: CGRect, size: CGSize, insert: UIEdgeInsets) {
        if refresh_direction_is_vertical {
            self.frame = CGRect(
                x: 0,
                y: size.height + insert.top,
                width: frame.width,
                height: refresh_space
            )
        }
        else {
            self.frame = CGRect(
                x: size.width + insert.left,
                y: 0,
                width: refresh_space,
                height: frame.height
            )
        }
    }
    
    /** 更新视图尺寸位置 */
    override func frame_update(frame: CGRect, size: CGSize, offset: CGPoint, insert: UIEdgeInsets) {
        if refresh_direction_is_vertical {
            self.frame = CGRect(
                x: 0,
                y: size.height,
                width: frame.width,
                height: refresh_space
            )
        }
        else {
            self.frame = CGRect(
                x: size.width,
                y: 0,
                width: refresh_space,
                height: frame.height
            )
        }
    }
    
    /** 更新视图偏移位置 */
    override func frame_offset(frame: CGRect, size: CGSize, offset: CGPoint) {
        // 假如大小尺寸为 0 , 不作处理
        if refresh_space == 0 {
            return
        }
        
        // 更新尺寸
        if refresh_direction_is_vertical {
            if self.frame.origin.y != size.height {
                self.frame.origin.y = size.height
            }
        }
        else {
            if self.frame.origin.x != size.width {
                self.frame.origin.x = size.width
            }
        }
        
        // 更新状态
        if scroll_view?.isDragging == true {
            // 拖动状态: 修改进度
            switch status {
            case .normal:
                if offset.y > 0 || offset.x > 0 {
                    let spcae = frame.height + offset.y - size.height
                    status = .draging(spcae / refresh_space)
                }
            case .draging(_):
                if refresh_direction_is_vertical {
                    if offset.y <= 0 {
                        status = .draging(0)
                        status = .normal
                    }
                    else if self.frame.maxY - offset.y < frame.height {
                        status = .draging(offset.y / refresh_space + 1)
                    }
                    else {
                        let space = frame.height + offset.y - size.height
                        status = .draging(space / refresh_space)
                    }
                }
                else {
                    if offset.x <= 0 {
                        status = .draging(0)
                        status = .normal
                    }
                    else if self.frame.maxX - offset.x < frame.width {
                        status = .draging(offset.x / refresh_space + 1)
                    }
                    else {
                        let space = frame.width + offset.x - size.width
                        status = .draging(space / refresh_space)
                    }
                }
            default:
                break
            }
        }
        else {
            // 松手状态: 判断是否进入刷新，并弹回
            switch status {
            case .draging(let value):
                if (value > 0)
                    && (
                        (self.frame.maxY - offset.y < frame.height)
                            ||
                        (self.frame.maxX - offset.x < frame.width)
                    ) {
                    status_set(refesh_to_refeshing: nil)
                }
                else {
                    status = .normal
                }
            default:
                break
            }
        }
    }

    // MARK: - Add or Move SuperView Action
    
    /** 添加到父视图时获取属性并添加监听 */
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if let table = newSuperview as? UITableView {
            if table.tableFooterView == nil {
                table.tableFooterView = UIView()
            }
        }
    }

}
