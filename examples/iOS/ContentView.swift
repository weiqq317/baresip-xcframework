//
//  ContentView.swift
//  Baresip iOS Example
//
//  主界面：SIP 注册、拨号与通话管理
//

import SwiftUI
import SwiftBaresip

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    @State private var showingSettings = false
    @State private var showingCallView = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // SIP 注册区域
                registrationSection
                
                Divider()
                
                // 拨号区域
                dialSection
                
                Divider()
                
                // 当前通话状态
                if let call = viewModel.currentCall {
                    currentCallSection(call: call)
                }
                
                Spacer()
                
                // 状态栏
                statusBar
            }
            .padding()
            .navigationTitle("Baresip VoIP")
            .navigationBarItems(trailing: settingsButton)
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .fullScreenCover(isPresented: $showingCallView) {
                if let call = viewModel.currentCall {
                    CallView(viewModel: CallViewModel(call: call))
                }
            }
            .alert(item: $viewModel.alertMessage) { alert in
                Alert(
                    title: Text(alert.title),
                    message: Text(alert.message),
                    dismissButton: .default(Text("确定"))
                )
            }
        }
        .onChange(of: viewModel.currentCall) { call in
            showingCallView = (call != nil)
        }
    }
    
    // MARK: - Registration Section
    
    private var registrationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("SIP 账号")
                    .font(.headline)
                
                Spacer()
                
                if viewModel.isRegistering {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }
            
            TextField("用户名", text: $viewModel.username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .disabled(viewModel.isRegistered)
            
            SecureField("密码", text: $viewModel.password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .disabled(viewModel.isRegistered)
            
            TextField("服务器域名", text: $viewModel.domain)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .disabled(viewModel.isRegistered)
            
            HStack(spacing: 12) {
                Button(action: viewModel.register) {
                    HStack {
                        Image(systemName: viewModel.isRegistered ? "checkmark.circle.fill" : "person.crop.circle")
                        Text(viewModel.isRegistered ? "已注册" : "注册")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.isRegistered ? Color.green : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .disabled(viewModel.isRegistered || viewModel.isRegistering)
                
                if viewModel.isRegistered {
                    Button(action: viewModel.unregister) {
                        HStack {
                            Image(systemName: "xmark.circle")
                            Text("注销")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
            }
        }
    }
    
    // MARK: - Dial Section
    
    private var dialSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("拨号")
                .font(.headline)
            
            HStack {
                TextField("SIP URI (如: sip:user@domain)", text: $viewModel.dialAddress)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                
                Button(action: {
                    // 从通讯录选择
                }) {
                    Image(systemName: "person.crop.circle")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
            
            HStack(spacing: 12) {
                Button(action: viewModel.makeCall) {
                    HStack {
                        Image(systemName: "phone.fill")
                        Text("呼叫")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .disabled(!viewModel.canMakeCall)
                
                Button(action: {
                    viewModel.dialAddress = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
                .disabled(viewModel.dialAddress.isEmpty)
            }
            
            // 快速拨号按钮
            if !viewModel.quickDialNumbers.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(viewModel.quickDialNumbers, id: \.self) { number in
                            QuickDialButton(number: number) {
                                viewModel.dialAddress = number
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Current Call Section
    
    private func currentCallSection(call: BaresipCall) -> some View {
        VStack(spacing: 12) {
            HStack {
                Text("当前通话")
                    .font(.headline)
                Spacer()
                Text(call.state.description)
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(call.remoteAddress)
                        .font(.body)
                    Text(call.isIncoming ? "来电" : "呼出")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Button(action: {
                    showingCallView = true
                }) {
                    Text("查看详情")
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
    }
    
    // MARK: - Status Bar
    
    private var statusBar: some View {
        HStack {
            Image(systemName: viewModel.isRegistered ? "wifi" : "wifi.slash")
                .foregroundColor(viewModel.isRegistered ? .green : .gray)
            
            Text(viewModel.statusText)
                .font(.caption)
                .foregroundColor(.gray)
            
            Spacer()
            
            if viewModel.pushTokenRegistered {
                Image(systemName: "bell.fill")
                    .foregroundColor(.green)
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Settings Button
    
    private var settingsButton: some View {
        Button(action: {
            showingSettings = true
        }) {
            Image(systemName: "gearshape.fill")
                .font(.title3)
        }
    }
}

// MARK: - Quick Dial Button

struct QuickDialButton: View {
    let number: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: "person.circle.fill")
                    .font(.title2)
                Text(number.components(separatedBy: "@").first ?? number)
                    .font(.caption2)
                    .lineLimit(1)
            }
            .frame(width: 60)
            .padding(.vertical, 8)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(8)
        }
    }
}

// MARK: - Alert Message

struct AlertMessage: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}

// MARK: - ViewModel

class ContentViewModel: ObservableObject {
    @Published var username = ""
    @Published var password = ""
    @Published var domain = ""
    @Published var dialAddress = ""
    @Published var isRegistered = false
    @Published var isRegistering = false
    @Published var currentCall: BaresipCall?
    @Published var statusText = "未连接"
    @Published var pushTokenRegistered = false
    @Published var alertMessage: AlertMessage?
    @Published var quickDialNumbers: [String] = []
    
    var canMakeCall: Bool {
        isRegistered && currentCall == nil && !dialAddress.isEmpty
    }
    
    init() {
        // 设置代理
        BaresipUA.shared.delegate = self
        
        // 加载保存的账号信息
        loadAccountInfo()
        
        // 加载快速拨号
        loadQuickDialNumbers()
        
        // 设置 PushKit 回调
        setupPushKit()
    }
    
    private func loadAccountInfo() {
        username = UserDefaults.standard.string(forKey: "sip_username") ?? ""
        domain = UserDefaults.standard.string(forKey: "sip_domain") ?? ""
        // 密码不保存在 UserDefaults 中，出于安全考虑
    }
    
    private func saveAccountInfo() {
        UserDefaults.standard.set(username, forKey: "sip_username")
        UserDefaults.standard.set(domain, forKey: "sip_domain")
    }
    
    private func loadQuickDialNumbers() {
        quickDialNumbers = UserDefaults.standard.stringArray(forKey: "quick_dial_numbers") ?? []
    }
    
    private func setupPushKit() {
        let pushKitManager = PushKitManager.shared
        
        pushKitManager.onTokenReceived = { [weak self] token in
            print("📱 Push Token: \(token)")
            self?.pushTokenRegistered = true
        }
        
        pushKitManager.onPushReceived = { payload in
            print("📞 收到来电推送: \(payload)")
        }
    }
    
    func register() {
        guard !username.isEmpty && !password.isEmpty && !domain.isEmpty else {
            showAlert(title: "错误", message: "请填写完整的账号信息")
            return
        }
        
        isRegistering = true
        statusText = "正在注册..."
        
        let account = BaresipAccount(
            username: username,
            password: password,
            domain: domain
        )
        
        do {
            try BaresipUA.shared.register(with: account)
            saveAccountInfo()
        } catch {
            isRegistering = false
            statusText = "注册失败"
            showAlert(title: "注册失败", message: error.localizedDescription)
        }
    }
    
    func unregister() {
        do {
            try BaresipUA.shared.unregister()
            statusText = "已注销"
        } catch {
            showAlert(title: "注销失败", message: error.localizedDescription)
        }
    }
    
    func makeCall() {
        guard canMakeCall else { return }
        
        do {
            let call = try BaresipUA.shared.inviteAddress(dialAddress)
            currentCall = call
            print("✅ 呼叫已发起: \(dialAddress)")
        } catch {
            showAlert(title: "呼叫失败", message: error.localizedDescription)
        }
    }
    
    private func showAlert(title: String, message: String) {
        alertMessage = AlertMessage(title: title, message: message)
    }
}

// MARK: - BaresipUADelegate

extension ContentViewModel: BaresipUADelegate {
    func callStateChanged(call: BaresipCall, state: BaresipCallState) {
        DispatchQueue.main.async {
            print("📞 通话状态变更: \(state.description)")
            
            if state.isEnded {
                self.currentCall = nil
            } else if self.currentCall == nil {
                self.currentCall = call
            }
        }
    }
    
    func registrationStateChanged(isRegistered: Bool, error: Error?) {
        DispatchQueue.main.async {
            self.isRegistering = false
            self.isRegistered = isRegistered
            
            if isRegistered {
                self.statusText = "已连接"
                print("✅ SIP 注册成功")
            } else {
                self.statusText = error != nil ? "注册失败" : "未连接"
                if let error = error {
                    self.showAlert(title: "注册失败", message: error.localizedDescription)
                }
            }
        }
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
