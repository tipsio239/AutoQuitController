//
//  AutoQuitControllerTests.swift
//  AutoQuitControllerTests
//
//  Created by Justin Wong on 2025/12/11.
//

import Foundation
import Testing
@testable import AutoQuitController

struct AutoQuitControllerTests {

    @Test func deletePastSchedulesRemovesExpiredOneTimeEntries() async throws {
        let referenceDate = Date(timeIntervalSince1970: 1_700_000_000)
        var appModel = AppModel()

        let pastOneTime = AppSchedule(
            appBundleId: "com.example.past",
            appName: "Past",
            quitTime: referenceDate.addingTimeInterval(-3600),
            isOneTime: true,
            repeatDays: []
        )

        let futureOneTime = AppSchedule(
            appBundleId: "com.example.future",
            appName: "Future",
            quitTime: referenceDate.addingTimeInterval(3600),
            isOneTime: true,
            repeatDays: []
        )

        let recurring = AppSchedule(
            appBundleId: "com.example.recurring",
            appName: "Recurring",
            quitTime: referenceDate.addingTimeInterval(-7200),
            isOneTime: false,
            repeatDays: [1, 3, 5]
        )

        appModel.schedules = [pastOneTime, futureOneTime, recurring]

        appModel.deletePastSchedules(referenceDate: referenceDate)

        #expect(appModel.schedules.contains(pastOneTime) == false)
        #expect(appModel.schedules.contains(futureOneTime))
        #expect(appModel.schedules.contains(recurring))
    }

    @Test func hasPastSchedulesMatchesHelperLogic() async throws {
        let referenceDate = Date(timeIntervalSince1970: 1_700_000_000)
        var appModel = AppModel()

        let pastOneTime = AppSchedule(
            appBundleId: "com.example.past",
            appName: "Past",
            quitTime: referenceDate.addingTimeInterval(-60),
            isOneTime: true,
            repeatDays: []
        )

        appModel.schedules = [pastOneTime]
        #expect(appModel.hasPastSchedules(referenceDate: referenceDate))

        let upcoming = AppSchedule(
            appBundleId: "com.example.upcoming",
            appName: "Upcoming",
            quitTime: referenceDate.addingTimeInterval(120),
            isOneTime: true,
            repeatDays: []
        )

        appModel.schedules.append(upcoming)
        #expect(appModel.hasPastSchedules(referenceDate: referenceDate))

        appModel.deletePastSchedules(referenceDate: referenceDate)
        #expect(appModel.hasPastSchedules(referenceDate: referenceDate) == false)
    }
}
