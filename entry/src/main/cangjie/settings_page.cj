package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

@Component
class SettingsPage {
    @Prop
    var currentLang: String
    @State
    var healthStatus: String = "—"
    @State
    var versionInfo: String = "—"
    @State
    var isChecking: Bool = false

    func build() {
        Scroll() {
            Column {
                Text("设置")
                    .fontSize(22)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(0xFF1D1D1F)
                    .width(100.percent)
                    .margin(top: 16, bottom: 16)

                this.buildHealthBlock()

                this.buildVersionBlock()

                this.buildArchBlock()

                this.buildDataBlock()
            }.width(100.percent).padding(left: 16, right: 16)
        }.width(100.percent).height(100.percent).scrollBar(BarState.Off).backgroundColor(0xFFF2F2F7)
    }

    @Builder
    func buildHealthBlock() {
        Column {
            Text("连通性").fontSize(17).fontWeight(FontWeight.Bold).fontColor(0xFF1D1D1F).margin(bottom: 8)

            Text("检测 Web 服务与 ComfyUI（服务端转发）。").fontSize(14).fontColor(0xFF86868B).margin(bottom: 12)

            Button(this.getHealthCheckButtonLabel())
                .shape(ButtonType.Capsule)
                .height(40)
                .backgroundColor(0xFFFFFFFF)
                .fontColor(0xFF007AFF)
                .fontSize(14)
                .borderWidth(1)
                .borderColor(0xFFE5E5EA)
                .enabled(!this.isChecking)
                .onClick({
                    _: ClickEvent => this.handleHealthCheck()
                })
                .margin(bottom: 12)

            Text(this.healthStatus)
                .fontSize(13)
                .fontColor(0xFF86868B)
                .width(100.percent)
                .padding(12)
                .backgroundColor(0xFFF2F2F7)
                .borderRadius(8)
        }
            .width(100.percent)
            .padding(20)
            .backgroundColor(0xFFFFFFFF)
            .borderRadius(16)
            .margin(bottom: 12)
            .alignItems(HorizontalAlign.Start)
    }

    @Builder
    func buildVersionBlock() {
        Column {
            Text("版本信息").fontSize(17).fontWeight(FontWeight.Bold).fontColor(0xFF1D1D1F).margin(bottom: 8)

            Text(this.versionInfo)
                .fontSize(13)
                .fontColor(0xFF86868B)
                .width(100.percent)
                .padding(12)
                .backgroundColor(0xFFF2F2F7)
                .borderRadius(8)
        }
            .width(100.percent)
            .padding(20)
            .backgroundColor(0xFFFFFFFF)
            .borderRadius(16)
            .margin(bottom: 12)
            .alignItems(HorizontalAlign.Start)
    }

    @Builder
    func buildArchBlock() {
        Column {
            Text("架构说明").fontSize(17).fontWeight(FontWeight.Bold).fontColor(0xFF1D1D1F).margin(bottom: 8)

            Text("鸿蒙客户端通过 HTTP 请求 Node 服务端；ComfyUI 由服务端连接，与 Web 端对齐同一套 REST/SSE 接口契约。")
                .fontSize(14)
                .fontColor(0xFF86868B)
                .lineHeight(22)
        }
            .width(100.percent)
            .padding(20)
            .backgroundColor(0xFFFFFFFF)
            .borderRadius(16)
            .margin(bottom: 12)
            .alignItems(HorizontalAlign.Start)
    }

    @Builder
    func buildDataBlock() {
        Column {
            Text("本地数据").fontSize(17).fontWeight(FontWeight.Bold).fontColor(0xFF1D1D1F).margin(bottom: 8)

            Text("演示兜底：GPU 不可用时，用历史记录回看已成功输出。")
                .fontSize(14)
                .fontColor(0xFF86868B)
                .margin(bottom: 12)

            Button("清空全部历史")
                .shape(ButtonType.Capsule)
                .height(40)
                .backgroundColor(0xFFFFFFFF)
                .fontColor(0xFFFF3B30)
                .fontSize(14)
                .borderWidth(1)
                .borderColor(0xFFFF3B30)
                .onClick({
                    _: ClickEvent =>
                })
        }
            .width(100.percent)
            .padding(20)
            .backgroundColor(0xFFFFFFFF)
            .borderRadius(16)
            .margin(bottom: 24)
            .alignItems(HorizontalAlign.Start)
    }

    func getHealthCheckButtonLabel(): String {
        if (this.isChecking) {
            return "检查中..."
        } else {
            return "执行健康检查"
        }
    }

    func handleHealthCheck() {
        this.isChecking = true
        this.healthStatus = "正在检查 ${API_BASE_URL} ..."
        this.versionInfo = "正在读取版本信息..."

        apiCheckHealth(
            {
                result: HealthCheckResult =>
                    this.healthStatus = "服务端：${result.serverStatus}\nComfyUI：${result.comfyuiStatus}"
                    this.fetchVersionInfo()
            },
            {
                message: String =>
                    this.healthStatus = "连接失败：${message}"
                    this.fetchVersionInfo()
            }
        )
    }

    func fetchVersionInfo() {
        apiFetchVersion(
            {
                info: VersionInfo =>
                    this.versionInfo = "${info.name} v${info.version}\n角色：${info.role}\nComfyUI：${info.comfyuiUrl}"
                    this.isChecking = false
            },
            {
                message: String =>
                    this.versionInfo = "版本信息获取失败：${message}"
                    this.isChecking = false
            }
        )
    }
}
