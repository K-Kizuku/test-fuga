import SwiftUI

struct CapabilityListView: View {
    var body: some View {
        NavigationStack {
            List(CapabilityRegistry.entries) { entry in
                NavigationLink {
                    entry.makeView().navigationTitle(entry.title)
                } label: {
                    VStack(alignment: .leading) {
                        Text(entry.title)
                        Text(entry.deviceChecks).font(.caption).foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Capability Playground")
        }
    }
}
