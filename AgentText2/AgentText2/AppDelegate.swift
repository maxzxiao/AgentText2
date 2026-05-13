//
//  AppDelegate.swift
//  AgentText2
//
//  Created by Max Xiao on 5/13/26.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    private let apiServer = AgentTextAPIServer()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        apiServer.start()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        apiServer.stop()
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }


}

private final class AgentTextAPIServer {
    private var process: Process?

    func start() {
        guard process?.isRunning != true else {
            print("🟢 [API] AgentText API is already running from this app session.")
            return
        }

        guard let apiDirectory = resolveAPIDirectory() else {
            print("🔴 [API] Could not find agenttext_api in bundled resources or ../agenttext_api.")
            return
        }

        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        task.arguments = ["npm", "run", "api"]
        task.currentDirectoryURL = apiDirectory
        task.environment = apiEnvironment()

        let outputPipe = Pipe()
        task.standardOutput = outputPipe
        task.standardError = outputPipe
        streamOutput(from: outputPipe)

        task.terminationHandler = { finishedProcess in
            print("🟡 [API] AgentText API exited with status \(finishedProcess.terminationStatus).")
        }

        do {
            try task.run()
            process = task
            print("🟢 [API] Started AgentText API from \(apiDirectory.path)")
        } catch {
            print("🔴 [API] Failed to start AgentText API: \(error.localizedDescription)")
        }
    }

    func stop() {
        guard let process, process.isRunning else { return }
        process.terminate()
        self.process = nil
        print("🟡 [API] Stopped AgentText API.")
    }

    private func resolveAPIDirectory() -> URL? {
        let fileManager = FileManager.default

        if let bundledURL = Bundle.main.resourceURL?.appendingPathComponent("agenttext_api"),
           fileManager.fileExists(atPath: bundledURL.appendingPathComponent("package.json").path) {
            print("🟢 [API] Using bundled agenttext_api path.")
            return bundledURL
        }

        let devURL = URL(fileURLWithPath: fileManager.currentDirectoryPath)
            .appendingPathComponent("../agenttext_api")
            .standardizedFileURL

        if fileManager.fileExists(atPath: devURL.appendingPathComponent("package.json").path) {
            print("🟢 [API] Using dev sibling agenttext_api path.")
            return devURL
        }

        return nil
    }

    private func apiEnvironment() -> [String: String] {
        var environment = ProcessInfo.processInfo.environment
        let bunPath = URL(fileURLWithPath: NSHomeDirectory())
            .appendingPathComponent(".bun/bin")
            .path
        let commonPaths = [
            bunPath,
            "/opt/homebrew/bin",
            "/usr/local/bin",
            "/usr/bin",
            "/bin",
            "/usr/sbin",
            "/sbin"
        ]
        let existingPath = environment["PATH"] ?? ""
        environment["PATH"] = (commonPaths + [existingPath])
            .filter { !$0.isEmpty }
            .joined(separator: ":")
        environment["BUN_INSTALL"] = URL(fileURLWithPath: NSHomeDirectory())
            .appendingPathComponent(".bun")
            .path
        print("🟢 [API] PATH includes \(bunPath)")
        return environment
    }

    private func streamOutput(from pipe: Pipe) {
        pipe.fileHandleForReading.readabilityHandler = { fileHandle in
            let data = fileHandle.availableData
            guard !data.isEmpty, let message = String(data: data, encoding: .utf8) else { return }
            print("🟣 [API] \(message.trimmingCharacters(in: .whitespacesAndNewlines))")
        }
    }
}
