//
//  UserTrackingButton.swift
//  UserTrackingButton
//
//  Created by Mikko Välimäki on 15-12-04.
//  Copyright © 2015 Mikko Välimäki. All rights reserved.
//

import Foundation
import MapKit

let animationDuration = 0.2

@IBDesignable public class UserTrackingButton : UIControl, MKMapViewDelegate {
    
    private var delegateProxy: MapViewDelegateProxy?
    private var locationButton: UIButton = UIButton()
    private var locationOffButton: UIButton = UIButton()
    private var trackingActivityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    private var viewState: ViewState = .Initial
    
    enum ViewState {
        case Initial
        case RetrievingLocation
        case TrackingLocationOff
        case TrackingLocation
    }
    
    @IBOutlet public var mapView: MKMapView? {
        didSet {
            if let mapView = mapView {
                self.delegateProxy = MapViewDelegateProxy(mapView: mapView, target: self)
                updateState(forMapView: mapView, animated: false)
            }
        }
    }
    
    required public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    private func setup() {
        self.addTarget(self, action: "pressed:", for: .touchUpInside)

        self.addButton(button: self.locationButton, withImage: getImage(named: "TrackingLocationMask"))
        self.addButton(button: self.locationOffButton, withImage: getImage(named: "TrackingLocationOffMask"))
        
        self.locationOffButton.isHidden = true
        self.locationButton.isHidden = true
        self.trackingActivityIndicator.stopAnimating()

        self.trackingActivityIndicator.hidesWhenStopped = true
        self.trackingActivityIndicator.isHidden = true
        self.trackingActivityIndicator.isUserInteractionEnabled = false
        self.trackingActivityIndicator.isExclusiveTouch = false
        self.trackingActivityIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.trackingActivityIndicator)
        self.addConstraints([
            NSLayoutConstraint(item: self.trackingActivityIndicator, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.trackingActivityIndicator, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0),
            ])
        
        self.layer.cornerRadius = 4
        self.clipsToBounds = true
        
        self.transitionToState(state: .TrackingLocationOff, animated: false)
    }
    
 
    
    public override func tintColorDidChange() {
        self.trackingActivityIndicator.tintColor = self.tintColor
    }
    
    internal func pressed(sender: UIButton!) {
        let userTrackingMode: MKUserTrackingMode
        switch mapView?.userTrackingMode {
        case .some(MKUserTrackingMode.follow):
            userTrackingMode = MKUserTrackingMode.none
        default:
            userTrackingMode = MKUserTrackingMode.follow
        }

        mapView?.setUserTrackingMode(userTrackingMode, animated: true)
    }
    
    // MARK: MKMapViewDelegate Implementation
    
    public func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        updateState(forMapView: mapView, animated: true)
    }
    
    public func mapView(mapView: MKMapView, didChangeUserTrackingMode mode: MKUserTrackingMode, animated: Bool) {
        updateState(forMapView: mapView, animated: true)
    }
    
    // MARK: Helpers
    
    private func addButton(button: UIButton, withImage image: UIImage?) {
        button.addTarget(self, action: "pressed:", for: .touchUpInside)
        button.setImage(image?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(button)
        
        self.addConstraints([
            NSLayoutConstraint(
                item: button,
                attribute: .leading,
                relatedBy: .equal,
                toItem: self,
                attribute: .leading,
                multiplier: 1,
                constant: 0),
            NSLayoutConstraint(
                item: button,
                attribute: .trailing,
                relatedBy: .equal,
                toItem: self,
                attribute: .trailing,
                multiplier: 1,
                constant: 0),
            NSLayoutConstraint(
                item: button,
                attribute: .top,
                relatedBy: .equal,
                toItem: self,
                attribute: .top,
                multiplier: 1,
                constant: 0),
            NSLayoutConstraint(
                item: button,
                attribute: .bottom,
                relatedBy: .equal,
                toItem: self,
                attribute: .bottom,
                multiplier: 1,
                constant: 0),
            ])
    }
    
    private func updateState(forMapView mapView: MKMapView, animated: Bool) {
        let state: ViewState
        if mapView.userTrackingMode == .none {
            state = .TrackingLocationOff
        } else if mapView.userLocation.location == nil || (mapView.userLocation.location?.horizontalAccuracy)! >= kCLLocationAccuracyHundredMeters {
            state = .RetrievingLocation
        } else {
            state = .TrackingLocation
        }
        transitionToState(state: state, animated: animated)
    }
    
    private func transitionToState(state: ViewState, animated: Bool) {
        
        switch state {
        case .RetrievingLocation:
            self.hide(button: locationOffButton, animated: animated)
            self.hide(button: locationButton, animated: animated) {
                self.trackingActivityIndicator.isHidden = false
                self.trackingActivityIndicator.startAnimating()
            }
        case .TrackingLocation:
            self.trackingActivityIndicator.stopAnimating()
            self.hide(button: locationOffButton, animated: animated)
            self.show(button: locationButton, animated: animated)
        case .TrackingLocationOff:
            self.trackingActivityIndicator.stopAnimating()
            self.hide(button: locationButton, animated: animated)
            self.show(button: locationOffButton, animated: animated)
        default:
            break
        }
        
        self.viewState = state
    }
    
    public func getImage(named: String) -> UIImage? {
        return UIImage(named: named, in: Bundle(for: type(of: self)), compatibleWith: nil)
    }
    
    // MARK: Interface Builder
    
    public override func prepareForInterfaceBuilder() {
        self.transitionToState(state: .TrackingLocationOff, animated: false)
    }
    
    // MARK: Button visibility
    
    // This would be as extension methods but there was some issues when importing
    // such a framework and using it as extension.
    
//}
//
//extension UIView {
    
    func setHidden(button: UIButton, hidden: Bool, animated: Bool, completion: (() -> Void)? = nil) {
        guard button.isHidden != hidden else {
            completion?()
            return
        }
        
        if button.isHidden {
            button.alpha = 0.0
            button.isHidden = false
        }
        
        let anim: () -> Void = {
            button.alpha = hidden ? 0.0 : 1.0
        }
        
        let compl: ((Bool) -> Void) = { _ in
            button.isHidden = hidden
            completion?()
        }
        
        if animated {
            UIView.animate(withDuration: 0.2, animations: anim, completion: compl)
        } else {
            anim()
            compl(true)
        }
    }
    
    func hide(button: UIButton, animated: Bool, completion: (() -> Void)? = nil) {
        setHidden(button: button, hidden: true, animated: animated, completion: completion)
    }
    
    func show(button: UIButton, animated: Bool, completion: (() -> Void)? = nil) {
        button.superview?.bringSubview(toFront: self)
        setHidden(button: button, hidden: false, animated: animated, completion: completion)
    }
}
