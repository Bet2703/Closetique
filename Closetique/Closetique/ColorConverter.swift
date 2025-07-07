import Foundation

class ColorConverter {
    static func getColorName(from hex: String, completion: @escaping (String?) -> Void) {
        let sanitizedHex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        guard let url = URL(string: "https://www.thecolorapi.com/id?hex=\(sanitizedHex)") else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                error == nil,
                let data = data,
                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                let nameInfo = json["name"] as? [String: Any],
                let name = nameInfo["value"] as? String
            else {
                completion(nil)
                return
            }

            completion(name)
        }.resume()
    }
}
