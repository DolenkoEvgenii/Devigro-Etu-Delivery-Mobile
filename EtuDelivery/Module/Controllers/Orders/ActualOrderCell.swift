//
// Created by Евгений Доленко on 01.11.2019.
// Copyright (c) 2019 Евгений Доленко. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

class ActualOrderCell: UITableViewCell {
    static let CELL_ID = "actualOrderCell"

    @IBOutlet weak var view: UIView!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var startAddressLabel: UILabel!
    @IBOutlet weak var endAddressLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!
    @IBOutlet weak var arriveTimeLabel: UILabel!

    @IBOutlet weak var timeBlock: UIView!
    @IBOutlet weak var statusBlock: UIView!
    @IBOutlet weak var completeOrderButton: ExtendedButton!
    @IBOutlet weak var actionButton: ExtendedButton!
    @IBOutlet weak var editTimeButton: ExtendedButton!
    @IBOutlet weak var changeStatusButton: ExtendedButton!
    @IBOutlet weak var currentStatusLabel: ExtendedLabel!

    @IBOutlet weak var startPointView: UIView!
    @IBOutlet weak var endPointView: UIView!
    @IBOutlet weak var markerStartView: UIImageView!
    @IBOutlet weak var markerEndView: UIImageView!

    @IBOutlet var editTimeBlockHeight: NSLayoutConstraint!
    @IBOutlet var changeStatusBlockHeight: NSLayoutConstraint!
    @IBOutlet var completeButtonHeight: NSLayoutConstraint!
    @IBOutlet var actionButtonHeight: NSLayoutConstraint!


    weak var delegate: ActualOrderDelegate? = nil
    var order: Order!

    let timeIntervals = ["8 - 9", "9 - 10", "10 - 11", "11 - 13", "13 - 15", "15 - 18", "18 - 19", "19 - 21", "21 - 24"]

    func setupWithOrder(order: Order) {
        self.order = order

        titleLabel.text = order.status.name
        startAddressLabel.text = order.from?.address ?? ""
        endAddressLabel.text = order.to?.address ?? ""

        let coordinateA = CLLocation(latitude: order.from?.lat ?? 0.0, longitude: order.from?.lng ?? 0.0)
        let coordinateB = CLLocation(latitude: order.to?.lat ?? 0.0, longitude: order.to?.lng ?? 0.0)
        let distanceInMeters = Int(coordinateA.distance(from: coordinateB))

        distanceLabel.text = "distance".localized() + ": \(distanceInMeters) м." 
        costLabel.text = "cost".localized() + ": \(order.cost) р."
        currentStatusLabel.text = "current_status".localized() + ": " + order.status.name

        completeOrderButton.onTap { [unowned self] _ in
            self.delegate?.onCompleteOrder(order: order)
        }

        editTimeButton.onTap { [unowned self] _ in
            self.onEditTimeClick(order: order)
        }

        if (order.status == OrderStatus.new) {
            changeStatusButton.onTap { [unowned self] _ in
                self.showOptionsSelector(order: order, options: [OrderStatus.on_road, OrderStatus.completed])
            }
        }

        if (order.status == OrderStatus.technical_stop) {
            changeStatusButton.onTap { [unowned self] _ in
                self.showOptionsSelector(order: order, options: [OrderStatus.on_road, OrderStatus.completed])
            }
        }

        if (order.status == OrderStatus.on_road) {
            changeStatusButton.onTap { [unowned self] _ in
                self.showOptionsSelector(order: order, options: [OrderStatus.technical_stop, OrderStatus.completed])
            }
        }
        if let from = order.from {
            markerStartView.onTap { [weak self] _ in
                self?.delegate?.onCordsClick(lat: from.lat, lng: from.lng)
            }
            startPointView.onTap { [weak self] _ in
                self?.delegate?.onCordsClick(lat: from.lat, lng: from.lng)
            }
        }
        if let to = order.to {
            markerEndView.onTap { [weak self] _ in
                self?.delegate?.onCordsClick(lat: to.lat, lng: to.lng)
            }
            endPointView.onTap { [weak self] _ in
                self?.delegate?.onCordsClick(lat: to.lat, lng: to.lng)
            }
        }

        updateConstraints()
    }

    func showOptionsSelector(order: Order, options: [OrderStatus]) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        for option in options {
            if (option == .technical_stop) {
                alert.addAction(UIAlertAction(title: "technical_stop".localized(), style: .default, handler: { (action: UIAlertAction!) -> Void in
                    self.delegate?.onTechnicalStop(order: order)
                }))
            }
            if (option == .on_road) {
                alert.addAction(UIAlertAction(title: "in_transit".localized(), style: .default, handler: { (action: UIAlertAction!) -> Void in
                    self.delegate?.onStartTrackOrder(order: order)
                }))
            }
            if (option == .completed) {
                alert.addAction(UIAlertAction(title: "completed".localized(), style: .default, handler: { (action: UIAlertAction!) -> Void in
                    self.delegate?.onCompleteOrder(order: order)
                }))
            }
        }

        alert.addAction(UIAlertAction(title: "cancel".localized(), style: .destructive, handler: { (_) in }))
        delegate?.providePresenter().present(alert, animated: true)
    }

    func onEditTimeClick(order: Order) {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date

        let dateChooserAlert = UIAlertController(title: "select_date".localized(), message: nil, preferredStyle: .actionSheet)
        dateChooserAlert.view.addSubview(datePicker)
        dateChooserAlert.addAction(UIAlertAction(title: "select".localized(), style: .cancel, handler: { [unowned self] action in
            self.showDateIntervalsPicker(order: order, date: datePicker.date)
        }))
        let height: NSLayoutConstraint = NSLayoutConstraint(item: dateChooserAlert.view!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.1, constant: 300)
        dateChooserAlert.view.addConstraint(height)
        delegate?.providePresenter().present(dateChooserAlert, animated: true, completion: nil)
    }

    func showDateIntervalsPicker(order: Order, date: Date) {
        let title = ""
        let message = "\n\n\n\n\n\n\n\n\n\n";

        let pickerFrame: CGRect = CGRect(x: 0, y: 0, width: (delegate?.providePresenter().view.width ?? CGFloat(220)) - 16, height: 230);
        let picker: UIPickerView = UIPickerView(frame: pickerFrame);

        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        alert.isModalInPopover = true;
        alert.addAction(UIAlertAction(title: "select".localized(), style: .cancel, handler: { [unowned self] action in
            let position = picker.selectedRow(inComponent: 0)
            let dateString = self.timeIntervals[position]

            let timeArray = dateString.components(separatedBy: " - ")
            let startHour = Int(timeArray[0])!
            let endHour = Int(timeArray[1])!

            let startDate = Calendar.current.date(bySettingHour: startHour, minute: 0, second: 0, of: date)!

            var endDate: Date
            if (endHour == 24) {
                endDate = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: date)!
                endDate = Calendar.current.date(byAdding: .day, value: 1, to: endDate)!
            } else {
                endDate = Calendar.current.date(bySettingHour: endHour, minute: 0, second: 0, of: date)!
            }

            //self.delegate?.onDatePicked(order: order, dateFrom: startDate, dateTo: endDate)
        }))

        picker.delegate = self;
        picker.dataSource = self;
        picker.clipsToBounds = true
        alert.view.addSubview(picker);

        delegate?.providePresenter().present(alert, animated: true)
    }

    override func updateConstraints() {
        var hideTimeBlock = true
        var hideStatusBlock = true
        var hideCompleteButton = true
        var hideActionButton = true

        if (order.status == OrderStatus.new) {
            hideActionButton = true
            hideCompleteButton = false
            hideTimeBlock = true
            hideStatusBlock = false
        }

        if (order.status == OrderStatus.on_road) {
            hideActionButton = true
            hideCompleteButton = false
            hideTimeBlock = true
            hideStatusBlock = false
        }

        if (order.status == OrderStatus.technical_stop) {
            hideActionButton = true
            hideCompleteButton = false
            hideTimeBlock = true
            hideStatusBlock = false
        }

        if (hideTimeBlock) {
            timeBlock.isHidden = true
            editTimeBlockHeight.isActive = true
            editTimeBlockHeight.constant = 0
        } else {
            timeBlock.isHidden = false
            editTimeBlockHeight.isActive = false
        }

        if (hideStatusBlock) {
            statusBlock.isHidden = true
            changeStatusBlockHeight.isActive = true
            changeStatusBlockHeight.constant = 0
        } else {
            statusBlock.isHidden = false
            changeStatusBlockHeight.isActive = false
        }

        if (hideActionButton) {
            actionButton.isHidden = true
            actionButtonHeight.constant = 0
        } else {
            actionButton.isHidden = false
            actionButtonHeight.constant = 40
        }

        if (hideCompleteButton) {
            completeOrderButton.isHidden = true
            completeButtonHeight.constant = 0
        } else {
            completeOrderButton.isHidden = false
            completeButtonHeight.constant = 40
        }

        super.updateConstraints()
    }
}

extension ActualOrderCell: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        timeIntervals.count
    }

    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return timeIntervals[row]
    }
}

protocol ActualOrderDelegate: class {
    func providePresenter() -> UIViewController
    func onStartTrackOrder(order: Order)
    func onTechnicalStop(order: Order)
    func onCompleteOrder(order: Order)
    func onCordsClick(lat: Double, lng: Double)
}
