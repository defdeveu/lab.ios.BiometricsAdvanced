import SwiftUI

struct WelcomeView: View {
    @StateObject private var viewModel: WelcomeViewModel = WelcomeViewModel()

    var body: some View {
        ZStack {
            NavigationLink(destination: ContentView(),
                           isActive: $viewModel.navigateToContent,
                           label: { EmptyView() })

            Button("Welcome", action: viewModel.enterContent)
                .buttonStyle(SolidButtonStyle())
                .disabled(!viewModel.isAppReady)
        }
        .padding()
        .alert(isPresented: $viewModel.showError, content: {
            Alert(title: Text(viewModel.error ?? "Undefined error"))
        })
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { appTitle() }
    }

    @ToolbarContentBuilder
    private func appTitle() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            HStack {
                AppImages.appTitleImage
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .colorInvert()
                // TODO colorInvert as per the scheme
                Text(AppStrings.appTitle)
                    .font(.title.bold())
                    .foregroundColor(AppColors.navigationForeground)
            }
            .padding(.bottom, 8)
        }
    }
}

#if DEBUG
@available(iOS 15.0, *)
struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
#endif
