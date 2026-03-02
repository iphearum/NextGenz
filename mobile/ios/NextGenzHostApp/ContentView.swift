import SwiftUI
import UIKit

struct ContentView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("NextGenz Khmer Keyboard")
                .font(.title2)
                .bold()

            Text("1. Open Settings")
            Text("2. Enable NextGenz Keyboard")
            Text("3. Select it while typing")

            Button("Open Keyboard Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .padding(.top, 12)
        }
        .padding(24)
    }
}

