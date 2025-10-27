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

struct HoldDownButton2: View {
    var text: String
    var duration: CGFloat = 2
    var paddingVertical: CGFloat = 12
    var paddingHorizontal: CGFloat = 25
    var scale: CGFloat = 0.95
    var background: Color = .gray
    var loadingTint: Color = .blue
    var action: () -> ()
    
    @StateObject private var holdTimer = HoldTimer()
    @State private var isHolding = false
    @State private var isComplete = false
    @State private var buttonStatus: ButtonStatus2 = .stop

    var body: some View {
        VStack {
            Text(text)
                .padding(.vertical, paddingVertical)
                .padding(.horizontal, paddingHorizontal)
                .background {
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(background)
                        GeometryReader { proxy in
                            let size = proxy.size
                            if !isComplete {
                                Rectangle()
                                    .fill(loadingTint)
                                    .frame(width: size.width * holdTimer.progress)
                                    .animation(.linear(duration: 0.1), value: holdTimer.progress) // Fortschrittswerts flüssig animiert
                                    .transition(.opacity)
                            }
                        }
                    }
                }
                .clipShape(Capsule())
                .contentShape(Capsule())
                .scaleEffect(isHolding ? scale : 1)
                .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isHolding)
                .gesture(dragGesture)
                .simultaneousGesture(longPressGesture)
                .accessibilityLabel(Text(text))
                .accessibilityValue(Text("Fortschritt \(Int(holdTimer.progress * 100)) Prozent"))
                .accessibilityAddTraits(.isButton)
                .accessibilityAction(named: Text("Gedrückt halten für Aktion")) {
                    startHold()
                }
            Text("Status: \(buttonStatus.rawValue)")
                .font(.headline)
                .foregroundStyle(.red)
                .background(.white)
                .padding(.top, 8)
        }
        .onAppear {
            holdTimer.reset()
            buttonStatus = .stop
        }
    }
    
    var dragGesture: some Gesture {
        DragGesture()
            .onChanged { _ in
                isHolding = true
            }
            .onEnded { _ in
                guard !isComplete else { return }
                holdTimer.reset()
                withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                    isComplete = false
                }
                isHolding = false
                buttonStatus = (buttonStatus == .start) ? .pause : .stop
            }
    }
    
    var longPressGesture: some Gesture {
        LongPressGesture(minimumDuration: duration)
            .onChanged { holding in
                isComplete = false
                holdTimer.reset()
                isHolding = holding
                startHold()
            }
            .onEnded { success in
                isHolding = false
                holdTimer.stop()
                withAnimation(.easeInOut(duration: 0.2)) {
                    isComplete = success
                }
                buttonStatus = success ? .pause : .start
                if success {
                    action()
                }
            }
    }
    
    private func startHold() {
            buttonStatus = .start
            holdTimer.start(duration: duration)
        }
}

#Preview {
    HoldDownButton2(
        text: "Hold to increase",
        duration: 2,
        background: .black,
        loadingTint: .white.opacity(0.3)
    ) {
        // Aktion
    }
    .foregroundStyle(.white)
}
