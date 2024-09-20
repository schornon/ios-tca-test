//
//  Book.swift
//  BooksSummary
//
//  Created by Serhii Chornonoh on 20.09.2024.
//

import Foundation

struct Book: Equatable {
    let coverPath: String
    let keyPoints: [KeyPoint]
}

struct KeyPoint: Equatable {
    let shortText: String
    let audioPath: String
    //let text: String
}


extension Book {
    static var mock: Book {
        .init(
            coverPath: "https://a.dropoverapp.com/cloud/download/44bcadc6-7de4-48b8-8a89-c2af9b77ab5e/8277c683-6c2b-41bc-8a27-dd6bc86b9a09",
            keyPoints: [
                .init(
                    shortText: "The number of the chapter is one. This chapter is perfect.",
                    audioPath: "https://a.dropoverapp.com/cloud/download/2af3cf6e-d413-47d5-8aa2-f1dc17bfe34a/539d9a00-92d0-4b69-9d6a-e974741657c8"
                ),
                .init(
                    shortText: "The number of the chapter is two. This chapter is the center of the book. Something intresting you can find here.",
                    audioPath: "https://a.dropoverapp.com/cloud/download/f0a875df-fb9f-485c-9dd7-f40ebf966fe6/35f7d4db-5290-4489-9e23-c25b09b864ce"
                ),
                .init(
                    shortText: "The number of the chapter is three. It's Briliant!",
                    audioPath: "https://a.dropoverapp.com/cloud/download/01c02fe2-240b-4e08-a590-1fe97d388c77/aa18b5b1-8c65-4a16-b000-85aa5a517dbf"
                )
            ]
        )
    }
}
