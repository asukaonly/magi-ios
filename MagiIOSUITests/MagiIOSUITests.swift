import XCTest

@MainActor final class MagiIOSUITests: XCTestCase {
    private func start(language: String = "en", reset: Bool = true) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = (reset ? ["--uitesting-reset"] : []) + ["-AppleLanguages", "(\(language))", "-AppleLocale", language == "en" ? "en_US" : "zh_CN"]
        app.launch()
        return app
    }
    private func fixture(_ path: String) async throws -> [String: Any] {
        let url = try XCTUnwrap(URL(string: "http://127.0.0.1:18992/test/" + path))
        let (data, response) = try await URLSession.shared.data(from: url)
        XCTAssertEqual((response as? HTTPURLResponse)?.statusCode, 200)
        return try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
    }
    private func connect(_ app: XCUIApplication) {
        let address = app.textFields["connection.address"]
        XCTAssertTrue(address.waitForExistence(timeout: 10))
        address.tap(); address.typeText("http://127.0.0.1:18992")
        let code = app.secureTextFields["connection.code"]
        code.tap(); code.typeText(String(repeating: "a", count: 64))
        app.buttons["connection.connect"].tap()
        XCTAssertTrue(app.textFields["chat.composer"].waitForExistence(timeout: 15))
    }
    func testConnectionFormRejectsUnsafeAddress() {
        let app = XCUIApplication()
        app.launchArguments = ["--uitesting-reset", "-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launch()
        let address = app.textFields["connection.address"]
        XCTAssertTrue(address.waitForExistence(timeout: 10))
        address.tap(); address.typeText("http://example.com")
        let code = app.secureTextFields["connection.code"]
        code.tap(); code.typeText(String(repeating: "a", count: 64))
        app.buttons["connection.connect"].tap()
        XCTAssertTrue(app.alerts.firstMatch.waitForExistence(timeout: 5))
        XCTAssertTrue(app.alerts.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "HTTPS")).firstMatch.exists)
    }

    func testSendWithLostAcknowledgementAndRelaunch() async throws {
        _ = try await fixture("reset")
        let app = start()
        connect(app)
        let composer = app.textFields["chat.composer"]
        XCTAssertTrue(composer.waitForExistence(timeout: 5))
        composer.tap(); composer.typeText("Hello from iOS")
        app.buttons["chat.send"].tap()
        let reply = app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "Received: Hello from iOS")).firstMatch
        XCTAssertTrue(reply.waitForExistence(timeout: 12))
        XCTAssertFalse(app.alerts.firstMatch.exists)
        app.terminate()
        let restored = start(reset: false)
        XCTAssertTrue(restored.textFields["chat.composer"].waitForExistence(timeout: 12))
        XCTAssertTrue(restored.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "Received: Hello from iOS")).firstMatch.waitForExistence(timeout: 8))
        XCUIDevice.shared.press(.home)
        restored.activate()
        XCTAssertTrue(restored.textFields["chat.composer"].waitForExistence(timeout: 5))
        _ = try await fixture("offline")
        restored.buttons["app.menu"].tap(); restored.buttons["Refresh"].tap()
        XCTAssertTrue(restored.alerts.firstMatch.waitForExistence(timeout: 8))
        restored.alerts.buttons["OK"].tap()
        let offlineDraft = restored.textFields["chat.composer"]
        offlineDraft.tap(); offlineDraft.typeText("Offline draft")
        XCTAssertFalse(restored.buttons["chat.send"].isEnabled)
        _ = try await fixture("online")
        restored.buttons["app.menu"].tap(); restored.buttons["Refresh"].tap()
        for _ in 0..<32 {
            if restored.buttons["chat.send"].isEnabled { break }
            try await Task.sleep(for: .milliseconds(250))
        }
        XCTAssertTrue(restored.buttons["chat.send"].isEnabled)
        XCTAssertEqual(offlineDraft.value as? String, "Offline draft")
        let state = try await fixture("state")
        XCTAssertEqual(state["sends"] as? Int, 1)
        let screenshot = XCTAttachment(screenshot: restored.screenshot())
        screenshot.name = "Conversation after recovery"; screenshot.lifetime = .keepAlways; add(screenshot)
    }

    func testQuestionsPermissionsTasksAndNotifications() async throws {
        _ = try await fixture("reset")
        _ = try await fixture("interactions")
        let app = start()
        connect(app)
        XCTAssertTrue(app.buttons["Start with iOS"].waitForExistence(timeout: 8))
        app.buttons["Start with iOS"].tap()
        XCTAssertTrue(app.buttons["Allow once"].waitForExistence(timeout: 8))
        app.buttons["Allow once"].tap()
        app.tabBars.buttons["Tasks"].tap()
        let complete = app.buttons["task.complete.fixture-task"]
        XCTAssertTrue(complete.waitForExistence(timeout: 8))
        complete.tap()
        XCTAssertTrue(app.staticTexts["Nothing here yet"].waitForExistence(timeout: 8))
        app.buttons["notifications.open"].tap()
        XCTAssertTrue(app.buttons["Mark read"].waitForExistence(timeout: 5))
        app.buttons["Mark read"].tap()
        let state = try await fixture("state")
        XCTAssertEqual(state["task"] as? Bool, true)
        XCTAssertEqual(state["permission"] as? Bool, false)
        // Wait for the asynchronous read action through its visible result.
        for _ in 0..<32 {
            if !app.buttons["Mark read"].exists { break }
            try await Task.sleep(for: .milliseconds(250))
        }
        XCTAssertFalse(app.buttons["Mark read"].exists)
        XCTAssertFalse(app.alerts.firstMatch.exists)
    }

    func testReceivedImageAndAttachmentMenu() async throws {
        _ = try await fixture("reset")
        _ = try await fixture("images")
        let app = start()
        connect(app)
        let image = app.buttons["chat.image"]
        XCTAssertTrue(image.waitForExistence(timeout: 10))
        image.tap()
        XCTAssertTrue(app.buttons["Done"].waitForExistence(timeout: 5))
        app.buttons["Done"].tap()
        app.buttons["chat.attach"].tap()
        XCTAssertTrue(app.buttons["Photo Library"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Take Photo"].exists)
        XCTAssertTrue(app.buttons["Choose File"].exists)
    }

    func testPhotoLibrarySendsImageAloneAndWithText() async throws {
        _ = try await fixture("reset")
        let app = start(); connect(app)
        for text in ["", "A photo with a note"] {
            app.buttons["chat.attach"].tap(); app.buttons["Photo Library"].tap()
            let photos = app.images.matching(NSPredicate(format: "label BEGINSWITH %@", "Photo"))
            XCTAssertTrue(photos.firstMatch.waitForExistence(timeout: 8), app.debugDescription)
            // The system picker exposes photo tiles as non-hittable AX images.
            let photo = photos.firstMatch
            photo.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
            app.buttons["Done"].tap()
            let send = app.buttons["chat.send"]
            for _ in 0..<40 {
                if send.isEnabled { break }
                try await Task.sleep(for: .milliseconds(250))
            }
            XCTAssertTrue(send.isEnabled)
            if !text.isEmpty { app.textFields["chat.composer"].tap(); app.textFields["chat.composer"].typeText(text) }
            send.tap()
            for _ in 0..<40 {
                if !app.buttons["chat.send"].isEnabled { break }
                try await Task.sleep(for: .milliseconds(250))
            }
            XCTAssertTrue(app.buttons["chat.image"].firstMatch.waitForExistence(timeout: 10))
        }
        let state = try await fixture("state")
        let sends = try XCTUnwrap(state["image_sends"] as? [[String: Any]])
        XCTAssertEqual(state["uploads"] as? Int, 2)
        XCTAssertEqual(sends.count, 2)
        XCTAssertEqual(sends.map { $0["text"] as? String ?? "" }, ["", "A photo with a note"])
        XCTAssertTrue(sends.allSatisfy { $0["count"] as? Int == 1 })
    }

    func testMemorySourcesAndHealthConsent() async throws {
        _ = try await fixture("reset")
        let app = start()
        connect(app)
        app.tabBars.buttons["Memory"].tap()
        let memory = app.buttons["memory.item.walking"]
        XCTAssertTrue(memory.waitForExistence(timeout: 8))
        memory.tap()
        XCTAssertTrue(app.staticTexts["You enjoy evening walks."].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons.containing(NSPredicate(format: "label CONTAINS %@", "An evening walk by the river.")).firstMatch.waitForExistence(timeout: 5))
        app.buttons["This is incorrect"].tap()
        XCTAssertTrue(app.staticTexts["Your memories will appear here"].waitForExistence(timeout: 8))
        app.tabBars.buttons["Extensions"].tap()
        let extensionRow = app.buttons.containing(NSPredicate(format: "label CONTAINS %@", "Apple Health")).firstMatch
        XCTAssertTrue(extensionRow.waitForExistence(timeout: 8))
        extensionRow.tap()
        XCTAssertTrue(app.buttons["health.open"].waitForExistence(timeout: 8))
        app.buttons["health.open"].tap()
        XCTAssertTrue(app.switches["Allow health data processing"].waitForExistence(timeout: 8))
        XCTAssertFalse(app.buttons["Read and preview"].isEnabled)
        let screenshot = XCTAttachment(screenshot: app.screenshot())
        screenshot.name = "Health consent"; screenshot.lifetime = .keepAlways; add(screenshot)
        let state = try await fixture("state")
        XCTAssertEqual(state["memory_corrected"] as? Bool, true)
    }

    func testChineseInterface() async throws {
        _ = try await fixture("reset")
        let app = start(language: "zh-Hans")
        XCTAssertTrue(app.staticTexts["每天，多懂你一点。"].waitForExistence(timeout: 8))
        connect(app)
        XCTAssertTrue(app.tabBars.buttons["对话"].exists)
        XCTAssertTrue(app.tabBars.buttons["任务"].exists)
        XCTAssertTrue(app.tabBars.buttons["记忆"].exists)
        XCTAssertTrue(app.tabBars.buttons["扩展"].exists)
        let screenshot = XCTAttachment(screenshot: app.screenshot())
        screenshot.name = "Chinese conversations"; screenshot.lifetime = .keepAlways; add(screenshot)
    }
}
