//
// Created by Best Mafen on 2020/3/3.
// Copyright (c) 2020 szabh. All rights reserved.
//

import Foundation

class Languages {
    static let DEFAULT_CODE = 0x01
    static let INVALID_CODE = 0x1F // R5语言包刷错时，code会变成该值
    static let DEFAULT_LANGUAGE = "en"

    private static let LANGUAGES = [
        "zh": 0x00, // 中文
        "en": 0x01, // 英语
        "tr": 0x02, // 土耳其语
        "ru": 0x04, // 俄语
        "es": 0x05, // 西班牙语
        "it": 0x06, // 意大利语
        "ko": 0x07, // 韩语
        "pt": 0x08, // 葡萄牙语
        "de": 0x09, // 德语
        "fr": 0x0A, // 法语
        "nl": 0x0B, // 荷兰语
        "pl": 0x0C, // 波兰语
        "cs": 0x0D, // 捷克语
        "hu": 0x0E, // 匈牙利语
        "sk": 0x0F, // 斯洛伐克语
        "ja": 0x10, // 日语
        "da": 0x11, // 丹麦
        "fi": 0x12, // 芬兰
        "no": 0x13, // 挪威
        "sv": 0x14, // 瑞典
        "sr": 0x15, // 塞尔维亚
        "th": 0x16, // 泰语
        "hi": 0x17, // 印地语
        "el": 0x18, // 希腊语
        "Hant": 0x19, // 中文(繁体)
        "lt": 0x1A, // 立陶宛
        "vi": 0x1B, // 越南语
        "ar": 0x1C, // 阿拉伯语
        "in": 0x1D, // 印尼语
        "id": 0x1D, // 印尼语
        "uk": 0x1E, // 乌克兰语
        "iw": 0x20, // 希伯来语
        "bn": 0x21, // 孟加拉语
        "et": 0x22, // 爱沙尼亚
        "sl": 0x23, // 斯洛文尼亚
        "fa": 0x24, // 波斯语
//        "invalid": 0x1F  // 1F不能再使用，R5语言包刷错时，code会变成该值
    ]

    // 将语言转换成协议对应的Int值
    static func languageToCode(
        language: String = String(NSLocale.current.identifier.prefix(2)), default: Int = DEFAULT_CODE
    ) -> Int {
        var code = LANGUAGES[language] ?? `default`
        if language.elementsEqual("zh"){
            //中文,判断是否为繁体
            if NSLocale.current.identifier.range(of: "TW") != nil ||
                NSLocale.current.identifier.range(of:"MO") != nil ||
                NSLocale.current.identifier.range(of:"HK") != nil {
                code = 0x19
            }
        }
        bleLog("Languages languageToCode -> language=\(language) - \(NSLocale.current.identifier), code=\(String(format: "0x%02X", code))")
        return code
    }

    // 将协议对应的Int值转换成语言
    static func codeToLanguage(code: Int, default: String = DEFAULT_LANGUAGE) -> String {
        var language: String? = nil
        for (key, value) in LANGUAGES {
            if value == code {
                language = key
                break
            }
        }
        language = language ?? `default`
        bleLog("Languages codeToLanguage -> code=\(String(format: "0x%02X", code)), language=\(language!)")
        return language!
    }
}
