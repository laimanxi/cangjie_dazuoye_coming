package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

@Component
class EditorPage {
    @Prop var accessCode: String
    @Prop var currentLang: String
    @State var currentMode: String = "edit"
    @State var editMode: String = "style"
    @State var promptText: String = ""
    @State var negativePrompt: String = ""
    @State var isProcessing: Bool = false
    @State var progress: Int64 = 0
    @State var hasImage: Bool = false
    @State var resultImageUrl: String = ""
    @State var showResult: Bool = false
    @State var genPrompt: String = ""
    @State var genWidth: Int64 = 1024
    @State var genHeight: Int64 = 1024
    @State var genSteps: Int64 = 4
    @State var genCfg: Float64 = 1.0
    var sceneLabels: Array<String> = ["随手自拍", "办公桌", "咖啡桌", "厨房", "卧室", "户外", "奢华", "人像", "自然"]

    func build() {
        Column {
            this.buildModeSwitch()

            Scroll() {
                Column {
                    if (this.currentMode == "edit") {
                        this.buildEditPage()
                    } else {
                        this.buildGeneratePage()
                    }

                    if (this.showResult) {
                        this.buildResultSection()
                    }
                }
                .width(100.percent)
                .padding(left: 16, right: 16)
            }
            .layoutWeight(1)
            .scrollBar(BarState.Off)
        }
        .width(100.percent)
        .height(100.percent)
        .backgroundColor(0xFFF2F2F7)
    }

    @Builder
    func buildModeSwitch() {
        Row {
            this.buildModeButton("编辑图片", "edit")
            this.buildModeButton("生成图片", "generate")
        }
        .width(100.percent)
        .padding(left: 16, right: 16, top: 12, bottom: 12)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(0xFFFFFFFF)
    }

    @Builder
    func buildModeButton(label: String, mode: String) {
        Text(label)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor(if (this.currentMode == mode) { 0xFF007AFF } else { 0xFF86868B })
            .padding(left: 20, right: 20, top: 10, bottom: 10)
            .backgroundColor(if (this.currentMode == mode) { 0xFFFFFFFF } else { 0x00000000 })
            .borderRadius(20)
            .onClick({ _: ClickEvent =>
                this.currentMode = mode
            })
    }

    @Builder
    func buildEditPage() {
        Column {
            this.buildEditModeSelector()

            this.buildEditModeBanner()

            this.buildUploadArea()

            this.buildPresetChips()

            Text("编辑指令")
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor(0xFF1D1D1F)
                .margin(top: 16, bottom: 8)

            TextArea(placeholder: "描述你想如何编辑图片...")
                .height(120)
                .width(100.percent)
                .backgroundColor(0xFFFFFFFF)
                .borderRadius(12)
                .padding(12)
                .fontSize(14)
                .onChange({ value: String =>
                    this.promptText = value
                })

            Text("排除内容（可选）")
                .fontSize(14)
                .fontColor(0xFF86868B)
                .margin(top: 12, bottom: 6)

            TextInput(placeholder: "例如：多余手指、水印、文字")
                .height(44)
                .width(100.percent)
                .backgroundColor(0xFFFFFFFF)
                .borderRadius(12)
                .padding(left: 12, right: 12)
                .fontSize(14)
                .onChange({ value: String =>
                    this.negativePrompt = value
                })

            Text("将作为排除说明附加在提示词后发送给模型。")
                .fontSize(12)
                .fontColor(0xFF86868B)
                .margin(top: 4, bottom: 16)

            Button(this.getEditButtonLabel())
                .shape(ButtonType.Capsule)
                .width(100.percent)
                .height(48)
                .backgroundColor(if (this.isProcessing) { 0xFF86868B } else { 0xFF007AFF })
                .fontColor(0xFFFFFFFF)
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .enabled(!this.isProcessing)
                .onClick({ _: ClickEvent =>
                    this.handleEditImage()
                })

            if (this.isProcessing) {
                this.buildProgressBar()
            }
        }
        .width(100.percent)
    }

    @Builder
    func buildEditModeSelector() {
        Row {
            this.buildEditModeChip("风格化", "style")
            this.buildEditModeChip("高清增强", "upscale")
            this.buildEditModeChip("背景重绘", "background")
        }
        .width(100.percent)
        .margin(top: 12, bottom: 8)
    }

    @Builder
    func buildEditModeChip(label: String, mode: String) {
        Text(label)
            .fontSize(13)
            .fontWeight(FontWeight.Medium)
            .fontColor(if (this.editMode == mode) { 0xFFFFFFFF } else { 0xFF86868B })
            .padding(left: 14, right: 14, top: 8, bottom: 8)
            .backgroundColor(if (this.editMode == mode) { 0xFF007AFF } else { 0xFFFFFFFF })
            .borderRadius(16)
            .borderWidth(1)
            .borderColor(if (this.editMode == mode) { 0xFF007AFF } else { 0xFFE5E5EA })
            .margin(right: 8)
            .onClick({ _: ClickEvent =>
                this.editMode = mode
            })
    }

    @Builder
    func buildEditModeBanner() {
        Text(this.getEditModeBannerText())
            .fontSize(12)
            .fontColor(0xFF86868B)
            .padding(12)
            .width(100.percent)
            .backgroundColor(0xFFFFFFFF)
            .borderRadius(8)
            .borderWidth(1)
            .borderColor(0xFFE5E5EA)
            .margin(bottom: 12)
    }

    @Builder
    func buildUploadArea() {
        Column {
            if (!this.hasImage) {
                Column {
                    Text("+")
                        .fontSize(40)
                        .fontColor(0xFF86868B)
                    Text("点击上传图片")
                        .fontSize(14)
                        .fontColor(0xFF86868B)
                        .margin(top: 8)
                    Text("JPG, PNG, WEBP · 最大 20MB")
                        .fontSize(12)
                        .fontColor(0xFFAEAEB2)
                        .margin(top: 4)
                }
                .width(100.percent)
                .height(200)
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center)
                .backgroundColor(0xFFFFFFFF)
                .borderRadius(16)
                .borderWidth(2)
                .borderColor(0xFFE5E5EA)
                .borderStyle(BorderStyle.Dashed)
                .onClick({ _: ClickEvent =>
                    this.hasImage = true
                })
            } else {
                Column {
                    Text("已选择图片")
                        .fontSize(14)
                        .fontColor(0xFF34C759)
                        .margin(bottom: 8)

                    Button("移除")
                        .shape(ButtonType.Capsule)
                        .height(32)
                        .backgroundColor(0xFFFF3B30)
                        .fontColor(0xFFFFFFFF)
                        .fontSize(13)
                        .onClick({ _: ClickEvent =>
                            this.hasImage = false
                        })
                }
                .width(100.percent)
                .height(200)
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center)
                .backgroundColor(0xFFFFFFFF)
                .borderRadius(16)
            }
        }
    }

    @Builder
    func buildPresetChips() {
        Column {
            Text("预设提示词")
                .fontSize(14)
                .fontColor(0xFF86868B)
                .margin(top: 12, bottom: 8)

            Row {
                this.buildPresetButton("人像精修")
                this.buildPresetButton("复古胶片")
                this.buildPresetButton("证件照清爽")
            }
        }
        .width(100.percent)
        .alignItems(HorizontalAlign.Start)
    }

    @Builder
    func buildPresetButton(label: String) {
        Text(label)
            .fontSize(12)
            .fontColor(0xFF86868B)
            .padding(left: 12, right: 12, top: 6, bottom: 6)
            .backgroundColor(0xFFFFFFFF)
            .borderRadius(14)
            .borderWidth(1)
            .borderColor(0xFFE5E5EA)
            .margin(right: 8)
            .onClick({ _: ClickEvent =>
                if (label == "人像精修") {
                    this.promptText = "人像精修：均匀肤色、自然眼神光、轻微锐化，保持五官与姿态不变。"
                } else if (label == "复古胶片") {
                    this.promptText = "复古胶片感：暖调褪色阴影、细腻颗粒、略降对比度，保持构图不变。"
                } else {
                    this.promptText = "证件照风格：背景简洁中性、面部光线均匀、色彩自然、淡妆感，主体不变。"
                }
            })
    }

    @Builder
    func buildGeneratePage() {
        Column {
            Text("图片描述")
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor(0xFF1D1D1F)
                .margin(top: 12, bottom: 8)

            TextArea(placeholder: "描述你想生成的图片...")
                .height(120)
                .width(100.percent)
                .backgroundColor(0xFFFFFFFF)
                .borderRadius(12)
                .padding(12)
                .fontSize(14)
                .onChange({ value: String =>
                    this.genPrompt = value
                })

            this.buildSceneChips()

            this.buildGenerateParams()

            Button(this.getGenerateButtonLabel())
                .shape(ButtonType.Capsule)
                .width(100.percent)
                .height(48)
                .backgroundColor(if (this.isProcessing) { 0xFF86868B } else { 0xFF007AFF })
                .fontColor(0xFFFFFFFF)
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .margin(top: 16)
                .enabled(!this.isProcessing)
                .onClick({ _: ClickEvent =>
                    this.handleGenerate()
                })

            if (this.isProcessing) {
                this.buildProgressBar()
            }
        }
        .width(100.percent)
    }

    @Builder
    func buildSceneChips() {
        Column {
            Text("场景预设")
                .fontSize(14)
                .fontColor(0xFF86868B)
                .margin(top: 12, bottom: 8)

            Flex(wrap: FlexWrap.Wrap) {
                ForEach(this.sceneLabels, itemGenerator: { scene: String, _: Int64 =>
                    Text(scene)
                        .fontSize(12)
                        .fontColor(0xFF86868B)
                        .padding(left: 12, right: 12, top: 6, bottom: 6)
                        .backgroundColor(0xFFFFFFFF)
                        .borderRadius(14)
                        .borderWidth(1)
                        .borderColor(0xFFE5E5EA)
                        .margin(right: 8, bottom: 8)
                        .onClick({ _: ClickEvent =>
                            this.genPrompt = scene
                        })
                })
            }
        }
        .width(100.percent)
        .alignItems(HorizontalAlign.Start)
    }

    @Builder
    func buildGenerateParams() {
        Column {
            Row {
                Text("宽度")
                    .fontSize(14)
                    .fontColor(0xFF1D1D1F)
                    .width(60)
                TextInput(text: "${this.genWidth}")
                    .height(40)
                    .layoutWeight(1)
                    .backgroundColor(0xFFFFFFFF)
                    .borderRadius(8)
                    .padding(left: 12, right: 12)
                    .fontSize(14)
                    .onChange({ value: String =>
                        this.genWidth = 1024
                    })
            }
            .width(100.percent)
            .margin(top: 12)

            Row {
                Text("高度")
                    .fontSize(14)
                    .fontColor(0xFF1D1D1F)
                    .width(60)
                TextInput(text: "${this.genHeight}")
                    .height(40)
                    .layoutWeight(1)
                    .backgroundColor(0xFFFFFFFF)
                    .borderRadius(8)
                    .padding(left: 12, right: 12)
                    .fontSize(14)
                    .onChange({ value: String =>
                        this.genHeight = 1024
                    })
            }
            .width(100.percent)
            .margin(top: 8)

            Row {
                Text("步数")
                    .fontSize(14)
                    .fontColor(0xFF1D1D1F)
                    .width(60)
                TextInput(text: "${this.genSteps}")
                    .height(40)
                    .layoutWeight(1)
                    .backgroundColor(0xFFFFFFFF)
                    .borderRadius(8)
                    .padding(left: 12, right: 12)
                    .fontSize(14)
                    .onChange({ value: String =>
                        this.genSteps = 4
                    })
            }
            .width(100.percent)
            .margin(top: 8)

            Row {
                Text("CFG")
                    .fontSize(14)
                    .fontColor(0xFF1D1D1F)
                    .width(60)
                TextInput(text: "1.0")
                    .height(40)
                    .layoutWeight(1)
                    .backgroundColor(0xFFFFFFFF)
                    .borderRadius(8)
                    .padding(left: 12, right: 12)
                    .fontSize(14)
                    .onChange({ value: String =>
                        this.genCfg = 1.0
                    })
            }
            .width(100.percent)
            .margin(top: 8)
        }
        .width(100.percent)
    }

    @Builder
    func buildResultSection() {
        Column {
            Text("结果")
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor(0xFF1D1D1F)
                .margin(top: 24, bottom: 12)

            if (!this.resultImageUrl.isEmpty()) {
                Image(this.resultImageUrl)
                    .width(100.percent)
                    .borderRadius(12)
                    .objectFit(ImageFit.Contain)
            }

            Row {
                Button("下载")
                    .shape(ButtonType.Capsule)
                    .height(40)
                    .backgroundColor(0xFF007AFF)
                    .fontColor(0xFFFFFFFF)
                    .fontSize(14)
                    .layoutWeight(1)
                    .margin(right: 8)

                Button("再次生成")
                    .shape(ButtonType.Capsule)
                    .height(40)
                    .backgroundColor(0xFFFFFFFF)
                    .fontColor(0xFF007AFF)
                    .fontSize(14)
                    .borderWidth(1)
                    .borderColor(0xFFE5E5EA)
                    .layoutWeight(1)
                    .onClick({ _: ClickEvent =>
                        this.showResult = false
                        this.resultImageUrl = ""
                    })
            }
            .width(100.percent)
            .margin(top: 16, bottom: 24)
        }
        .width(100.percent)
    }

    @Builder
    func buildProgressBar() {
        Column {
            Progress(value: Float64(this.progress), total: 100.0)
                .width(100.percent)
                .margin(top: 12)

            Text("${this.progress}%")
                .fontSize(14)
                .fontColor(0xFF007AFF)
                .margin(top: 4)
        }
        .width(100.percent)
        .alignItems(HorizontalAlign.Center)
    }

    func getEditModeBannerText(): String {
        if (this.editMode == "style") {
            return "当前：风格化 · 约 1MP、4 步、nearest 缩放 · 模板 img2img_style"
        } else if (this.editMode == "upscale") {
            return "当前：高清增强 · lanczos + 约 2.25MP、12 步 · 模板 image_upscale"
        } else {
            return "当前：背景重绘 · CFG 1.22、8 步 · 模板 background_repaint"
        }
    }

    func getEditButtonLabel(): String {
        if (this.isProcessing) {
            return "处理中..."
        } else {
            return "编辑图片  ~2 积分"
        }
    }

    func getGenerateButtonLabel(): String {
        if (this.isProcessing) {
            return "生成中..."
        } else {
            return "生成图片  ~1 积分"
        }
    }

    func getWorkflowTemplate(): String {
        if (this.editMode == "style") {
            return "img2img_style"
        } else if (this.editMode == "upscale") {
            return "image_upscale"
        } else {
            return "background_repaint"
        }
    }

    func handleEditImage() {
        if (this.promptText.isEmpty()) {
            return
        }
        this.isProcessing = true
        this.progress = 0
        this.simulateProgress()
    }

    func handleGenerate() {
        if (this.genPrompt.isEmpty()) {
            return
        }
        this.isProcessing = true
        this.progress = 0
        this.simulateProgress()
    }

    func simulateProgress() {
        this.progress = 100
        this.isProcessing = false
        this.showResult = true
        this.resultImageUrl = ""
    }
}
