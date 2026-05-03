package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

@Component
class HomePage {
    @Prop var currentLang: String
    @Prop var contentTopInset: Float64
    @Prop var hMarginVp: Float64
    @Prop var bottomBarOverlapVp: Float64
    @State var scrollY: Float64 = 0.0
    var onNavigateTab: (Int32) -> Unit = { _: Int32 => }
    var onOpenEditor: (String, String) -> Unit = { _: String, _: String => }

    func getStartEditLabel(): String {
        if (this.currentLang == "zh") {
            "开始编辑图片"
        } else {
            "Start editing"
        }
    }

    func getStartGenerateLabel(): String {
        if (this.currentLang == "zh") {
            "开始生成图片"
        } else {
            "Start generating"
        }
    }

    func heroTitle(): String {
        "ImageForge"
    }

    func heroSubtitle(): String {
        if (this.currentLang == "zh") {
            "AI 驱动的图片编辑与合成"
        } else {
            "AI image editing & composition"
        }
    }

    func blurMix(a: Float64, b: Float64, lim: Float64): Float64 {
        let r = a / b
        if (r < lim) {
            r
        } else {
            lim
        }
    }

    func build() {
        Scroll() {
            Column {
                Blank().height(6)

                Text(this.heroTitle())
                    .fontSize(30)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(0xFF141820)
                    .margin(bottom: 6)

                Text(this.heroSubtitle())
                    .fontSize(15)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(0xFF5C6670)
                    .lineHeight(22)
                    .margin(bottom: 22)

                this.buildFeatureCards()

                this.buildQuickActions()
            }
            .width(100.percent)
            .padding(
                left: this.hMarginVp,
                right: this.hMarginVp,
                top: this.contentTopInset,
                bottom: this.bottomBarOverlapVp
            )
            .opacity(1.0 - this.blurMix(this.scrollY, 220.0, 0.18))
            .backdropBlur(6.0 + this.blurMix(this.scrollY, 28.0, 12.0))
        }
        .width(100.percent)
        .height(100.percent)
        .scrollBar(BarState.Off)
        .backgroundColor(0xFFF0F3FA)
        .onDidScroll({
            _, yOffset: Float64, _: ScrollState =>
                this.scrollY = yOffset
        })
    }

    @Builder
    func buildFeatureCards() {
        Column {
            Row {
                this.buildGlassCard("风格化修图", "自然语言编辑 · Flux2", {
                    => this.onOpenEditor("edit", "style")
                })
                Blank().width(12)
                this.buildGlassCard("高清增强", "lanczos · 更高清细节", {
                    => this.onOpenEditor("edit", "upscale")
                })
            }
            .width(100.percent)

            Row {
                this.buildGlassCard("背景重绘", "CFG 与步数适配图景", {
                    => this.onOpenEditor("edit", "background")
                })
                Blank().width(12)
                this.buildGlassCard("文生图", "文字描述生成全新图像", {
                    => this.onOpenEditor("generate", "style")
                })
            }
            .width(100.percent)
            .margin(top: 12)
        }
        .width(100.percent)
        .margin(bottom: 28)
    }

    /// 两列等宽、等高卡片
    @Builder
    func buildGlassCard(title: String, desc: String, onTap: () -> Unit) {
        Column {
            Text(title)
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor(0xFF1A2430)
                .margin(bottom: 8)

            Text(desc)
                .fontSize(12)
                .fontColor(0xFF6B7680)
                .maxLines(3)
                .textOverflow(TextOverflow.Ellipsis)
        }
        .layoutWeight(1)
        .height(148)
        .padding(18)
        .justifyContent(FlexAlign.Start)
        .linearGradient(
            direction: GradientDirection.RightBottom,
            colors: [(0xFFECF6FF, 0.0), (0xFFD6E8FF, 0.55), (0xFFC4DDFF, 1.0)]
        )
        .backdropBlur(22.0)
        .borderRadius(20)
        .borderWidth(1)
        .borderColor(0x66FFFFFF)
        .alignItems(HorizontalAlign.Start)
        .clip(true)
        .shadow(radius: 20.0, color: 0x16000055, offsetX: 0.0, offsetY: 8.0)
        .onClick({ _: ClickEvent => onTap() })
    }

    @Builder
    func buildQuickActions() {
        Column {
            Text(if (this.currentLang == "zh") {
                "快速开始"
            } else {
                "Quick start"
            })
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor(0xFF1A2430)
                .margin(bottom: 14)

            Button(this.getStartEditLabel())
                .shape(ButtonType.Capsule)
                .width(100.percent)
                .height(50)
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor(0xFF10305C)
                .linearGradient(
                    direction: GradientDirection.RightBottom,
                    colors: [(0xFFDBEEFF, 0.0), (0xFFB8CEFF, 1.0)]
                )
                .borderWidth(1)
                .borderColor(0x55FFFFFF)
                .shadow(radius: 18.0, color: 0x1800286E, offsetX: 0.0, offsetY: 6.0)
                .margin(bottom: 12)
                .onClick({ _: ClickEvent =>
                    this.onOpenEditor("edit", "style")
                })

            Button(this.getStartGenerateLabel())
                .shape(ButtonType.Capsule)
                .width(100.percent)
                .height(50)
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor(0xFF10305C)
                .linearGradient(
                    direction: GradientDirection.RightBottom,
                    colors: [(0xFFE8F3FF, 0.0), (0xFFC5DBFF, 1.0)]
                )
                .borderWidth(1)
                .borderColor(0x55FFFFFF)
                .shadow(radius: 14.0, color: 0x1200286E, offsetX: 0.0, offsetY: 5.0)
                .onClick({ _: ClickEvent =>
                    this.onOpenEditor("generate", "style")
                })
        }
        .width(100.percent)
        .padding(bottom: 28)
    }
}
