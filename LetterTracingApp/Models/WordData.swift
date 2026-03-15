import Foundation

struct WordItem {
    let word: String
    let emoji: String
    let firstLetter: String

    init(word: String, emoji: String) {
        self.word = word.lowercased()
        self.emoji = emoji
        self.firstLetter = String(word.prefix(1)).lowercased()
    }
}

struct LetterSet {
    let letter: String
    let words: [WordItem]
}

class WordDataManager {
    static let shared = WordDataManager()

    private init() {}

    // Words organized by starting letter, suitable for ages 4-5
    let letterSets: [LetterSet] = [
        LetterSet(letter: "b", words: [
            WordItem(word: "bat", emoji: "🦇"),
            WordItem(word: "bed", emoji: "🛏️"),
            WordItem(word: "bug", emoji: "🐛"),
            WordItem(word: "box", emoji: "📦"),
            WordItem(word: "bus", emoji: "🚌"),
            WordItem(word: "bun", emoji: "🍔"),
            WordItem(word: "ball", emoji: "🏀"),
            WordItem(word: "bag", emoji: "👜")
        ]),
        LetterSet(letter: "c", words: [
            WordItem(word: "cat", emoji: "🐱"),
            WordItem(word: "car", emoji: "🚗"),
            WordItem(word: "cup", emoji: "☕"),
            WordItem(word: "cow", emoji: "🐮"),
            WordItem(word: "can", emoji: "🥫"),
            WordItem(word: "cap", emoji: "🧢"),
            WordItem(word: "cub", emoji: "🐻"),
            WordItem(word: "cake", emoji: "🎂")
        ]),
        LetterSet(letter: "d", words: [
            WordItem(word: "dog", emoji: "🐕"),
            WordItem(word: "dot", emoji: "⚫"),
            WordItem(word: "dad", emoji: "👨"),
            WordItem(word: "den", emoji: "🏠"),
            WordItem(word: "doll", emoji: "🪆"),
            WordItem(word: "drum", emoji: "🥁"),
            WordItem(word: "dig", emoji: "⛏️"),
            WordItem(word: "deer", emoji: "🦌")
        ]),
        LetterSet(letter: "f", words: [
            WordItem(word: "fox", emoji: "🦊"),
            WordItem(word: "fan", emoji: "🪭"),
            WordItem(word: "fig", emoji: "🫒"),
            WordItem(word: "foot", emoji: "🦶"),
            WordItem(word: "fun", emoji: "🎉"),
            WordItem(word: "fish", emoji: "🐟"),
            WordItem(word: "fog", emoji: "🌫️"),
            WordItem(word: "frog", emoji: "🐸")
        ]),
        LetterSet(letter: "h", words: [
            WordItem(word: "hat", emoji: "🎩"),
            WordItem(word: "hop", emoji: "🦘"),
            WordItem(word: "hen", emoji: "🐔"),
            WordItem(word: "ham", emoji: "🍖"),
            WordItem(word: "hug", emoji: "🤗"),
            WordItem(word: "hot", emoji: "🔥"),
            WordItem(word: "hand", emoji: "🖐️"),
            WordItem(word: "hill", emoji: "⛰️")
        ]),
        LetterSet(letter: "p", words: [
            WordItem(word: "pig", emoji: "🐷"),
            WordItem(word: "pen", emoji: "🖊️"),
            WordItem(word: "pet", emoji: "🐾"),
            WordItem(word: "pot", emoji: "🍲"),
            WordItem(word: "pond", emoji: "🏞️"),
            WordItem(word: "pat", emoji: "🤚"),
            WordItem(word: "pup", emoji: "🐶"),
            WordItem(word: "pan", emoji: "🍳")
        ]),
        LetterSet(letter: "r", words: [
            WordItem(word: "rat", emoji: "🐀"),
            WordItem(word: "run", emoji: "🏃"),
            WordItem(word: "red", emoji: "🔴"),
            WordItem(word: "rug", emoji: "🧶"),
            WordItem(word: "rock", emoji: "🪨"),
            WordItem(word: "ram", emoji: "🐏"),
            WordItem(word: "rip", emoji: "✂️"),
            WordItem(word: "rain", emoji: "🌧️")
        ]),
        LetterSet(letter: "s", words: [
            WordItem(word: "sun", emoji: "☀️"),
            WordItem(word: "sit", emoji: "🪑"),
            WordItem(word: "sip", emoji: "🥤"),
            WordItem(word: "sad", emoji: "😢"),
            WordItem(word: "sock", emoji: "🧦"),
            WordItem(word: "star", emoji: "⭐"),
            WordItem(word: "snow", emoji: "❄️"),
            WordItem(word: "song", emoji: "🎵")
        ]),
        LetterSet(letter: "t", words: [
            WordItem(word: "top", emoji: "🔝"),
            WordItem(word: "ten", emoji: "🔟"),
            WordItem(word: "tap", emoji: "🚰"),
            WordItem(word: "tail", emoji: "🐕"),
            WordItem(word: "tree", emoji: "🌳"),
            WordItem(word: "tub", emoji: "🛁"),
            WordItem(word: "tag", emoji: "🏷️"),
            WordItem(word: "toad", emoji: "🐸")
        ]),
        LetterSet(letter: "a", words: [
            WordItem(word: "ant", emoji: "🐜"),
            WordItem(word: "arm", emoji: "💪"),
            WordItem(word: "art", emoji: "🎨"),
            WordItem(word: "ape", emoji: "🐒"),
            WordItem(word: "axe", emoji: "🪓"),
            WordItem(word: "acorn", emoji: "🌰"),
            WordItem(word: "apple", emoji: "🍎"),
            WordItem(word: "angel", emoji: "👼")
        ]),
        LetterSet(letter: "e", words: [
            WordItem(word: "egg", emoji: "🥚"),
            WordItem(word: "elf", emoji: "🧝"),
            WordItem(word: "elk", emoji: "🦌"),
            WordItem(word: "ear", emoji: "👂"),
            WordItem(word: "eel", emoji: "🐍"),
            WordItem(word: "eagle", emoji: "🦅"),
            WordItem(word: "earth", emoji: "🌍"),
            WordItem(word: "elbow", emoji: "💪")
        ]),
        LetterSet(letter: "g", words: [
            WordItem(word: "gem", emoji: "💎"),
            WordItem(word: "gum", emoji: "🍬"),
            WordItem(word: "goat", emoji: "🐐"),
            WordItem(word: "gift", emoji: "🎁"),
            WordItem(word: "game", emoji: "🎮"),
            WordItem(word: "grass", emoji: "🌿"),
            WordItem(word: "grape", emoji: "🍇"),
            WordItem(word: "girl", emoji: "👧")
        ]),
        LetterSet(letter: "i", words: [
            WordItem(word: "ink", emoji: "🖊️"),
            WordItem(word: "igloo", emoji: "🏔️"),
            WordItem(word: "ivy", emoji: "🌿"),
            WordItem(word: "ill", emoji: "🤒"),
            WordItem(word: "itch", emoji: "😖"),
            WordItem(word: "icy", emoji: "❄️"),
            WordItem(word: "iris", emoji: "🌸"),
            WordItem(word: "ice", emoji: "🧊")
        ]),
        LetterSet(letter: "j", words: [
            WordItem(word: "jet", emoji: "✈️"),
            WordItem(word: "jam", emoji: "🍓"),
            WordItem(word: "jog", emoji: "🏃"),
            WordItem(word: "jar", emoji: "🫙"),
            WordItem(word: "joy", emoji: "😊"),
            WordItem(word: "jump", emoji: "🦘"),
            WordItem(word: "jelly", emoji: "🍮"),
            WordItem(word: "jaw", emoji: "🦷")
        ]),
        LetterSet(letter: "k", words: [
            WordItem(word: "kit", emoji: "🧰"),
            WordItem(word: "kid", emoji: "🧒"),
            WordItem(word: "kite", emoji: "🪁"),
            WordItem(word: "key", emoji: "🔑"),
            WordItem(word: "koala", emoji: "🐨"),
            WordItem(word: "kiss", emoji: "💋"),
            WordItem(word: "king", emoji: "👑"),
            WordItem(word: "knee", emoji: "🦵")
        ]),
        LetterSet(letter: "l", words: [
            WordItem(word: "leg", emoji: "🦵"),
            WordItem(word: "log", emoji: "🪵"),
            WordItem(word: "lip", emoji: "💋"),
            WordItem(word: "lap", emoji: "🪑"),
            WordItem(word: "lid", emoji: "🫙"),
            WordItem(word: "lamb", emoji: "🐑"),
            WordItem(word: "lion", emoji: "🦁"),
            WordItem(word: "leaf", emoji: "🍃")
        ]),
        LetterSet(letter: "m", words: [
            WordItem(word: "map", emoji: "🗺️"),
            WordItem(word: "mud", emoji: "🟫"),
            WordItem(word: "mat", emoji: "🧹"),
            WordItem(word: "mop", emoji: "🫧"),
            WordItem(word: "mix", emoji: "🥣"),
            WordItem(word: "mug", emoji: "☕"),
            WordItem(word: "men", emoji: "👨"),
            WordItem(word: "milk", emoji: "🥛")
        ]),
        LetterSet(letter: "n", words: [
            WordItem(word: "nap", emoji: "😴"),
            WordItem(word: "net", emoji: "🥅"),
            WordItem(word: "nut", emoji: "🥜"),
            WordItem(word: "nod", emoji: "🙂"),
            WordItem(word: "nose", emoji: "👃"),
            WordItem(word: "nest", emoji: "🪺"),
            WordItem(word: "nail", emoji: "🔨"),
            WordItem(word: "neck", emoji: "🦒")
        ]),
        LetterSet(letter: "o", words: [
            WordItem(word: "owl", emoji: "🦉"),
            WordItem(word: "orca", emoji: "🐋"),
            WordItem(word: "oven", emoji: "🔥"),
            WordItem(word: "oak", emoji: "🌳"),
            WordItem(word: "otter", emoji: "🦦"),
            WordItem(word: "ocean", emoji: "🌊"),
            WordItem(word: "olive", emoji: "🫒"),
            WordItem(word: "onion", emoji: "🧅")
        ]),
        LetterSet(letter: "q", words: [
            WordItem(word: "queen", emoji: "👑"),
            WordItem(word: "quiz", emoji: "📝"),
            WordItem(word: "quilt", emoji: "🛏️"),
            WordItem(word: "quit", emoji: "✋"),
            WordItem(word: "quack", emoji: "🦆"),
            WordItem(word: "quick", emoji: "⚡"),
            WordItem(word: "quiet", emoji: "🤫"),
            WordItem(word: "quake", emoji: "🌍")
        ]),
        LetterSet(letter: "u", words: [
            WordItem(word: "uncle", emoji: "👨"),
            WordItem(word: "ugh", emoji: "😤"),
            WordItem(word: "upset", emoji: "😟"),
            WordItem(word: "undo", emoji: "↩️"),
            WordItem(word: "ugly", emoji: "🙈"),
            WordItem(word: "urge", emoji: "💪"),
            WordItem(word: "unit", emoji: "📏"),
            WordItem(word: "upon", emoji: "🔝")
        ]),
        LetterSet(letter: "v", words: [
            WordItem(word: "van", emoji: "🚐"),
            WordItem(word: "vet", emoji: "👨‍⚕️"),
            WordItem(word: "vase", emoji: "🪷"),
            WordItem(word: "viola", emoji: "🎻"),
            WordItem(word: "vine", emoji: "🌿"),
            WordItem(word: "vest", emoji: "🦺"),
            WordItem(word: "video", emoji: "📹"),
            WordItem(word: "viper", emoji: "🐍")
        ]),
        LetterSet(letter: "w", words: [
            WordItem(word: "web", emoji: "🕸️"),
            WordItem(word: "wig", emoji: "👱"),
            WordItem(word: "win", emoji: "🏆"),
            WordItem(word: "wag", emoji: "🐕"),
            WordItem(word: "wolf", emoji: "🐺"),
            WordItem(word: "wet", emoji: "💧"),
            WordItem(word: "worm", emoji: "🪱"),
            WordItem(word: "wave", emoji: "🌊")
        ]),
        LetterSet(letter: "x", words: [
            WordItem(word: "fox", emoji: "🦊"),
            WordItem(word: "box", emoji: "📦"),
            WordItem(word: "six", emoji: "6️⃣"),
            WordItem(word: "wax", emoji: "🕯️"),
            WordItem(word: "fix", emoji: "🔧"),
            WordItem(word: "ox", emoji: "🐂"),
            WordItem(word: "ax", emoji: "🪓"),
            WordItem(word: "rex", emoji: "🦖")
        ]),
        LetterSet(letter: "y", words: [
            WordItem(word: "yak", emoji: "🐃"),
            WordItem(word: "yam", emoji: "🍠"),
            WordItem(word: "yes", emoji: "✅"),
            WordItem(word: "yell", emoji: "📢"),
            WordItem(word: "yolk", emoji: "🥚"),
            WordItem(word: "yip", emoji: "🐕"),
            WordItem(word: "yoga", emoji: "🧘"),
            WordItem(word: "yarn", emoji: "🧶")
        ]),
        LetterSet(letter: "z", words: [
            WordItem(word: "zip", emoji: "🤐"),
            WordItem(word: "zap", emoji: "⚡"),
            WordItem(word: "zero", emoji: "0️⃣"),
            WordItem(word: "zoo", emoji: "🦁"),
            WordItem(word: "zebra", emoji: "🦓"),
            WordItem(word: "zig", emoji: "↗️"),
            WordItem(word: "zag", emoji: "↘️"),
            WordItem(word: "zoom", emoji: "🔍")
        ])
    ]

    func getLetterSet(for letter: String) -> LetterSet? {
        return letterSets.first { $0.letter == letter.lowercased() }
    }

    // Split 8 words into two pages of 4 words each
    func getPages(for letterSet: LetterSet) -> [[WordItem]] {
        let words = letterSet.words
        let page1 = Array(words.prefix(4))
        let page2 = Array(words.dropFirst(4).prefix(4))
        return [page1, page2]
    }
}
