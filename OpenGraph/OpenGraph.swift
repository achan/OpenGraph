import Foundation

public struct OpenGraph {
    fileprivate let source: [OpenGraphMetadata: String]
    
    public static func fetch(url: URL,header:[String:String], completion: @escaping (OpenGraph?, Error?) -> Void) {
        
        var mutableURLRequest = URLRequest(url: url)
        mutableURLRequest.setValue("Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.103 Safari/537.36", forHTTPHeaderField: "User-Agent")
        for hkey in header.keys {
            let value:String! = header[hkey]
            if value != nil {
                mutableURLRequest.setValue(value, forHTTPHeaderField: hkey)
            }
        }
        
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration)
        
        
        let task = session.dataTask(with: mutableURLRequest, completionHandler: { (data, response, error) in
            switch (data, response, error) {
            case (_, _, let error?):
                completion(nil, error)
                break
            case (let data?, let response as HTTPURLResponse, _):
                if !(200..<300).contains(response.statusCode) {
                    completion(nil, OpenGraphResponseError.unexpectedStatusCode(response.statusCode))
                } else {
                    guard let htmlString = String(data: data, encoding: String.Encoding.utf8) else {
                        completion(nil, OpenGraphParseError.encodingError)
                        return
                    }
                    
                    let og = OpenGraph(htmlString: htmlString)
                    completion(og, error)
                }
                break
            default:
                break
            }
        }) 
        
        task.resume()
    }
    
    init(htmlString: String, injector: () -> OpenGraphParser = { DefaultOpenGraphParser() }) {
        let parser = injector()
        source = parser.parse(htmlString: htmlString)
    }
    
    public subscript (attributeName: OpenGraphMetadata) -> String? {
        return source[attributeName]
    }
}

private struct DefaultOpenGraphParser: OpenGraphParser {
}
