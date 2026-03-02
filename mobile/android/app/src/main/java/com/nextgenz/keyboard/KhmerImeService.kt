package com.nextgenz.keyboard

import android.inputmethodservice.InputMethodService
import android.inputmethodservice.Keyboard
import android.inputmethodservice.KeyboardView
import android.view.KeyEvent
import android.view.View
import android.view.inputmethod.EditorInfo
import android.widget.Button
import android.widget.LinearLayout

class KhmerImeService : InputMethodService(), KeyboardView.OnKeyboardActionListener {
    private lateinit var keyboardView: KeyboardView
    private lateinit var keyboard: Keyboard
    private lateinit var suggestionRow: LinearLayout
    private lateinit var engine: PredictionEngine

    private val composing = StringBuilder()
    private val acceptedWords = ArrayDeque<String>()

    override fun onCreate() {
        super.onCreate()
        engine = PredictionEngine(this)
    }

    override fun onCreateInputView(): View {
        val view = layoutInflater.inflate(R.layout.ime_view, null)
        keyboardView = view.findViewById(R.id.keyboardView)
        suggestionRow = view.findViewById(R.id.suggestionRow)

        keyboard = Keyboard(this, R.xml.qwerty)
        keyboardView.keyboard = keyboard
        keyboardView.setOnKeyboardActionListener(this)
        return view
    }

    override fun onStartInput(attribute: EditorInfo?, restarting: Boolean) {
        super.onStartInput(attribute, restarting)
        composing.clear()
        acceptedWords.clear()
        renderSuggestions(emptyList())
    }

    override fun onKey(primaryCode: Int, keyCodes: IntArray?) {
        val ic = currentInputConnection ?: return

        when (primaryCode) {
            Keyboard.KEYCODE_DELETE -> {
                if (composing.isNotEmpty()) {
                    composing.deleteCharAt(composing.length - 1)
                    ic.deleteSurroundingText(1, 0)
                } else {
                    ic.deleteSurroundingText(1, 0)
                }
            }
            Keyboard.KEYCODE_DONE -> {
                commitCurrentWord()
                ic.sendKeyEvent(KeyEvent(KeyEvent.ACTION_DOWN, KeyEvent.KEYCODE_ENTER))
            }
            32 -> {
                commitCurrentWord()
                ic.commitText(" ", 1)
                updateSuggestions("")
                return
            }
            else -> {
                val codePoint = primaryCode.toChar().toString()
                if (!isKhmerWord(codePoint)) return
                composing.append(codePoint)
                ic.commitText(codePoint, 1)
            }
        }

        updateSuggestions(currentToken())
    }

    private fun commitCurrentWord() {
        val word = currentToken()
        if (word.isNotBlank()) {
            acceptedWords.addLast(word)
            if (acceptedWords.size > 2) {
                acceptedWords.removeFirst()
            }
        }
        composing.clear()
    }

    private fun currentToken(): String {
        return composing.toString().trim()
    }

    private fun updateSuggestions(token: String) {
        val suggestions = when {
            token.isNotBlank() -> engine.suggestPrefix(token, 5)
            acceptedWords.size >= 2 -> {
                val w1 = acceptedWords.elementAt(acceptedWords.size - 2)
                val w2 = acceptedWords.elementAt(acceptedWords.size - 1)
                engine.predictNext(w1, w2, 5)
            }
            else -> emptyList()
        }
        renderSuggestions(suggestions)
    }

    private fun renderSuggestions(items: List<String>) {
        suggestionRow.removeAllViews()
        items.take(3).forEach { text ->
            val btn = Button(this).apply {
                this.text = text
                textSize = 14f
                isAllCaps = false
                setOnClickListener { acceptSuggestion(text) }
            }
            suggestionRow.addView(btn)
        }
    }

    private fun acceptSuggestion(word: String) {
        val ic = currentInputConnection ?: return
        val token = currentToken()
        if (token.isNotBlank()) {
            repeat(token.length) { ic.deleteSurroundingText(1, 0) }
        }
        composing.clear()
        if (!isKhmerWord(word)) return
        ic.commitText(word, 1)
        acceptedWords.addLast(word)
        if (acceptedWords.size > 2) {
            acceptedWords.removeFirst()
        }
        updateSuggestions("")
    }

    private fun isKhmerWord(text: String): Boolean {
        if (text.isBlank()) return false
        var hasKhmer = false
        for (ch in text) {
            if (ch.isWhitespace()) continue
            val isKhmer = (ch.code in 0x1780..0x17FF) || (ch.code in 0x19E0..0x19FF)
            if (!isKhmer) return false
            hasKhmer = true
        }
        return hasKhmer
    }

    override fun onPress(primaryCode: Int) {}
    override fun onRelease(primaryCode: Int) {}
    override fun onText(text: CharSequence?) {}
    override fun swipeLeft() {}
    override fun swipeRight() {}
    override fun swipeDown() {}
    override fun swipeUp() {}
}
