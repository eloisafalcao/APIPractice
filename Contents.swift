//: A UIKit based Playground for presenting user interface

import UIKit

//MARK: DEALING WITH ERROR
//Aqui podemos criar um enum para cada erro Code
enum HolidayError: Error {
    case notAvaliable
}

// MARK: DATA MODELS
struct HolidaysResponse: Decodable {
    var response: Holidays
}

struct Holidays: Decodable {
    var holidays: [HolidayDetail]
}

struct HolidayDetail: Decodable {
    var name: String
    var date: DateInfo
}

struct DateInfo: Decodable {
    var iso: String
}

//MARK: REQUESTS
struct HolidayRequest {
    let resourceURL: URL
    let API_KEY = "7b304dfc994784b8805abbe41653e2f3296ac52b"

    init(contryCode: String) {
        let date = Date()
        let format = DateFormatter()
        format.dateFormat = "yyyy"
        let currentYear = format.string(from: date)

        let resourceString = "https://calendarific.com/api/v2/holidays?api_key=\(API_KEY)&country=\(contryCode)&year=\(currentYear)"

        guard let resourceURL = URL(string: resourceString) else {fatalError()}
        self.resourceURL = resourceURL
    }

    // A funcão que vai de fato ser a request, tudo isso acontece de forma assíncrona.
    func getHolidays(completion: @escaping(Result<[HolidayDetail], Error>) -> Void) {
        URLSession.shared.dataTask(with: resourceURL) {(data, resp, error) in
            guard let jsonData = data else { return
//                completion(.failure(.notAvaliable))
            }

            do {
                let decoder = JSONDecoder()
                let hollidaysResponse = try decoder.decode(HolidaysResponse.self, from: jsonData)
                let hollidayDetails = hollidaysResponse.response.holidays
                completion(.success(hollidayDetails))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

// MARK: CHAMANDO A FUNÇÃO DA REQUEST
var listOfHollidays = [HolidayDetail]()
let countryCode = "BR"

let request = HolidayRequest(contryCode: countryCode)
request.getHolidays { result in
    switch result {
    case .failure(let error):
        print(error)
    case .success(let hollidays):
        listOfHollidays = hollidays
    }

    listOfHollidays.forEach { (holiday) in
        print(holiday.name)
    }
}
