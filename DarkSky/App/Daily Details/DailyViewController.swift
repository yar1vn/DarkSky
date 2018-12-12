//
//  DailyViewController.swift
//  DarkSky
//
//  Created by Yariv Nissim on 12/10/18.
//  Copyright © 2018 Yariv. All rights reserved.
//

import UIKit

final class DailyViewController: UIViewController, DarkSkyDailyContainer {
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var summaryLabel: UILabel!

    var daily: DarkSkyDaily!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Storyboards don't allow custom initializers so this property cannot be
        // checked in compile time.
        assert(daily != nil, "daily cannot be empty")

        updateUI()
    }

    private func updateUI() {
        summaryLabel.text = daily.summary
        imageView.image = daily.iconImage
    }
}
