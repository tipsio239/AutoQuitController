//
//  AutoQuitControllerTests.swift
//  AutoQuitControllerTests
//
//  Created by Justin Wong on 2025/12/11.
//

import Testing
@testable import AutoQuitController

struct AutoQuitControllerTests {

    @Test func oneTimeScheduleExecutesOnlyOnExactDate() async throws {
        let calendar = Calendar(identifier: .gregorian)
        let scheduledDate = calendar.date(from: DateComponents(year: 2024, month: 2, day: 1, hour: 9, minute: 30))!

        let schedule = AppSchedule(
            appBundleId: "com.example.test",
            appName: "Test App",
            quitTime: scheduledDate,
            warningMinutes: 5,
            isOneTime: true
        )

        #expect(ScheduleService.isExecutionTime(for: schedule, at: scheduledDate, calendar: calendar))

        let nextDaySameTime = calendar.date(byAdding: .day, value: 1, to: scheduledDate)!
        #expect(!ScheduleService.isExecutionTime(for: schedule, at: nextDaySameTime, calendar: calendar))

        let oneHourLater = calendar.date(byAdding: .hour, value: 1, to: scheduledDate)!
        #expect(!ScheduleService.isExecutionTime(for: schedule, at: oneHourLater, calendar: calendar))
    }

    @Test func oneTimeWarningMatchesExactDate() async throws {
        let calendar = Calendar(identifier: .gregorian)
        let scheduledDate = calendar.date(from: DateComponents(year: 2024, month: 2, day: 1, hour: 9, minute: 30))!

        let schedule = AppSchedule(
            appBundleId: "com.example.test",
            appName: "Test App",
            quitTime: scheduledDate,
            warningMinutes: 10,
            isOneTime: true
        )

        let warningDate = calendar.date(byAdding: .minute, value: -10, to: scheduledDate)!
        #expect(ScheduleService.isWarningTime(for: schedule, at: warningDate, calendar: calendar))

        let sameTimeDifferentDay = calendar.date(byAdding: .day, value: 1, to: warningDate)!
        #expect(!ScheduleService.isWarningTime(for: schedule, at: sameTimeDifferentDay, calendar: calendar))

        let warningMinutePassed = calendar.date(byAdding: .minute, value: 1, to: warningDate)!
        #expect(!ScheduleService.isWarningTime(for: schedule, at: warningMinutePassed, calendar: calendar))
    }

}
