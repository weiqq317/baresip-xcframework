//
//  SettingsView.swift
//  Baresip iOS Example
//
//  设置界面：音频、网络等配置
//

import SwiftUI
import SwiftBaresip

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                // 音频设置
                Section(header: Text("音频设置")) {
                    Picker("音频编解码器", selection: $viewModel.selectedCodec) {
                        ForEach(viewModel.availableCodecs, id: \.self) { codec in
                            Text(codec).tag(codec)
                        }
                    }
                    
                    Toggle("回声消除", isOn: $viewModel.echoCancellation)
                    Toggle("噪音抑制", isOn: $viewModel.noiseSuppression)
                }
                
                // 网络设置
                Section(header: Text("网络设置")) {
                    Picker("传输协议", selection: $viewModel.transportProtocol) {
                        Text("UDP").tag("UDP")
                        Text("TCP").tag("TCP")
                        Text("TLS").tag("TLS")
                    }
                    
                    Toggle("ICE (NAT 穿透)", isOn: $viewModel.iceEnabled)
                    Toggle("STUN", isOn: $viewModel.stunEnabled)
                    
                    if viewModel.stunEnabled {
                        TextField("STUN 服务器", text: $viewModel.stunServer)
                            .autocapitalization(.none)
                    }
                }
                
                // 通话设置
                Section(header: Text("通话设置")) {
                    Toggle("自动接听", isOn: $viewModel.autoAnswer)
                    
                    Stepper("振铃时长: \(viewModel.ringTimeout)秒",
                           value: $viewModel.ringTimeout,
                           in: 10...60,
                           step: 5)
                }
                
                // 高级设置
                Section(header: Text("高级设置")) {
                    Toggle("调试日志", isOn: $viewModel.debugLogging)
                    
                    Button("清除缓存") {
                        viewModel.clearCache()
                    }
                    .foregroundColor(.red)
                }
                
                // 关于
                Section(header: Text("关于")) {
                    HStack {
                        Text("版本")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        Text("Baresip 版本")
                        Spacer()
                        Text("3.14.0")
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("设置")
            .navigationBarItems(trailing: Button("完成") {
                viewModel.saveSettings()
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

// MARK: - Settings ViewModel

class SettingsViewModel: ObservableObject {
    @Published var selectedCodec = "Opus"
    @Published var echoCancellation = true
    @Published var noiseSuppression = true
    @Published var transportProtocol = "UDP"
    @Published var iceEnabled = true
    @Published var stunEnabled = true
    @Published var stunServer = "stun.l.google.com:19302"
    @Published var autoAnswer = false
    @Published var ringTimeout = 30
    @Published var debugLogging = false
    
    let availableCodecs = ["Opus", "G.711 (PCMU)", "G.711 (PCMA)", "G.722"]
    
    init() {
        loadSettings()
    }
    
    func loadSettings() {
        // 从 UserDefaults 加载设置
        selectedCodec = UserDefaults.standard.string(forKey: "selectedCodec") ?? "Opus"
        echoCancellation = UserDefaults.standard.bool(forKey: "echoCancellation")
        noiseSuppression = UserDefaults.standard.bool(forKey: "noiseSuppression")
        transportProtocol = UserDefaults.standard.string(forKey: "transportProtocol") ?? "UDP"
        iceEnabled = UserDefaults.standard.bool(forKey: "iceEnabled")
        stunEnabled = UserDefaults.standard.bool(forKey: "stunEnabled")
        stunServer = UserDefaults.standard.string(forKey: "stunServer") ?? "stun.l.google.com:19302"
        autoAnswer = UserDefaults.standard.bool(forKey: "autoAnswer")
        ringTimeout = UserDefaults.standard.integer(forKey: "ringTimeout")
        debugLogging = UserDefaults.standard.bool(forKey: "debugLogging")
    }
    
    func saveSettings() {
        // 保存到 UserDefaults
        UserDefaults.standard.set(selectedCodec, forKey: "selectedCodec")
        UserDefaults.standard.set(echoCancellation, forKey: "echoCancellation")
        UserDefaults.standard.set(noiseSuppression, forKey: "noiseSuppression")
        UserDefaults.standard.set(transportProtocol, forKey: "transportProtocol")
        UserDefaults.standard.set(iceEnabled, forKey: "iceEnabled")
        UserDefaults.standard.set(stunEnabled, forKey: "stunEnabled")
        UserDefaults.standard.set(stunServer, forKey: "stunServer")
        UserDefaults.standard.set(autoAnswer, forKey: "autoAnswer")
        UserDefaults.standard.set(ringTimeout, forKey: "ringTimeout")
        UserDefaults.standard.set(debugLogging, forKey: "debugLogging")
        
        print("✅ 设置已保存")
    }
    
    func clearCache() {
        // 清除缓存
        print("🗑️ 缓存已清除")
    }
}

// MARK: - Preview

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
