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
        dateTranscoder: ISO8601DateTranscoder(options: .withFractionalSeconds)
    ),
    transport: URLSessionTransport()
)
