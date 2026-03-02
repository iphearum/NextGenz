import UIKit

final class KeyboardViewController: UIInputViewController {
    private let engine = PredictionEngine()
    private var composing = ""
    private var acceptedWords: [String] = []

    private let suggestionStack = UIStackView()
    private let keyboardStack = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        engine.loadModel()
        updateSuggestions()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground

        suggestionStack.axis = .horizontal
        suggestionStack.spacing = 6
        suggestionStack.distribution = .fillEqually

        keyboardStack.axis = .vertical
        keyboardStack.spacing = 6

        let root = UIStackView(arrangedSubviews: [suggestionStack, keyboardStack])
        root.axis = .vertical
        root.spacing = 8
        root.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(root)

        NSLayoutConstraint.activate([
            root.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            root.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            root.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            root.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8)
        ])

        let rows = [
            ["ក","ខ","គ","ឃ","ង","ច","ឆ","ជ","ញ","ដ"],
            ["ត","ថ","ទ","ធ","ន","ប","ផ","ព","ភ"],
            ["ម","យ","រ","ល","វ","ស","ហ","⌫"],
            ["space","enter"]
        ]
        for row in rows {
            keyboardStack.addArrangedSubview(makeRow(row))
        }
    }

    private func makeRow(_ keys: [String]) -> UIStackView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 6
        row.distribution = .fillEqually
        for key in keys {
            let button = UIButton(type: .system)
            button.setTitle(key, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 18)
            button.backgroundColor = UIColor.systemGray6
            button.layer.cornerRadius = 8
            button.addTarget(self, action: #selector(handleKey(_:)), for: .touchUpInside)
            row.addArrangedSubview(button)
        }
        return row
    }

    @objc private func handleKey(_ sender: UIButton) {
        guard let key = sender.currentTitle else { return }
        let proxy = textDocumentProxy

        switch key {
        case "⌫":
            proxy.deleteBackward()
            if !composing.isEmpty { composing.removeLast() }
        case "space":
            commitCurrentWord()
            proxy.insertText(" ")
        case "enter":
            commitCurrentWord()
            proxy.insertText("\n")
        default:
            guard PredictionEngine.isKhmerWord(key) else { return }
            composing += key
            proxy.insertText(key)
        }
        updateSuggestions()
    }

    private func commitCurrentWord() {
        let token = composing.trimmingCharacters(in: .whitespacesAndNewlines)
        if !token.isEmpty {
            acceptedWords.append(token)
            if acceptedWords.count > 2 { acceptedWords.removeFirst() }
        }
        composing = ""
    }

    private func updateSuggestions() {
        let items: [String]
        if !composing.isEmpty {
            items = engine.suggestPrefix(composing, topN: 3)
        } else if acceptedWords.count >= 2 {
            items = engine.predictNext(acceptedWords[acceptedWords.count - 2], acceptedWords[acceptedWords.count - 1], topN: 3)
        } else {
            items = []
        }
        renderSuggestionButtons(items)
    }

    private func renderSuggestionButtons(_ words: [String]) {
        suggestionStack.arrangedSubviews.forEach { v in
            suggestionStack.removeArrangedSubview(v)
            v.removeFromSuperview()
        }
        for word in words {
            let b = UIButton(type: .system)
            b.setTitle(word, for: .normal)
            b.titleLabel?.font = .systemFont(ofSize: 15)
            b.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.12)
            b.layer.cornerRadius = 8
            b.addAction(UIAction { [weak self] _ in
                self?.acceptSuggestion(word)
            }, for: .touchUpInside)
            suggestionStack.addArrangedSubview(b)
        }
    }

    private func acceptSuggestion(_ word: String) {
        guard PredictionEngine.isKhmerWord(word) else { return }
        let proxy = textDocumentProxy
        for _ in composing { proxy.deleteBackward() }
        composing = ""
        proxy.insertText(word)
        acceptedWords.append(word)
        if acceptedWords.count > 2 { acceptedWords.removeFirst() }
        updateSuggestions()
    }
}

