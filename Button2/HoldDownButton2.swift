//
//  HoldDownButton2.swift
//  Button2
//
//  Created by Juergen Schulz on 27.10.25.
//
//  A button with start/pause/stop status and a loading bar.
//  A short tap starts/pauses, a long press stops and triggers an action.


import SwiftUI
import Combine

// Button status enumeration
public enum ButtonStatus2: String {
    case start = "Running"
        case pause = "Pause"
        case stop = "Stopped"
        case ready = "Bereit"
    
    public var isActive: Bool {
        switch self {
        case .start, .pause: return true
        case .stop, .ready: return false
        }
    }
}

let defaultStatusTexts: [ButtonStatus2: String] = [
    .start: "Running!",
    .pause: "Pause!",
    .stop: "Stopped!",
    .ready: "Ready!"
]

let defaultStatusColors: [ButtonStatus2: Color] = [
    .start: .green,
    .pause: .yellow,
    .stop: .red,
    .ready: .blue
]

class HoldTimer: ObservableObject {
    @Published private(set) var progress: CGFloat = 0
    @Published private(set) var isActive = false

    private var timer: AnyCancellable?
    private var duration: CGFloat = 3
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

struct HoldDownButton2<ButtonContent: View>: View {
    var duration: CGFloat = 3 /// duration Progress bar
    var paddingVertical: CGFloat = 12 /// Verticale padding
    var paddingHorizontal: CGFloat = 25 /// Horizontale padding
    var loadingTint: Color = .gray /// Colors of Progress bar
    ///
    // External specifications for texts and colors
    var statusTexts: [ButtonStatus2: String] = defaultStatusTexts
    var statusColors: [ButtonStatus2: Color] = defaultStatusColors
    var statusTextColor: Color = .white

    var onStateChange: (ButtonStatus2) -> Void = { _ in } /// Callback on state change
    @ViewBuilder var buttonContent: () -> ButtonContent /// Custom button content (not used in this version)
    
    @StateObject private var holdTimer = HoldTimer() /// Timer for Progress bar
    @State private var isHolding = false /// hold Button (for Animation)
    @State private var buttonStatus: ButtonStatus2 = .ready // Transferring status to another app part.
    // Example: via Binding: @Binding var buttonStatus: ButtonStatus2
    
    var body: some View {
        VStack {
            Text(statusTexts[buttonStatus] ?? "") // Button
                .foregroundColor(statusTextColor)
                .padding(.vertical, paddingVertical)
                .padding(.horizontal, paddingHorizontal)
                .frame(width: 150, height: 40)
                .background {
                    ZStack(alignment: .leading) {
                        Rectangle() // Button Background
                            .fill(statusColors[buttonStatus] ?? .gray)
                        if buttonStatus == .start || buttonStatus == .pause || buttonStatus == .ready {
                            Rectangle() // progress bar
                                .fill(loadingTint)
                                .frame(width: 150 * holdTimer.progress, height: 40, alignment: .leading)
                                .animation(.linear(duration: 0.1), value: holdTimer.progress)
                                .transition(.opacity)
                        }
                    }
                }
                .clipShape(Capsule())
                .contentShape(Capsule())
                .scaleEffect(isHolding ? 0.95 : 1)
                .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isHolding)
                .gesture(tapGesture.exclusively(before: longPressGesture))
            
            // Statusanzeige unterhalb des Buttons (optional)
            /*
             Text("Status: \(buttonStatus.rawValue)")
             .font(.headline)
             .foregroundStyle(.red)
             .background(.white)
             .padding(.top, 8)
             */
        }
        // Initialisierung beim Anzeigen
        .onAppear {
            holdTimer.reset()
            buttonStatus = .ready
        }
        .onChange(of: buttonStatus) { newStatus in
            onStateChange(newStatus)
        }
    }
    
    /// Tap-Geste: Start/Pause switching
    var tapGesture: some Gesture {
        TapGesture()
            .onEnded {
                if buttonStatus == .start {
                    buttonStatus = .pause
                    holdTimer.reset()
                } else {
                    buttonStatus = .start
                    holdTimer.reset()
                }
            }
    }

    /// LongPress-Geste: Set stop
    var longPressGesture: some Gesture {
        LongPressGesture(minimumDuration: duration)
            .onChanged { _ in
                isHolding = true
                holdTimer.start(duration: duration)
            }
            .onEnded { success in
                isHolding = false
                holdTimer.stop()
                holdTimer.reset()
                buttonStatus = .stop
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        buttonStatus = .ready
                    }
            }
    }
}

#Preview {
    HoldDownButton2(
        duration: 3,
        loadingTint: .white.opacity(0.3),
        statusTextColor: .white,
        /*statusTexts: [
            .start: "Start",
            .pause: "Pause",
            .stop: "Stop",
            .ready: "Bereit"
        ],
         statusColors: [
            .start: .green,
            .pause: .orange,
            .stop: .red,
            .ready: .gray
        ]
         */
    ) {
        EmptyView()
    }
}
