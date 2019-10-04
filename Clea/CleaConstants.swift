//
//  CleaConstants.swift
//  Clea
//
//  Created by Damian Elsen on 9/11/19.
//  Copyright © 2019 Damian Elsen. All rights reserved.
//

import Foundation

class CleaConstants {
    
    // MARK: - Constants
    
    static let accentColorName = "AccentColor"
    static let taskScheduledColorName = "TaskScheduledColor"
    static let taskDueColorName = "TaskDueColor"
    static let taskOverdueColorName = "TaskOverdueColor"
    static let toastBackgroundColorName = "ToastBackgroundColor"

    static let entityNameRoom = "Room"
    static let entityNameRoomType = "RoomType"
    static let entityNameTask = "Task"
    static let entityNameIntervalType = "IntervalType"
    
    static let keyNameName = "name"
    static let keyNameDays = "noOfDays"
    
    static let cellReuseIdentifierRoom = "RoomTableViewCell"
    static let cellReuseIdentifierTask = "TaskTableViewCell"
    
    static let segueShowDetailRoom = "ShowRoomDetail"
    static let segueShowDetailTask = "ShowTaskDetail"
    static let segueShowRoomTasks = "ShowRoomTasks"

    static let notificationRefreshRooms = "com.damianelsen.Clea.notificationKey.refreshRoomList"
    static let notificationRefreshTasks = "com.damianelsen.Clea.notificationKey.refreshTaskList"

    static let predicateOverdueTask = "CAST(CAST(lastCompleted, 'NSNumber') + (interval * intervalType.noOfDays * 86400), 'NSDate') < %@"
    static let predicateDueTodayTask = "CAST(CAST(lastCompleted, 'NSNumber') + (interval * intervalType.noOfDays * 86400), 'NSDate') = %@"

    static let notificationIdentifier = "com.damianelsen.Clea.notificationID"
    
}
