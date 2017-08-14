//
//  SessionFactory.swift
//  MRNBike
//
//  Created by Bartosz Wilkusz on 26.06.17.
//
//

import Foundation

class SessionFactory {
    
    private var session: URLSession;
    
    private static var sharedSessionFactory: SessionFactory = {
        
        let sessionFactory = SessionFactory()
        
        return sessionFactory
    }()
    
    private init() {
        let config = URLSessionConfiguration.default
        self.session = URLSession(configuration: config, delegate: nil, delegateQueue:OperationQueue.main)
    }
    
    class func shared() -> SessionFactory {
        return sharedSessionFactory
    }
    
    func getSession() -> URLSession {
        return self.session
    }
}
