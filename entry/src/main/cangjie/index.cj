package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import ohos.arkui.state_management.*
import std.convert.*

@Entry
@Component
class EntryView {
    @State
    var currentTabIndex: Int32 = 0
    @State
    var editorMainMode: String = "edit"
    @State
    var editorEditWorkflow: String = "style"
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

    func getTopSafeHeight(): Float64 {
        if (!AppStorage.has("topHeight")) {
            return 0.0
        }
        let s = AppStorage.get<String>("topHeight").getOrThrow()
        if (s.isEmpty() || s == "0") {
            return 0.0
        }
        match (this.getUIContext().px2vp(Float64.parse(s).px)) {
            case Some(l) => return l.value
            case None => return 0.0
        }
    }

    func getBottomSafeHeight(): Float64 {
        if (!AppStorage.has("bottomHeight")) {
            return 0.0
        }
        let s = AppStorage.get<String>("bottomHeight").getOrThrow()
        if (s.isEmpty() || s == "0") {
            return 0.0
        }
        match (this.getUIContext().px2vp(Float64.parse(s).px)) {
            case Some(l) => return l.value
            case None => return 0.0
        }
    }

    func syncMainTab(index: Int32): Unit {
        if (index < 0 || index > 3) {
            return
        }
        this.currentTabIndex = index
    }

    func mainSideInsetVp(): Float64 {
        16.0
    }

    /// 主内容区需为顶部悬浮栏让出的垂直空间（vp）
    func mainHeaderReserveVp(): Float64 {
        8.0 + this.getTopSafeHeight() + 52.0
    }

    /// 主导航在主页 Column 底部常驻（非全屏叠层），Scroll 只需文末少量留白，避免最后一项贴边。
    func mainScrollBottomInsetVp(): Float64 {
        24.0
    }

    func getBetaUserLabel(): String {
        if (this.currentLang == "zh") {
            "Beta 用户"
        } else {
            "Beta User"
        }
    }

    func getHomeHeroSubtitle(): String {
        if (this.currentLang == "zh") {
            "AI 驱动的图片编辑与合成"
        } else {
            "AI image editing & composition"
        }
    }

    func getCreditsHint(): String {
        if (this.currentLang == "zh") {
            "积分"
        } else {
            "credits"
        }
    }

    func pickLang(zh: String, en: String): String {
        if (this.currentLang == "zh") {
            zh
        } else {
            en
        }
    }

    func build() {
        Column {
            if (!this.isLoggedIn) {
                this.buildLoginPage()
            } else {
                this.buildMainPage()
            }
        }
            .width(100.percent)
            .height(100.percent)
            .backgroundColor(0xFFEBEFF7)
            .linearGradient(
                direction: GradientDirection.Bottom,
                colors: [(0xFFF0F4FC, 0.0), (0xFFF3F6FB, 0.55), (0xFFF7F8FC, 1.0)]
            )
            .expandSafeArea(types: [SafeAreaType.System], edges: [SafeAreaEdge.Top, SafeAreaEdge.Bottom])
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
                        .backgroundColor(0x99FFFFFF)
                        .backdropBlur(14.0)
                        .borderRadius(14)
                        .borderWidth(1)
                        .borderColor(0x33FFFFFF)
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
                    .backgroundColor(0xB3FFFFFF)
                    .backdropBlur(28.0)
                    .borderRadius(26)
                    .borderWidth(1)
                    .borderColor(0x66FFFFFF)
                    .alignItems(HorizontalAlign.Start)
            }.width(88.percent).alignItems(HorizontalAlign.Center)

            Blank()

            Text(this.getLoginFooter()).fontSize(12).fontColor(0xFF86868B).margin(bottom: 26.0 + this.getBottomSafeHeight())
        }
            .width(100.percent)
            .height(100.percent)
            .padding(left: 16, right: 16)
            .alignItems(HorizontalAlign.Center)
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
                .backgroundColor(0xB3FFFFFF)
                .backdropBlur(18.0)
                .fontColor(0xFF1D1D1F)
                .fontSize(14)
                .borderWidth(1)
                .borderColor(0x59FFFFFF)
                .onClick({
                    _: ClickEvent => this.toggleLanguage()
                })
        }
            .width(100.percent)
            .padding(left: 12, right: 12, top: 8.0 + this.getTopSafeHeight(), bottom: 10)
            .backgroundColor(0xA6FFFFFF)
            .backdropBlur(22.0)
            .borderRadius(topLeft: 0.0.vp, topRight: 0.0.vp, bottomLeft: 24.0.vp, bottomRight: 24.0.vp)
    }

    @Builder
    func buildMainPage() {
        /// 全屏叠层 + 高 zIndex 的底栏在仓颉绑定里会整面截获触摸；底栏改为 Column 第二子节点，位置仍在屏底且主体可点。
        Column {
            Stack(alignContent: Alignment.TopStart) {
                Stack(alignContent: Alignment.TopStart) {
                    if (this.currentTabIndex == 0) {
                        HomePage(
                            currentLang: this.currentLang,
                            contentTopInset: this.mainHeaderReserveVp(),
                            hMarginVp: this.mainSideInsetVp(),
                            bottomBarOverlapVp: this.mainScrollBottomInsetVp(),
                            onNavigateTab: {
                                page: Int32 => this.syncMainTab(page)
                            },
                            onOpenEditor: {
                                mainMode: String, workflow: String =>
                                    this.editorMainMode = mainMode
                                    this.editorEditWorkflow = workflow
                                    this.syncMainTab(1)
                            }
                        )
                } else if (this.currentTabIndex == 1) {
                    EditorPage(
                        accessCode: this.accessCode,
                        currentLang: this.currentLang,
                        editorMainMode: this.editorMainMode,
                        editorEditWorkflow: this.editorEditWorkflow,
                        modeBarTopVp: this.mainHeaderReserveVp() + 4.0,
                        scrollPadTopVp: this.mainHeaderReserveVp() + 78.0,
                        barSideInsetVp: this.mainSideInsetVp(),
                        bottomBarOverlapVp: this.mainScrollBottomInsetVp(),
                        onEditorMainModeChange: {
                            m: String => this.editorMainMode = m
                        },
                        onEditorEditWorkflowChange: {
                            w: String => this.editorEditWorkflow = w
                        },
                        onCreditsChange: {
                            remaining: Int64 => if (remaining >= 0) {
                                this.credits = remaining
                            }
                        }
                    )
                } else if (this.currentTabIndex == 2) {
                    HistoryPage(
                        currentLang: this.currentLang,
                        contentTopInset: this.mainHeaderReserveVp(),
                        bottomBarOverlapVp: this.mainScrollBottomInsetVp()
                    )
                } else {
                    SettingsPage(
                        currentLang: this.currentLang,
                        contentTopInset: this.mainHeaderReserveVp(),
                        bottomBarOverlapVp: this.mainScrollBottomInsetVp()
                    )
                }
            }
                .width(100.percent)
                .height(100.percent)

            Column {
                this.buildTopBar()
            }
                .width(100.percent)
                .padding(left: this.mainSideInsetVp(), right: this.mainSideInsetVp(), top: this.getTopSafeHeight())
                .zIndex(24)
        }
            .layoutWeight(1)
            .width(100.percent)

            Column {
                this.buildMainBottomBar()
            }
                .width(100.percent)
        }
            .width(100.percent)
            .height(100.percent)
            .clip(false)
            .backgroundColor(0xFFEBEFF7)
            .linearGradient(
                direction: GradientDirection.Bottom,
                colors: [(0xFFF0F4FC, 0.0), (0xFFF3F6FB, 0.55), (0xFFF7F8FC, 1.0)]
            )
    }

    /// 底部主导航条：文档中 HdsTabs.barFloatingStyle + systemMaterialEffect 为 ArkTS @kit.UIDesignKit；
    /// 当前仓颉工程依赖树无 kit.UIDesignKit，故用毛玻璃/悬浮边距对齐 HDS 页签观感，避免再用 Tabs 自定义 tabBar 踩布局坑。
    @Builder
    func buildMainBottomBar() {
        Column {
            Row {
                this.buildBottomNavItem(0, "🏠", "首页", "Home")
                this.buildBottomNavItem(1, "✎", "创作", "Create")
                this.buildBottomNavItem(2, "🕘", "历史", "History")
                this.buildBottomNavItem(3, "⚙", "设置", "Settings")
            }
                .width(100.percent)
                .height(62)
                .padding(left: 8, right: 8)
        }
            .linearGradient(
                direction: GradientDirection.Bottom,
                colors: [(0xE8FFFFFF, 0.0), (0xFFD0E8FF, 0.55), (0xFFB8D4FA, 1.0)]
            )
            .margin(
                left: this.mainSideInsetVp(),
                right: this.mainSideInsetVp(),
                bottom: 14.0 + this.getBottomSafeHeight()
            )
            .backdropBlur(40.0)
            .borderRadius(26)
            .borderWidth(1)
            .borderColor(0x80FFFFFF)
            .clip(true)
            .shadow(radius: 36.0, color: 0x30000040, offsetX: 0.0, offsetY: -6.0)
    }

    @Builder
    func buildBottomNavItem(index: Int32, icon: String, labelZh: String, labelEn: String) {
        Stack(alignContent: Alignment.Center) {
            if (this.currentTabIndex == index) {
                Column()
                    .width(78)
                    .height(48)
                    .borderRadius(24)
                    .linearGradient(
                        direction: GradientDirection.RightBottom,
                        colors: [(0xFFEAF4FF, 0.0), (0xFFAACFFF, 0.48), (0xFF7EB6FF, 1.0)]
                    )
                    .borderWidth(1)
                    .borderColor(0x66007AFF)
                    .shadow(radius: 14.0, color: 0x40007AFF, offsetX: 0.0, offsetY: 4.0)
            }

            Column {
                Text(icon)
                    .fontSize(if (index == 1) {
                        19
                    } else {
                        21
                    })
                    .lineHeight(22)
                    .fontWeight(if (this.currentTabIndex == index) {
                        FontWeight.Medium
                    } else {
                        FontWeight.Normal
                    })
                    .fontColor(if (this.currentTabIndex == index) {
                        0xFF007AFF
                    } else {
                        0xFF8E8E93
                    })

                Text(this.pickLang(labelZh, labelEn))
                    .fontSize(11)
                    .lineHeight(14)
                    .fontWeight(if (this.currentTabIndex == index) {
                        FontWeight.Bold
                    } else {
                        FontWeight.Medium
                    })
                    .fontColor(if (this.currentTabIndex == index) {
                        0xFF007AFF
                    } else {
                        0xFF8E8E93
                    })
                    .margin(top: 1)
            }
            .alignItems(HorizontalAlign.Center)
        }
            .layoutWeight(1)
            .height(62)
            .padding(left: 2, right: 2)
            .onClick({ _: ClickEvent => this.syncMainTab(index) })
    }

    @Builder
    func buildTopBar() {
        Row {
            Text(this.getBetaUserLabel())
                .fontSize(22)
                .fontWeight(FontWeight.Bold)
                .fontColor(0xFF111111)
                .maxLines(1)
                .textOverflow(TextOverflow.Ellipsis)

            Blank()

            Row {
                Text("${this.credits}")
                    .fontSize(14)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(0xFF0F2A4A)
                    .margin(right: 4)
                Text(this.getCreditsHint())
                    .fontSize(12)
                    .fontColor(0xFF3D5A7A)
            }
                .padding(left: 14, right: 14, top: 9, bottom: 9)
                .linearGradient(
                    direction: GradientDirection.RightBottom,
                    colors: [(0xE8FFFFFF, 0.0), (0xFFD0E6FA, 1.0)]
                )
                .backdropBlur(18.0)
                .borderRadius(20)
                .borderWidth(1)
                .borderColor(0x66FFFFFF)
                .shadow(radius: 14.0, color: 0x14000050, offsetX: 0.0, offsetY: 4.0)

            Text(this.getLanguageSwitchLabel())
                .fontSize(13)
                .fontWeight(FontWeight.Medium)
                .fontColor(0xFF0F2A4A)
                .padding(left: 14, right: 14, top: 9, bottom: 9)
                .margin(left: 10)
                .linearGradient(
                    direction: GradientDirection.RightBottom,
                    colors: [(0xE8FFFFFF, 0.0), (0xFFD0E6FA, 1.0)]
                )
                .backdropBlur(18.0)
                .borderRadius(20)
                .borderWidth(1)
                .borderColor(0x66FFFFFF)
                .shadow(radius: 14.0, color: 0x14000050, offsetX: 0.0, offsetY: 4.0)
                .onClick({ _: ClickEvent => this.toggleLanguage() })
        }
            .width(100.percent)
            .padding(left: 4, right: 4, top: 10, bottom: 12)
            .linearGradient(
                direction: GradientDirection.Bottom,
                colors: [(0xEEFFFFFF, 0.0), (0xFFD8E8F6, 1.0)]
            )
            .backdropBlur(32.0)
            .borderRadius(22)
            .borderWidth(1)
            .borderColor(0x7AFFFFFF)
            .shadow(radius: 22.0, color: 0x18000030, offsetX: 0.0, offsetY: 8.0)
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
