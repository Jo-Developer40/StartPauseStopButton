//
//  HoldDownButton2.swift
//  Button2
//
//  Created by Juergen Schulz on 26.10.25.
//

import SwiftUI


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

struct HoldDownButton2: View {
    var text: String
    var duration: CGFloat = 2
    var paddingVertical: CGFloat = 12
    var paddingHorizontal: CGFloat = 25
    var scale: CGFloat = 0.95
    var background: Color = .gray
    var loadingTint: Color = .blue
    var shape: AnyShape = .init(.capsule)
    var action: () -> ()

    @State private var timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    @State private var timerCount: CGFloat = 0
    @State private var progress: CGFloat = 0

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
                                    .frame(width: size.width * progress)
                                    .transition(.opacity)
                            }
                        }
                    }
                }
                .clipShape(shape)
                .contentShape(shape)
                .scaleEffect(isHolding ? scale : 1)
                .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isHolding)
            
                .gesture(dragGesture)
                .simultaneousGesture(longPressGesture)
                .onReceive(timer) { _ in
                    guard isHolding, progress < 1 else { return }
                    timerCount += 0.01
                    progress = min(max(timerCount / duration, 0), 1)
                    buttonStatus = .pause
                }
                .onAppear {
                    cancelTimer()
                    buttonStatus = .stop
                }
            Text("Status: \(buttonStatus.rawValue)")
                .font(.headline)
                .foregroundStyle(.red)
                .background(.white)
                .padding(.top, 8)
        }
    }

    var dragGesture: some Gesture {
        DragGesture()
            .onChanged { _ in
                isHolding = true
            }
            .onEnded { _ in
                guard !isComplete else { return }
                cancelTimer()
                withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                    stop()
                }
                //isComplete = false
                isHolding = false
                buttonStatus = (buttonStatus == .start) ? .pause : .stop
            }
    }
    
    var longPressGesture: some Gesture {
        LongPressGesture(minimumDuration: duration)
            .onChanged { holding in
                isComplete = false
                reset()
                isHolding = holding
                addTimer()
                buttonStatus = .start
            }
            .onEnded { success in
                isHolding = false
                cancelTimer()
                withAnimation(.easeInOut(duration: 0.2)) {
                    isComplete = success
                }
                buttonStatus = success ? .pause : .start
                if success {
                    action()
                }
            }
    }

    private func addTimer() {
        timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    }

    private func cancelTimer() {
        timer.upstream.connect().cancel()
    }

    private func reset() {
        isHolding = false
        progress = 0
        timerCount = 0
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
        //count += 1
    }
    .foregroundStyle(.white)
}
