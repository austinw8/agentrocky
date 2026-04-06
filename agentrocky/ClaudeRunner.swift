//
//  ClaudeRunner.swift
//  agentrocky
//

import Foundation
import Darwin

enum ClaudeRunner {
    /// Returns the real home directory, bypassing sandbox container redirection.
    private static var realHomeDirectory: String {
        let pw = getpwuid(getuid())
        return pw.flatMap { String(cString: $0.pointee.pw_dir, encoding: .utf8) }
            ?? realHomeDirectory
    }
    /// Runs `claude --print "<prompt>"` and returns the output string.
    static func run(prompt: String) async -> String {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                guard let claudePath = findClaude() else {
                    continuation.resume(returning: "Could not find the `claude` binary. Checked:\n\(searchPaths().joined(separator: "\n"))")
                    return
                }

                let process = Process()
                let pipe = Pipe()

                process.executableURL = URL(fileURLWithPath: claudePath)
                process.arguments = ["--print", prompt]
                process.standardOutput = pipe
                process.standardError = pipe
                process.currentDirectoryURL = URL(fileURLWithPath: realHomeDirectory)
                process.environment = ProcessInfo.processInfo.environment

                do {
                    try process.run()
                    process.waitUntilExit()
                    let data = pipe.fileHandleForReading.readDataToEndOfFile()
                    let output = String(data: data, encoding: .utf8) ?? ""
                    continuation.resume(returning: output.isEmpty ? "(no output)" : output)
                } catch {
                    continuation.resume(returning: "Error running claude: \(error.localizedDescription)")
                }
            }
        }
    }

    private static func searchPaths() -> [String] {
        let home = realHomeDirectory
        return [
            "\(home)/.local/bin/claude",
            "\(home)/.npm-global/bin/claude",
            "/opt/homebrew/bin/claude",
            "/usr/local/bin/claude",
            "/usr/bin/claude",
        ]
    }

    private static func findClaude() -> String? {
        searchPaths().first { FileManager.default.fileExists(atPath: $0) }
    }
}
