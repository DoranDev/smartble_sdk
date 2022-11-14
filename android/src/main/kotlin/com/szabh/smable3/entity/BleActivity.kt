package com.szabh.smable3.entity

import com.bestmafen.baseble.data.BleReadable

data class BleActivity(
    var mTime: Int = 0,     //距离当地2000/1/1 00:00:00的秒数
    var mMode: Int = 0,     //运动模式，可参考下方 companion object 中的定义
    var mState: Int = 0,    //运动状态，可参考下方 companion object 中的定义
    var mStep: Int = 0,     //步数，例如值为10，即代表走了10步
    var mCalorie: Int = 0,  // 1/10000千卡，例如接收到的数据为56045，则代表 5.6045 Kcal 约等于 5.6 Kcal
    var mDistance: Int = 0  // 1/10000米，例如接收到的数据为56045，则代表移动距离 5.6045 米 约等于 5.6 米
) : BleReadable() {

    override fun decode() {
        super.decode()
        mTime = readInt32()
        mMode = readIntN(5).toInt()
        mState = readIntN(3).toInt()
        mStep = readInt24()
        mCalorie = readInt32()
        mDistance = readInt32()
    }

    companion object {
        const val ITEM_LENGTH = 16

        //运动模式 以下三种为自动识别的模式，没有开始、暂停、结束等状态
        const val AUTO_NONE = 1
        const val AUTO_WALK = 2
        const val AUTO_RUN = 3

        //运动模式 以下为手动锻炼模式 对应 mMode
        const val RUNNING = 7     // 跑步
        const val INDOOR = 8      // 室内运动，跑步机
        const val OUTDOOR = 9     // 户外运动
        const val CYCLING = 10    // 骑行
        const val SWIMMING = 11   // 游泳
        const val WALKING = 12    // 步行，健走
        const val CLIMBING = 13   // 爬山
        const val YOGA = 14       // 瑜伽
        const val SPINNING = 15   // 动感单车
        const val BASKETBALL = 16 // 篮球
        const val FOOTBALL = 17   // 足球
        const val BADMINTON = 18  // 羽毛球
        const val MARATHON = 19  // 马拉松
        const val INDOOR_WALKING = 20  // 室内步行
        const val FREE_EXERCISE = 21  // 自由锻炼
        const val AEROBIC_EXERCISE = 22  // 有氧运动
        const val WEIGHTTRANNING = 23  // 力量训练
        const val WEIGHTLIFTING = 24  // 举重
        const val BOXING = 25   // 拳击
        const val JUMP_ROPE = 26    // 跳绳
        const val CLIMB_STAIRS = 27 // 爬楼梯
        const val SKI = 28  // 滑雪
        const val SKATE = 29    // 滑冰
        const val ROLLER_SKATING = 30   // 轮滑
        const val HULA_HOOP = 32    // 呼啦圈
        const val GOLF = 33 // 高尔夫
        const val BASEBALL = 34 // 棒球
        const val DANCE = 35    // 舞蹈
        const val PING_PONG = 36    // 乒乓球
        const val HOCKEY = 37   // 曲棍球
        const val PILATES = 38  // 普拉提
        const val TAEKWONDO = 39    // 跆拳道
        const val HANDBALL = 40 // 手球
        const val DANCE_STREET = 41 // 街舞
        const val VOLLEYBALL = 42   // 排球
        const val TENNIS = 43   // 网球
        const val DARTS = 44    // 飞镖
        const val GYMNASTICS = 45   // 体操
        const val STEPPING = 46 // 踏步
        const val ELLIPIICAL = 47 //椭圆机
        const val ZUMBA = 48 //尊巴

        const val CRICHKET = 49  // 板球
        const val TREKKING = 50 // 徒步旅行
        const val AEROBICS = 51 // 有氧运动
        const val ROWING_MACHINE = 52    // 划船机
        const val RUGBY = 53    // 橄榄球
        const val SIT_UP = 54   // 仰卧起坐
        const val DUM_BLE = 55  // 哑铃
        const val BODY_EXERCISE = 56     // 健身操
        const val KARATE = 57   // 空手道
        const val FENCING = 58  // 击剑
        const val MARTIAL_ARTS = 59      // 武术
        const val TAI_CHI = 60  // 太极拳
        const val FRISBEE = 61  // 飞盘
        const val ARCHERY = 62  // 射箭
        const val HORSE_RIDING = 63      // 骑马
        const val BOWLING = 64  // 保龄球
        const val SURF = 65     // 冲浪
        const val SOFTBALL = 66 // 垒球
        const val SQUASH = 67   // 壁球
        const val SAILBOAT = 68 // 帆船
        const val PULL_UP = 69  // 引体向上
        const val SKATEBOARD = 70 // 滑板
        const val TRAMPOLINE = 71 // 蹦床
        const val FISHING = 72  // 钓鱼
        const val POLE_DANCING = 73      // 钢管舞
        const val SQUARE_DANCE = 74      // 广场舞
        const val JAZZ_DANCE = 75 // 爵士舞
        const val BALLET = 76   // 芭蕾舞
        const val DISCO = 77    // 迪斯科
        const val TAP_DANCE = 78// 踢踏舞
        const val MODERN_DANCE = 79      // 现代舞
        const val PUSH_UPS = 80 // 俯卧撑
        const val SCOOTER = 81  // 滑板车
        const val PLANK = 82     // 平板支撑
        const val BILLIARDS = 83 // 桌球
        const val ROCK_CLIMBING = 84
        const val DISCUS = 85    // 铁饼
        const val RACE_RIDING = 86 // 赛马
        const val WRESTLING = 87 // 摔跤
        const val HIGH_JUMP = 88 // 跳高
        const val PARACHUTE = 89 // 跳伞
        const val SHOT_PUT = 90  // 铅球
        const val LONG_JUMP = 91 // 跳远
        const val JAVELIN = 92   // 标枪
        const val HAMMER = 93    // 链球
        const val SQUAT = 94     // 深蹲
        const val LEG_PRESS = 95 // 压腿
        const val OFF_ROAD_BIKE = 96 // 越野自行车
        const val MOTOCROSS = 97 // 越野摩托车
        const val ROWING = 98    // 赛艇
        const val CROSSFIT = 99  // CROSSFIT
        const val WATER_BIKE = 100 // 水上自行车
        const val KAYAK = 101    // 皮划艇
        const val CROQUET = 102  // 槌球
        const val FLOOR_BALL = 103   // 地板球
        const val THAI = 104     // 泰拳
        const val JAI_BALL = 105 // 回力球
        const val TENNIS_DOUBLES = 106    // 网球(双打)
        const val BACK_TRAINING = 107     // 背部训练
        const val WATER_VOLLEYBALL = 108  // 水上排球
        const val WATER_SKIING = 109      // 滑水
        const val MOUNTAIN_CLIMBER = 110  // 登山机
        const val HIIT = 111     // HIIT  高强度间歇性训练
        const val BODY_COMBAT = 112  // BODY COMBAT 搏击（拳击）的一种
        const val BODY_BALANCE = 113  // BODY BALANCE  瑜伽、太极和普拉提融合在一起的身心训练项目
        const val TRX = 114      // TRX 全身抗阻力锻炼 全身抗阻力锻炼
        const val TAE_BO = 115   // 跆搏（TAE BO）   集跆拳道、空手道、拳击、自由搏击、舞蹈韵律操为一体

        //运动状态 手动锻炼模式下的状态 对应 mState
        const val BEGIN = 0 // 开始
        const val ONGOING = 1 // 进行中
        const val PAUSE = 2 // 暂停
        const val RESUME = 3 // 继续
        const val END = 4 // 结束
    }
}
