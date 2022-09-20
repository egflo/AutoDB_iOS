//
//  NetworkManager.swift
//  AutoDB
//
//

import Foundation
import Alamofire
import Combine
import Auth0


enum NetworkError: Error {
    case invalidAuthorization
    case invalidJSON
    case invalidJSONResponse
    case invalidResponeCode
    case invalidURL
    case invalidCredentials
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

        }
    }
}

class NetworkManager {
    
    static let shared: NetworkManager = {
        return NetworkManager()
    }()
    
    let session: Session
    
    init() {
        session = Session()
        //#self.keychain = Keychain(service: "com.dataflix")
    }
    
    func getRequest<T: Decodable>(of type: T.Type = T.self, url: String, completion: @escaping (Result<T,Error>) -> Void) {
        let encoded_url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

        let headers: HTTPHeaders = [
            "Accept": "application/json"
        ]
        
        
        session.request(encoded_url!,
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

                    default:
                        completion(.failure(NetworkError.invalidResponeCode))
                
                }
                case .failure(let error):
                    completion(.failure(error))

                }
            })
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
        urlComponents.scheme = "http"
        urlComponents.host = "10.81.1.123"
        urlComponents.port = 8080
        urlComponents.path = "\(path)"
        urlComponents.queryItems = current
        
        
        guard canLoadMorePages else {
            return
        }
        
        isLoadingPage = true

        let encoded_url = urlComponents.url?.absoluteString
        print(encoded_url!)
        
        var request = URLRequest(url: URL(string: encoded_url!)!)
        request.httpMethod = "GET"


        
        var token = ""
        if auth {
            let credentialsManager = CredentialsManager(authentication: Auth0.authentication())
            
            credentialsManager.credentials { result in
                switch result {
                case .success(let credentials):
                    print("Obtained credentials: \(credentials)")
                    
                    let token = credentials.accessToken
                    print(token)
                    
                    request.setValue("Bearer \(credentials.accessToken)", forHTTPHeaderField: "Authorization")
                    request.setValue("Bearer \(credentials.accessToken)", forHTTPHeaderField: "Authorization")

                case .failure(let error):
                    print("Failed with: \(error)")
                }
            }
        
        }
        


        URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: Response<T>.self, decoder: JSONDecoder())
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
