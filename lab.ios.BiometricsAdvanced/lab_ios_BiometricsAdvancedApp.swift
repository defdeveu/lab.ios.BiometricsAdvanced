import SwiftUI

@main
struct lab_ios_BiometricsAdvancedApp: App {
    init() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(AppColors.navigationBackground)
        appearance.backgroundImage = AppImages.navigationImage

        let attrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(AppColors.navigationForeground)
        ]

        appearance.largeTitleTextAttributes = attrs
        appearance.titleTextAttributes = attrs

        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().standardAppearance = appearance
    }

    var body: some Scene {
        WindowGroup {
            NavigationView {
                WelcomeView()
            }
            .navigationViewStyle(.stack)
            .preferredColorScheme(.dark)
            .accentColor(AppColors.navigationForeground)
        }
    }
}
