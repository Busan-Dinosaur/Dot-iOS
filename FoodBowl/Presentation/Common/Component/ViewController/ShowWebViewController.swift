//
//  ShowWebViewController.swift
//  FoodBowl
//
//  Created by COBY_PRO on 2023/01/15.
//

import UIKit

import SnapKit
import Then
@preconcurrency import WebKit

final class ShowWebViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {
    
    // MARK: - ui component
    
    lazy var webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration()).then {
        $0.navigationDelegate = self
        $0.uiDelegate = self
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    // MARK: - property
    
    private let url: String
    
    // MARK: - init
    
    init(url: String) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("\(#file) is dead")
    }
    
    // MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        setupNavigationBar()
    }
    
    private func setupLayout() {
        view.addSubviews(webView)

        webView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        DispatchQueue.main.async {
            if let url = URL(string: self.url) { self.webView.load(URLRequest(url: url)) }
        }
    }

    private func setupNavigationBar() {
        navigationController?.navigationBar.isHidden = true
    }

    func webView(
        _: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let url = navigationAction.request.url, url.scheme != "http" && url.scheme != "https" {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
}
