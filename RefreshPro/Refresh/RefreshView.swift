//
//  RefreshView.swift
//  RefreshPro
//
//  Created by Myron on 2017/6/7.
//  Copyright © 2017年 Myron. All rights reserved.
//

import UIKit

// MARK: - Extension ScrollView

extension UIScrollView {
    
    /** 设置所有子视图中的 RefreshView 代理对象 */
    func refresh(set_delegate delegate: RefreshView_Delegate) {
        for i in 501 ..< 503 {
            if let refresh = viewWithTag(i) as? RefreshView {
                refresh.delegate = delegate
            }
        }
    }
    
}

// MARK: - Delegate Protocol

@objc protocol RefreshView_Delegate: class {
    /** 必须在完成数据刷新后回调 status_set(refreshed: false, data: nil) */
    func refreshView(view: RefreshView, identifier: String)
}

// MARK: - Status Enum

/** 刷新状态 */
enum RefreshView_Status {
    case normal                 // 常态
    case draging(CGFloat)       // 拖动中 value: 当前偏移/额定偏移
    case refresh                // 等待刷新
    case refreshing             // 进行刷新 刷新动画
    case refreshed(Bool, Any?)  // 刷新完毕 结束动画
}


// MARK: - RefreshView

class RefreshView: UIView {
    
    // MARK: - Datas
    
    /** 标识符 */
    @IBInspectable var identifier: String = "RefreshView_Base"
    
    /** 刷新视图的默认高度 */
    @IBInspectable var refresh_space: CGFloat = 100
    
    /** 刷新方向是否是垂直的 */
    @IBInspectable var refresh_direction_is_vertical: Bool = true
    
    /** 父视图，可用于在 Storyboard 上直接连接 UIScrollView */
    @IBOutlet weak var scroll_view: UIScrollView? {
        didSet {
            if oldValue !== scroll_view {
                scroll_view?.addSubview(self)
            }
        }
    }
    
    /** 代理回调 */
    weak var delegate: RefreshView_Delegate?
    
    /** 用于在 Storyboard 上连接 UIScrollView */
    @IBOutlet weak var delegate_link: NSObject? {
        didSet {
            if let r_delegate = delegate_link as? RefreshView_Delegate {
                delegate = r_delegate
            }
        }
    }
    
    /** 当前刷新状态，每次变更会触发响应事件 */
    var status: RefreshView_Status = .normal {
        didSet {
            switch status {
            case .normal:
                status_normal()
            case .draging(let value):
                status_draging(value: value)
            case .refresh:
                status_refresh()
            case .refreshing:
                status_refreshing()
            case .refreshed(let result, let data):
                status_refreshed(result: result, data: data)
            }
        }
    }
    
    // MARK: - Datas To SubView
    
    
    /** 附带数据对象 */
    weak var datas_obj: AnyObject?
    
    /** 附带数据字典 */
    var datas_dic: [String: Any] = [:]
    
    /** 拖动中的图片 */
    @IBInspectable var draging_image: UIImage?
    /** 刷新成功的图片 */
    @IBInspectable var success_image: UIImage?
    /** 刷新失败的图片 */
    @IBInspectable var error_image: UIImage?
    
    /** 刷新中的文本提示 */
    @IBInspectable var refreshing_text: String?
    /** 刷新成功的文本提示 */
    @IBInspectable var success_text: String?
    /** 刷新失败的文本提示 */
    @IBInspectable var error_text: String?
    
    /** 默认文本 */
    @IBInspectable var normal_text: String?
    /** 时间文本前缀 */
    @IBInspectable var time_prefix_text: String?
    /** 拖拽文本 */
    @IBInspectable var draging_text: String?
    
    // MARK: Image
    
    var image_draging: UIImage? {
        return draging_image ?? image(name: "refresh_draging")
    }
    var image_success: UIImage? {
        return success_image ?? image(name: "refresh_success")
    }
    var image_error: UIImage? {
        return error_image ?? image(name: "refresh_error")
    }
    
    // MARK: Text
    
    var text_refreshing: String {
        if let text = refreshing_text {
            return NSLocalizedString(text, comment: text)
        }
        return localized(key: "RefreshView_Header_Refreshing_Text")
    }
    var text_success: String {
        if let text = success_text {
            return NSLocalizedString(text, comment: text)
        }
        return localized(key: "RefreshView_Header_Refresh_Success")
    }
    var text_error: String {
        if let text = error_text {
            return NSLocalizedString(text, comment: text)
        }
        return localized(key: "RefreshView_Header_Refresh_Error")
    }
    
    var text_normal: String {
        if let text = normal_text {
            return NSLocalizedString(text, comment: text)
        }
        return localized(key: "RefreshView_Header_Normal_Text")
    }
    var text_time_prefix: String {
        if let text = time_prefix_text {
            return NSLocalizedString(text, comment: text)
        }
        return localized(key: "RefreshView_Header_None_Time_Prefix_Text")
    }
    var text_draging: String {
        if let text = draging_text {
            return NSLocalizedString(text, comment: text)
        }
        return localized(key: "RefreshView_Header_Draging_Text")
    }
    
    // MARK: - Init Deploy
    
    init() {
        super.init(frame: CGRect.zero)
        deploy_at_init()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        deploy_at_init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        deploy_at_init()
    }
    
    /** 初始化完毕时调用，用于配置视图属性 */
    func deploy_at_init() {
        self.clipsToBounds = true
    }
    
    // MARK: - Status Actions
    
    /** 设置刷新状态为 normal 时调用 */
    func status_normal() {}
    
    /** 设置刷新状态为 draging 时调用 */
    func status_draging(value: CGFloat) {}
    
    /** 设置刷新状态为 refresh 时调用 */
    func status_refresh() {}
    
    /** 设置刷新状态为 refreshing 时调用
        刷新动画写在这个位置。
        默认会调用 delegate.refreshView(view: RefreshView, identifier: String);
        假如 delegate 为空，则直接调用 status_set(refreshed: false, data: nil)
     */
    func status_refreshing() {
        if let delegate = self.delegate {
            delegate.refreshView(
                view: self,
                identifier: identifier
            )
        }
        else {
            print("Refresh View Error: didn't have any refresh delegate, please set the 'delegate' or 'delegate_refresh' property.")
            status_set(refreshed: false, data: nil)
        }
    }
    
    /** 设置刷新状态为 refreshed 时调用。
        结束时动画写在这个位置。
        默认调用 status_set(normal: nil)
     */
    func status_refreshed(result: Bool, data: Any?) {
        status_set(normal: nil)
    }
    
    // MARK: Set
    
    /** 设置状态成为 normal */
    func status_set(normal complete: (() -> Void)?) {
        status = .normal
        complete?()
    }
    
    /** 设置状态成为 refreshed */
    func status_set(refreshed result: Bool, data: Any?) {
        status = .refreshed(result, data)
    }
    
    // MARK: - Self and Sub Size Update
    
    override var frame: CGRect {
        didSet {
            if frame.size != oldValue.size {
                frame_subviews_update(size: frame)
            }
        }
    }
    
    override var bounds: CGRect {
        didSet {
            if bounds.size != oldValue.size {
                frame_subviews_update(size: frame)
            }
        }
    }
    
    /** 初始化视图尺寸位置 */
    func frame_deploy(frame: CGRect, size: CGSize, insert: UIEdgeInsets) {}
    
    /** 更新视图尺寸位置 */
    func frame_update(frame: CGRect, size: CGSize, offset: CGPoint) {}
    
    /** 更新视图偏移位置 */
    func frame_offset(frame: CGRect, size: CGSize, offset: CGPoint) {}
    
    /** 更新子视图的尺寸 */
    func frame_subviews_update(size: CGRect) {}
    
    // MARK: - Key Value Observer
    
    static let key_path_contentOffset = "contentOffset"
    static let key_path_contentSize   = "contentSize"
    
    /** 监听父视图的属性更新 */
    func observer() {
        let options = NSKeyValueObservingOptions(
            rawValue: NSKeyValueObservingOptions.new.rawValue | NSKeyValueObservingOptions.old.rawValue
        )
        self.scroll_view?.addObserver(
            self,
            forKeyPath: RefreshView.key_path_contentOffset,
            options: options,
            context: nil
        )
        self.scroll_view?.addObserver(
            self,
            forKeyPath: RefreshView.key_path_contentSize,
            options: options,
            context: nil
        )
    }
    
    /** 取消监听父视图的属性更新 */
    func unobserver() {
        self.superview?.removeObserver(
            self,
            forKeyPath: RefreshView.key_path_contentOffset
        )
        self.superview?.removeObserver(
            self,
            forKeyPath: RefreshView.key_path_contentSize
        )
    }
    
    /** 监听事件 */
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == RefreshView.key_path_contentOffset {
            super_view_constant_offset(change: change)
        }
        else if keyPath == RefreshView.key_path_contentSize {
            super_view_constant_size(change: change)
        }
    }
    
    /** 父视图 constant offset 属性变化 */
    func super_view_constant_offset(change: [NSKeyValueChangeKey : Any]?) {
        if let view = superview as? UIScrollView {
            frame_offset(
                frame: view.frame,
                size: view.contentSize,
                offset: view.contentOffset
            )
        }
    }
    
    /** 父视图 constant size 属性变化 */
    func super_view_constant_size(change: [NSKeyValueChangeKey : Any]?) {
        if let view = superview as? UIScrollView {
            frame_update(
                frame: view.frame,
                size: view.contentSize,
                offset: view.contentOffset
            )
        }
    }
    
    
    // MARK: - Add or Move SuperView Action
    
    /** 添加到父视图时获取属性并添加监听 */
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        /// 如果已经存在当前父视图中，直接退出
        if newSuperview === superview {
            return
        }
        
        /// 移除旧的父视图监听
        unobserver()
        
        /// 判断方向
        refresh_direction_is_vertical = true
        if let collection = newSuperview as? UICollectionView {
            if let layout = collection.collectionViewLayout as? UICollectionViewFlowLayout {
                if layout.scrollDirection == .horizontal {
                    refresh_direction_is_vertical = false
                }
            }
        }
        
        /// 配置属性
        if let scroll = newSuperview as? UIScrollView {
            status = .normal
            scroll_view = scroll
            frame_deploy(
                frame: scroll.frame,
                size: scroll.contentSize,
                insert: scroll.contentInset
            )
            observer()
        }
    }
    
    /** 从父视图移除时删除属性并移除监听 */
    override func removeFromSuperview() {
        unobserver()
        scroll_view = nil
        super.removeFromSuperview()
    }
    
}


// MARK: - RefreshView Tools

/** 基类提供的小工具集合，用于子类简化代码 */
extension RefreshView {
    
    /** 延迟调用，制作动画等效果时用于简化代码的小工具 */
    func delay(time: TimeInterval, block: @escaping () -> Void) {
        DispatchQueue.global().async {
            Thread.sleep(forTimeInterval: time)
            DispatchQueue.main.async {
                block()
            }
        }
    }
    
    /** 获取字典中的数据 */
    func datas(key: String) -> Any? {
        return datas_dic[key]
    }
    
    /** 获取字典中的数据 */
    func datas<T>(key: String) -> T? {
        return datas_dic[key] as? T
    }
    
}

// MARK: - RefreshView Resources

/** 访问 RefreshPro.bundle 文件夹内容 */
extension RefreshView {
    
    /** 获取资源文件夹 */
    private static var bundle: Bundle?
    func get_bundle() -> Bundle? {
        if RefreshView.bundle == nil {
            if let path = Bundle.main.path(
                forResource: "RefreshPro",
                ofType: "bundle") {
                RefreshView.bundle = Bundle(path: path)
            }
        }
        return RefreshView.bundle
    }
    
    /** 获取资源文件中的图片 */
    private static var _images: [String: UIImage] = [:]
    func image(name: String) -> UIImage? {
        if let image = RefreshView._images[name] {
            return image
        }
        else {
            if let path = get_bundle()?.path(forResource: name, ofType: "png") {
                if let image = UIImage(contentsOfFile: path) {
                    RefreshView._images["name"] = image
                    return image
                }
            }
        }
        return nil
    }
    
    /** 获取资源文件中的本地化语言 */
    private static var languages: [String: Bundle] = [:]
    func localized(key: String) -> String {
        func local(bundle: Bundle, key: String) -> String {
            return bundle.localizedString(forKey: key, value: nil, table: nil)
        }
        
        // 获取当前环境语言
        var language = "en"
        if let l_type = Locale.preferredLanguages.first {
            if l_type.hasPrefix("zh") {
                if l_type.contains("Hans") {
                    language = "zh-Hans"
                }
                else {
                    language = "zh-Hant"
                }
            }
            
        }
        
        // 获取本地化语言包以及其中的语言
        if let l_bundle = RefreshView.languages[language] {
            return l_bundle.localizedString(forKey: key, value: nil, table: nil)
        }
        
        if let path = get_bundle()?.path(forResource: language, ofType: "lproj") {
            if let l_bundle = Bundle(path: path) {
                RefreshView.languages[language] = l_bundle
                return l_bundle.localizedString(forKey: key, value: nil, table: nil)
            }
        }
        
        return key
    }
    
}
