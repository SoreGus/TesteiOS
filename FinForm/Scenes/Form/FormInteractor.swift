//
//  FormInteractor.swift
//  FinForm
//
//  Created by Gustavo Luís Soré on 23/07/2018.
//  Copyright (c) 2018 Sore. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol FormBusinessLogic
{
  func fetchCells(request: Form.FetchCells.Request)
  func showHideCell(request: Form.ShowHideCell.Request)
  func validate(request: Form.Validate.Request)
  func restart(request: Form.Restart.Request)
}

protocol FormDataStore
{
    var arrayMetaData: [CellMetaData] { get set }
}

class FormInteractor: FormBusinessLogic, FormDataStore
{

  var presenter: FormPresentationLogic?
  var cellWorker = CellWorker(cellEngine: CellRequester())
  var formWorker = FormWorker()
    
    // MARK: Data Store
  var arrayMetaData: [CellMetaData] = []
  
  // MARK: Fetch Cells
    func fetchCells(request: Form.FetchCells.Request) {
        cellWorker.fetchCells(completionHandler: { (result) in
            switch result{
            case .Success(let cells):
                let arrayMetaData = self.formWorker.sort(array: self.formWorker.generateMetaDataArray(cells: cells))
                let response = Form.FetchCells.Response.init(arrayMetaData: arrayMetaData, noInternt: false)
                self.arrayMetaData = arrayMetaData
                self.presenter?.presentFetchedCells(response: response)
            case .Failure(let error):
                switch error{
                case .RequestError(let requestRrror):
                    switch requestRrror{
                    case .NoInternetAcces:
                        let response = Form.FetchCells.Response.init(arrayMetaData: [], noInternt: true)
                        self.presenter?.presentFetchedCells(response: response)
                    default:
                        let response = Form.FetchCells.Response.init(arrayMetaData: [], noInternt: true)
                        self.presenter?.presentFetchedCells(response: response)
                        break
                    }
                    break
                default:
                    let response = Form.FetchCells.Response.init(arrayMetaData: [], noInternt: false)
                    self.presenter?.presentFetchedCells(response: response)
                    break
                }
            }
        })
    }
    
  // MARK: Show / Hide Cell
    func showHideCell(request: Form.ShowHideCell.Request) {
        let cellMetaData = request.cellMetaData
        
        let result = formWorker.didSelect(cellMetaData: cellMetaData, arrayMetaData: self.arrayMetaData)
        self.arrayMetaData[result.index] = result.cellMetaData
        
        let response = Form.ShowHideCell.Response.init(cellMetaData: result.cellMetaData, index: result.index, show: result.show)
        presenter?.showHideCell(response: response)
    }
    
    // MARK: Validation
    func validate(request: Form.Validate.Request){
        let metaData:CellMetaData? = formWorker.validateForm(arrayMetaData: request.arrayMetaData)
        let response = Form.Validate.Response.init(wrongMetaData: metaData)
        presenter?.validate(response: response)
    }
    
    // MARK: Restart
    func restart(request: Form.Restart.Request){
        arrayMetaData = formWorker.restartCellsMetaData(arrayMetaData: arrayMetaData)
        let response = Form.Restart.Response.init(arrayMetaData: arrayMetaData)
        presenter?.restart(response: response)
    }
    
}
