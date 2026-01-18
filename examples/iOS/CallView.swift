//
//  CallView.swift
//  Baresip iOS Example
//
//  通话界面：完整的通话控制
//

import SwiftUI
import SwiftBaresip

struct CallView: View {
    @ObservedObject var viewModel: CallViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // 通话信息
            callInfoSection
            
            Spacer()
            
            // DTMF 拨号盘
            if viewModel.showDTMFPad {
                dtmfPadSection
            }
            
            // 通话控制按钮
            callControlsSection
            
            // 主要操作按钮
            mainActionsSection
            
            Spacer()
        }
        .padding()
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .foregroundColor(.white)
        .navigationBarHidden(true)
    }
    
    // MARK: - Call Info Section
    
    private var callInfoSection: some View {
        VStack(spacing: 10) {
            Text(viewModel.call.remoteAddress)
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(viewModel.callStateText)
                .font(.headline)
                .foregroundColor(.gray)
            
            if viewModel.callDuration > 0 {
                Text(viewModel.formattedDuration)
                    .font(.title)
                    .fontWeight(.light)
                    .monospacedDigit()
            }
        }
    }
    
    // MARK: - DTMF Pad Section
    
    private var dtmfPadSection: some View {
        VStack(spacing: 15) {
            ForEach(0..<4) { row in
                HStack(spacing: 15) {
                    ForEach(0..<3) { col in
                        let digit = viewModel.dtmfDigits[row * 3 + col]
                        DTMFButton(digit: digit) {
                            viewModel.sendDTMF(digit)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(15)
    }
    
    // MARK: - Call Controls Section
    
    private var callControlsSection: some View {
        HStack(spacing: 40) {
            // 静音
            ControlButton(
                icon: viewModel.isMuted ? "mic.slash.fill" : "mic.fill",
                label: "静音",
                isActive: viewModel.isMuted
            ) {
                viewModel.toggleMute()
            }
            
            // 扬声器
            ControlButton(
                icon: viewModel.isSpeakerOn ? "speaker.wave.3.fill" : "speaker.fill",
                label: "扬声器",
                isActive: viewModel.isSpeakerOn
            ) {
                viewModel.toggleSpeaker()
            }
            
            // DTMF
            ControlButton(
                icon: "number",
                label: "键盘",
                isActive: viewModel.showDTMFPad
            ) {
                viewModel.toggleDTMFPad()
            }
        }
    }
    
    // MARK: - Main Actions Section
    
    private var mainActionsSection: some View {
        HStack(spacing: 30) {
            // 保持/恢复
            MainActionButton(
                icon: viewModel.isOnHold ? "play.fill" : "pause.fill",
                label: viewModel.isOnHold ? "恢复" : "保持",
                color: .orange
            ) {
                viewModel.toggleHold()
            }
            
            // 挂断
            MainActionButton(
                icon: "phone.down.fill",
                label: "挂断",
                color: .red
            ) {
                viewModel.hangup()
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

// MARK: - DTMF Button

struct DTMFButton: View {
    let digit: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(digit)
                .font(.title)
                .fontWeight(.medium)
                .frame(width: 70, height: 70)
                .background(Color.gray.opacity(0.3))
                .foregroundColor(.white)
                .cornerRadius(35)
        }
    }
}

// MARK: - Control Button

struct ControlButton: View {
    let icon: String
    let label: String
    var isActive: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .frame(width: 60, height: 60)
                    .background(isActive ? Color.blue : Color.gray.opacity(0.3))
                    .foregroundColor(.white)
                    .cornerRadius(30)
                
                Text(label)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}

// MARK: - Main Action Button

struct MainActionButton: View {
    let icon: String
    let label: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.title)
                    .frame(width: 80, height: 80)
                    .background(color)
                    .foregroundColor(.white)
                    .cornerRadius(40)
                
                Text(label)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}

// MARK: - Call ViewModel

class CallViewModel: ObservableObject {
    @Published var call: BaresipCall
    @Published var callStateText: String = ""
    @Published var callDuration: TimeInterval = 0
    @Published var isMuted: Bool = false
    @Published var isSpeakerOn: Bool = false
    @Published var isOnHold: Bool = false
    @Published var showDTMFPad: Bool = false
    
    let dtmfDigits = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "*", "0", "#"]
    
    private var timer: Timer?
    private var callStartTime: Date?
    
    init(call: BaresipCall) {
        self.call = call
        self.callStateText = call.state.description
        
        // 启动计时器
        if call.state == .connected {
            startTimer()
        }
        
        // 监听通话状态
        setupCallStateObserver()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    var formattedDuration: String {
        let hours = Int(callDuration) / 3600
        let minutes = Int(callDuration) / 60 % 60
        let seconds = Int(callDuration) % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    private func setupCallStateObserver() {
        // 这里应该监听 call 的状态变化
        // 由于我们的 BaresipCall 没有直接的状态观察机制
        // 实际应用中应该通过 delegate 或 Combine 来实现
    }
    
    private func startTimer() {
        callStartTime = Date()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, let startTime = self.callStartTime else { return }
            self.callDuration = Date().timeIntervalSince(startTime)
        }
    }
    
    func toggleMute() {
        do {
            if isMuted {
                try call.unmute()
            } else {
                try call.mute()
            }
            isMuted.toggle()
        } catch {
            print("❌ 静音操作失败: \(error)")
        }
    }
    
    func toggleSpeaker() {
        // 切换音频路由
        let audioManager = AudioSessionManager.shared
        do {
            if isSpeakerOn {
                try audioManager.setAudioRoute(.receiver)
            } else {
                try audioManager.setAudioRoute(.speaker)
            }
            isSpeakerOn.toggle()
        } catch {
            print("❌ 扬声器切换失败: \(error)")
        }
    }
    
    func toggleHold() {
        do {
            if isOnHold {
                try call.resume()
            } else {
                try call.putOnHold()
            }
            isOnHold.toggle()
        } catch {
            print("❌ 保持操作失败: \(error)")
        }
    }
    
    func toggleDTMFPad() {
        showDTMFPad.toggle()
    }
    
    func sendDTMF(_ digit: String) {
        do {
            try call.sendDTMF(digit)
            print("📞 发送 DTMF: \(digit)")
        } catch {
            print("❌ DTMF 发送失败: \(error)")
        }
    }
    
    func hangup() {
        do {
            try call.terminate()
            timer?.invalidate()
        } catch {
            print("❌ 挂断失败: \(error)")
        }
    }
}

// MARK: - Preview

struct CallView_Previews: PreviewProvider {
    static var previews: some View {
        // 预览需要一个模拟的 call 对象
        // CallView(viewModel: CallViewModel(call: mockCall))
        Text("Call View Preview")
    }
}
