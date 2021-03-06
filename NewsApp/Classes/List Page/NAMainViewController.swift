//
//  NAMainViewController.swift
//  NewsApp
//
//  Created by Dmitriy Lupych on 7/8/19.
//  Copyright © 2019 Dmitry Lupich. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class NAMainViewController: NABaseViewController {
    
    // MARK: - Properties

    private let tableView = UITableView()
    private let viewModel: MainViewModel
    private let refreshControl = UIRefreshControl()
    
    // MARK: - Initialization
    
    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bindViewModel()
    }
}

// MARK: - Setup View

extension NAMainViewController {
    private func setupView() {
        view.addSubview(tableView)
        refreshControl.layer.zPosition = -1
        tableView.addSubview(refreshControl)
        tableView.register(NAListTableViewCell.self)
        tableView.rowHeight = Constants.rowHeigh
        tableView.translatesAutoresizingMaskIntoConstraints = false
        let _ = [tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
                 tableView.topAnchor.constraint(equalTo: view.topAnchor),
                 tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
                 tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ].map { $0.isActive = true }

        tableView.rx.itemSelected
            .bind { [unowned self] indexPath in
                self.tableView
                    .deselectRow(at: indexPath, animated: true)
            }.disposed(by: disposeBag)
    }
}

// MARK: - Bind ViewModel

extension NAMainViewController {
    private func bindViewModel() {

        let lastCellIndex = tableView.rx
            .willDisplayCell
            .map { $0.indexPath.row }

        let refresh = refreshControl.rx
            .controlEvent(.valueChanged)
            .asObservable()

        let modelSelected = tableView.rx
            .modelSelected(NewsModel.self)
            .asObservable()

        let input = MainViewModel.Input(didLoad: didLoad.asObservable(),
                                        lastCellIndex: lastCellIndex,
                                        onRefresh: refresh,
                                        onSelectedModel: modelSelected)

        let output = viewModel.transform(input: input)

        output.news
            .share()
            .bind(to: tableView
                .rx
                .items(cellIdentifier: NAListTableViewCell.reuseIdentifier,
                       cellType: NAListTableViewCell.self))
            { row, model, cell in
                cell.fill(model)
            }.disposed(by: disposeBag)

        output.isLoading
            .bind(to: refreshControl.rx.isRefreshing)
            .disposed(by: disposeBag)

        output.errorMessage
            .bind { (text) in
                Logger.log(message: "Error catched in VC",
                           value: text,
                           logType: .error)
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - Constants

extension NAMainViewController {
    struct Constants {
        static let rowHeigh: CGFloat = 64.0
    }
}
