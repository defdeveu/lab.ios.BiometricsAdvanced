import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel: ContentViewModel = ContentViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Spacer()

                TextField("message", text: $viewModel.message)
                    .padding([.leading, .trailing], 10)
                    .frame(height: 44)
                    .background(RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .stroke(AppColors.textInputOverlay, lineWidth: 1))

                Button("Save", action: viewModel.saveMessage)
                    .buttonStyle(SolidButtonStyle())

                Spacer()

                Button("Show message", action: viewModel.showMessage)
                    .buttonStyle(SolidButtonStyle())

                Spacer()
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $viewModel.showAlert, content: {
            Alert(title: Text(viewModel.alertMessage))
        })
    }
}

#if DEBUG
@available(iOS 15.0, *)
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
#endif
