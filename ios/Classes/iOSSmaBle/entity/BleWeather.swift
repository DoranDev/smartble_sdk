//
// Created by Best Mafen on 2019/9/27.
// Copyright (c) 2019 szabh. All rights reserved.
//

import Foundation

class BleWeather: BleWritable {
    static let ITEM_LENGTH = 10

    // weather types
    static let SUNNY = 1
    static let CLOUDY = 2
    static let OVERCAST = 3
    static let RAINY = 4
    static let THUNDER = 5
    static let THUNDERSHOWER = 6
    static let HIGH_WINDY = 7
    static let SNOWY = 8
    static let FOGGY = 9
    static let SAND_STORM = 10
    static let HAZE = 11
    static let OTHER = 0

    override var mLengthToWrite: Int {
        BleWeather.ITEM_LENGTH
    }

    var mCurrentTemperature: Int = 0 // 摄氏度，for BleWeatherRealtime
    var mMaxTemperature: Int = 0     // 摄氏度，for BleWeatherForecast
    var mMinTemperature: Int = 0     // 摄氏度，for BleWeatherForecast
    var mWeatherCode: Int = 0        // 天气类型，for both
    var mWindSpeed: Int = 0          // km/h，for both
    var mHumidity: Int = 0           // %，for both  2023-04-07 从for BleWeatherForecast, 其他地方还未修改
    var mVisibility: Int = 0         // km，for both
    // https://en.wikipedia.org/wiki/Ultraviolet_index
    // https://zh.wikipedia.org/wiki/%E7%B4%AB%E5%A4%96%E7%BA%BF%E6%8C%87%E6%95%B0
    // 紫外线指数，在API没有此数据的情况下，由云量和天气状态推算得出大概值，
    // [0, 2] -> low, [3, 5] -> moderate, [6, 7] -> high, [8, 10] -> very high, >10 -> extreme
    var mUltraVioletIntensity: Int = 0  // 紫外线强度，for BleWeatherForecast
    var mPrecipitation: Int = 0         // 降水量 mm，for both

    required init(_ data: Data? = nil, _ byteOrder: ByteOrder = .BIG_ENDIAN) {
        super.init(data, byteOrder)
    }

    init(currentTemperature: Int = 0,
         maxTemperature: Int = 0,
         minTemperature: Int = 0,
         weatherType: Int = 0,
         windSpeed: Int = 0,
         humidity: Int = 0,
         visibility: Int = 0,
         ultraVioletIntensity: Int = 0,
         precipitation: Int = 0
    ) {
        super.init()
        mCurrentTemperature = currentTemperature
        mMaxTemperature = maxTemperature
        mMinTemperature = minTemperature
        mWeatherCode = weatherType
        mWindSpeed = windSpeed
        mHumidity = humidity
        mVisibility = visibility
        mUltraVioletIntensity = ultraVioletIntensity
        mPrecipitation = precipitation
    }

    override func encode() {
        super.encode()
        writeInt8(mCurrentTemperature)
        writeInt8(mMaxTemperature)
        writeInt8(mMinTemperature)
        writeInt8(mWeatherCode)
        writeInt8(mWindSpeed)
        writeInt8(mHumidity)
        writeInt8(mVisibility)
        writeInt8(mUltraVioletIntensity)
        writeInt16(mPrecipitation, .LITTLE_ENDIAN)
    }

    override func decode() {
        super.decode()
        mCurrentTemperature = Int(readInt8())
        mMaxTemperature = Int(readInt8())
        mMinTemperature = Int(readInt8())
        mWeatherCode = Int(readUInt8())
        mWindSpeed = Int(readUInt8())
        mHumidity = Int(readUInt8())
        mVisibility = Int(readUInt8())
        mUltraVioletIntensity = Int(readUInt8())
        mPrecipitation = Int(readUInt16(.LITTLE_ENDIAN))
    }

    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        mCurrentTemperature = try container.decode(Int.self, forKey: .mCurrentTemperature)
        mMaxTemperature = try container.decode(Int.self, forKey: .mMaxTemperature)
        mMinTemperature = try container.decode(Int.self, forKey: .mMinTemperature)
        mWeatherCode = try container.decode(Int.self, forKey: .mWeatherCode)
        mWindSpeed = try container.decode(Int.self, forKey: .mWindSpeed)
        mHumidity = try container.decode(Int.self, forKey: .mHumidity)
        mVisibility = try container.decode(Int.self, forKey: .mVisibility)
        mUltraVioletIntensity = try container.decode(Int.self, forKey: .mUltraVioletIntensity)
        mPrecipitation = try container.decode(Int.self, forKey: .mPrecipitation)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(mCurrentTemperature, forKey: .mCurrentTemperature)
        try container.encode(mMaxTemperature, forKey: .mMaxTemperature)
        try container.encode(mMinTemperature, forKey: .mMinTemperature)
        try container.encode(mWeatherCode, forKey: .mWeatherCode)
        try container.encode(mWindSpeed, forKey: .mWindSpeed)
        try container.encode(mHumidity, forKey: .mHumidity)
        try container.encode(mVisibility, forKey: .mVisibility)
        try container.encode(mUltraVioletIntensity, forKey: .mUltraVioletIntensity)
        try container.encode(mPrecipitation, forKey: .mPrecipitation)
    }

    private enum CodingKeys: String, CodingKey {
        case mCurrentTemperature, mMaxTemperature, mMinTemperature, mWeatherCode, mWindSpeed, mHumidity,
             mVisibility, mUltraVioletIntensity, mPrecipitation
    }

    override var description: String {
        "BleWeather(mCurrentTemperature: \(mCurrentTemperature), mMaxTemperature: \(mMaxTemperature)" +
            ", mMinTemperature: \(mMinTemperature), mWeatherCode: \(mWeatherCode), mWindSpeed: \(mWindSpeed)" +
            ", mHumidity: \(mHumidity), mVisibility: \(mVisibility)" +
            ", mUltraVioletIntensity: \(mUltraVioletIntensity), mPrecipitation: \(mPrecipitation))"
    }
    
    func toDictionary()->[String:Any]{
        let dic : [String : Any] = ["mCurrentTemperature":mCurrentTemperature,
                                    "mMaxTemperature":mMaxTemperature,
                                    "mMinTemperature":mMinTemperature,
                                    "mWeatherCode":mWeatherCode,
                                    "mWindSpeed":mWindSpeed,
                                    "mHumidity":mHumidity,
                                    "mVisibility":mVisibility,
                                    "mUltraVioletIntensity":mUltraVioletIntensity,
                                    "mPrecipitation":mPrecipitation]
        return dic
    }
    
    func dictionaryToObjct(_ dic:[String:Any]) ->BleWeather{

        let newModel = BleWeather()
        if dic.keys.count<1{
            return newModel
        }
        newModel.mCurrentTemperature = dic["mCurrentTemperature"] as? Int ?? 0
        newModel.mMaxTemperature = dic["mMaxTemperature"] as? Int ?? 0
        newModel.mMinTemperature = dic["mMinTemperature"] as? Int ?? 0
        newModel.mWeatherCode = dic["mWeatherCode"] as? Int ?? 0
        newModel.mWindSpeed = dic["mWindSpeed"] as? Int ?? 0
        newModel.mHumidity = dic["mHumidity"] as? Int ?? 0
        newModel.mVisibility = dic["mVisibility"] as? Int ?? 0
        newModel.mUltraVioletIntensity = dic["mUltraVioletIntensity"] as? Int ?? 0
        newModel.mPrecipitation = dic["mPrecipitation"] as? Int ?? 0
        return newModel
    }
        
    
    /// 注意这个方法有2个, 另外一个在支持7天天气协议的地方
    /// 把天气服务code转成BLE协议中的code, 这个是我们公司的天气服务请求的数据转换对应的天气类型
    /// 其他公司使用的天气服务器需要他们单独写一个
    func transformWeatherCode(code: Int) -> Int {
        var weatherCode = BleWeather.OTHER
        switch code {
        case 200, 201, 202, 210, 211, 212, 230, 231, 232:   //Group 2xx: Thunderstorm
            weatherCode = BleWeather.THUNDERSHOWER
        case 300, 301, 302, 310, 311, 312, 313, 314, 321:  //Group 3xx: Drizzle 毛毛雨
            weatherCode = BleWeather.RAINY
        case 500, 501, 502, 503, 504, 511, 520, 521, 522, 531:   //Group 5xx: Rain
            weatherCode = BleWeather.RAINY
        case 600, 601, 602, 611, 612, 613, 615, 616, 620, 621, 622:  //Group 6xx: Snow
            weatherCode = BleWeather.SNOWY
        case 701, 711, 721, 741: //Group 7xx: Atmosphere
            weatherCode = BleWeather.FOGGY
        case 731, 751, 761, 762:
            weatherCode = BleWeather.SAND_STORM
        case 771, 781: //Squall、Tornado
            weatherCode = BleWeather.HIGH_WINDY
        case 800: //Group 800: Clear 晴
            weatherCode = BleWeather.SUNNY
        case 801: //Group 80x: Clouds 阴
            weatherCode = BleWeather.OVERCAST
        case 802, 803, 804:  //多云
            weatherCode = BleWeather.CLOUDY
        default:
            weatherCode = BleWeather.OTHER
        }

        return weatherCode
    }
}
