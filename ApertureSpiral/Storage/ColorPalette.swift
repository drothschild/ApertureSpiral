import SwiftUI

struct PaletteColor: Codable, Equatable {
    let r: Double
    let g: Double
    let b: Double

    init(_ r: Double, _ g: Double, _ b: Double) {
        self.r = r
        self.g = g
        self.b = b
    }
}

struct ColorPalette: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let colors: [PaletteColor]

    var colorComponents: [(r: Double, g: Double, b: Double)] {
        colors.map { ($0.r, $0.g, $0.b) }
    }

    var swiftUIColors: [Color] {
        colors.map { Color(red: $0.r / 255, green: $0.g / 255, blue: $0.b / 255) }
    }
}

extension ColorPalette {
    static let warm = ColorPalette(
        id: "warm",
        name: "Warm",
        colors: [
            PaletteColor(248, 181, 0),
            PaletteColor(255, 107, 53),
            PaletteColor(247, 37, 133),
            PaletteColor(114, 9, 183),
            PaletteColor(72, 149, 239),
            PaletteColor(0, 245, 160),
            PaletteColor(255, 200, 87),
            PaletteColor(255, 71, 87),
        ]
    )

    static let cool = ColorPalette(
        id: "cool",
        name: "Cool",
        colors: [
            PaletteColor(0, 150, 199),
            PaletteColor(0, 119, 182),
            PaletteColor(0, 180, 216),
            PaletteColor(144, 224, 239),
            PaletteColor(72, 202, 228),
            PaletteColor(202, 240, 248),
            PaletteColor(3, 4, 94),
            PaletteColor(2, 62, 138),
        ]
    )

    static let ocean = ColorPalette(
        id: "ocean",
        name: "Ocean",
        colors: [
            PaletteColor(0, 77, 64),
            PaletteColor(0, 121, 107),
            PaletteColor(38, 166, 154),
            PaletteColor(128, 203, 196),
            PaletteColor(178, 223, 219),
            PaletteColor(0, 150, 136),
            PaletteColor(77, 182, 172),
            PaletteColor(0, 188, 212),
        ]
    )

    static let sunset = ColorPalette(
        id: "sunset",
        name: "Sunset",
        colors: [
            PaletteColor(255, 183, 77),
            PaletteColor(255, 138, 101),
            PaletteColor(255, 112, 67),
            PaletteColor(255, 87, 51),
            PaletteColor(244, 67, 54),
            PaletteColor(239, 83, 80),
            PaletteColor(255, 205, 210),
            PaletteColor(255, 171, 145),
        ]
    )

    static let rainbow = ColorPalette(
        id: "rainbow",
        name: "Rainbow",
        colors: [
            PaletteColor(255, 0, 0),
            PaletteColor(255, 127, 0),
            PaletteColor(255, 255, 0),
            PaletteColor(0, 255, 0),
            PaletteColor(0, 0, 255),
            PaletteColor(75, 0, 130),
            PaletteColor(148, 0, 211),
            PaletteColor(255, 192, 203),
        ]
    )

    static let pastel = ColorPalette(
        id: "pastel",
        name: "Pastel",
        colors: [
            PaletteColor(255, 179, 186),
            PaletteColor(255, 223, 186),
            PaletteColor(255, 255, 186),
            PaletteColor(186, 255, 201),
            PaletteColor(186, 225, 255),
            PaletteColor(218, 186, 255),
            PaletteColor(255, 186, 255),
            PaletteColor(186, 255, 255),
        ]
    )

    static let monochrome = ColorPalette(
        id: "monochrome",
        name: "Monochrome",
        colors: [
            PaletteColor(255, 255, 255),
            PaletteColor(224, 224, 224),
            PaletteColor(189, 189, 189),
            PaletteColor(158, 158, 158),
            PaletteColor(117, 117, 117),
            PaletteColor(97, 97, 97),
            PaletteColor(66, 66, 66),
            PaletteColor(33, 33, 33),
        ]
    )

    static let neon = ColorPalette(
        id: "neon",
        name: "Neon",
        colors: [
            PaletteColor(255, 0, 102),
            PaletteColor(0, 255, 255),
            PaletteColor(255, 255, 0),
            PaletteColor(0, 255, 0),
            PaletteColor(255, 0, 255),
            PaletteColor(255, 102, 0),
            PaletteColor(102, 0, 255),
            PaletteColor(0, 255, 102),
        ]
    )

    static let allBuiltIn: [ColorPalette] = [
        .warm, .cool, .ocean, .sunset, .rainbow, .pastel, .monochrome, .neon
    ]

    static let `default` = warm

    static func find(id: String) -> ColorPalette? {
        allBuiltIn.first { $0.id == id }
    }
}
