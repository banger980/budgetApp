//
//  AddCategoryViewController.swift
//  BudgetApp
//
//  Created by Nikita on 2.02.23.
//

import UIKit

final class AddCategoryViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var number = ""
    private var currencyArray: [CurrencyRealmModel] = RealmManager<CurrencyRealmModel>().read()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        registerCells()
        collectionView.dataSource = self
        collectionView.delegate = self
        
    }
    
    
    private func registerCells() {
        let nib = UINib(nibName: AddCategoryCollectionViewCell.id, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: AddCategoryCollectionViewCell.id)
    }
    
   
    
    @IBAction func deleteSheetController(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func makeYourCategory(_ sender: UIButton) {
        let vc = AddNewCurrencyViewController(nibName: "AddNewCurrencyViewController", bundle: nil)
        present(vc, animated: true)
        vc.completionHandler = { [weak self] in
            self?.currencyArray = RealmManager<CurrencyRealmModel>().read()
            self?.collectionView.reloadData()
        }
    }
    
}

extension AddCategoryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let currency = currencyArray[indexPath.row]
        let changeCurrency = currencyArray.filter { $0.name == currency.name }.first
        guard let changeCurrency else { return }
        print(currency.sum)
        let transaction = ReplenishmentRealmModel(count: Int(number)!, ownerID: changeCurrency.id)
        RealmManager<ReplenishmentRealmModel>().write(object: transaction)
        
        RealmManager<CurrencyRealmModel>().update { realm in
            try? realm.write({
                changeCurrency.sum = currency.sum + Int(self.number)!
            })
        }
        dismiss(animated: true, completion: nil)
    }
}

 
extension AddCategoryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currencyArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AddCategoryCollectionViewCell.id, for: indexPath)
            guard let currencyCell = cell as? AddCategoryCollectionViewCell else { return cell }
            currencyCell.set(image: UIImage(systemName: currencyArray[indexPath.row].image)!)
            return currencyCell
        }
        
    }


extension AddCategoryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let inset = 25.0
        guard let screen = view.window?.windowScene?.screen else { return .zero }
        let cellCount = 4.0
        let width = (screen.bounds.width - (inset * (cellCount + 1)))  / cellCount
        return CGSize(width: width, height: width)
    }
}
