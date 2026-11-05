import SwiftUI
import UniformTypeIdentifiers
import PhotosUI
import AVFoundation
import MagiCore

struct ChatView: View {
    let sessionID: String
    @Environment(AppStore.self) private var store
    @State private var importing = false
    @State private var pickingPhotos = false
    @State private var photos: [PhotosPickerItem] = []
    @State private var takingPhoto = false
    @State private var cameraDenied = false
    @Environment(\.openURL) private var openURL
    @FocusState private var focused: Bool
    var body: some View {
        @Bindable var store = store
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 18) {
                    ConnectionStatus().frame(maxWidth: .infinity)
                    if store.historyBefore != nil {
                        Button("chat.older") { Task { await store.loadOlder() } }
                            .disabled(store.isLoadingHistory).frame(maxWidth: .infinity)
                    }
                    if store.messages.isEmpty && store.outgoing.allSatisfy({ $0.request.session_id != sessionID }) {
                        VStack(spacing: 18) {
                            MagiMark(size: 48)
                            Text("chat.start").font(.title3.weight(.medium))
                        }.frame(maxWidth: .infinity).padding(.vertical, 72)
                    }
                    TimelineView(.periodic(from: .now, by: 1)) { timeline in
                        ForEach(Array(store.messages.enumerated()), id: \.offset) { _, message in
                            if message.kind != "status", !["assistant_thinking", "assistant_reasoning"].contains(message.message_kind ?? ""), message.message_kind != "assistant_rhythm_segment" || message.timestamp <= Int64(timeline.date.timeIntervalSince1970 * 1000) {
                                MessageView(message: message, sessionID: sessionID)
                            }
                        }
                    }
                    ForEach(store.outgoing.filter { $0.request.session_id == sessionID }) { pending in PendingTurnView(pending: pending) }
                    if !store.previewText.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(store.previewText).textSelection(.enabled)
                        }.padding(.vertical, 10).padding(.horizontal, 4)
                            .accessibilityIdentifier("chat.preview")
                    }
                    ForEach(store.interactions) { interaction in InteractionView(interaction: interaction) }
                    if let turn = store.turn, !turn.response_complete, turn.acceptance != "absent" {
                        HStack(spacing: 10) {
                            if !turn.terminal { WorkingIndicator() }
                            else if turn.state == "failed" { Text("chat.failed").font(.footnote).foregroundStyle(.secondary) }
                            else if turn.state == "cancelled" { Text("chat.stopped").font(.footnote).foregroundStyle(.secondary) }
                            Spacer()
                            if !turn.terminal {
                                Button("chat.stop") { Task { await store.stopTurn() } }.font(.caption)
                                    .disabled(store.phase != .online)
                            }
                        }.padding(.horizontal, 8)
                    }
                    Color.clear.frame(height: 1).id("bottom")
                }.padding(16)
            }
            .background(Color.canvas)
            .scrollDismissesKeyboard(.interactively)
            .defaultScrollAnchor(.bottom)
            .safeAreaInset(edge: .bottom, spacing: 0) { composer }
            .onChange(of: store.messages.count) { before, after in
                if after > before && !store.isLoadingHistory { withAnimation { proxy.scrollTo("bottom", anchor: .bottom) } }
            }
            .onChange(of: store.outgoing.count) { _, _ in withAnimation { proxy.scrollTo("bottom", anchor: .bottom) } }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .task(id: sessionID) { if store.selectedSessionID != sessionID { await store.select(sessionID) } }
        .photosPicker(isPresented: $pickingPhotos, selection: $photos, maxSelectionCount: max(1, 8 - store.attachments.count), matching: .images)
        .task(id: photos) {
            guard !photos.isEmpty else { return }
            let selected = photos, owner = store.selectedSessionID
            store.isPreparingImages = true
            defer { store.isPreparingImages = false }
            do {
                var data: [Data] = []
                for photo in selected {
                    guard let bytes = try await photo.loadTransferable(type: Data.self) else { throw ClientError.invalidResponse }
                    try Task.checkCancellation()
                    data.append(bytes)
                }
                await store.addImages(data, sessionID: owner)
            } catch { store.report(error) }
            photos = []
        }
        .fullScreenCover(isPresented: $takingPhoto) {
            CameraCapture { bytes in
                Task {
                    store.isPreparingImages = true
                    defer { store.isPreparingImages = false }
                    await store.addImages([bytes], sessionID: sessionID)
                }
            }.ignoresSafeArea()
        }
        .alert("attachment.camera.denied", isPresented: $cameraDenied) {
            Button("action.settings") { if let url = URL(string: UIApplication.openSettingsURLString) { openURL(url) } }
            Button("action.cancel", role: .cancel) {}
        }
        .fileImporter(isPresented: $importing, allowedContentTypes: [.item], allowsMultipleSelection: true) { result in
            switch result {
            case .success(let urls): Task { await store.addFiles(urls) }
            case .failure(let error): store.report(error)
            }
        }
    }
    private var composer: some View {
        @Bindable var store = store
        return VStack(alignment: .leading, spacing: 8) {
            if !store.attachments.isEmpty {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(store.attachments) { file in
                            if file.mimeType.hasPrefix("image/") {
                                DraftImage(file: file) { store.attachments.removeAll { $0.id == file.id } }
                            } else {
                            HStack(spacing: 8) {
                                Image(systemName: "doc")
                                Text(file.filename).lineLimit(1)
                                Button { store.attachments.removeAll { $0.id == file.id } } label: { Image(systemName: "xmark.circle.fill") }
                                    .accessibilityLabel(Text("attachment.remove"))
                            }.font(.caption).padding(8).background(.quaternary, in: Capsule())
                            }
                        }
                    }
                }.scrollIndicators(.hidden)
            }
            if store.isPreparingImages { ProgressView().accessibilityLabel(Text("attachment.loading")) }
            HStack(alignment: .bottom, spacing: 10) {
                Menu {
                    Button("attachment.photos", systemImage: "photo.on.rectangle") { pickingPhotos = true }
                    Button("attachment.camera", systemImage: "camera") {
                        Task {
                            if await AVCaptureDevice.requestAccess(for: .video) { takingPhoto = true }
                            else { cameraDenied = true }
                        }
                    }.disabled(!UIImagePickerController.isSourceTypeAvailable(.camera))
                    Button("attachment.files", systemImage: "folder") { importing = true }
                } label: { Image(systemName: "plus").font(.title3).frame(width: 32, height: 44) }
                    .accessibilityLabel(Text("attachment.add")).accessibilityIdentifier("chat.attach").disabled(store.isSending || store.isPreparingImages || store.attachments.count >= 8 || store.phase != .online)
                TextField("chat.placeholder", text: $store.draft, axis: .vertical)
                    .lineLimit(1...6).padding(.vertical, 11).focused($focused)
                    .accessibilityIdentifier("chat.composer").disabled(store.isSending)
                Button { focused = false; Task { await store.send() } } label: {
                    Group { if store.isSending { ProgressView().tint(.white) } else { Image(systemName: "arrow.up").font(.headline) } }
                        .frame(width: 38, height: 38).background(store.canSend ? Color.magi : Color.gray, in: Circle()).foregroundStyle(Color.canvas)
                }.disabled(!store.canSend).padding(.bottom, 3)
                    .accessibilityLabel(Text("chat.send")).accessibilityIdentifier("chat.send")
            }
        }.padding(.horizontal, 16).padding(.vertical, 8).background(.bar)
    }
}

struct MessageView: View {
    let message: Wire.ChatDisplayMessage
    let sessionID: String
    private var isUser: Bool { message.role == "user" }
    var body: some View {
        HStack {
            if isUser { Spacer(minLength: 32) }
            VStack(alignment: .leading, spacing: 8) {
                if !message.content.isEmpty { Text(message.content).textSelection(.enabled) }
                ForEach(Array((message.attachments ?? []).enumerated()), id: \.offset) { _, attachment in
                    if attachment["kind"]?.string == "image", let id = attachment["attachment_id"]?.string {
                        ChatImage(sessionID: sessionID, attachmentID: id)
                    } else {
                        Label(attachment["original_name"]?.string ?? L("attachment.file"), systemImage: "paperclip").font(.caption)
                    }
                }
            }
            .padding(isUser ? 14 : 4)
            .background(isUser ? Color.magi.opacity(0.07) : Color.clear, in: RoundedRectangle(cornerRadius: 20))
            .accessibilityElement(children: .contain)
            if !isUser { Spacer(minLength: 20) }
        }
    }
}

struct PendingTurnView: View {
    let pending: OutgoingTurn
    @Environment(AppStore.self) private var store
    @State private var confirmDiscard = false
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(pending.confirmed ? "outgoing.confirmed" : "outgoing.pending", systemImage: pending.confirmed ? "checkmark.circle" : "clock")
                .font(.caption.bold()).foregroundStyle(.secondary)
            if let text = pending.request.message, !text.isEmpty { Text(text).textSelection(.enabled) }
            if !(pending.request.attachments ?? []).isEmpty { Label("attachment.file", systemImage: "paperclip").font(.caption) }
            if pending.dataEpoch != store.dataEpoch { Text("outgoing.expired").font(.caption).foregroundStyle(.orange) }
            HStack {
                Button("outgoing.verify") { Task { await store.retry(pending) } }
                    .disabled(store.phase != .online || store.isSending || pending.dataEpoch != store.dataEpoch)
                Spacer()
                Button("outgoing.discard", role: .destructive) { confirmDiscard = true }
            }.font(.caption).buttonStyle(.borderless)
        }
        .padding(14).background(Color.orange.opacity(0.08), in: RoundedRectangle(cornerRadius: 16))
        .confirmationDialog("outgoing.discard.confirm", isPresented: $confirmDiscard, titleVisibility: .visible) {
            Button("outgoing.discard", role: .destructive) { Task { await store.discard(pending) } }
        } message: { Text("outgoing.discard.help") }
    }
}

struct InteractionView: View {
    let interaction: Interaction
    @Environment(AppStore.self) private var store
    @State private var answer = ""
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(interaction.kind == "ask" ? "interaction.question" : "permission.title", systemImage: interaction.kind == "ask" ? "questionmark.bubble" : "hand.raised")
                .font(.caption.bold()).foregroundStyle(Color.magi)
            Text(interaction.title).font(.headline).textSelection(.enabled)
            if !interaction.detail.isEmpty { Text(interaction.detail).font(.footnote.monospaced()).textSelection(.enabled) }
            if interaction.kind == "ask" {
                ForEach(interaction.options, id: \.self) { option in
                    Button(option) { respond(option) }.buttonStyle(.bordered)
                }
                if interaction.allowsText {
                    TextField("interaction.answer", text: $answer, axis: .vertical).textFieldStyle(.roundedBorder)
                    Button("interaction.submit") { respond(answer) }.disabled(answer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            } else {
                Text("permission.help").font(.caption).foregroundStyle(.secondary)
                HStack {
                    Button("permission.deny", role: .destructive) { respond("deny") }.buttonStyle(.bordered)
                    Spacer()
                    Button("permission.allow") { respond("allow") }.buttonStyle(.borderedProminent)
                }
            }
        }.padding(16).background(Color.magi.opacity(0.07), in: RoundedRectangle(cornerRadius: 20))
            .disabled(store.phase != .online || store.isSending)
    }
    private func respond(_ value: String) { Task { await store.respond(interaction, answer: value) } }
}

struct WorkingIndicator: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    var body: some View {
        TimelineView(.animation(minimumInterval: 0.05, paused: reduceMotion)) { context in
            let phase = context.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 1.8) / 1.8
            Capsule().fill(Color.magi.opacity(0.08)).frame(width: 112, height: 3)
                .overlay(alignment: .leading) {
                    Capsule().fill(Color.magi.opacity(0.5)).frame(width: 38, height: 3)
                        .offset(x: reduceMotion ? 37 : 74 * (1 - cos(phase * .pi * 2)) / 2)
                }
        }.frame(height: 26).accessibilityLabel(Text("chat.working"))
    }
}
