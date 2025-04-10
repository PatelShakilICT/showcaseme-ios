import UIKit
import WebKit
import MobileCoreServices
import UniformTypeIdentifiers

class ViewController: UIViewController {

    var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure preferences
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        preferences.javaScriptCanOpenWindowsAutomatically = true
        
        // Configure WKWebViewConfiguration
        let contentController = WKUserContentController()
        contentController.add(self, name: "qrButtonClicked") // 👈 message handler for JavaScript
        

        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        configuration.dataDetectorTypes = [.all]
        configuration.allowsAirPlayForMediaPlayback = true
        
        // Initialize WKWebView
        webView = WKWebView(frame: .zero, configuration: configuration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        self.webView.configuration.userContentController = contentController
        view.addSubview(webView)
        
        // Set constraints
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        webView.navigationDelegate = self
        webView.uiDelegate = self
        
        var obj = UserDefaults.standard
        
        // Load URL
//        let url = "https://patelshakil.tech"
        var url = "http://192.168.6.51:5173/jwt-verify/\(obj.string(forKey: "token")!)"
        if let myURL = URL(string: url) {
            let myRequest = URLRequest(url: myURL)
            webView.load(myRequest)
        }
        
        // For iOS 11+
        if #available(iOS 11.0, *) {
            webView.scrollView.contentInsetAdjustmentBehavior = .never
        }

        // Enable gestures
        webView.allowsBackForwardNavigationGestures = true
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let js = """
        let attempts = 0;
        const maxAttempts = 20;

        const interval = setInterval(function() {
            let logoutBtn = document.getElementById("logoutBtn");
            let qrBtn = document.getElementById("qrBtn");
            console.log("js attached");

            if (logoutBtn && qrBtn) {
                if (!logoutBtn.hasAttribute("listener-attached")) {
                    logoutBtn.addEventListener("click", function() {});
                    logoutBtn.setAttribute("listener-attached", "true");
                }

                if (!qrBtn.hasAttribute("listener-attached")) {
                    qrBtn.classList.remove("hidden");
                    qrBtn.classList.add("flex");
                    qrBtn.addEventListener("click", function() {
                        window.webkit.messageHandlers.qrButtonClicked.postMessage("clicked");           
                    });
                    qrBtn.setAttribute("listener-attached", "true");
                }

                clearInterval(interval);
            } else {
                attempts++;
                if (attempts > maxAttempts) {
                    clearInterval(interval);
                }
            }
        }, 500);
        """
        
        webView.evaluateJavaScript(js, completionHandler: { (result, error) in
            if let error = error {
                print("JS Error: \(error.localizedDescription)")
            } else {
                print("JS successfully injected")
            }
        })
    }


    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Inject JavaScript to capture qrBtn click
        let js = """
          let attempts = 0;
                    const maxAttempts = 20;

                    const interval = setInterval(function() {
                        let logoutBtn = document.getElementById("logoutBtn");
                        let qrBtn = document.getElementById("qrBtn");
        console.log("js attached");

                        if (logoutBtn && qrBtn) {
                            if (!logoutBtn.hasAttribute("listener-attached")) {
                                logoutBtn.addEventListener("click", function() {});
                                logoutBtn.setAttribute("listener-attached", "true");
                            }

                            if (!qrBtn.hasAttribute("listener-attached")) {
                                qrBtn.classList.remove("hidden");
                                qrBtn.classList.add("flex");
                                qrBtn.addEventListener("click", function() {
                    window.webkit.messageHandlers.qrButtonClicked.postMessage("clicked");           
                     });
                                qrBtn.setAttribute("listener-attached", "true");
                            }

                            clearInterval(interval);
                        } else {
                            attempts++;
                            if (attempts > maxAttempts) {
                                clearInterval(interval);
                            }
                        }
                    }, 500);
        """
        webView.evaluateJavaScript(js, completionHandler: nil)
    }
	
    func navigateToQRCodeVC() {
        let qrVC = storyboard?.instantiateViewController(withIdentifier: "qrcode") as! QRCodeViewController
        navigationController?.pushViewController(qrVC, animated: false)
        debugPrint("QR Code navigation")
    }
}

// MARK: - WKScriptMessageHandler (for JavaScript -> Native)
extension ViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        debugPrint(message.name)
        if message.name == "qrButtonClicked" {
            navigateToQRCodeVC()
        }
    }
}

// MARK: - Navigation Delegate
extension ViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }

        let urlString = url.absoluteString
        if urlString.contains("mailto:") || urlString.contains("sms:") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }
}

// MARK: - UI Delegate for Uploading
extension ViewController: WKUIDelegate {
    
    private struct Holder {
        static var handler: (([URL]?) -> Void)?
    }
    var uploadCompletionHandler: (([URL]?) -> Void)? {
        get { return Holder.handler }
        set { Holder.handler = newValue }
    }
}

// MARK: - Document Picker
extension ViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        uploadCompletionHandler?(urls)
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        uploadCompletionHandler?(nil)
    }
}
