class XXStackView: UIView {
    public private(set) var arragedSubviews: [UIView] = []
    
    public var spacing: CGFloat = 0 {
        didSet {
            if spacing != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    open func addArrangedSubview(_ view: UIView) {
        arragedSubviews.append(view)
        view.kvo(\UIView.isHidden) { [weak self] isHidden in
            guard let self = self else { return }
            self._isSubviewChanged = true
            self.setNeedsLayout()
        }
        _isSubviewChanged = true
        setNeedsLayout()
    }
    open func removeArrangedSubview(_ view: UIView) {
        arragedSubviews.remove(object: view)
        view.removeFromSuperview()
        _displayingSubViews.remove(object: view)
        _isSubviewChanged = true
        setNeedsLayout()
    }
    open func insertArrangedSubview(_ view: UIView, at stackIndex: Int) {
        arragedSubviews.insert(view, at: stackIndex)
        _isSubviewChanged = true
        setNeedsLayout()
    }
    
    private var _isSubviewChanged = false
    
    private var _displayingSubViews = [UIView]()
    
    override var intrinsicContentSize: CGSize {
        Log.debug("intrinsicContentSize:\(contentWidth)")
        return .init(contentWidth, contentMaxHeight)
    }
    
    var contentWidth: CGFloat = 0 {
        didSet {
            if contentWidth != oldValue {
                invalidateIntrinsicContentSize()
            }
        }
    }
    var contentMaxHeight: CGFloat = 0 {
        didSet {
            if contentMaxHeight != oldValue {
                invalidateIntrinsicContentSize()
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        Log.info("\(self.width), subviews num: \(_displayingSubViews.count)")
        if _isSubviewChanged {
            _isSubviewChanged = false
            
            _displayingSubViews.forEach { view in
                view.removeFromSuperview()
            }
            _displayingSubViews.removeAll()
            arragedSubviews.forEach { view in
                if !view.isHidden {
                    _displayingSubViews.append(view)
                    addSubview(view)
                }
            }
        }
        var x: CGFloat = 0
        var maxHeight: CGFloat = 0
        _displayingSubViews.forEach { view in
            let size = view.systemLayoutSizeFitting(CGSize.init(1000, 40))
            maxHeight = max(maxHeight, size.height)
            let y = (self.height - size.height) / 2.0
            view.frame = CGRect.init(x, y, size.width, size.height)
            x = x + view.width + spacing
        }
        contentWidth = x
        contentMaxHeight = maxHeight
    }
}
