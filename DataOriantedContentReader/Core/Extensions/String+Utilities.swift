// String+Utilities.swift
// DataOriantedContentReader
// Core → Extensions

import Foundation

extension String {

    /// HTML etiketlerini temizler (<p>, <b>, <a href="..."> vb.)
    func strippingHTML() -> String {
        guard let data = data(using: .utf8) else { return self }
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue,
        ]
        let attributed = try? NSAttributedString(data: data, options: options, documentAttributes: nil)
        return attributed?.string ?? self
    }

    /// Kelime sayısına göre tahmini okuma süresi (dakika).
    /// Ortalama okuma hızı: 238 kelime/dakika.
    var estimatedReadTimeMinutes: Int {
        let wordCount = self.split(separator: " ").count
        return max(1, Int(ceil(Double(wordCount) / 238.0)))
    }

    /// Boş veya sadece boşluk içerip içermediği.
    var isBlank: Bool {
        trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
