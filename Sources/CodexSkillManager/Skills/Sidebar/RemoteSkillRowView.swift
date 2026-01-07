import SwiftUI

struct RemoteSkillRowView: View {
    let skill: RemoteSkill
    let installedTargets: Set<SkillPlatform>

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(skill.displayName)
                .font(.headline)
                .foregroundStyle(.primary)

            if let summary = skill.summary, !summary.isEmpty {
                Text(summary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            HStack(spacing: 6) {
                if let version = skill.latestVersion {
                    TagView(text: "v\(version)")
                }

                ForEach(SkillPlatform.allCases) { platform in
                    if installedTargets.contains(platform) {
                        TagView(text: platform.rawValue, tint: .green)
                    }
                }
            }
        }
        .padding(.vertical, 6)
    }
}
