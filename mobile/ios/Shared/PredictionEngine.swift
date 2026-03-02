import Foundation

final class PredictionEngine {
    private var prefixMap: [String: [String]] = [:]
    private var nextMap: [String: [String]] = [:]

    func loadModel(bundle: Bundle = .main) {
        prefixMap = loadPrefix(bundle: bundle)
        nextMap = loadNext(bundle: bundle)
    }

    func suggestPrefix(_ prefix: String, topN: Int = 3) -> [String] {
        guard Self.isKhmerWord(prefix) else { return [] }
        return Array((prefixMap[prefix] ?? []).prefix(max(1, topN)))
    }

    func predictNext(_ w1: String, _ w2: String, topN: Int = 3) -> [String] {
        guard Self.isKhmerWord(w1), Self.isKhmerWord(w2) else { return [] }
        return Array((nextMap["\(w1)\t\(w2)"] ?? []).prefix(max(1, topN)))
    }

    static func isKhmerWord(_ text: String) -> Bool {
        guard !text.isEmpty else { return false }
        var hasKhmer = false
        for scalar in text.unicodeScalars {
            let v = scalar.value
            if CharacterSet.whitespacesAndNewlines.contains(scalar) { continue }
            let isKhmer = (0x1780...0x17FF).contains(v) || (0x19E0...0x19FF).contains(v)
            if !isKhmer { return false }
            hasKhmer = true
        }
        return hasKhmer
    }

    private func loadPrefix(bundle: Bundle) -> [String: [String]] {
        guard let url = bundle.url(forResource: "prefix", withExtension: "tsv", subdirectory: "Model"),
              let text = try? String(contentsOf: url, encoding: .utf8) else {
            return [:]
        }
        var out: [String: [String]] = [:]
        for line in text.split(separator: "\n") {
            let parts = line.split(separator: "\t", maxSplits: 1)
            if parts.count != 2 { continue }
            let key = String(parts[0])
            if !Self.isKhmerWord(key) { continue }
            let vals = parts[1].split(separator: "|").map(String.init).filter { Self.isKhmerWord($0) }
            if !vals.isEmpty { out[key] = vals }
        }
        return out
    }

    private func loadNext(bundle: Bundle) -> [String: [String]] {
        guard let url = bundle.url(forResource: "next", withExtension: "tsv", subdirectory: "Model"),
              let text = try? String(contentsOf: url, encoding: .utf8) else {
            return [:]
        }
        var out: [String: [String]] = [:]
        for line in text.split(separator: "\n") {
            let parts = line.split(separator: "\t")
            if parts.count < 3 { continue }
            let w1 = String(parts[0])
            let w2 = String(parts[1])
            if !Self.isKhmerWord(w1) || !Self.isKhmerWord(w2) { continue }
            let vals = parts[2].split(separator: "|").map(String.init).filter { Self.isKhmerWord($0) }
            if !vals.isEmpty { out["\(w1)\t\(w2)"] = vals }
        }
        return out
    }
}

