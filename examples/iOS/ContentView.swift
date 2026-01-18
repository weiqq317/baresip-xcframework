//
//  ContentView.swift
//  Baresip iOS Example
//
//  主界面：SIP 注册与拨号
//

import SwiftUI
import SwiftBaresip

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // SIP 注册区域
                registrationSection
                
                Divider()
                
                // 拨号区域
                dialSection
                
                Divider()
                
                // 当前通话区域
                if let call = viewModel.currentCall {
                    callSection(call: call)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Baresip VoIP")
        }
    }
    
    // MARK: - Registration Section
    
    private var registrationSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("SIP 账号")
                .font(.headline)
            
            TextField("用户名", text: $viewModel.username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
            
            SecureField("密码", text: $viewModel.password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("服务器域名", text: $viewModel.domain)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
            
            HStack {
                Button(action: viewModel.register) {
                    Text(viewModel.isRegistered ? "已注册" : "注册")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.isRegistered ? Color.green : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(viewModel.isRegistered)
                
                if viewModel.isRegistered {
                    Button(action: viewModel.unregister) {
                        Text("注销")
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
        VStack(alignment: .leading, spacing: 10) {
            Text("拨号")
                .font(.headline)
            
            TextField("SIP URI (如: sip:user@domain)", text: $viewModel.dialAddress)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
            
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
            .disabled(!viewModel.isRegistered || viewModel.currentCall != nil)
        }
    }
    
    // MARK: - Call Section
    
    private func callSection(call: BaresipCall) -> some View {
        VStack(spacing: 15) {
            Text("通话中")
                .font(.headline)
            
            Text(call.remoteAddress)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Text(call.state.description)
                .font(.title2)
                .foregroundColor(.blue)
            
            HStack(spacing: 20) {
                // 挂断按钮
                Button(action: { viewModel.hangup(call: call) }) {
                    VStack {
                        Image(systemName: "phone.down.fill")
                            .font(.title)
                        Text("挂断")
                            .font(.caption)
                    }
                    .frame(width: 80, height: 80)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(40)
                }
                
                // 保持/恢复按钮
                Button(action: { viewModel.toggleHold(call: call) }) {
                    VStack {
                        Image(systemName: call.isOnHold ? "play.fill" : "pause.fill")
                            .font(.title)
                        Text(call.isOnHold ? "恢复" : "保持")
                            .font(.caption)
                    }
                    .frame(width: 80, height: 80)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(40)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(15)
    }
}

// MARK: - ViewModel

class ContentViewModel: ObservableObject {
    @Published var username = ""
    @Published var password = ""
    @Published var domain = ""
    @Published var dialAddress = ""
    @Published var isRegistered = false
    @Published var currentCall: BaresipCall?
    
    init() {
        // 设置代理
        BaresipUA.shared.delegate = self
        
        // 示例账号（测试用）
        username = "test"
        password = "test123"
        domain = "sip.example.com"
    }
    
    func register() {
        let account = BaresipAccount(
            username: username,
            password: password,
            domain: domain
        )
        
        do {
            try BaresipUA.shared.register(with: account)
            print("✅ 开始注册...")
        } catch {
            print("❌ 注册失败: \(error)")
        }
    }
    
    func unregister() {
        do {
            try BaresipUA.shared.unregister()
            print("✅ 已注销")
        } catch {
            print("❌ 注销失败: \(error)")
        }
    }
    
    func makeCall() {
        do {
            let call = try BaresipUA.shared.inviteAddress(dialAddress)
            currentCall = call
            print("✅ 呼叫已发起: \(dialAddress)")
        } catch {
            print("❌ 呼叫失败: \(error)")
        }
    }
    
    func hangup(call: BaresipCall) {
        do {
            try call.terminate()
            print("✅ 已挂断")
        } catch {
            print("❌ 挂断失败: \(error)")
        }
    }
    
    func toggleHold(call: BaresipCall) {
        do {
            if call.isOnHold {
                try call.resume()
                print("✅ 已恢复通话")
            } else {
                try call.putOnHold()
                print("✅ 已保持通话")
            }
        } catch {
            print("❌ 操作失败: \(error)")
        }
    }
}

// MARK: - BaresipUADelegate

extension ContentViewModel: BaresipUADelegate {
    func callStateChanged(call: BaresipCall, state: BaresipCallState) {
        DispatchQueue.main.async {
            if state.isEnded {
                self.currentCall = nil
            } else if self.currentCall == nil {
                self.currentCall = call
            }
        }
    }
    
    func registrationStateChanged(isRegistered: Bool, error: Error?) {
        DispatchQueue.main.async {
            self.isRegistered = isRegistered
        }
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
