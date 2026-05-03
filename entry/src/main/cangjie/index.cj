package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

@Entry
@Component
class EntryView {
    @State
    var currentTabIndex: Int32 = 0
    @State
    var accessCode: String = ""
    @State
    var isLoggedIn: Bool = false
    @State
    var userName: String = "User"
    @State
    var userPlan: String = "Free"
    @State
    var credits: Int64 = 0
    @State
    var currentLang: String = "zh"
    @State
    var statusText: String = "就绪"
    @State
    var loginMessage: String = ""
    @State
    var isLoggingIn: Bool = false

    func build() {
        Column {
            if (!this.isLoggedIn) {
                this.buildLoginPage()
            } else {
                this.buildMainPage()
            }
        }.width(100.percent).height(100.percent).backgroundColor(0xFFF2F2F7)
    }

    @Builder
    func buildLoginPage() {
        Column {
            this.buildLoginHeader()

            Blank()

            Column {
                Text("ImageForge").fontSize(34).fontWeight(FontWeight.Bold).fontColor(0xFF1D1D1F).margin(bottom: 8)

                Text(this.getLoginTagline()).fontSize(15).fontColor(0xFF6E6E73).margin(bottom: 28)

                Column {
                    Text(this.getLoginTitle())
                        .fontSize(22)
                        .fontWeight(FontWeight.Medium)
                        .fontColor(0xFF1D1D1F)
                        .width(100.percent)
                        .margin(bottom: 8)

                    Text(this.getLoginDescription())
                        .fontSize(14)
                        .fontColor(0xFF6E6E73)
                        .width(100.percent)
                        .lineHeight(21)
                        .margin(bottom: 24)

                    TextInput(placeholder: this.getAccessCodePlaceholder())
                        .height(52)
                        .width(100.percent)
                        .backgroundColor(0xDFFFFFFF)
                        .borderRadius(14)
                        .borderWidth(1)
                        .borderColor(0x14000000)
                        .padding(left: 16, right: 16)
                        .fontSize(17)
                        .onChange(
                            {
                                value: String =>
                                    this.accessCode = value
                                    if (!this.loginMessage.isEmpty()) {
                                        this.loginMessage = ""
                                    }
                            }
                        )

                    if (!this.loginMessage.isEmpty()) {
                        Text(this.loginMessage)
                            .fontSize(13)
                            .fontColor(0xFFC93428)
                            .width(100.percent)
                            .textAlign(TextAlign.Center)
                            .margin(top: 12)
                    }

                    Button(this.getLoginButtonLabel())
                        .shape(ButtonType.Capsule)
                        .width(100.percent)
                        .height(52)
                        .backgroundColor(if (this.isLoggingIn) {
                            0x1A000000
                        } else {
                            0xFF2B2B2E
                        })
                        .fontColor(if (this.isLoggingIn) {
                            0x8CFFFFFF
                        } else {
                            0xFFFFFFFF
                        })
                        .fontSize(17)
                        .fontWeight(FontWeight.Medium)
                        .margin(top: 18)
                        .enabled(!this.isLoggingIn)
                        .onClick({
                            _: ClickEvent => this.handleLogin()
                        })
                }
                    .width(100.percent)
                    .padding(left: 28, right: 28, top: 32, bottom: 32)
                    .backgroundColor(0xCFFFFFFF)
                    .borderRadius(26)
                    .borderWidth(1)
                    .borderColor(0xB8FFFFFF)
                    .alignItems(HorizontalAlign.Start)
            }.width(88.percent).alignItems(HorizontalAlign.Center)

            Blank()

            Text(this.getLoginFooter()).fontSize(12).fontColor(0xFF86868B).margin(bottom: 26)
        }
            .width(100.percent)
            .height(100.percent)
            .padding(left: 16, right: 16)
            .alignItems(HorizontalAlign.Center)
            .backgroundColor(0xFFF5F5F7)
    }

    @Builder
    func buildLoginHeader() {
        Row {
            Row {
                Text("●").fontSize(12).fontColor(this.getStatusColor()).margin(right: 6)
                Text(this.getStatusLabel()).fontSize(13).fontColor(0xFF6E6E73)
            }

            Blank()

            Button(this.getLanguageSwitchLabel())
                .shape(ButtonType.Capsule)
                .height(36)
                .backgroundColor(0xBFFFFFFF)
                .fontColor(0xFF1D1D1F)
                .fontSize(14)
                .borderWidth(1)
                .borderColor(0x99FFFFFF)
                .onClick({
                    _: ClickEvent => this.toggleLanguage()
                })
        }.width(100.percent).height(64).padding(left: 4, right: 4, top: 12)
    }

    @Builder
    func buildMainPage() {
        Column {
            this.buildTopBar()

            Tabs(barPosition: BarPosition.End) {
                TabContent() {
                    HomePage(
                        currentLang: this.currentLang,
                        onNavigate: {
                            page: Int32 => this.currentTabIndex = page
                        }
                    )
                }.tabBar("首页")

                TabContent() {
                    EditorPage(
                        accessCode: this.accessCode,
                        currentLang: this.currentLang,
                        onCreditsChange: {
                            remaining: Int64 => if (remaining >= 0) {
                                this.credits = remaining
                            }
                        }
                    )
                }.tabBar("创作")

                TabContent() {
                    HistoryPage(currentLang: this.currentLang)
                }.tabBar("历史")

                TabContent() {
                    SettingsPage(currentLang: this.currentLang)
                }.tabBar("设置")
            }.barHeight(56).onChange({
                index: Int32 => this.currentTabIndex = index
            }).layoutWeight(1)
        }.width(100.percent).height(100.percent)
    }

    @Builder
    func buildTopBar() {
        Row {
            Text("ImageForge").fontSize(18).fontWeight(FontWeight.Bold).fontColor(0xFF1D1D1F)

            Blank()

            Column {
                Text(this.userName).fontSize(13).fontWeight(FontWeight.Medium).fontColor(0xFF1D1D1F)
                Text(this.userPlan).fontSize(11).fontColor(0xFF6E6E73).margin(top: 2)
            }
                .padding(left: 12, right: 12, top: 6, bottom: 6)
                .backgroundColor(0x73FFFFFF)
                .borderRadius(20)
                .borderWidth(1)
                .borderColor(0x99FFFFFF)
                .alignItems(HorizontalAlign.Start)

            Row {
                Text("●").fontSize(10).fontColor(0xFFFFFFFF).margin(right: 4)
                Text("${this.credits}").fontSize(13).fontWeight(FontWeight.Bold).fontColor(0xFFFFFFFF)
            }.margin(left: 12).height(34).padding(left: 12, right: 12).backgroundColor(0xFF2B2B2E).borderRadius(18)

            Button(this.getLanguageSwitchLabel())
                .shape(ButtonType.Capsule)
                .height(34)
                .backgroundColor(0xFFFFFFFF)
                .fontColor(0xFF1D1D1F)
                .fontSize(13)
                .borderWidth(1)
                .borderColor(0xFFE5E5EA)
                .margin(left: 10)
                .onClick({
                    _: ClickEvent => this.toggleLanguage()
                })
        }.width(100.percent).height(56).padding(left: 16, right: 16).backgroundColor(0xFFFFFFFF)
    }

    func handleLogin() {
        this.accessCode = this.accessCode.trimAscii()
        if (this.accessCode.isEmpty()) {
            this.loginMessage = "请输入访问码"
            return
        }
        if (this.isLoggingIn) {
            return
        }

        this.isLoggingIn = true
        this.loginMessage = this.getLoginCheckingMessage()

        apiLogin(
            this.accessCode,
            {
                user: UserInfo =>
                    this.userName = user.username
                    this.userPlan = user.planName
                    this.credits = user.credits
                    this.isLoggedIn = true
                    this.isLoggingIn = false
                    this.loginMessage = ""
                    this.statusText = this.getLoggedInStatus()
            },
            {
                message: String =>
                    this.isLoggingIn = false
                    this.loginMessage = message
                    this.statusText = this.getLoginFailedStatus()
            }
        )
    }

    func getLoginButtonLabel(): String {
        if (this.isLoggingIn) {
            return if (this.currentLang == "zh") {
                "验证中..."
            } else {
                "Verifying..."
            }
        }
        return if (this.currentLang == "zh") {
            "提交"
        } else {
            "Submit"
        }
    }

    func toggleLanguage() {
        if (this.currentLang == "zh") {
            this.currentLang = "en"
            if (this.statusText == "就绪") {
                this.statusText = "Ready"
            }
        } else {
            this.currentLang = "zh"
            if (this.statusText == "Ready") {
                this.statusText = "就绪"
            }
        }
        this.loginMessage = ""
    }

    func getLoginTagline(): String {
        if (this.currentLang == "zh") {
            return "AI 驱动的图像编辑与生成"
        }
        return "AI image editing and generation"
    }

    func getLoginTitle(): String {
        if (this.currentLang == "zh") {
            return "需要访问码"
        }
        return "Access Code Required"
    }

    func getLoginDescription(): String {
        if (this.currentLang == "zh") {
            return "请输入内测访问码以继续。登录成功后将同步用户名、订阅方案和剩余积分。"
        }
        return "Enter the beta access code to continue. User, plan, and credits are loaded after login."
    }

    func getAccessCodePlaceholder(): String {
        if (this.currentLang == "zh") {
            return "输入访问码"
        }
        return "Enter access code"
    }

    func getLoginCheckingMessage(): String {
        if (this.currentLang == "zh") {
            return "正在验证访问码..."
        }
        return "Verifying access code..."
    }

    func getLoggedInStatus(): String {
        if (this.currentLang == "zh") {
            return "已登录"
        }
        return "Signed in"
    }

    func getLoginFailedStatus(): String {
        if (this.currentLang == "zh") {
            return "登录失败"
        }
        return "Sign-in failed"
    }

    func getStatusLabel(): String {
        if (this.statusText.isEmpty()) {
            if (this.currentLang == "zh") {
                return "就绪"
            }
            return "Ready"
        }
        return this.statusText
    }

    func getStatusColor(): UInt32 {
        if (this.isLoggingIn) {
            return 0xFFFFCC00
        }
        if (this.statusText == "登录失败" || this.statusText == "Sign-in failed") {
            return 0xFFC93428
        }
        return 0xFF5A7A5F
    }

    func getLanguageSwitchLabel(): String {
        if (this.currentLang == "zh") {
            return "English"
        }
        return "中文"
    }

    func getLoginFooter(): String {
        if (this.currentLang == "zh") {
            return "© 2026 ImageForge · 图像编辑与生成服务"
        }
        return "© 2026 ImageForge · Image editing & generation"
    }
}
