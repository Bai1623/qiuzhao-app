import EventKit
import EventKitUI
import UIKit
import WebKit

final class WebViewController: UIViewController {
    private var webView: WKWebView!
    private let eventStore = EKEventStore()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.96, green: 0.98, blue: 0.98, alpha: 1)
        configureWebView()
        loadLocalApp()
    }

    private func configureWebView() {
        let controller = WKUserContentController()
        controller.add(self, name: "iosBridge")
        controller.addUserScript(WKUserScript(
            source: Self.bridgeScript,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: false
        ))

        let configuration = WKWebViewConfiguration()
        configuration.userContentController = controller
        configuration.websiteDataStore = .default()
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = true

        webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(webView)
        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            webView.topAnchor.constraint(equalTo: guide.topAnchor),
            webView.bottomAnchor.constraint(equalTo: guide.bottomAnchor)
        ])
    }

    private func loadLocalApp() {
        guard
            let resourceDirectory = Bundle.main.resourceURL?.appendingPathComponent("Resources", isDirectory: true),
            let indexURL = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "Resources")
        else {
            showToast("找不到内置页面资源")
            return
        }
        webView.loadFileURL(indexURL, allowingReadAccessTo: resourceDirectory)
    }

    private func handleBridgeMessage(_ body: Any) {
        guard
            let message = body as? [String: Any],
            let action = message["action"] as? String
        else { return }
        let args = message["args"] as? [Any] ?? []

        switch action {
        case "copyJson":
            copyText(args.first as? String ?? "", toast: "投递记录 JSON 已复制")
        case "copyTextSilent":
            UIPasteboard.general.string = args.first as? String ?? ""
        case "shareJson":
            shareJson(args.first as? String ?? "", filename: safeFilename(args.dropFirst().first as? String))
        case "saveJson":
            saveJson(args.first as? String ?? "", filename: safeFilename(args.dropFirst().first as? String))
        case "createCalendarEvent":
            createCalendarEvent(args: args)
        default:
            break
        }
    }

    private func copyText(_ text: String, toast: String) {
        UIPasteboard.general.string = text
        showToast(toast)
    }

    private func shareJson(_ json: String, filename: String) {
        guard let fileURL = writeTemporaryJSON(json, filename: filename) else {
            copyText(json, toast: "分享失败，已复制 JSON")
            return
        }
        let controller = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
        controller.popoverPresentationController?.sourceView = view
        controller.popoverPresentationController?.sourceRect = CGRect(
            x: view.bounds.midX,
            y: view.bounds.maxY - 80,
            width: 1,
            height: 1
        )
        present(controller, animated: true)
    }

    private func saveJson(_ json: String, filename: String) {
        guard let fileURL = writeTemporaryJSON(json, filename: filename) else {
            copyText(json, toast: "保存失败，已复制 JSON")
            return
        }
        let picker = UIDocumentPickerViewController(forExporting: [fileURL], asCopy: true)
        picker.shouldShowFileExtensions = true
        present(picker, animated: true)
    }

    private func writeTemporaryJSON(_ json: String, filename: String) -> URL? {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        do {
            try json.data(using: .utf8)?.write(to: url, options: .atomic)
            return url
        } catch {
            return nil
        }
    }

    private func safeFilename(_ raw: String?) -> String {
        let name = raw?.trimmingCharacters(in: .whitespacesAndNewlines)
        let fallback = "秋招投递记录.json"
        let chosen = name?.isEmpty == false ? name! : fallback
        let illegal = CharacterSet(charactersIn: "/\\:*?\"<>|")
        let cleaned = chosen
            .components(separatedBy: illegal)
            .joined(separator: "_")
        return cleaned.hasSuffix(".json") ? cleaned : "\(cleaned).json"
    }

    private func createCalendarEvent(args: [Any]) {
        let title = args[safe: 0] as? String ?? "秋招提醒"
        let notes = args[safe: 1] as? String ?? ""
        let location = args[safe: 2] as? String ?? ""
        let startMillis = Double(args[safe: 3] as? String ?? "") ?? 0
        let endMillis = Double(args[safe: 4] as? String ?? "") ?? 0
        guard startMillis > 0 else {
            showToast("日历时间无效")
            return
        }

        let startDate = Date(timeIntervalSince1970: startMillis / 1000)
        let endDate = endMillis > startMillis
            ? Date(timeIntervalSince1970: endMillis / 1000)
            : startDate.addingTimeInterval(30 * 60)

        requestCalendarAccess { [weak self] granted in
            guard let self else { return }
            guard granted else {
                self.showToast("没有日历写入权限")
                return
            }
            let event = EKEvent(eventStore: self.eventStore)
            event.title = title
            event.notes = notes
            event.location = location
            event.startDate = startDate
            event.endDate = endDate
            event.calendar = self.eventStore.defaultCalendarForNewEvents
            event.addAlarm(EKAlarm(relativeOffset: 0))

            let editor = EKEventEditViewController()
            editor.eventStore = self.eventStore
            editor.event = event
            editor.editViewDelegate = self
            self.present(editor, animated: true)
        }
    }

    private func requestCalendarAccess(_ completion: @escaping (Bool) -> Void) {
        if #available(iOS 17.0, *) {
            eventStore.requestWriteOnlyAccessToEvents { granted, _ in
                DispatchQueue.main.async { completion(granted) }
            }
        } else {
            eventStore.requestAccess(to: .event) { granted, _ in
                DispatchQueue.main.async { completion(granted) }
            }
        }
    }

    private func showToast(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            alert.dismiss(animated: true)
        }
    }

    private static let bridgeScript = """
    (function () {
      if (window.AndroidBridge && window.AndroidBridge.__iosProxy) return;
      function post(action, args) {
        try {
          window.webkit.messageHandlers.iosBridge.postMessage({
            action: action,
            args: Array.prototype.slice.call(args || [])
          });
        } catch (error) {}
      }
      window.AndroidBridge = {
        __iosProxy: true,
        exportJson: function () { post("copyJson", arguments); },
        copyJson: function () { post("copyJson", arguments); },
        copyTextSilent: function () { post("copyTextSilent", arguments); },
        shareJson: function () { post("shareJson", arguments); },
        saveJson: function () { post("saveJson", arguments); },
        createCalendarEvent: function () { post("createCalendarEvent", arguments); }
      };
    })();
    """
}

extension WebViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "iosBridge" {
            handleBridgeMessage(message.body)
        }
    }
}

extension WebViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }
        if url.isFileURL || navigationAction.navigationType == .other {
            decisionHandler(.allow)
            return
        }
        if ["http", "https", "mailto"].contains(url.scheme?.lowercased() ?? "") {
            UIApplication.shared.open(url)
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }
}

extension WebViewController: WKUIDelegate {
    func webView(
        _ webView: WKWebView,
        createWebViewWith configuration: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction,
        windowFeatures: WKWindowFeatures
    ) -> WKWebView? {
        if let url = navigationAction.request.url {
            UIApplication.shared.open(url)
        }
        return nil
    }
}

extension WebViewController: EKEventEditViewDelegate {
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        controller.dismiss(animated: true)
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
