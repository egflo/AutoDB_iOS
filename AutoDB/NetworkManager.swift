//
//  NetworkManager.swift
//  AutoDB
//
//

import Foundation
import Alamofire
import Combine
import Auth0

class API {
    static let scheme = "http"
    static let host = "192.168.18.12"
    static let port: Int = 8080
}


enum NetworkError: Error {
    case invalidAuthorization
    case invalidJSON
    case invalidJSONResponse
    case invalidResponeCode
    case invalidURL
    case invalidCredentials
    case notFound
}


extension NetworkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidAuthorization:
            return NSLocalizedString("Unauthorized Access", comment: "Invalid Authentication")
        case .invalidJSON:
            return NSLocalizedString("Unable to Encode Data Model", comment: "Invalid JSON")
        case .invalidJSONResponse:
            return NSLocalizedString("Invalid JSON From Recieved", comment: "Invalid JSON")
        case .invalidResponeCode:
            return NSLocalizedString("Invalide Respone Code", comment: "Non 200 Status Code")
        case .invalidURL:
            return NSLocalizedString("Invalid URL", comment: "Bad URL")
        case .invalidCredentials:
            return NSLocalizedString("Incorrect Email/Password", comment: "Bad Username/Password")
        case .notFound:
            return NSLocalizedString("Resource Not Found", comment: "Selected Resource was not found.")

        }
    }
}

class NetworkManager {
    
    static let shared: NetworkManager = {
        return NetworkManager()
    }()
    
    let session: Session
    var components: URLComponents
    
    init() {
        self.session = Session()
        
        var components = URLComponents()
        components.scheme = API.scheme
        components.host = API.host
        components.port = API.port
        self.components = components
        
        //#self.keychain = Keychain(service: "com.dataflix")
    }
    
    func getRequest<T: Decodable>(of type: T.Type = T.self, url: String, auth: Bool = false, completion: @escaping (Result<T,Error>) -> Void) {
        
        let path = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        components.path = path!
        
        let headers: HTTPHeaders = [
            "Accept": "application/json"
        ]
        
        if auth {
            
            let credentialsManager = CredentialsManager(authentication: Auth0.authentication())

            credentialsManager.credentials { result in
                switch result {
                case .success(let credentials):
                    print("Obtained credentials: \(credentials)")
                    let accessToken = credentials.accessToken
                    
                    let headers: HTTPHeaders = [
                        "Authorization": "Bearer \(accessToken)",
                        "Content-Type": "application/json",
                        "Accept": "application/json"
                    ]
                    
                    self.session.request(self.components.url!,
                               method: .get,
                               encoding: JSONEncoding.default,
                               headers: headers
                        )
                    
                        .validate(statusCode: 200..<500)
                        .response(completionHandler: { (response) in
                            switch response.result {
                                case .success(let data):
                                switch response.response?.statusCode {
                                case 200:
                                    do {
                                        let content = try JSONDecoder().decode(T.self, from:  data!)
                                        completion(.success(content))
                                        
                                    } catch let error {
                                        completion(.failure(error))
                                    }

                                default:
                                    completion(.failure(NetworkError.invalidResponeCode))
                            
                            }
                            case .failure(let error):
                                completion(.failure(error))

                            }
                        })

                case .failure(let error):
                    completion(.failure(error))
                }
            }
            
        }
        
        else {
            session.request(self.components.url!,
                       method: .get,
                       parameters: nil,
                       encoding: URLEncoding.default,
                       headers: headers
                )
            
                .validate(statusCode: 200..<500)
                .response(completionHandler: { (response) in
                    switch response.result {
                        case .success(let data):
                        switch response.response?.statusCode {
                        case 200:
                            do {
                                let content = try JSONDecoder().decode(T.self, from:  data!)
                                completion(.success(content))
                                
                            } catch let error {
                                completion(.failure(error))
                            }
                        case 404:
                            completion(.failure(NetworkError.notFound))

                        default:
                            print(response.response?.statusCode)
                            completion(.failure(NetworkError.invalidResponeCode))
                    
                    }
                    case .failure(let error):
                        completion(.failure(error))

                    }
                })
        }
        
    }
    
    func postRequest<T: Decodable>(of type: T.Type = T.self, url: String, parameters: Parameters, completion: @escaping (Result<T,Error>) -> Void) {
        
        // Prepare URL
        let path = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        components.path = path!
        
    
        guard let url = URL(string: path!) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        let credentialsManager = CredentialsManager(authentication: Auth0.authentication())

        credentialsManager.credentials { result in
            switch result {
            case .success(let credentials):
                print("Obtained credentials: \(credentials)")
                let accessToken = credentials.accessToken
                
                let headers: HTTPHeaders = [
                    "Authorization": "Bearer \(accessToken)",
                    "Content-Type": "application/json",
                    "Accept": "application/json"
                ]
                
                self.session.request(self.components.url!,
                           method: .post,
                           parameters: parameters,
                           encoding: JSONEncoding.default,
                           headers: headers
                    )
                
                    .validate(statusCode: 200..<500)
                    .response(completionHandler: { (response) in
                        switch response.result {
                            case .success(let data):
                            switch response.response?.statusCode {
                            case 200:
                                do {
                                    let content = try JSONDecoder().decode(T.self, from:  data!)
                                    completion(.success(content))
                                    
                                } catch let error {
                                    completion(.failure(error))
                                }

                            default:
                                completion(.failure(NetworkError.invalidResponeCode))
                        
                        }
                        case .failure(let error):
                            completion(.failure(error))

                        }
                    })

            case .failure(let error):
                completion(.failure(error))
            }
        }
                
    }
    
    func deleteRequest<T: Decodable>(of type: T.Type = T.self, url: String, completion: @escaping (Result<T,Error>) -> Void) {
        
        // Prepare URL
        let path = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        components.path = path!
        
        guard let url = URL(string: path!) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        let credentialsManager = CredentialsManager(authentication: Auth0.authentication())

        credentialsManager.credentials { result in
            switch result {
            case .success(let credentials):
                print("Obtained credentials: \(credentials)")
                let accessToken = credentials.accessToken

                
                let headers: HTTPHeaders = [
                    "Authorization": "Bearer \(accessToken)",
                    "Content-Type": "application/json",
                    "Accept": "application/json"
                ]
                
                self.session.request(self.components.url!,
                           method: .delete,
                           encoding: JSONEncoding.default,
                           headers: headers
                    )
                
                    .validate(statusCode: 200..<500)
                    .response(completionHandler: { (response) in
                        switch response.result {
                            case .success(let data):
                            switch response.response?.statusCode {
                            case 200:
                                do {
                                    let content = try JSONDecoder().decode(T.self, from:  data!)
                                    completion(.success(content))
                                    
                                } catch let error {
                                    completion(.failure(error))
                                }

                            default:
                                completion(.failure(NetworkError.invalidResponeCode))
                        
                        }
                        case .failure(let error):
                            completion(.failure(error))

                        }
                    })

            case .failure(let error):
                completion(.failure(error))
            }
        }
                
    }
}




class ContentDataSource<T: Codable & Equatable>: ObservableObject {
    @Published var items = [T]()
    @Published var isLoadingPage = false
    @Published var endOfList = false
    
    private var canLoadMorePages = true
    private var currentPage = 0
    private let pageSize = 25
    
    
    var auth: Bool
    var cancellable: Set<AnyCancellable> = Set()

    init(auth: Bool = false) {
        self.auth = auth
    }
    
    func reset() {
        items.removeAll()
        currentPage = 0
        canLoadMorePages = true
        isLoadingPage = false
        endOfList = false
    }
    
    
    func shouldLoadMore(item : T) -> Bool{
        if let last = items.last
        {
            if item == last{
                return true
            }
            else{
                return false
            }
        }
        return false
    }
    
    func fetch(path: String, params: [URLQueryItem], auth: Bool = false) {
        
        var current = params
        current.append(URLQueryItem(name: "limit", value: String(pageSize)))
        current.append(URLQueryItem(name: "page", value: String(currentPage)))

        var urlComponents = URLComponents()
        urlComponents.scheme = API.scheme
        urlComponents.host = API.host
        urlComponents.port = API.port
        urlComponents.path = path
        urlComponents.queryItems = current
        
        
        print(urlComponents.url!)
        
        guard canLoadMorePages else {
            return
        }
        
        isLoadingPage = true
        let encoded_url = urlComponents.url?.absoluteString
                
        var request = URLRequest(url: URL(string: encoded_url!)!)
        request.httpMethod = "GET"
        
        if auth {
            let credentialsManager = CredentialsManager(authentication: Auth0.authentication())
            
            credentialsManager.credentials { result in
                switch result {
                case .success(let credentials):
                    print("Obtained credentials: \(credentials)")
                    request.setValue("Bearer \(credentials.accessToken)", forHTTPHeaderField: "Authorization")
                    
                    URLSession.shared.dataTaskPublisher(for: request)
                        .map { $0.data }
                        .decode(type: Page<T>.self, decoder: JSONDecoder())
                        .eraseToAnyPublisher()
                        .receive(on: DispatchQueue.main)
                        .handleEvents(receiveOutput: { response in
                                                        
                            self.canLoadMorePages = !response.last
                            self.isLoadingPage = false
                            self.currentPage += 1
                            self.endOfList = response.content.isEmpty
                        })
                        .sink(receiveCompletion: { completion in
                        }) { item in
                            self.items.append(contentsOf: item.content)
                        }
                        .store(in: &self.cancellable)

                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        
        }
        

        else {
            URLSession.shared.dataTaskPublisher(for: request)
                .map { $0.data }
                .decode(type: Page<T>.self, decoder: JSONDecoder())
                .eraseToAnyPublisher()
                .receive(on: DispatchQueue.main)
                .handleEvents(receiveOutput: { response in
                    self.canLoadMorePages = !response.last
                    self.isLoadingPage = false
                    self.currentPage += 1
                    self.endOfList = response.content.isEmpty
                })
                .sink(receiveCompletion: { completion in
                }) { item in
                    self.items.append(contentsOf: item.content)
                }
                .store(in: &cancellable)
        }
 
    }
}
