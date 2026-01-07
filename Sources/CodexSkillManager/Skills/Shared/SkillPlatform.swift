import Foundation

enum SkillPlatform: String, CaseIterable, Identifiable, Hashable {
    case codex = "Codex"
    case claude = "Claude Code"

    var id: String { rawValue }

    var storageKey: String {
        switch self {
        case .codex:
            return "codex"
        case .claude:
            return "claude"
        }
    }

    var rootURL: URL {
        let home = FileManager.default.homeDirectoryForCurrentUser
        switch self {
        case .codex:
            return home.appendingPathComponent(".codex/skills/public")
        case .claude:
            return home.appendingPathComponent(".claude/skills")
        }
    }

    var description: String {
        switch self {
        case .codex:
            return "Install in \(rootURL.path)"
        case .claude:
            return "Install in \(rootURL.path)"
        }
    }
}
