//
//  BoardViewModel.swift
//  OrderMate
//
//  Created by 문영균 on 2023/03/20.
//

import Foundation

class BoardViewModel: ObservableObject {
    static var shared = BoardViewModel()
    @Published var board: BoardModel?
    
     init() {
        //리뷰 필요
        getBoard(postId: 1) { isComplete in
        }
    }
    
    //모든 리스트 정보 받아오기
    func GetAllRoomList(completionHandler: @escaping (Bool, Any) -> Void) {
        print("모든 리스트 정보 가져오기")
        if let url = URL(string: "http://localhost:8080/post") {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"

            let session = URLSession.shared
            let task = session.dataTask(with: request) { (data, response, error) in
                guard error == nil else {
                    print("Error: error calling GET")
                    print(error!)
                    return
                }
                guard let data = data else {
                    print("Error: Did not receive data")
                    return
                }
                guard let response = response as? HTTPURLResponse, (200 ..< 300) ~= response.statusCode else {
                    print("Error: HTTP request failed")
                    return
                }
                
                do {
                    let output = try JSONDecoder().decode([RoomInfoPreview].self, from: data)
                    print(output)
                    print("JSON Data Parsing")
                    
                    
                    completionHandler(true, output)
                } catch {
                    print(error)
                }
            }
            task.resume()
        }
    }
    
    //특정 게시물 받아오기
    func getBoard(postId: Int, completion: @escaping (Bool) -> Void) {
        let url = URL(string: urlString + APIModel.post.rawValue + "/" + String(postId))
        
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            let successRange = 200..<300
            guard error == nil, let statusCode = (response as? HTTPURLResponse)?.statusCode, successRange.contains(statusCode) else {
                print()
                print("Error occur: \(String(describing: error)) error code: \((response as? HTTPURLResponse)?.statusCode)")
                completion(false)
                return
            }
            guard let data = data else {
                print("invalid data")
                completion(false)
                return
            }
            let decoder = JSONDecoder()
            
            do {
                let response = try decoder.decode(BoardModel.self, from: data)
                DispatchQueue.main.async {
                    self.board = response
                    completion(true)
                }
            } catch {
                print("error occured.")
            }
            
            let getSuccess = 200
            if getSuccess == (response as? HTTPURLResponse)?.statusCode {
                print("게시글 정보 get 성공")
                print(response as Any)
                completion(true)
                
            } else {
                print("게시글 정보 get 실패")
                print(response as Any)
                completion(false)
            }
        }
        task.resume()
    }
    
    //게시글 생성하기
    func UploadData(title:String, maxPeopleNum:String, isAnonymous:Int,
                    spaceType:String, content:String, withOrderLink:String,
                    pickupSpace:String, accountNum:String, estimatedOrdTime:String
                    ,completion: @escaping (Bool) -> Void) {
        let post = CreatRoom(title: title, maxPeopleNum: maxPeopleNum, isAnonymous: isAnonymous,
                             spaceType: spaceType, content: content, withOrderLink: withOrderLink,
                             pickupSpace: pickupSpace, accountNum: accountNum, estimatedOrdTime: estimatedOrdTime)
    
        guard let uploadData = try? JSONEncoder().encode(post)
        else {
            completion(false)
            return
        }
        
        let url = URL(string: "http://localhost:8080/post/upload")
        
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        let task = session.uploadTask(with: request, from: uploadData) { data, response, error in

            let successRange = 200..<300
            guard error == nil, let statusCode = (response as? HTTPURLResponse)?.statusCode, successRange.contains(statusCode) else {
                print((response as? HTTPURLResponse)?.statusCode)
                print("Error occur: \(String(describing: error))")
                return
            }
            
            
            let postSuccess = 201
            if postSuccess == (response as? HTTPURLResponse)?.statusCode {
                print("새 글 post 성공")
                print(response as Any)
                completion(true)
            }
        }
        task.resume()
    }
}
