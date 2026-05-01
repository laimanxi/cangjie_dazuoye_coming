package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

@Entry
@Component
class EntryView {
    @State var currentTabIndex: Int32 = 0
    @State var accessCode: String = ""
    @State var isLoggedIn: Bool = false
    @State var userName: String = "User"
    @State var userPlan: String = "Free"
    @State var credits: Int64 = 0
    @State var currentLang: String = "zh"
    @State var statusText: String = "就绪"

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
        .backgroundColor(0xFFF2F2F7)
    }

    @Builder
    func buildLoginPage() {
        Column {
            Blank().height(120)

            Text("ImageForge")
                .fontSize(32)
                .fontWeight(FontWeight.Bold)
                .fontColor(0xFF1D1D1F)

            Text("图像编辑与生成")
                .fontSize(16)
                .fontColor(0xFF86868B)
                .margin(top: 8, bottom: 60)

            Column {
                Text("需要访问码")
                    .fontSize(20)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(0xFF1D1D1F)
                    .margin(bottom: 8)

                Text("请输入内测访问码以继续")
                    .fontSize(14)
                    .fontColor(0xFF86868B)
                    .margin(bottom: 24)

                TextInput(placeholder: "输入访问码")
                    .height(48)
                    .width(100.percent)
                    .backgroundColor(0xFFFFFFFF)
                    .borderRadius(12)
                    .padding(left: 16, right: 16)
                    .onChange({ value: String =>
                        this.accessCode = value
                    })

                Button("提交")
                    .shape(ButtonType.Capsule)
                    .width(100.percent)
                    .height(48)
                    .backgroundColor(0xFF007AFF)
                    .fontColor(0xFFFFFFFF)
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .margin(top: 16)
                    .onClick({ _: ClickEvent =>
                        this.handleLogin()
                    })
            }
            .width(100.percent)
            .padding(left: 32, right: 32)
            .alignItems(HorizontalAlign.Center)

            Blank()

            Text("© 2026 ImageForge · 图像编辑与生成服务")
                .fontSize(12)
                .fontColor(0xFF86868B)
                .margin(bottom: 40)
        }
        .width(100.percent)
        .height(100.percent)
        .alignItems(HorizontalAlign.Center)
        .backgroundColor(0xFFF2F2F7)
    }

    @Builder
    func buildMainPage() {
        Column {
            this.buildTopBar()

            Tabs(barPosition: BarPosition.End) {
                TabContent() {
                    HomePage(
                        currentLang: this.currentLang,
                        onNavigate: { page: Int32 =>
                            this.currentTabIndex = page
                        }
                    )
                }
                .tabBar("首页")

                TabContent() {
                    EditorPage(
                        accessCode: this.accessCode,
                        currentLang: this.currentLang
                    )
                }
                .tabBar("创作")

                TabContent() {
                    HistoryPage(currentLang: this.currentLang)
                }
                .tabBar("历史")

                TabContent() {
                    SettingsPage(currentLang: this.currentLang)
                }
                .tabBar("设置")
            }
            .barHeight(56)
            .onChange({ index: Int32 =>
                this.currentTabIndex = index
            })
            .layoutWeight(1)
        }
        .width(100.percent)
        .height(100.percent)
    }

    @Builder
    func buildTopBar() {
        Row {
            Text("ImageForge")
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor(0xFF1D1D1F)

            Blank()

            Row {
                Text(this.userName)
                    .fontSize(14)
                    .fontColor(0xFF1D1D1F)
                Text(" · ")
                    .fontSize(14)
                    .fontColor(0xFF86868B)
                Text(this.userPlan)
                    .fontSize(12)
                    .fontColor(0xFF007AFF)
            }

            Row {
                Text("${this.credits}")
                    .fontSize(14)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(0xFF007AFF)
                Text(" 积分")
                    .fontSize(12)
                    .fontColor(0xFF86868B)
            }
            .margin(left: 12)
        }
        .width(100.percent)
        .height(56)
        .padding(left: 16, right: 16)
        .backgroundColor(0xFFFFFFFF)
    }

    func handleLogin() {
        if (this.accessCode.isEmpty()) {
            return
        }
        this.isLoggedIn = true
        this.userName = "Beta User"
        this.userPlan = "内测用户"
        this.credits = 999999
    }
}
