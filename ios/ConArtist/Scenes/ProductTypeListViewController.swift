//
//  ProductTypeListViewController.swift
//  ConArtist
//
//  Created by Cameron Eldridge on 2017-12-23.
//  Copyright © 2017 Cameron Eldridge. All rights reserved.
//

import UIKit
import RxSwift
import MaterialComponents.MaterialSnackbar

class ProductTypeListViewController: UIViewController {
    fileprivate static let ID = "ProductTypeList"
    @IBOutlet weak var productTypesTableView: UITableView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    fileprivate var convention: Convention!
    fileprivate let øproductTypes = Variable<[ProductType]>([])
    fileprivate let øproducts = Variable<[Product]>([])
    fileprivate let øprices = Variable<[Price]>([])
    fileprivate let disposeBag = DisposeBag()

    fileprivate let results = PublishSubject<([Product], Money)>()
}

// MARK: - Lifecycle
extension ProductTypeListViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        øproductTypes
            .asDriver()
            .map(const(()))
            .drive(onNext: productTypesTableView.reloadData)
            .disposed(by: disposeBag)
        
        titleLabel.text = convention.name
        
        backButton.rx.tap
            .filter { [tabBarController] _ in tabBarController?.selectedViewController == self }
            .subscribe(onNext: { _ in ConArtist.model.navigate(back: 1) })
            .disposed(by: disposeBag)
    }
}

// MARK: - UITableViewDataSource
extension ProductTypeListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? øproductTypes.value.count : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ProductTypeTableViewCell.ID, for: indexPath) as! ProductTypeTableViewCell
        if indexPath.row < øproductTypes.value.count {
            let item = øproductTypes.value[indexPath.row]
            cell.fill(with: item)
        }
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ProductTypeListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let productType = øproductTypes.value[indexPath.row]
        let products = øproducts.value.filter { $0.typeId == productType.id }
        let prices = øprices.value.filter { $0.typeId == productType.id }
        ProductListViewController.show(for: productType, products, and: prices)
            .flatMap { [unowned self] (products, price) -> Observable<Void> in
                let newRecord = Record(id: nil, products: products.map { $0.id }, price: price, time: Date())
                self.convention.addRecord(newRecord)
                return self.convention.save()
                    .catchError { _ in
                        MDCSnackbarManager.show(MDCSnackbarMessage(text: "Some data could not be saved... Check your network status"))
                        return Observable.empty()
                    }
            }
            .subscribe(onNext: { _ in MDCSnackbarManager.show(MDCSnackbarMessage(text: "Saved!")) })
            .disposed(by: disposeBag)
    }
}

// MARK: Navigation
extension ProductTypeListViewController {
    class func show(for convention: Convention) -> Observable<([Product], Money)> {
        let controller: ProductTypeListViewController = ProductTypeListViewController.instantiate(withId: ProductTypeListViewController.ID)

        controller.convention = convention
        convention.products
            .bind(to: controller.øproducts)
            .disposed(by: controller.disposeBag)
        convention.productTypes
            .bind(to: controller.øproductTypes)
            .disposed(by: controller.disposeBag)
        convention.prices
            .bind(to: controller.øprices)
            .disposed(by: controller.disposeBag)

        ConArtist.model.navigate(present: controller)
        return controller.results.asObservable()
    }
}