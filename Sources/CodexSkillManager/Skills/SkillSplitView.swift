import AppKit
import SwiftUI

struct SkillSplitView: View {
    @Environment(SkillStore.self) private var store
    @State private var searchText = ""

    private var filteredSkills: [Skill] {
        guard !searchText.isEmpty else { return store.skills }
        return store.skills.filter { skill in
            skill.displayName.localizedCaseInsensitiveContains(searchText)
                || skill.description.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        @Bindable var store = store

        NavigationSplitView {
            SkillListView(skills: filteredSkills, selection: $store.selectedSkillID)
        } detail: {
            SkillDetailView()
        }
        .task {
            await store.loadSkills()
        }
        .onChange(of: store.selectedSkillID) { _, _ in
            Task { await store.loadSelectedSkill() }
        }
        .searchable(text: $searchText, placement: .sidebar, prompt: "Filter skills")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    openSkillsFolder()
                } label: {
                    Label("Open Skills", systemImage: "folder")
                }
                .labelStyle(.iconOnly)
            }

            ToolbarItem(placement: .primaryAction) {
                Button {
                } label: {
                    Label("Import Skills", systemImage: "plus")
                }
                .labelStyle(.iconOnly)
            }
        }
    }

    private func openSkillsFolder() {
        let url = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".codex/skills/public")
        NSWorkspace.shared.open(url)
    }
}
