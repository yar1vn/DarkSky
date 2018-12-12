//
//  WeatherViewController.swift
//  DarkSky
//
//  Created by Yariv Nissim on 12/10/18.
//  Copyright © 2018 Yariv. All rights reserved.
//

import UIKit

final class ForecastViewController: UITableViewController {
    private let viewModel = ForecastViewModel(darkSky: DarkSkyService(apiKey: "05ddd5da3a5fe8f422d08abfe6ff08cd"),
                                              locationService: LocationService(),
                                              cellIdentifier: "DailyCell")

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.stateChanged = self.handleState
        tableView.dataSource = viewModel
    }

    func handleState(state: ForecastViewModel.State) {
        DispatchQueue.main.async {
            switch state {
            case .loading:
                break // a good place to put a loading indicator
            case .location(let location):
                self.viewModel.loadWeatherForecast(for: location)
            case .forecast, .empty:
                self.tableView.reloadData()
            case .error(let error):
                print(error.localizedDescription)
            }
        }
    }

    @IBAction func findCurrentLocation(_ sender: UIBarButtonItem) {
        viewModel.findCurrentLocation()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if var dailyContainer = segue.destination as? DarkSkyDailyContainer,
            let indexPath = tableView.indexPath(for: sender),
            let dailyForecast = viewModel[indexPath] {
            dailyContainer.daily = dailyForecast
        }
    }
}
