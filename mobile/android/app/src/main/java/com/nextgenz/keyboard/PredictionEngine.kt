package com.nextgenz.keyboard

import android.content.Context

class PredictionEngine(context: Context) {
    private val prefixMap = HashMap<String, List<String>>()
    private val nextMap = HashMap<String, List<String>>()

    init {
        loadPrefix(context)
        loadNext(context)
    }

    fun suggestPrefix(prefix: String, topN: Int = 5): List<String> {
        if (prefix.isBlank() || !isKhmerWord(prefix)) return emptyList()
        return prefixMap[prefix]?.take(topN) ?: emptyList()
    }

    fun predictNext(w1: String, w2: String, topN: Int = 5): List<String> {
        if (w1.isBlank() || w2.isBlank()) return emptyList()
        if (!isKhmerWord(w1) || !isKhmerWord(w2)) return emptyList()
        val key = "$w1\t$w2"
        return nextMap[key]?.take(topN) ?: emptyList()
    }

    private fun loadPrefix(context: Context) {
        context.assets.open("model/prefix.tsv").bufferedReader(Charsets.UTF_8).useLines { lines ->
            lines.forEach { line ->
                val firstTab = line.indexOf('\t')
                if (firstTab <= 0) return@forEach
                val key = line.substring(0, firstTab)
                val values = line.substring(firstTab + 1).split('|').filter { it.isNotBlank() }
                if (isKhmerWord(key) && values.isNotEmpty()) {
                    val khmerValues = values.filter { isKhmerWord(it) }
                    if (khmerValues.isEmpty()) return@forEach
                    prefixMap[key] = khmerValues
                }
            }
        }
    }

    private fun loadNext(context: Context) {
        context.assets.open("model/next.tsv").bufferedReader(Charsets.UTF_8).useLines { lines ->
            lines.forEach { line ->
                val parts = line.split('\t')
                if (parts.size < 3) return@forEach
                val key = "${parts[0]}\t${parts[1]}"
                val values = parts[2].split('|').filter { it.isNotBlank() }
                if (isKhmerWord(parts[0]) && isKhmerWord(parts[1]) && values.isNotEmpty()) {
                    val khmerValues = values.filter { isKhmerWord(it) }
                    if (khmerValues.isEmpty()) return@forEach
                    nextMap[key] = khmerValues
                }
            }
        }
    }

    private fun isKhmerWord(text: String): Boolean {
        if (text.isBlank()) return false
        var hasKhmer = false
        for (ch in text) {
            if (ch.isWhitespace() || ch == '\'' || ch == '’' || ch == '-' || ch == '_') {
                continue
            }
            val isKhmer = (ch.code in 0x1780..0x17FF) || (ch.code in 0x19E0..0x19FF)
            if (!isKhmer) return false
            hasKhmer = true
        }
        return hasKhmer
    }
}
