import SwiftUI

struct JSONEscapeStudioView: View {
    @State private var inputText: String = #"""
import SwiftUI

struct JSONEscapeStudioView: View {
    @State private var outputText: String = ""
    @State private var isUnescapeMode = false
    @State private var showCopied = false
    @State private var showPasted = false
    @FocusState private var isEditorFocused: Bool
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 22) {
                
                // 🔘 Modus-Schalter + Einfügen-Button
                HStack(spacing: 12) {
                    Picker("Modus", selection: $isUnescapeMode) {
                        Text("Escape → JSON").tag(false)
                        Text("Unescape → Klartext").tag(true)
                    }
                    .pickerStyle(.segmented)
                    
                    Button {
                        pasteInput()
                    } label: {
                        Label("Einfügen", systemImage: "doc.on.clipboard.fill")
                            .font(.caption.bold())
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.15))
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)
                .onChange(of: isUnescapeMode) { _, newValue in
                    withAnimation(.easeInOut(duration: 0.25)) {
                        outputText = newValue
                            ? unescapeFromJSON(inputText)
                            : escapeForJSON(inputText)
                    }
                }
                
                // 🟢 Eingabe
                VStack(alignment: .leading, spacing: 8) {
                    Label(isUnescapeMode ? "Escaped JSON eingeben" : "Original-Code", systemImage: "doc.text.fill")
                        .font(.headline)
                        .foregroundStyle(.blue)
                    
                    ZStack(alignment: .topLeading) {
                        if inputText.isEmpty {
                            Text("Hier Code einfügen oder schreiben …")
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .font(.system(.body, design: .monospaced))
                        }
                        
                        TextEditor(text: $inputText)
                            .focused($isEditorFocused)
                            .font(.system(.body, design: .monospaced))
                            .padding(10)
                            .scrollContentBackground(.hidden)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.gray.opacity(0.15))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(isEditorFocused ? Color.blue : Color.blue.opacity(0.3),
                                                    lineWidth: isEditorFocused ? 1.8 : 1.2)
                                    )
                            )
                            .frame(minHeight: 180)
                            .onChange(of: inputText) { _, newValue in
                                outputText = isUnescapeMode
                                    ? unescapeFromJSON(newValue)
                                    : escapeForJSON(newValue)
                            }
                            .onTapGesture { isEditorFocused = true }
                    }
                }
                .animation(.easeInOut(duration: 0.25), value: isEditorFocused)
                
                // 🔵 Ausgabe
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Label(isUnescapeMode ? "Klartext" : "Escaped JSON",
                              systemImage: "chevron.left.forwardslash.chevron.right")
                            .font(.headline)
                            .foregroundStyle(.orange)
                        
                        Spacer()
                        
                        Button(action: copyOutput) {
                            Label("Kopieren", systemImage: "doc.on.doc.fill")
                                .font(.caption.bold())
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color.orange.opacity(0.15))
                                .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                    }
                    
                    ScrollView {
                        Text(outputText.isEmpty ? "// Ausgabe erscheint hier …" : outputText)
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.white)
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                LinearGradient(
                                    colors: [Color.black, Color(hex: "#1C1C1E")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.4), radius: 6, y: 3)
                    }
                    .frame(minHeight: 200)
                    .overlay(alignment: .topTrailing) {
                        VStack(alignment: .trailing, spacing: 4) {
                            if showCopied {
                                Label("Kopiert!", systemImage: "checkmark.circle.fill")
                                    .transition(.scale.combined(with: .opacity))
                            }
                            if showPasted {
                                Label("Eingefügt!", systemImage: "arrow.down.doc.fill")
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .font(.caption.bold())
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.orange)
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .padding()
                        .shadow(radius: 4)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("JSON Escape Studio")
            .navigationBarTitleDisplayMode(.inline)
            
            // ✅ Ausgabe beim Start sofort vorbereiten
            .onAppear {
                outputText = escapeForJSON(inputText)
                
                // Fokus leicht verzögert aktivieren
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    isEditorFocused = true
                }
            }
        }
    }
    
    // MARK: - Aktionen
    private func copyOutput() {
        UIPasteboard.general.string = outputText
        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
            showCopied = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
            withAnimation(.easeOut(duration: 0.35)) {
                showCopied = false
            }
        }
    }
    
    private func pasteInput() {
        if let clipboard = UIPasteboard.general.string, !clipboard.isEmpty {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                inputText = clipboard
                showPasted = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                withAnimation(.easeOut(duration: 0.35)) {
                    showPasted = false
                }
            }
        }
    }
}

// MARK: - Escape / Unescape Helpers
func escapeForJSON(_ text: String) -> String {
    text
        .replacingOccurrences(of: "\\", with: "\\\\")
        .replacingOccurrences(of: "\"", with: "\\\"")
        .replacingOccurrences(of: "\n", with: "\\n")
        .replacingOccurrences(of: "\t", with: "\\t")
        .replacingOccurrences(of: "\r", with: "")
}

func unescapeFromJSON(_ text: String) -> String {
    text
        .replacingOccurrences(of: "\\n", with: "\n")
        .replacingOccurrences(of: "\\t", with: "\t")
        .replacingOccurrences(of: "\\\"", with: "\"")
        .replacingOccurrences(of: "\\\\", with: "\\")
}

// MARK: - Preview
#Preview {
    JSONEscapeStudioView()
        .preferredColorScheme(.dark)
}
"""#
    

    
    @State private var outputText: String = ""
    @State private var isUnescapeMode = false
    @State private var showCopied = false
    @State private var showPasted = false
    @FocusState private var isEditorFocused: Bool
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 22) {
                
                // 🔘 Modus-Schalter + Einfügen-Button
                HStack(spacing: 12) {
                    Picker("Modus", selection: $isUnescapeMode) {
                        Text("Escape → JSON").tag(false)
                        Text("Unescape → Klartext").tag(true)
                    }
                    .pickerStyle(.segmented)
                    
                    Button {
                        pasteInput()
                    } label: {
                        Label("Einfügen", systemImage: "doc.on.clipboard.fill")
                            .font(.caption.bold())
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.15))
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)
                .onChange(of: isUnescapeMode) { _, newValue in
                    withAnimation(.easeInOut(duration: 0.25)) {
                        outputText = newValue
                            ? unescapeFromJSON(inputText)
                            : escapeForJSON(inputText)
                    }
                }
                
                // 🟢 Eingabe
                VStack(alignment: .leading, spacing: 8) {
                    Label(isUnescapeMode ? "Escaped JSON eingeben" : "Original-Code", systemImage: "doc.text.fill")
                        .font(.headline)
                        .foregroundStyle(.blue)
                    
                    ZStack(alignment: .topLeading) {
                        if inputText.isEmpty {
                            Text("Hier Code einfügen oder schreiben …")
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .font(.system(.body, design: .monospaced))
                        }
                        
                        TextEditor(text: $inputText)
                            .focused($isEditorFocused)
                            .font(.system(.body, design: .monospaced))
                            .padding(10)
                            .scrollContentBackground(.hidden)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.gray.opacity(0.15))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(isEditorFocused ? Color.blue : Color.blue.opacity(0.3),
                                                    lineWidth: isEditorFocused ? 1.8 : 1.2)
                                    )
                            )
                            .frame(minHeight: 180)
                            .onChange(of: inputText) { _, newValue in
                                outputText = isUnescapeMode
                                    ? unescapeFromJSON(newValue)
                                    : escapeForJSON(newValue)
                            }
                            .onTapGesture { isEditorFocused = true }
                    }
                }
                .animation(.easeInOut(duration: 0.25), value: isEditorFocused)
                
                // 🔵 Ausgabe
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Label(isUnescapeMode ? "Klartext" : "Escaped JSON",
                              systemImage: "chevron.left.forwardslash.chevron.right")
                            .font(.headline)
                            .foregroundStyle(.orange)
                        
                        Spacer()
                        
                        Button(action: copyOutput) {
                            Label("Kopieren", systemImage: "doc.on.doc.fill")
                                .font(.caption.bold())
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color.orange.opacity(0.15))
                                .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                    }
                    
                    ScrollView {
                        Text(outputText.isEmpty ? "// Ausgabe erscheint hier …" : outputText)
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.white)
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                LinearGradient(
                                    colors: [Color.black, Color(hex: "#1C1C1E")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.4), radius: 6, y: 3)
                    }
                    .frame(minHeight: 200)
                    .overlay(alignment: .topTrailing) {
                        VStack(alignment: .trailing, spacing: 4) {
                            if showCopied {
                                Label("Kopiert!", systemImage: "checkmark.circle.fill")
                                    .transition(.scale.combined(with: .opacity))
                            }
                            if showPasted {
                                Label("Eingefügt!", systemImage: "arrow.down.doc.fill")
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .font(.caption.bold())
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.orange)
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .padding()
                        .shadow(radius: 4)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("JSON Escape Studio")
            .navigationBarTitleDisplayMode(.inline)
            
            // ✅ Ausgabe beim Start sofort vorbereiten
            .onAppear {
                outputText = escapeForJSON(inputText)
                
                // Fokus leicht verzögert aktivieren
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    isEditorFocused = true
                }
            }
        }
    }
    
    // MARK: - Aktionen
    private func copyOutput() {
        UIPasteboard.general.string = outputText
        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
            showCopied = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
            withAnimation(.easeOut(duration: 0.35)) {
                showCopied = false
            }
        }
    }
    
    private func pasteInput() {
        if let clipboard = UIPasteboard.general.string, !clipboard.isEmpty {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                inputText = clipboard
                showPasted = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                withAnimation(.easeOut(duration: 0.35)) {
                    showPasted = false
                }
            }
        }
    }
}

// MARK: - Escape / Unescape Helpers
func escapeForJSON(_ text: String) -> String {
    text
        .replacingOccurrences(of: "\\", with: "\\\\")
        .replacingOccurrences(of: "\"", with: "\\\"")
        .replacingOccurrences(of: "\n", with: "\\n")
        .replacingOccurrences(of: "\t", with: "\\t")
        .replacingOccurrences(of: "\r", with: "")
}

func unescapeFromJSON(_ text: String) -> String {
    text
        .replacingOccurrences(of: "\\n", with: "\n")
        .replacingOccurrences(of: "\\t", with: "\t")
        .replacingOccurrences(of: "\\\"", with: "\"")
        .replacingOccurrences(of: "\\\\", with: "\\")
}

// MARK: - Preview
#Preview {
    JSONEscapeStudioView()
        .preferredColorScheme(.dark)
}
