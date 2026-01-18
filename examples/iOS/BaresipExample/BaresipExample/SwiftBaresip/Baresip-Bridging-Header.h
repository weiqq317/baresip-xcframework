//
//  Baresip-Bridging-Header.h
//  Baresip C API 桥接头文件
//
//  用于将 Baresip 的 C 语言接口暴露给 Swift
//

#ifndef Baresip_Bridging_Header_h
#define Baresip_Bridging_Header_h

#import <Foundation/Foundation.h>

// ============================================================================
// MARK: - libre 核心函数声明
// ============================================================================

// SIP 用户代理结构体
struct ua;
struct call;
struct account;
struct sip_addr;

// 用户代理管理
struct ua* ua_create(void);
void ua_destroy(struct ua *ua);
int ua_register(struct ua *ua, const char *user, const char *pass, const char *domain);
int ua_unregister(struct ua *ua);

// 呼叫控制
int ua_invite(struct ua *ua, struct call **callp, const char *uri, const char *params, int vid_mode);
int call_answer(struct call *call, uint16_t scode);
int call_hangup(struct call *call, uint16_t scode);
int call_hold(struct call *call);
int call_resume(struct call *call);
void call_destroy(struct call *call);

// DTMF 发送
int call_send_digit(struct call *call, char digit);

// 呼叫状态查询
const char* call_peeruri(const struct call *call);
const char* call_localuri(const struct call *call);
int call_duration(const struct call *call);
bool call_is_onhold(const struct call *call);

// 事件回调类型定义
typedef void (*ua_event_h)(struct ua *ua, int event, struct call *call, const char *prm, void *arg);

// 事件注册
int ua_event_register(struct ua *ua, ua_event_h h, void *arg);

// 呼叫状态枚举（对应 Baresip 的 call_event）
enum call_event {
    CALL_EVENT_INCOMING = 0,
    CALL_EVENT_RINGING,
    CALL_EVENT_PROGRESS,
    CALL_EVENT_ESTABLISHED,
    CALL_EVENT_CLOSED,
    CALL_EVENT_TRANSFER,
    CALL_EVENT_TRANSFER_FAILED,
    CALL_EVENT_MENC,
};

// 视频模式枚举
enum {
    VID_MODE_OFF = 0,
    VID_MODE_ON = 1,
};

// ============================================================================
// MARK: - librem 核心函数声明
// ============================================================================

// 音频设备管理
int audio_device_set(const char *device);
int audio_device_list(void);

// ============================================================================
// MARK: - baresip 核心函数声明
// ============================================================================

// Baresip 初始化与清理
int baresip_init(const char *config_path);
void baresip_close(void);

// 主循环（用于后台线程）
int re_main(void (*signal_handler)(int));
void re_cancel(void);

// 唤醒（用于 PushKit）
void ua_wakeup(struct ua *ua);

// 账号配置
struct account* account_create(const char *aor, const char *auth_user, const char *auth_pass);
void account_destroy(struct account *acc);

// SIP 地址解析
struct sip_addr* sip_addr_decode(const char *uri);
void sip_addr_free(struct sip_addr *addr);
const char* sip_addr_uri(const struct sip_addr *addr);

#endif /* Baresip_Bridging_Header_h */
