import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

package let traqAPIClient = Client(
    serverURL: {
        do {
            let url = try Servers.Server1.url()
            return url
        } catch {
            fatalError()
        }
    }(),
    configuration: Configuration(
        dateTranscoder: ISO8601DateTranscoder(options: .withFractionalSeconds)
    ),
    transport: URLSessionTransport()
)
