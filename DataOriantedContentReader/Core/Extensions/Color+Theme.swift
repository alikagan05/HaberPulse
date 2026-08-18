import SwiftUI

extension Color {
    static func sectionColor(_ section: String) -> Color {
        switch section.lowercased() {
        case "technology":   return Color(hue: 0.60, saturation: 0.7, brightness: 0.85)
        case "science":      return Color(hue: 0.50, saturation: 0.6, brightness: 0.80)
        case "sport":        return Color(hue: 0.33, saturation: 0.65, brightness: 0.78)
        case "business":     return Color(hue: 0.15, saturation: 0.65, brightness: 0.82)
        case "culture":      return Color(hue: 0.75, saturation: 0.55, brightness: 0.80)
        case "world":        return Color(hue: 0.02, saturation: 0.70, brightness: 0.80)
        case "environment":  return Color(hue: 0.38, saturation: 0.60, brightness: 0.75)
        case "politics":     return Color(hue: 0.00, saturation: 0.55, brightness: 0.78)
        case "health":       return Color(hue: 0.90, saturation: 0.55, brightness: 0.80)
        default:             return Color.secondary
        }
    }
}
