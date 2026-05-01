package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

@Component
class HistoryPage {
    @Prop var currentLang: String
    @State var historyItems: Array<String> = []
    @State var showDetail: Bool = false
    @State var selectedIndex: Int64 = -1

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
            .padding(left: 16, right: 16, top: 16, bottom: 12)

            if (this.historyItems.size == 0) {
                this.buildEmptyState()
            } else {
                this.buildHistoryList()
            }
        }
        .width(100.percent)
        .height(100.percent)
        .backgroundColor(0xFFF2F2F7)
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
    func buildHistoryList() {
        List() {
            ForEach(this.historyItems, itemGenerator: { item: String, index: Int64 =>
                ListItem() {
                    Row {
                        Column {
                            Text("任务 ${index + 1}")
                                .fontSize(14)
                                .fontWeight(FontWeight.Medium)
                                .fontColor(0xFF1D1D1F)

                            Text(item)
                                .fontSize(12)
                                .fontColor(0xFF86868B)
                                .margin(top: 4)
                                .maxLines(1)
                                .textOverflow(TextOverflow.Ellipsis)
                        }
                        .alignItems(HorizontalAlign.Start)
                        .layoutWeight(1)
                    }
                    .width(100.percent)
                    .padding(16)
                    .backgroundColor(0xFFFFFFFF)
                    .borderRadius(12)
                    .margin(left: 16, right: 16, bottom: 8)
                }
            })
        }
        .width(100.percent)
        .layoutWeight(1)
    }
}
