import SwiftUI

struct SkillListView: View {
    @Environment(SkillStore.self) private var store

    let localCodexSkills: [Skill]
    let localClaudeSkills: [Skill]
    let remoteLatestSkills: [RemoteSkill]
    let remoteSearchResults: [RemoteSkill]
    let remoteSearchState: RemoteSkillStore.LoadState
    let remoteLatestState: RemoteSkillStore.LoadState
    let remoteQuery: String
    let installedPlatforms: [String: Set<SkillPlatform>]

    @Binding var source: SkillSource
    @Binding var localSelection: Skill.ID?
    @Binding var remoteSelection: RemoteSkill.ID?

    var body: some View {
        List(selection: source == .local ? $localSelection : $remoteSelection) {
            if source == .local {
                SidebarHeaderView(
                    skillCount: localCodexSkills.count + localClaudeSkills.count,
                    source: $source
                )
                .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 8, trailing: 0))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)

                Section("Codex") {
                    localSectionContent(localCodexSkills)
                }

                Section("Claude Code") {
                    localSectionContent(localClaudeSkills)
                }
            } else {
                SidebarHeaderView(
                    skillCount: remoteLatestSkills.count,
                    source: $source
                )
                .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 8, trailing: 0))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)

                if shouldShowSearchSection {
                    Section("Search Results") {
                        searchSectionContent
                    }
                }

                Section("Latest Drops") {
                    latestSectionContent
                }
            }
        }
        .listStyle(.sidebar)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    Task { await store.loadSkills() }
                } label: {
                    Label("Reload", systemImage: "arrow.clockwise")
                }
                .labelStyle(.iconOnly)
                .disabled(source != .local)
            }
        }
    }

    private var shouldShowSearchSection: Bool {
        !remoteQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    @ViewBuilder
    private var searchSectionContent: some View {
        if remoteSearchState == .loading {
            HStack {
                ProgressView()
                Text("Searching…")
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 8)
        } else if case let .failed(message) = remoteSearchState {
            Text("Search failed: \(message)")
                .foregroundStyle(.secondary)
                .padding(.vertical, 8)
        } else if remoteSearchResults.isEmpty {
            Text("No results yet.")
                .foregroundStyle(.secondary)
                .padding(.vertical, 8)
        } else {
            ForEach(remoteSearchResults) { skill in
                RemoteSkillRowView(
                    skill: skill,
                    installedTargets: installedPlatforms[skill.slug, default: []]
                )
            }
        }
    }

    @ViewBuilder
    private var latestSectionContent: some View {
        if remoteLatestState == .loading {
            HStack {
                ProgressView()
                Text("Loading latest…")
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 8)
        } else if case let .failed(message) = remoteLatestState {
            Text("Latest drops unavailable: \(message)")
                .foregroundStyle(.secondary)
                .padding(.vertical, 8)
        } else if remoteLatestSkills.isEmpty {
            Text("No skills yet.")
                .foregroundStyle(.secondary)
                .padding(.vertical, 8)
        } else {
            ForEach(remoteLatestSkills) { skill in
                RemoteSkillRowView(
                    skill: skill,
                    installedTargets: installedPlatforms[skill.slug, default: []]
                )
            }
        }
    }

    @ViewBuilder
    private func localSectionContent(_ skills: [Skill]) -> some View {
        if skills.isEmpty {
            Text("No skills yet.")
                .foregroundStyle(.secondary)
                .padding(.vertical, 8)
        } else {
            ForEach(skills) { skill in
                SkillRowView(skill: skill)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            Task { await store.deleteSkills(ids: [skill.id]) }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
            .onDelete { offsets in
                let ids = offsets
                    .filter { skills.indices.contains($0) }
                    .map { skills[$0].id }
                Task { await store.deleteSkills(ids: ids) }
            }
        }
    }
}
