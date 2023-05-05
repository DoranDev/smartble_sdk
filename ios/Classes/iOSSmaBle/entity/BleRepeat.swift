//
// Created by Best Mafen on 2020/1/13.
// Copyright (c) 2020 szabh. All rights reserved.
//

import Foundation

class BleRepeat {
    static let MONDAY = 1
    static let TUESDAY = 1 << 1
    static let WEDNESDAY = 1 << 2
    static let THURSDAY = 1 << 3
    static let FRIDAY = 1 << 4
    static let SATURDAY = 1 << 5
    static let SUNDAY = 1 << 6
    static let ONCE = 0
    static let WORKDAY = MONDAY | TUESDAY | WEDNESDAY | THURSDAY | FRIDAY
    static let WEEKEND = SATURDAY | SUNDAY
    static let EVERYDAY = MONDAY | TUESDAY | WEDNESDAY | THURSDAY | FRIDAY | SATURDAY | SUNDAY

    private static let WEEKDAYS = [MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY, SATURDAY, SUNDAY]

    /**
     * 把Int值的重复转换成"周一 周二 周三"，或者"Mon Tues Thur"，具体依赖transfer的返回值
     */
    static func toWeekdayText(
        repeat: Int, transfer: (Int) -> String) -> String {
        var text = ""
        for weekday in WEEKDAYS {
            if (`repeat` & EVERYDAY) & weekday > 0 {
                text += transfer(weekday)
            }
        }
        return text
    }

    /**
     * 把Int值的重复转换成索引集合，比如 MONDAY | TUESDAY 转换成 (0 ,1), 具体依赖transfer的返回值，默认:
     * MONDAY索引为0
     * TUESDAY索引为1
     *   ..
     *   ..
     * SATURDAY索引为5
     * SUNDAY索引为6
     */
    static func toIndices(repeat: Int, transfer: (Int) -> Int = ({ WEEKDAYS.firstIndex(of: $0) ?? -1 }))
            -> Set<Int> {
        var indices = Set<Int>()
        for weekday in WEEKDAYS {
            if (`repeat` & EVERYDAY) & weekday > 0 {
                indices.insert(transfer(weekday))
            }
        }
        return indices
    }

    /**
     * 把索引集合转换成Int值的重复，比如 (0 ,1) 转换成 MONDAY | TUESDAY, 具体依赖transfer的返回值，默认:
     * 0为MONDAY
     * 1为TUESDAY
     *   ..
     *   ..
     * 5为SATURDAY
     * 6为SUNDAY
     */
    static func indicesToRepeat(indices: Set<Int>, transfer: (Int) -> Int = ({ WEEKDAYS[$0] }))
            -> Int {
        var `repeat` = 0
        for index in indices {
            `repeat` |= transfer(index)
        }
        return `repeat`
    }
}
