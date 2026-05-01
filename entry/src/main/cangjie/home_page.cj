package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

@Component
class HomePage {
    @Prop var currentLang: String
    var onNavigate: (Int32) -> Unit = { _: Int32 => }

    func build() {
        Scroll() {
            Column {
                Text("ImageForge")
                    .fontSize(28)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(0xFF1D1D1F)
                    .margin(top: 24, bottom: 4)

                Text("AI 驱动的图像编辑与生成")
                    .fontSize(14)
                    .fontColor(0xFF86868B)
                    .margin(bottom: 24)

                this.buildFeatureCards()

                this.buildQuickActions()
            }
            .width(100.percent)
            .padding(left: 16, right: 16)
            .alignItems(HorizontalAlign.Start)
        }
        .width(100.percent)
        .height(100.percent)
        .scrollBar(BarState.Off)
    }

    @Builder
    func buildFeatureCards() {
        Column {
            Row {
                this.buildCard("风格化修图", "自然语言编辑 + Flux2 工作流")
                this.buildCard("高清增强", "lanczos 放大 + 更高像素与步数")
            }
            .width(100.percent)
            .justifyContent(FlexAlign.SpaceBetween)

            Row {
                this.buildCard("背景重绘", "提高 CFG + 中等步数，配合背景提示")
                this.buildCard("文生图", "输入文字描述，生成全新图像")
            }
            .width(100.percent)
            .justifyContent(FlexAlign.SpaceBetween)
            .margin(top: 12)

            Row {
                this.buildCard("历史记录", "本机保存的成功任务，可离线回看")
                this.buildCard("服务设置", "健康检查与版本信息")
            }
            .width(100.percent)
            .justifyContent(FlexAlign.SpaceBetween)
            .margin(top: 12)
        }
        .width(100.percent)
        .margin(bottom: 24)
    }

    @Builder
    func buildCard(title: String, desc: String) {
        Column {
            Text(title)
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor(0xFF1D1D1F)
                .margin(bottom: 6)

            Text(desc)
                .fontSize(12)
                .fontColor(0xFF86868B)
                .maxLines(2)
                .textOverflow(TextOverflow.Ellipsis)
        }
        .width(48.percent)
        .padding(20)
        .backgroundColor(0xFFFFFFFF)
        .borderRadius(16)
        .alignItems(HorizontalAlign.Start)
        .onClick({ _: ClickEvent =>
            if (title == "历史记录") {
                this.onNavigate(2)
            } else if (title == "服务设置") {
                this.onNavigate(3)
            } else {
                this.onNavigate(1)
            }
        })
    }

    @Builder
    func buildQuickActions() {
        Column {
            Text("快速开始")
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor(0xFF1D1D1F)
                .margin(bottom: 12)

            Button("开始编辑图片")
                .shape(ButtonType.Capsule)
                .width(100.percent)
                .height(48)
                .backgroundColor(0xFF007AFF)
                .fontColor(0xFFFFFFFF)
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .margin(bottom: 12)
                .onClick({ _: ClickEvent =>
                    this.onNavigate(1)
                })

            Button("查看历史记录")
                .shape(ButtonType.Capsule)
                .width(100.percent)
                .height(48)
                .backgroundColor(0xFFFFFFFF)
                .fontColor(0xFF007AFF)
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .borderWidth(1)
                .borderColor(0xFFE5E5EA)
                .onClick({ _: ClickEvent =>
                    this.onNavigate(2)
                })
        }
        .width(100.percent)
        .padding(bottom: 24)
    }
}
