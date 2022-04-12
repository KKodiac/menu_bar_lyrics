//
//  lyricsbarApp.swift
//  lyricsbar
//
//  Created by Sean Hong on 2022/04/08.
//

import SwiftUI

@main
struct lyricsbarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    
        var popover = NSPopover.init()
        var statusBar: StatusBarController?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Popover 가 아닌 Window, 즉 맨 처음 생성되는 창을 닫아줌
        if let window = NSApplication.shared.windows.first {
            window.close()
        }
        let contentView = ContentView()
        popover.contentSize = NSSize(width: 400, height: 200)
        popover.contentViewController = NSHostingController(rootView: contentView)
        popover.setValue(true, forKeyPath: "shouldHideAnchor")
        statusBar = StatusBarController.init(popover)
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        // TODO: Termination Code
    }
}
