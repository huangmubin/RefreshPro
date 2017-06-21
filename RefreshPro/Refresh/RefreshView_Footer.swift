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
    
    override var frame: CGRect {
        didSet {
            print("Footer = \(frame)")
            if frame.origin.y == 0 {
                print("")
            }
        }
    }
    
    // MARK: - Init Deploy
    
    /** 初始化完毕时调用，用于配置视图属性 */
    override func deploy_at_init() {
        super.deploy_at_init()
        self.identifier = "RefreshView_Footer"
        self.tag = 502
        self.refreshed_animation_time = 0.5
    }
    
    // MARK: - Status Actions
    
    override func status_normal(complete: (() -> Void)?) {
        if refresh_inset_is_offseted {
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
                    self.refresh_inset_is_offseted = false
                    complete?()
                })
            }
        }
        else {
            complete?()
        }
    }
    
    override func status_refresh() {
        if refresh_inset_is_offseted {
            self.status_change(to: .refreshing)
        }
        else {
            if refresh_direction_is_vertical {
                UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 10, options: .curveLinear, animations: {
                    if var inset = self.scroll_view?.contentInset {
                        inset.bottom = inset.bottom + self.refresh_space
                        self.scroll_view?.contentInset = inset
                    }
                }, completion: { _ in
                    self.status_change(to: .refreshing)
                    self.refresh_inset_is_offseted = true
                })
            }
            else {
                UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 10, options: .curveLinear, animations: {
                    if var inset = self.scroll_view?.contentInset {
                        inset.right = inset.right + self.refresh_space
                        self.scroll_view?.contentInset = inset
                    }
                }, completion: { _ in
                    self.status_change(to: .refreshing)
                    self.refresh_inset_is_offseted = true
                })
            }
        }
    }
    
    override func status_refreshed(result: Bool, data: Any?) {
        delay(time: refreshed_animation_time, block: {
            self.status_change(to: .normal)
        })
    }
    
    // MARK: - Self and Sub Size Update
    
    /** 初始化视图尺寸位置 */
    override func frame_deploy(frame: CGRect, size: CGSize, insert: UIEdgeInsets) {
        if refresh_direction_is_vertical {
            var height: CGFloat = size.height
            if size.height == 0 {
                height += frame.height
            }
            self.frame = CGRect(
                x: 0,
                y: height + insert.top,
                width: frame.width,
                height: refresh_space
            )
        }
        else {
            var width: CGFloat = size.width
            if size.width == 0 {
                width += frame.width
            }
            self.frame = CGRect(
                x: width + insert.left,
                y: 0,
                width: refresh_space,
                height: frame.height
            )
        }
    }
    
    /** 更新视图尺寸位置 */
    override func frame_update(frame: CGRect, size: CGSize, offset: CGPoint, insert: UIEdgeInsets) {
        if refresh_direction_is_vertical {
            var height: CGFloat = size.height
            if size.height == 0 {
                height += frame.height
                height -= insert.bottom
            }
            self.frame = CGRect(
                x: 0,
                y: height + insert.top,
                width: frame.width,
                height: refresh_space
            )
        }
        else {
            var width: CGFloat = size.width
            if size.width == 0 {
                width += frame.width
                width -= insert.right
            }
            self.frame = CGRect(
                x: width + insert.left,
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
            if size.height == 0 {
                if self.frame.origin.y != frame.height {
                    if frame.height - self.scroll_view!.contentInset.bottom == 0 {
                        print("")
                    }
                    self.frame.origin.y = frame.height - self.scroll_view!.contentInset.bottom
                }
            }
            else if self.frame.origin.y != size.height {
                if size.height == 0 {
                    print("")
                }
                self.frame.origin.y = size.height
            }
        }
        else {
            if size.width == 0 {
                if self.frame.origin.x != frame.width {
                    self.frame.origin.x = frame.width - self.scroll_view!.contentInset.right
                }
            }
            else if self.frame.origin.x != size.width {
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
                    status_change(to: .draging(spcae / refresh_space))
                }
            case .draging(_):
                if refresh_direction_is_vertical {
                    if offset.y <= 0 {
                        status_change(to: .draging(0))
                        status_change(to: .normal)
                    }
                    else if self.frame.maxY - offset.y < frame.height {
                        status_change(to: .draging(offset.y / refresh_space + 1))
                    }
                    else {
                        let space = frame.height + offset.y - size.height
                        status_change(to: .draging(space / refresh_space))
                    }
                }
                else {
                    if offset.x <= 0 {
                        status_change(to: .draging(0))
                        status_change(to: .normal)
                    }
                    else if self.frame.maxX - offset.x < frame.width {
                        status_change(to: .draging(offset.x / refresh_space + 1))
                    }
                    else {
                        let space = frame.width + offset.x - size.width
                        status_change(to: .draging(space / refresh_space))
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
                    status_change(to: .refresh)
                }
                else {
                    status_change(to: .normal)
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
