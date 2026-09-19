//
//  IconLibrary.swift
//  Sterium
//
//  All app icon assets, grouped into categories for the icon picker.
//  Generated from the asset catalog; edit categories/order freely.
//

import Foundation

struct IconCategory: Identifiable, Hashable {
    var id: String { name }
    let name: String
    let icons: [String]

    init(_ name: String, _ icons: [String]) {
        self.name = name
        self.icons = icons
    }
}

enum IconLibrary {
    static let categories: [IconCategory] = [
        IconCategory("Numbers", [
            "0wavy", "1wavy", "2wavy", "3wavy", "4wavy", "5wavy",
            "6wavy", "7wavy", "8wavy", "9wavy",
        ]),
        IconCategory("Elements", [
            "air", "earth", "fire", "water",
        ]),
        IconCategory("Zodiac Signs", [
            "aquarius", "aries", "cancer", "capricorn", "gemini", "leo",
            "libra", "pisces", "sagittarius", "scorpio", "taurus", "virgo",
        ]),
        IconCategory("Planets", [
            "jupiter", "jupiterline", "mars", "marsline", "mercury", "mercuryline",
            "neptune", "neptuneline", "planet", "pluto", "plutoline", "saturn",
            "saturnline", "uranus", "uranusline", "venus", "venusline",
        ]),
        IconCategory("Sun, Moon & Sky", [
            "cloudie", "cloudsync", "galaxy", "moonzs", "rainbow", "rainbowclouds",
            "sun", "sunflower", "themoon", "themoonline", "thesun", "thesunline",
        ]),
        IconCategory("Stars & Sparkles", [
            "bolt", "boltprogress", "boltprogressbar", "boltsparkle", "cloudsparkleball", "galaxysparkle",
            "goalsparkle", "linesstar", "moonstar", "sparkbolt", "sparkle", "sparklearrowprogress",
            "sparklecircle", "sparkledrophands", "sparkleprogress", "sparklesearch", "sparklesstarflag", "starbadge",
            "starbars", "starblist", "starboxhand", "starbulb", "starcard", "starchart",
            "starcircle", "starcirclecase", "starfill", "starhand", "starladder", "starlocation",
            "starmark", "staroutline", "starprogress", "starprogressbar", "starringtags", "starry",
            "starrybox", "starscase", "starshand", "starshield", "starsparklesbox", "startarget",
            "starwavy", "tagsparkle", "tagstar",
        ]),
        IconCategory("Spiritual & Ritual", [
            "bat", "batcal", "blackcat", "bones", "candlebra", "candleslit",
            "casemagic", "cauldron", "cloudmind", "coffin", "crossroads", "crystalball",
            "deadcat", "eye", "eyecircle", "eyeslash", "eyeslashcircle", "eyex",
            "flame", "ghost", "ghostcal", "grimoire", "hauntedhouse", "jackolantern",
            "meditate", "potion", "potionsign", "potionsparkle", "siwrlmind", "skullpotion",
            "starchalice", "tarot", "tarotcards", "tombstone", "wand", "witchhat",
            "zenrocks",
            "triplemoon", "3tarotcards", "suntarot", "sunspellbook", "starspellbook", "startarot", "pentacle", "runes", "moontarot", "moonspellbook", "tmspellbook", "pentgrimoire", "crystal", "crystals", "crystalballhand",
        ]),
        IconCategory("Love & Romance", [
            "bandaidheart", "blovelist", "bulbxoxo", "bulletheartlist", "calheart", "calhearts",
            "doclineslove", "dotlovering", "fingersheart", "floatlove", "flowersheart", "halfheart",
            "heartballoon", "heartblist", "heartbox", "heartboxcal", "heartcircle", "heartfill",
            "hearthand", "heartlinescal", "heartlock", "heartlovechat", "heartoscope", "heartoutline",
            "heartphone", "heartpopbox", "heartpulse", "heartsegg", "heartshirt", "heartsparkle",
            "heartsum", "hearttag", "heartunlock", "heartwavy", "lockheartjournal", "lockhearts",
            "loveairballoon", "lovebottle", "lovebox", "lovebrowser", "lovecake", "lovecalendar",
            "lovecards", "lovecase", "lovechatbubbles", "lovedate", "lovedeck", "lovedeodorant",
            "lovedocs", "lovedocslines", "lovedropper", "lovedryer", "loveeye", "loveflag",
            "loveflame", "lovehoodie", "lovehouse", "loveiron", "lovejournal", "lovelaptop",
            "loveletter", "lovelinepage", "lovelist", "lovelocation", "lovelycal", "lovemail",
            "lovemakeup", "lovemind", "lovemoney", "lovemug", "lovemusicnote", "loveoscope",
            "lovephone", "lovepills", "lovepotion", "loveprogressbar", "lovesearch", "loveshirt",
            "loveshopbags", "lovesmokes", "lovespiralbook", "lovetag", "lovetickets", "lovetv",
            "luvemail", "luvmail", "luvmailfill", "openlovebook", "plusheart", "twinhearts",
            "wedcard", "wedinvite", "windowheart", "xoxobulb", "xoxocal",
        ]),
        IconCategory("Party & Celebration", [
            "batcake", "bdaycake", "cake", "candlecake", "confetticake", "dotcake",
            "halloweeninvite", "handstrophy", "handtrophy", "movietix", "partinvite", "partyballoons",
            "partycal", "partycandlecake", "partyfavorbag", "partyinvite", "popcornpack", "popper",
            "rewardscard", "spacemanbday", "sprinklecake", "stargift", "starhandtrophy", "starpopgift",
            "starsparklegift", "startickets", "startrophy", "startrophyfill", "startrophyhand", "startrophyhands",
            "trophycircle", "trophystar",
        ]),
        IconCategory("Baby & Kids", [
            "babyblock", "bblocks", "bbuildingblocks", "bbypiano", "blocks", "blocksfill",
            "buggy", "childsrack", "handbuggy",
        ]),
        IconCategory("Pets & Animals", [
            "bearlockpassword", "bearpoppet", "catface", "catsleep", "catstretch", "circlepaw",
            "dogface", "dogstore", "feetprints", "kennel", "paw", "petalarm",
            "petbox", "petfood", "petmeddrops", "petmeds", "petpaw", "petpills",
            "petshampoo", "petsoap", "pettreat", "vet",
        ]),
        IconCategory("Nature & Plants", [
            "bubbles", "flower", "flowerfilled", "seedling", "treeoutside",
        ]),
        IconCategory("Health & Medical", [
            "doublepills", "health", "healthoutline", "medhand", "medhouse", "medical",
            "medication", "medsymbol", "pillcapsules", "pilldrop", "pillhand", "pillorganizer",
            "pillpacket", "pillshand", "pillshands", "pillsleeve", "rxbottle", "stethoscope",
            "tabletpill", "tabpill", "tabpillshand", "twopills", "weight", "workout",
        ]),
        IconCategory("Beauty & Self-care", [
            "armchair", "beautystation", "blowdryer", "bottlecream", "buttons", "creambottle",
            "creamjar", "cuteslippers", "daycream", "dressshirt", "dropper", "fingernail",
            "foot", "footcream", "footspa", "hairbrush", "hanger", "kingtooth",
            "mirrorbottle", "mooncream", "mouthwash", "nailfiling", "nailpolish", "nailsparkle",
            "nightcream", "perfume", "pumpbottle", "razor", "rollondeodorant", "shampoo",
            "shaverazor", "shoe", "shower", "showercurtain", "slippers", "specialcream",
            "spraybottle", "starsocks", "stickscara", "tooth", "toothburst", "toothhand",
            "toothhands", "toothset", "toothsparklehands", "toothypaste", "towel", "tpaste",
            "tubetoothpaste", "vanity",
        ]),
        IconCategory("Home & Living", [
            "bed", "bedpillow", "blackwindow", "breadoven", "bucket", "codewindow",
            "coffeemaker", "coffeemakermachine", "diningtable", "dishwasher", "dooropen", "drawers",
            "electricblender", "exitdoor", "expressomachine", "fireplace", "flatiron", "fridgefilled",
            "frontdoor", "garage", "glass", "homebar", "homesparkle", "houseoutline",
            "jug", "kitchentable", "lamp", "laundry", "oven", "pillows",
            "refrigerator", "silverware", "singleblender", "sofa", "starrypillow", "starwindow",
            "stool", "teapot", "toilet", "toiletpaper", "tproll", "vacuumcleaner",
            "washer", "washmachine", "whisk", "window", "yard",
        ]),
        IconCategory("Food & Drink", [
            "bottle", "bottlewater", "bowegg", "candybag", "corncrate", "eggs",
            "energydrink", "flowersegg", "foodbox", "foodrack", "groceries", "market",
            "waterbottle",
        ]),
        IconCategory("Tech & Media", [
            "3dglasses", "appsphone", "camfill", "camlense", "cellphone", "cinemafill",
            "devbulb", "device", "devwavy", "film", "filmstrip", "flatscreen",
            "mediaphone", "micfill", "nophones", "novideo", "phone", "photocam",
            "play", "playwavy", "remotecontrol", "socialphone", "sparkledevice", "starphone",
            "television", "videocam", "videofilm", "videoreel", "videoslider", "webcircle",
        ]),
        IconCategory("Social & Communication", [
            "chatlinesfill", "chatsparkle", "discord", "facebook", "github", "groupfill",
            "hashtag", "hashtagwavy", "inbox", "instagram", "mailbox", "starchat",
            "starlinesmail", "starmailing", "threads",
        ]),
        IconCategory("Finance & Shopping", [
            "basketflowers", "billsfile", "cardlines", "coinssparkle", "moneybaghands", "moneybills",
            "monies", "pigbank", "shopbasket", "starshopbags", "store", "threecoins",
            "walletfill",
        ]),
        IconCategory("Time & Calendar", [
            "blackcal", "circlescal", "clockfill", "clockwavy", "dotscal", "hourglassfill",
            "numcal", "ringstarcal", "starcal", "timebook", "timehand",
        ]),
        IconCategory("Security & Keys", [
            "circlefingerprint", "fingerprint", "handkey", "lockpassword", "lockwavy", "password",
            "starskey",
        ]),
        IconCategory("Documents & Writing", [
            "artboard", "blankpages", "bookmark", "bookstand", "colorpicker", "copy",
            "document", "flatbook", "flipnotebook", "handbook", "imagesign", "journey",
            "linedpages", "lineimagepage", "linenotepage", "linespencil", "linespiralbook", "office",
            "openbook", "openedfolder", "pagefold", "paintbrush", "paintdrop", "pbrush",
            "pencil", "pencilcircle", "pinnednote", "plainpencil", "quote", "sign",
            "sparklebrush", "sparklesbook", "starlinesdoc", "starmarkbook", "starnote", "sticknote",
            "writenote", "writepencil",
        ]),
        IconCategory("Navigation & Controls", [
            "addwavy", "arrowin", "arrowinfinity", "arrowscircle", "arrowsprofile", "backwavy",
            "balancewavy", "bellfill", "bells", "chartcircle", "chartdown", "chartup",
            "checkwavy", "chevdown", "chevleft", "chevright", "chevup", "cogwavy",
            "downwavy", "infowavy", "leftarrow", "leftwavy", "levelup", "linkcircle",
            "listcircle", "markcircle", "minuswavy", "nonotifs", "objects", "packagefill",
            "pausewavy", "percentwavy", "pin", "prohibitedwavy", "questionwavy", "repeat",
            "repeatarrows", "repeatfill", "rightarrow", "rightwavy", "searchwavy", "settings",
            "skipbackwavy", "skipwavy", "stopwavy", "threeboxes", "trash", "trinket",
            "upwavy", "warnwavy", "xmarkwavy",
        ]),
        IconCategory("Symbols & Misc", [
            "blackcircle", "brightbulb", "dotswavy", "dropfill", "handbulb", "linesbmark",
            "linescard", "profilewavy", "xsmile",
        ]),
    ]

    static var categoryNames: [String] { categories.map(\.name) }

    static func icons(for category: String) -> [String] {
        categories.first { $0.name == category }?.icons ?? []
    }

    static func category(containing icon: String) -> String? {
        categories.first { $0.icons.contains(icon) }?.name
    }
}
