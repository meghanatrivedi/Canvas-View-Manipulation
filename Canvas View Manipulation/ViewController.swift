//
//  ViewController.swift
//  Canvas View Manipulation
//
//  Created by Meggi on 21/11/25.
//

import UIKit

// selected view alignment
enum Align{
    case top,bottom,left,right,centerHorizonatal,centerVertical
}

class ViewController: UIViewController {
    
    @IBOutlet weak var canvashView:UIView!
    
    var selectedTextField:UITextView?
    var itemPadding:CGFloat = 8
    
    var textViews: [UITextView]{
        canvashView.subviews.compactMap { $0 as? UITextView }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        canvashView.clipsToBounds = true
        addCanvasTapGesture()
    }
    func addCanvasTapGesture(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(canvasTapped(_:)))
        canvashView.addGestureRecognizer(tapGesture)
    }
    @objc private func canvasTapped(_ gesture:UITapGestureRecognizer){
        let location = gesture.location(in:canvashView)
        
        if textViews.first(where: { $0.frame.contains(location) }) == nil {
            deselectAll()
        }
    }
    func deselectAll(){
        selectedTextField?.layer.borderWidth = 0
        selectedTextField?.resignFirstResponder()
        selectedTextField = nil
        
        for tv in textViews{
            tv.isUserInteractionEnabled = true
            tv.isEditable = false
        }
    }
    // add the textView for add button tap
    func addTextView(){
        let tv = makeTextView()
        
        let size = CGSize(width: 160, height: 60)
        let origin = CGPoint(
            x: (canvashView.bounds.width - size.width) / 2, y: (canvashView.bounds.height - size.height) / 2
        )
        tv.frame = CGRect(origin: origin, size: size)
        canvashView.addSubview(tv)
        select(tv)
    }
    
    // display & making the textview behavior
    func makeTextView() -> UITextView{
        let tv = UITextView()
        tv.backgroundColor = randomColor()
        tv.text = "Tap to edit"
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.isScrollEnabled = false
        tv.delegate = self
        tv.layer.cornerRadius = 8
        tv.textContainerInset = .init(top: 8, left: 6, bottom: 8, right: 6)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(textviewTapped(_:)))
        tv.addGestureRecognizer(tap)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        tv.addGestureRecognizer(pan)
        
        return tv
    }
    
    @objc private func textviewTapped(_ g:UITapGestureRecognizer){
        if let tv = g.view as? UITextView{
            select(tv)
        }
    }
    
    // dragging the selected text view 
    @objc private func handlePan(_ g: UIPanGestureRecognizer) {
        guard let tv = g.view as? UITextView,
              tv == selectedTextField else { return }
        
        let translation = g.translation(in: canvashView)
        var f = tv.frame
        
        f.origin.x = max(0, min(f.origin.x + translation.x, canvashView.bounds.width - f.width))
        f.origin.y = max(0, min(f.origin.y + translation.y, canvashView.bounds.height - f.height))
        
        tv.frame = f
        g.setTranslation(.zero, in: canvashView)
    }
    // hightlight and enables editing textview
    func select(_ tv: UITextView) {
        deselectAll()
        selectedTextField = tv
        
        tv.layer.borderWidth = 2
        tv.layer.borderColor = UIColor.blue.cgColor
        
        for other in textViews where other != tv {
            other.isUserInteractionEnabled = false
        }
        
        tv.isEditable = true
        tv.becomeFirstResponder()
        
        canvashView.bringSubviewToFront(tv)
    }
    
    // generate the every time random color
    func randomColor() -> UIColor{
        UIColor(
            red: .random(in: 0.2...0.95),
            green: .random(in: 0.2...0.95),
            blue: .random(in: 0.2...0.95),
            alpha: 1
        )
    }
    
    // set the  top left to bottom right
    func orderAllViews() {
        let views = textViews.sorted {
            $0.frame.minY == $1.frame.minY ?
            $0.frame.minX < $1.frame.minX :
            $0.frame.minY < $1.frame.minY
        }
        
        var x: CGFloat = itemPadding
        var y: CGFloat = itemPadding
        var rowHeight: CGFloat = 0
        
        for tv in views {
            let w = tv.frame.width
            let h = tv.frame.height
            
            if x + w + itemPadding > canvashView.bounds.width {
                x = itemPadding
                y += rowHeight + itemPadding
                rowHeight = 0
            }
            
            tv.frame.origin = CGPoint(x: x, y: y)
            
            x += w + itemPadding
            rowHeight = max(rowHeight, h)
        }
    }
    // alignment selected in the enum and set accoding to that
    func alignSeleted(_ alignment:Align){
        guard let tv = selectedTextField else{ return}
        var f = tv.frame
        
        switch alignment {
        case .top:
            f.origin.y = 0
            
        case .bottom:
            f.origin.y = canvashView.bounds.height - f.height
            
        case .left:
            f.origin.x = 0
            
        case .right:
            f.origin.x = canvashView.bounds.width - f.width
        case .centerVertical:
            f.origin.y = (canvashView.bounds.height - f.height) / 2
            
        case.centerHorizonatal:
            f.origin.x = (canvashView.bounds.width - f.width) / 2
        }
        tv.frame = f
    }
    // button click event all the button same click event so identifire with the title
    @IBAction func controlButtonTapped(_ sender: UIButton){
        guard let title = sender.currentTitle else { return }
        print("title....\(title)")
        switch title {
        case "Add" : addTextView()
        case "Top": alignSeleted(.top)
        case "Bottom": alignSeleted(.bottom)
        case "Left": alignSeleted(.left)
        case "Right": alignSeleted(.right)
        case "Center V": alignSeleted(.centerVertical)
        case "Center H":
            alignSeleted(.centerHorizonatal)
        case "Order": orderAllViews()
        default: break
            
            
        }
    }
    
}

// delegate method of textviewDelegate
extension ViewController:UITextViewDelegate{
    
    // resize based on the text
    func textViewDidChange(_ tv: UITextView) {
        let maxWidth = canvashView.bounds.width - 16
        
        let fitted = tv.sizeThatFits(CGSize(width: maxWidth, height: .infinity))
        var size = CGSize(width: fitted.width, height: fitted.height)
        
        size.width = min(size.width, maxWidth)
        size.width = max(size.width, 60)
        size.height = max(size.height, 30)
        
        var f = tv.frame
        f.size = size
        tv.frame = f
    }
    
}
