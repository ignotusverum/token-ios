//
//  TMRequestViewModel.swift
//  consumer
//
//  Created by Gregory Sapienza on 2/14/17.
//  Copyright © 2017 Human Ventures Co. All rights reserved.
//

import CoreStore
import IGListKit
import Foundation

protocol TMRequestViewModelProtocol {
    
    /// Called when new requests have been fetched successfully.
    ///
    /// - Parameter requests: Requests fetched from database.
    func newRequestsFetched(requests: [TMRequest])
    
    /// Called when new requests have been updated successfully.
    ///
    /// - Parameter requests: Requests updated in database.
    func reloadRequestsFetched(request: TMRequest)
    
    /// Called when new requests have been fetched unsuccessfully.
    ///
    /// - Parameter error: Error for fetch request.
    func requestFetchError(error: Error)
}

class TMRequestViewModel: ListSectionObserver {
    // MARK: - Public iVars
    
    /// Number of requests in collection view.
    var totalCount = 0
    
    /// Delegate representing TMRequestViewModelProtocol.
    var delegate: TMRequestViewModelProtocol?

    // MARK: - Private iVars

    /// Paging size.
    private let pageSize = 20
    
    /// Current page.
    private var currentPage = 0
    
    // Observers
    let requestMonitor: ListMonitor<TMRequest> = {
        
        return TMCoreDataManager.defaultStack.monitorList(From<TMRequest>(),
                                                          OrderBy(.descending("createdAt")),
                                                          Tweak { fetchRequest-> Void in
                                                            fetchRequest.fetchLimit = 20
        })
    }()
    
    init() {
        
        requestMonitor.addObserver(self)
    }
    
    // MARK: - Public

    /// Fetch requests.
    ///
    /// - Parameter completion: Completion closure.
    func fetchRequest(_ completion: @escaping ()->()?) {
        let nextPage = currentPage + 1
        currentPage = nextPage
        
        fetchDataForPage(currentPage) { requests -> Void in
            
            self.requestMonitor.refetch(Tweak { fetchRequest-> Void in
                
                fetchRequest.fetchLimit = self.currentPage * self.pageSize
            })
            
            completion()
        }
    }
    
    // MARK: - Private

    /// Fetch data for a page.
    ///
    /// - Parameters:
    ///   - page: Page to fetch.
    ///   - completion: Fetch completion closure.
    private func fetchDataForPage(_ page: Int, completion: (([TMRequest]) -> Void)?) {
        
        let numberOfItemsToLoad = page * pageSize
        
        fetchDataWithNumberOfResults(numberOfItemsToLoad) { requests in
            completion?(requests)
        }
    }
    
    /// Fetches data with a limited number of results.
    ///
    /// - Parameters:
    ///   - numberOfResults: Number of results to fetch.
    ///   - completion: Fetch completion closure.
    private func fetchDataWithNumberOfResults(_ numberOfResults: Int, completion: (([TMRequest]) -> Void)?) {
        
        // Fetch request list with page limit - for first page
        TMRequestAdapter.fetchRequestList(limit: numberOfResults).then { requestArray -> Void in
            
            self.totalCount = TMRequestAdapter.totalCount
            
            if self.currentPage * self.pageSize > self.totalCount {
                
                self.currentPage = (self.totalCount / self.pageSize) + 1
            }
            
            self.delegate?.newRequestsFetched(requests: requestArray)
            completion?(requestArray)
            }.catch { error in
                self.delegate?.requestFetchError(error: error)
        }
    }
    
    // MARK: ListObjectObserver
    func listMonitor(_ monitor: ListMonitor<TMRequest>, didUpdateObject object: TMRequest, atIndexPath indexPath: IndexPath) {
        
        delegate?.reloadRequestsFetched(request: object)
    }
    
    func listMonitorDidChange(_ monitor: ListMonitor<TMRequest>) { }
}
