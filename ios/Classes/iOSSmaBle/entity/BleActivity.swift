//
// Created by Best Mafen on 2019/9/26.
// Copyright (c) 2019 szabh. All rights reserved.
//

import Foundation

class BleActivity: BleReadable {
    static let ITEM_LENGTH = 16

    // 以下三种为自动识别的模式，没有开始、暂停、结束等状态
    static let AUTO_NONE = 1
    static let AUTO_WALK = 2
    static let AUTO_RUN = 3

    // 以下为手动锻炼模式 -- mMode定义
    static let RUNNING = 7     // 跑步
    static let INDOOR = 8      // 室内运动，跑步机
    static let OUTDOOR = 9     // 户外运动
    static let CYCLING = 10    // 骑行
    static let SWIMMING = 11   // 游泳
    static let WALKING = 12    // 步行，健走
    static let CLIMBING = 13   // 爬山
    static let YOGA = 14       // 瑜伽
    static let SPINNING = 15   // 动感单车
    static let BASKETBALL = 16 // 篮球
    static let FOOTBALL = 17   // 足球
    static let BADMINTON = 18  // 羽毛球
    static let MARATHON = 19    // 马拉松    未查到
    static let INDOOR_WALK = 20   // 室内步行
    static let FREE_TRAINING = 21   // 自由锻炼
    static let WEIGHTTRANNING = 23  // 力量训练
    static let WEIGHTLIFTING = 24   // 举重
    static let BOXING = 25         // 拳击
    static let JUMP_ROPE = 26      // 跳绳
    static let CLIMB_STAIRS = 27   // 爬楼梯
    static let SKI = 28            // 滑雪
    static let SKATE = 29          // 滑冰
    static let ROLLER_SKATING = 30  // 轮滑
    static let HULA_HOOP = 32         // 呼啦圈
    static let GOLF = 33              // 高尔夫
    static let BASEBALL = 34          // 棒球
    static let DANCE = 35             // 舞蹈
    static let PING_PONG = 36         // 乒乓球
    static let HOCKEY = 37            // 曲棍球
    static let PILATES = 38           // 普拉提
    static let TAEKWONDO = 39         // 跆拳道
    static let HANDBALL = 40          // 手球
    static let DANCE_STREET = 41     // 街舞
    static let VOLLEYBALL = 42        // 排球
    static let TENNIS = 43            // 网球
    static let DARTS = 44             // 飞镖
    static let GYMNASTICS = 45        // 体操
    static let STEPPING = 46          // 踏步
    static let ELLIPIICAL = 47          // 椭圆机
    static let ZUMBA = 48          // 尊巴
    static let CRICHKET = 49 // 板球
    static let TREKKING = 50          // 徒步旅行        6 MET/70Kg/60分钟/441千卡
    static let AEROBICS = 51          // 有氧运动        5.8 MET/70Kg/60分钟/408千卡
    static let ROWING_MACHINE = 52    // 划船机          12 MET/70Kg/60分钟/840千卡
    static let RUGBY = 53             // 橄榄球          8 MET/70Kg/60分钟/560千卡
    static let SIT_UP = 54            // 仰卧起坐        8 MET/70KG/60分钟/560千卡
    static let DUM_BLE = 55           // 哑铃            3 MET/70KG/60分钟/210千卡
    static let BODY_EXERCISE = 56     // 健身操          4.7 MET/70KG/60分钟/327千卡
    static let KARATE = 57            // 空手道          10 MET/70KG/60分钟/700千卡
    static let FENCING = 58           // 击剑            6 MET/70KG/60分钟/420千卡
    static let MARTIAL_ARTS = 59      // 武术            13.2 MET/70KG/60分钟/922千卡
    static let TAI_CHI = 60           // 太极拳          4 MET/70KG/60分钟/280千卡
    static let FRISBEE = 61           // 飞盘            3 MET/70KG/60分钟/220千卡
    static let ARCHERY = 62           // 射箭            4 MET/70KG/60分钟/294千卡
    static let HORSE_RIDING = 63      // 骑马            4 MET/70KG/60分钟/294千卡
    static let BOWLING = 64           // 保龄球          4 MET/70KG/60分钟/294千卡
    static let SURF = 65              // 冲浪            3 MET/70KG/60分钟/220千卡
    static let SOFTBALL = 66         // 垒球            5 MET/70KG/60分钟/368千卡
    static let SQUASH = 67            // 壁球            8 MET/70KG/60分钟/588千卡
    static let SAILBOAT = 68          // 帆船            3 MET/70KG/60分钟/220千卡
    static let PULL_UP = 69           // 引体向上        8 MET/70KG/60分钟/560千卡
    static let SKATEBOARD = 70        // 滑板            5 MET/70KG/60分钟/350千卡
    static let TRAMPOLINE = 71        // 蹦床            6 MET/70KG/60分钟/441千卡
    static let FISHING = 72           // 钓鱼            3 MET/70KG/60分钟/220千卡
    static let POLE_DANCING = 73      // 钢管舞          6 MET/70KG/60分钟/441千卡
    static let SQUARE_DANCE = 74      // 广场舞          3 MET/70KG/60分钟/210千卡
    static let JAZZ_DANCE = 75        // 爵士舞          4.8 MET/70KG/60分钟/336千卡
    static let BALLET = 76            // 芭蕾舞          4.8 MET/70KG/60分钟/336千卡
    static let DISCO = 77             // 迪斯科          4.5 MET/70KG/60分钟/420千卡
    static let TAP_DANCE = 78         // 踢踏舞          4.8 MET/70KG/60分钟/336千卡
    static let MODERN_DANCE = 79      // 现代舞          4.8 MET/70KG/60分钟/336千卡
    static let PUSH_UPS = 80          // 俯卧撑          8 MET/70KG/60分钟/560千卡
    static let SCOOTER = 81           // 滑板车          7 MET/70KG/60分钟/490千卡
    static let PLANK = 82              // 平板支撑        3.3 MET/70KG/60分钟/228千卡
    static let BILLIARDS = 83          // 桌球            2.5 MET/70KG/60分钟/175千卡
    static let ROCK_CLIMBING = 84      // 攀岩            11 MET/70KG/60分钟/770千卡
    static let DISCUS = 85             // 铁饼            4 MET/70KG/60分钟/280千卡
    static let RACE_RIDING = 86        // 赛马            10 MET/70KG/60分钟/700千卡
    static let WRESTLING = 87          // 摔跤            6 MET/70KG/60分钟/420千卡
    static let HIGH_JUMP = 88          // 跳高            6 MET/70KG/60分钟/420千卡
    static let PARACHUTE = 89          // 跳伞            3.5 MET/70KG/60分钟/245千卡
    static let SHOT_PUT = 90           // 铅球            4 MET/70KG/60分钟/280千卡
    static let LONG_JUMP = 91          // 跳远            6 MET/70KG/60分钟/420千卡
    static let JAVELIN = 92            // 标枪            6 MET/70KG/60分钟/420千卡
    static let HAMMER = 93             // 链球            4 MET/70KG/60分钟/280千卡
    static let SQUAT = 94              // 深蹲            4 MET/70KG/60分钟/280千卡
    static let LEG_PRESS = 95          // 压腿            2.5 MET/70KG/60分钟/175千卡
    static let OFF_ROAD_BIKE = 96      // 越野自行车      8.3 MET/70KG/60分钟/581千卡
    static let MOTOCROSS = 97          // 越野摩托车      4 MET/70KG/60分钟/280千卡
    static let ROWING = 98             // 赛艇            8 MET/70KG/60分钟/588千卡
    static let CROSSFIT = 99           // CROSSFIT        7 MET/70KG/60分钟/514千卡 通过多种以自身重量、负重 为主的高次数、快速、爆发力的动作增强自己的体能和运动能力
    static let WATER_BIKE = 100        // 水上自行车      4 MET/70KG/60分钟/294千卡
    static let KAYAK = 101             // 皮划艇          5 MET/70KG/60分钟/368千卡
    static let CROQUET = 102           // 槌球            2.5 MET/70KG/60分钟/175千卡
    static let FLOOR_BALL = 103        // 地板球          6 MET/70KG/60分钟/441千卡 （福乐球 FLOORBALL） 软式曲棍球
    static let THAI = 104            // 泰拳            7 MET/70KG/514 280千卡
    static let JAI_BALL = 105         // 回力球          12 MET/70KG/60分钟/840千卡
    static let TENNIS_DOUBLES = 106    // 网球(双打)      6 MET/70KG/60分钟/420千卡
    static let BACK_TRAINING = 107     // 背部训练        3.5 MET/70KG/60分钟/245千卡
    static let WATER_VOLLEYBALL = 108  // 水上排球        3 MET/70KG/60分钟/210千卡
    static let WATER_SKIING = 109      // 滑水            6 MET/70KG/60分钟/420千卡
    static let MOUNTAIN_CLIMBER = 110  // 登山机          8 MET/70KG/60分钟/588千卡
    static let HIIT = 111              // HIIT            7 MET/70KG/60分钟/514千卡  高强度间歇性训练
    static let BODY_COMBAT = 112      // BODY COMBAT     7 MET/70KG/60分钟/514千卡  搏击（拳击）的一种
    static let BODY_BALANCE = 113      // BODY BALANCE    7 MET/70KG/60分钟/514千卡  瑜伽、太极和普拉提融合在一起的身心训练项目
    static let TRX = 114               // TRX             7 MET/70KG/60分钟/514千卡 全身抗阻力锻炼 全身抗阻力锻炼
    static let TAE_BO = 115 // 跆搏（TAE BO）   7 MET/70KG/60分钟/514千卡 集跆拳道、空手道、拳击、自由搏击、舞蹈韵律操为一体
    // 手动锻炼模式下的状态 -- mState定义
    static let BEGIN = 0 // 开始
    static let ONGOING = 1 // 进行中
    static let PAUSE = 2 // 暂停
    static let RESUME = 3 // 继续
    static let END = 4 // 结束

    var mTime: Int = 0 // 距离当地2000/1/1 00:00:00的秒数
    var mMode: Int = 0 //运动模式，可参考 mMode的定义
    var mState: Int = 0  //运动状态，可参考 mState定义
    var mStep: Int = 0  //步数，例如值为10，即代表走了10步
    var mCalorie: Int = 0  // 1/10000千卡，例如接收到的数据为56045，则代表 5.6045 Kcal 约等于 5.6 Kcal
    var mDistance: Int = 0 // 1/10000米，例如接收到的数据为56045，则代表移动距离 5.6045 米 约等于 5.6 米

    override func decode() {
        super.decode()
        mTime = Int(readInt32())
        mMode = Int(readUIntN(5))
        mState = Int(readUIntN(3))
        mStep = Int(readUInt24())
        mCalorie = Int(readUInt32())
        mDistance = Int(readUInt32())
    }

    override var description: String {
        "BleActivity(mTime: \(mTime), mMode: \(mMode), mState: \(mState), mStep: \(mStep), mCalorie: \(mCalorie), mDistance: \(mDistance))"
    }
    
    func toDictionary()->[String:Any]{
        let dic : [String : Any] = ["mTime":mTime,
                                    "mMode":mMode,
                                    "mState":mState,
                                    "mStep":mStep,
                                    "mCalorie":mCalorie,
                                    "mDistance":mDistance]
        return dic
    }
    
    func dictionaryToObjct(_ dic:[String:Any]) ->BleActivity{

        let newModel = BleActivity()
        if dic.keys.count<1{
            return newModel
        }
        newModel.mTime = dic["mTime"] as? Int ?? 0
        newModel.mMode = dic["mMode"] as? Int ?? 0
        newModel.mState = dic["mState"] as? Int ?? 0
        newModel.mStep = dic["mStep"] as? Int ?? 0
        newModel.mCalorie = dic["mCalorie"] as? Int ?? 0
        newModel.mDistance = dic["mDistance"] as? Int ?? 0
        return newModel
    }
}
