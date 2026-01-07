import SwiftUI

@main
struct CodexSkillManagerApp: App {
    @State private var store = SkillStore()

    var body: some Scene {
        WindowGroup("Codex Skill Manager") {
            SkillSplitView()
                .environment(store)
        }
    }
}
