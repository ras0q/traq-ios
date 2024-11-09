import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

package let traqServerURL = {
    do {
        let url = try Servers.Server1.url()
        return url
    } catch {
        fatalError()
    }
}()

package let traqAPIClient = Client(
    serverURL: traqServerURL,
    configuration: Configuration(
        dateTranscoder: CustomDateTranscoder()
    ),
    transport: URLSessionTransport()
)


struct CustomDateTranscoder: DateTranscoder {
    let dateFormatter: DateFormatter
    let dateFormatterWithFractional: DateFormatter

    init() {
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd'T'HH:mm:ssZ"
        dateFormatter.locale = .current
        dateFormatter.timeZone = .current

        dateFormatterWithFractional = DateFormatter()
        dateFormatterWithFractional.dateFormat = "YYYY-MM-dd'T'HH:mm:ss.SSSSSSZ"
        dateFormatterWithFractional.locale = .current
        dateFormatterWithFractional.timeZone = .current
    }

    func encode(_ date: Date) throws -> String {
        dateFormatterWithFractional.string(from: date)
    }

    func decode(_ dateString: String) throws -> Date {
        if let date = dateFormatterWithFractional.date(from: dateString) {
            return date
        }

        if let date = dateFormatter.date(from: dateString) {
            return date
        }

        throw DecodingError.dataCorrupted(
            .init(
                codingPath: [],
                debugDescription: "Expected date string to be ISO8601-formatted."
            )
        )
    }
}
