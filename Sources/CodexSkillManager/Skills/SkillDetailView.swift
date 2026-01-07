import MarkdownUI
import SwiftUI

struct SkillDetailView: View {
    @Environment(SkillStore.self) private var store

    var body: some View {
        if let skill = store.selectedSkill {
            content(for: skill)
        } else {
            ContentUnavailableView("Select a skill",
                                   systemImage: "sparkles",
                                   description: Text("Pick a skill from the list."))
        }
    }

    @ViewBuilder
    private func content(for skill: Skill) -> some View {
        switch store.detailState {
        case .idle, .loading:
            ProgressView("Loading \(skill.name)...")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .missing:
            ContentUnavailableView("Missing SKILL.md",
                                   systemImage: "doc",
                                   description: Text("No SKILL.md found in this skill folder."))
        case .failed(let message):
            ContentUnavailableView("Unable to load",
                                   systemImage: "exclamationmark.triangle",
                                   description: Text(message))
        case .loaded:
            SkillMarkdownView(skill: skill, markdown: store.selectedMarkdown)
        }
    }
}

private struct SkillMarkdownView: View {
    let skill: Skill
    let markdown: String
    @Environment(SkillStore.self) private var store

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(skill.displayName)
                        .font(.largeTitle.bold())
                    Text(skill.folderPath)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                Markdown(markdown)

                if !skill.references.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("References")
                            .font(.title2.bold())
                        ReferenceListView(references: skill.references)
                    }
                    .padding(.top, 8)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
    }
}

private struct ReferenceListView: View {
    let references: [SkillReference]
    @Environment(SkillStore.self) private var store

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(references) { reference in
                VStack(alignment: .leading, spacing: 8) {
                    Button {
                        Task { await toggleReference(reference) }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "doc.text")
                                .foregroundStyle(.secondary)
                            Text(reference.name)
                                .foregroundStyle(.primary)
                            Spacer(minLength: 0)
                            Image(systemName: isSelected(reference) ? "chevron.down" : "chevron.right")
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 6)
                        .padding(.horizontal, 8)
                        .background(selectionBackground(for: reference))
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                    .buttonStyle(.plain)

                    if isSelected(reference) {
                        ReferenceDetailInlineView()
                            .padding(.horizontal, 8)
                    }
                }
            }
        }
    }

    private func selectionBackground(for reference: SkillReference) -> some View {
        let isSelected = store.selectedReferenceID == reference.id
        return RoundedRectangle(cornerRadius: 8, style: .continuous)
            .fill(isSelected ? Color.accentColor.opacity(0.15) : Color.secondary.opacity(0.08))
    }

    private func isSelected(_ reference: SkillReference) -> Bool {
        store.selectedReferenceID == reference.id
    }

    private func toggleReference(_ reference: SkillReference) async {
        if isSelected(reference) {
            store.selectedReferenceID = nil
            store.selectedReferenceMarkdown = ""
            store.referenceState = .idle
        } else {
            await store.selectReference(reference)
        }
    }
}

private struct ReferenceDetailInlineView: View {
    @Environment(SkillStore.self) private var store

    var body: some View {
        switch store.referenceState {
        case .idle:
            EmptyView()
        case .loading:
            ProgressView("Loading reference…")
                .frame(maxWidth: .infinity, alignment: .leading)
        case .missing:
            ContentUnavailableView("Missing reference",
                                   systemImage: "doc",
                                   description: Text("This reference file could not be found."))
        case .failed(let message):
            ContentUnavailableView("Unable to load reference",
                                   systemImage: "exclamationmark.triangle",
                                   description: Text(message))
        case .loaded:
            Markdown(store.selectedReferenceMarkdown)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.secondary.opacity(0.06))
                )
        }
    }
}
