import SwiftUI

struct ContentView: View {

    @State private var showingSheet = false


    func buildWebviewURL(amount: Float, token: String, note: String) -> URL {
        let urlString = "https://1pay.network/app?recipient=\(Constants.RECIPIENT)&token=\(Constants.TOKENS)&network=\(Constants.NETWORKS)&paymentAmount=\(amount)&paymentToken=\(token)&paymentNote=\(note.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)"
        return URL(string: urlString)!
    }

    func handlePaymentResult() {

    }

    var body: some View {
        VStack {
            Button("Start") {
                showingSheet.toggle()
            }
        }
        .sheet(isPresented: $showingSheet, content: {
            ZStack(alignment: .topTrailing) {
                HStack {
                    Button(action: {
                        showingSheet.toggle()
                    }) {
                        Image(systemName: "xmark")

                    }
                    .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
                    .background(.gray)
                    .foregroundColor(.white)
                    .clipShape(Circle())
                }.zIndex(1000).padding()

                PaymentWebView(url: buildWebviewURL(amount: 0.1, token: "usdt", note: "demo note"))
                    .onepaySuccess { response in

                    }
                    .onepayFail { response in

                    }
            }
        })
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
