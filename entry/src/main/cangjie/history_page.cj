package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import std.regex.*

@Component
class HistoryPage {
    @Prop var currentLang: String
    @Prop var contentTopInset: Float64
    @Prop var bottomBarOverlapVp: Float64
    @StorageProp["imageForgeHistoryLines"]
    let historyBlob: String = ""
    @State var showDetail: Bool = false
    @State var selectedIndex: Int64 = -1

    func historyLines(): Array<String> {
        if (this.historyBlob.isEmpty()) {
            return []
        }
        return Regex("\n").split(this.historyBlob)
    }

    func build() {
        Column {
            Row {
                Text("历史记录")
                    .fontSize(22)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(0xFF1D1D1F)

                Blank()

                Text("仅保存在本设备")
                    .fontSize(12)
                    .fontColor(0xFF86868B)
            }
            .width(100.percent)
            .padding(top: 16, bottom: 12)

            if (this.historyLines().size == 0) {
                this.buildEmptyState()
            } else {
                this.buildHistoryList(this.historyLines())
            }
        }
        .width(100.percent)
        .height(100.percent)
        .padding(
            left: 16,
            right: 16,
            top: this.contentTopInset,
            bottom: this.bottomBarOverlapVp
        )
        .backgroundColor(0xFFF0F3FA)
    }

    @Builder
    func buildEmptyState() {
        Column {
            Blank().height(80)

            Text("暂无已完成任务")
                .fontSize(16)
                .fontColor(0xFF86868B)

            Text("完成图片编辑或生成后，结果会自动保存在此处")
                .fontSize(13)
                .fontColor(0xFFAEAEB2)
                .margin(top: 8)
                .textAlign(TextAlign.Center)
        }
        .width(100.percent)
        .alignItems(HorizontalAlign.Center)
        .layoutWeight(1)
    }

    @Builder
    func buildHistoryList(historyItems: Array<String>) {
        List() {
            ForEach(historyItems, itemGenerator: { item: String, index: Int64 =>
                ListItem() {
                    Row {
                        Column {
                            Text("任务 ${index + 1}")
                                .fontSize(14)
                                .fontWeight(FontWeight.Medium)
                                .fontColor(0xFF1D1D1F)
                                .width(100.percent)

                            Text(item)
                                .fontSize(12)
                                .fontColor(0xFF86868B)
                                .margin(top: 4)
                                .maxLines(3)
                                .textOverflow(TextOverflow.Ellipsis)
                                .width(100.percent)
                        }
                        .alignItems(HorizontalAlign.Start)
                        .layoutWeight(1)
                    }
                    .width(100.percent)
                    .padding(16)
                    .linearGradient(
                        direction: GradientDirection.Right,
                        colors: [(0xFFF2F6FC, 0.0), (0xFFE8EEF8, 1.0)]
                    )
                    .backdropBlur(18.0)
                    .borderRadius(14)
                    .borderWidth(1)
                    .borderColor(0x5EFFFFFF)
                    .margin(bottom: 8)
                    .shadow(radius: 10.0, color: 0x10000000, offsetX: 0.0, offsetY: 4.0)
                }
            })
        }
        .width(100.percent)
        .layoutWeight(1)
    }
}
