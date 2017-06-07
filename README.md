# RefreshPro

A refresh view to scrollview.

UIScrollView 的外设类库，用于扩展 ScrollView 子类，主要以 TableView、CollectionView 为主的常用库。  
设计宗旨，为提供一个可通过代码简易的为应用添加上下拉刷新等功能，或可通过 Storeboard 进行高度的定制的上下拉刷新功能界面。

* 功能列表
    * 下拉刷新
    * 上拉刷新
    * 空白页面填充

* 文件结构
    * Refresh
        * RefreshView.swift
    * Empty
    * Resource

# Refresh

上下拉刷新控件。
提供简易的 ScrollView 嵌入方案，以及高效的调用方式，自由的可定制化功能。

> 默认的 RefreshViewHeader 的 Tag 为 501
> 默认的 RefreshViewFooter 的 Tag 为 502

## RefreshView.swift

上下拉刷新控件基类。用于提供参数以及基础 api 列表，基础监听调用功能。

* Extension ScrollView: 扩展 UIScrollView, 提供快捷方法
* Delegate Protocol: 定义 RefreshView_Delegate
* Status Enum: 定义 RefreshView_Status
* RefreshView: 基类
    * Datas: 各类属性数据
    * Datas to SubViews: 各类为子类准备的属性数据
    * Init Deploy: 初始化调用
    * Status Actions: status 属性相关的回调以及设置方法
    * Self and Sub Size Update: 视图尺寸变化方法
    * Key Value Observer: 父视图属性监听
    * Add or Move SuperView Action: 添加或移除自父视图方法监听
* RefreshView Tools: 代码工具，用于简化代码
* RefreshView Resources: 访问 RefreshPro.bundle 文件夹内容


* 监听 status 属性
    * func status_normal() 
    * func status_draging(value: CGFloat) 
    * func status_refresh() 
    * func status_refreshing() 
    * func status_refreshed(result: Bool, data: Any?) 
        * delegate.refreshView(view: RefreshView, identifier: String)
* 监听 frame/bounds 属性
    * frame_subviews_update(size: frame)
* 监听父视图 contentOffset/contentSize 属性
    * func super_view_constant_offset(change: [NSKeyValueChangeKey : Any]?)
        * func frame_deploy(frame: CGRect, size: CGSize, insert: UIEdgeInsets)
    * func super_view_constant_size(change: [NSKeyValueChangeKey : Any]?)
        * func frame_update(frame: CGRect, size: CGSize, offset: CGPoint)
* 监听添加或移除父视图
    * 设置相应属性
    * func frame_deploy(frame: CGRect, size: CGSize, insert: UIEdgeInsets)
    * 调用 func observer()
    * 调用 func unobserver()

## RefreshView_Header.swift

下拉控件基类。
默认 View.tag 为 501。

* 复写
    * func status_set(normal complete: (() -> Void)?) 
        * 添加刷新完毕的回弹动画
    * func frame_deploy(frame: CGRect, size: CGSize, insert: UIEdgeInsets)
        * 设置尺寸位置
    * func frame_update(frame: CGRect, size: CGSize, offset: CGPoint)
        * 设置尺寸位置
    * func frame_offset(frame: CGRect, size: CGSize, offset: CGPoint)
        * 更新视图偏移
        * 根据偏移量修改 status
        * 进入刷新位置的偏移动画


## RefreshView_Header_Simple.swift

简单下拉控件。

* 添加
    * info_text: 用于显示提示信息
    * time_text: 用于显示刷新时间
    * hint_image: 用于显示提示图标
    * hint_activity: 用于显示等待状态
