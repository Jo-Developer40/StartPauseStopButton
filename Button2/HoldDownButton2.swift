//
//  HoldDownButton2.swift
//  Button2
//
//  Created by Juergen Schulz on 26.10.25.
//

import SwiftUI
import Combine

public enum ButtonStatus2: String {
    case start = "Start"
    case pause = "Pause"
    case stop = "Stop"
    
    public var isActive: Bool {
        switch self {
        case .start, .pause:
            return true
        case .stop:
            return false
        }
    }
    public var currentBackground: Color {
            switch self {
            case .start:
                return .green
            case .pause:
                return .yellow
            case .stop:
                return .red
            }
        }
}

class HoldTimer: ObservableObject {
    @Published private(set) var progress: CGFloat = 0
    @Published private(set) var isActive = false

    private var timer: AnyCancellable?
    private var duration: CGFloat = 2
    private var elapsed: CGFloat = 0

    func start(duration: CGFloat) {
        self.duration = duration
        self.elapsed = 0
        self.progress = 0
        self.isActive = true
        timer?.cancel()
        timer = Timer.publish(every: 0.01, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, self.isActive else { return }
                self.elapsed += 0.01
                self.progress = min(self.elapsed / self.duration, 1)
                if self.progress >= 1 {
                    self.stop()
                }
            }
    }

    func stop() {
        isActive = false
        timer?.cancel()
        timer = nil
    }

    func reset() {
        stop()
        progress = 0
        elapsed = 0
    }
}

// Swift
/// Ein Button mit Start/Pause/Stop-Status und Ladebalken.
/// Kurzes Tippen startet/pausiert, langes Drücken stoppt und löst eine Aktion aus.
struct HoldDownButton2: View {
    var text: String /// Button-Text
    var duration: CGFloat = 2 /// Dauer für den Fortschritt (LongPress)
    var paddingVertical: CGFloat = 12 /// Vertikales Padding des Buttons
    var paddingHorizontal: CGFloat = 25 /// Horizontales Padding des Buttons
    var scale: CGFloat = 0.95 /// Skalierung beim Halten
    var background: Color = .gray /// Hintergrundfarbe des Buttons
    var loadingTint: Color = .blue /// Farbe des Ladebalkens
    var action: () -> Void = {} /// Aktion, die beim erfolgreichen LongPress ausgeführt wird

    @StateObject private var holdTimer = HoldTimer() /// Timer für den Ladebalken
    @State private var isHolding = false /// Button wird gehalten (für Animation)
    @State private var buttonStatus: ButtonStatus2 = .stop /// Status des Buttons (Start/Pause/Stop)

    var body: some View {
        VStack {
            // Button mit Statusanzeige und Ladebalken
            Text("\(buttonStatus.rawValue)")
                .padding(.vertical, paddingVertical)
                .padding(.horizontal, paddingHorizontal)
                .background {
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(buttonStatus.currentBackground)
                        GeometryReader { proxy in
                            let size = proxy.size
                            if buttonStatus == .start {
                                Rectangle()
                                    .fill(loadingTint)
                                    .frame(width: size.width * holdTimer.progress)
                                    .animation(.linear(duration: 0.1), value: holdTimer.progress)
                                    .transition(.opacity)
                            }
                        }
                    }
                }
                .clipShape(Capsule())
                .contentShape(Capsule())
                .scaleEffect(isHolding ? scale : 1)
                .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isHolding)
                .gesture(tapGesture.simultaneously(with: longPressGesture))
                // Accessibility für VoiceOver
                .accessibilityLabel(Text(text))
                .accessibilityValue(Text("Fortschritt \(Int(holdTimer.progress * 100)) Prozent"))
                .accessibilityAddTraits(.isButton)
                .accessibilityAction(named: Text("Gedrückt halten für Aktion")) {
                    startHold()
                }
            // Statusanzeige unterhalb des Buttons
            Text("Status: \(buttonStatus.rawValue)")
                .font(.headline)
                .foregroundStyle(.red)
                .background(.white)
                .padding(.top, 8)
        }
        // Initialisierung beim Anzeigen
        .onAppear {
            holdTimer.reset()
            buttonStatus = .stop
        }
    }

    /// Tap-Geste: Start/Pause umschalten
    var tapGesture: some Gesture {
        TapGesture()
            .onEnded {
                if buttonStatus == .start {
                    buttonStatus = .pause
                    holdTimer.stop()
                } else {
                    buttonStatus = .start
                    holdTimer.start(duration: duration)
                }
                withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                    isHolding = false
                }
            }
    }

    /// LongPress-Geste: Stop setzen und Aktion ausführen
    var longPressGesture: some Gesture {
        LongPressGesture(minimumDuration: duration)
            .onChanged { _ in
                isHolding = true
            }
            .onEnded { success in
                isHolding = false
                holdTimer.stop()
                buttonStatus = .stop
                if success {
                    action()
                }
            }
    }

    /// Startet den Hold-Timer (für Accessibility)
    private func startHold() {
        buttonStatus = .start
        holdTimer.start(duration: duration)
    }
}

#Preview {
    HoldDownButton2(
        text: "Start",
        duration: 2,
        background: .black,
        loadingTint: .white.opacity(0.3)
    ) {
        // Aktion
    }
    .foregroundStyle(.white)
}
