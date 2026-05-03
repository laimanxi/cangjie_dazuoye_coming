package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import std.convert.*
import std.fs.*

@Component
class EditorPage {
    @Prop
    var accessCode: String
    @Prop
    var currentLang: String
    @Prop
    var editorMainMode: String
    @Prop
    var editorEditWorkflow: String
    @Prop
    var modeBarTopVp: Float64
    @Prop
    var scrollPadTopVp: Float64
    @Prop
    var barSideInsetVp: Float64
    @Prop
    var bottomBarOverlapVp: Float64
    var onEditorMainModeChange: (String) -> Unit = { _: String => }
    var onEditorEditWorkflowChange: (String) -> Unit = { _: String => }
    var onCreditsChange: (Int64) -> Unit = { _: Int64 => }
    @State
    var promptText: String = ""
    @State
    var negativePrompt: String = ""
    @State
    var isProcessing: Bool = false
    @State
    var progress: Int64 = 0
    @State
    var hasImage: Bool = false
    @State
    var sourceImageUrl: String = ""
    @State
    var resultImageUrl: String = ""
    /// 远端结果地址（HTTPS），用于下载与历史；预览优先使用落盘后的 file://（参考 cangjie_dazuoye_coming-main 的稳定做法）
    @State
    var resultRemoteUrl: String = ""
    @State
    var genPreviewSeq: Int64 = 0
    @State
    var showResult: Bool = false
    @State
    var genPrompt: String = ""
    @State
    var genWidth: Int64 = 1024
    @State
    var genHeight: Int64 = 1024
    @State
    var genSteps: Int64 = 4
    @State
    var genCfg: Float64 = 1.0
    @State
    var taskMessage: String = ""
    @State
    var isTaskError: Bool = false
    @State
    var pasteImageUrl: String = ""
    @State
    var editorScrollY: Float64 = 0.0
    var sceneLabels: Array<String> = ["随手自拍", "办公桌", "咖啡桌", "厨房", "卧室", "户外", "奢华", "人像", "自然"]

    func edFade(v: Float64, d: Float64, cap: Float64): Float64 {
        let r = v / d
        if (r < cap) {
            r
        } else {
            cap
        }
    }

    func build() {
        Stack(alignContent: Alignment.TopStart) {
            Scroll() {
                Column {
                    if (!this.taskMessage.isEmpty()) {
                        this.buildTaskMessage()
                    }

                    if (this.editorMainMode == "edit") {
                        this.buildEditPage()
                    } else {
                        this.buildGeneratePage()
                    }

                    if (this.showResult) {
                        this.buildResultSection()
                    }
                }
                    .width(100.percent)
                    .padding(
                        left: 16,
                        right: 16,
                        top: this.scrollPadTopVp,
                        bottom: this.bottomBarOverlapVp
                    )
                    .opacity(1.0 - this.edFade(this.editorScrollY, 200.0, 0.16))
                    .backdropBlur(5.0 + this.edFade(this.editorScrollY, 26.0, 14.0))
            }
                .width(100.percent)
                .height(100.percent)
                .scrollBar(BarState.Off)
                .backgroundColor(0xFFF0F3FA)
                .onDidScroll({
                    _, y: Float64, _: ScrollState =>
                        this.editorScrollY = y
                })

            Column {
                this.buildFloatingModeBar()
            }
                .width(100.percent)
                .padding(left: this.barSideInsetVp, right: this.barSideInsetVp)
                .margin(top: this.modeBarTopVp)
                .zIndex(16)
        }
            .width(100.percent)
            .height(100.percent)
            .backgroundColor(0xFFF0F3FA)
    }

    @Builder
    func buildFloatingModeBar() {
        Row {
            this.buildMainModeButton("编辑图片", "edit")
            Blank().width(10)
            this.buildMainModeButton("生成图片", "generate")
        }
            .width(100.percent)
            .padding(left: 10, right: 10, top: 10, bottom: 10)
            .justifyContent(FlexAlign.SpaceBetween)
            .linearGradient(
                direction: GradientDirection.Bottom,
                colors: [(0xEEFFFFFF, 0.0), (0xFFDCE8F5, 1.0)]
            )
            .backdropBlur(24.0)
            .borderRadius(20)
            .borderWidth(1)
            .borderColor(0x6EFFFFFF)
            .shadow(radius: 22.0, color: 0x19000040, offsetX: 0.0, offsetY: 6.0)
    }

    @Builder
    func buildMainModeButton(label: String, mode: String) {
        Button(label)
            .layoutWeight(1)
            .height(44)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor(if (this.editorMainMode == mode) {
                0xFF007AFF
            } else {
                0xFF63636B
            })
            .backgroundColor(if (this.editorMainMode == mode) {
                0xFFFFFFFF
            } else {
                0x00FFFFFF
            })
            .borderRadius(14)
            .borderWidth(if (this.editorMainMode == mode) {
                2
            } else {
                1
            })
            .borderColor(if (this.editorMainMode == mode) {
                0x66007AFF
            } else {
                0x44FFFFFF
            })
            .shadow(
                radius: if (this.editorMainMode == mode) {
                    14.0
                } else {
                    0.0
                },
                color: 0x28007AFF,
                offsetX: 0.0,
                offsetY: 4.0
            )
            .onClick({ _: ClickEvent => this.applyMainModeTap(mode) })
    }

    @Builder
    func buildTaskMessage() {
        Text(this.taskMessage)
            .fontSize(13)
            .fontColor(if (this.isTaskError) {
                0xFFFF3B30
            } else {
                0xFF007AFF
            })
            .width(100.percent)
            .padding(12)
            .backgroundColor(0xE6FFFFFF)
            .backdropBlur(16.0)
            .borderRadius(10)
            .borderWidth(1)
            .borderColor(0x59FFFFFF)
            .margin(top: 12, bottom: 4)
    }

    @Builder
    func buildEditPage() {
        Column {
            this.buildEditModeSelector()

            this.buildEditModeBanner()

            this.buildUploadArea()

            this.buildPresetChips()

            Text("编辑指令").fontSize(16).fontWeight(FontWeight.Medium).fontColor(0xFF1D1D1F).margin(top: 16, bottom: 8)

            TextArea(placeholder: "描述你想如何编辑图片...", text: "${this.promptText}")
                .height(120)
                .width(100.percent)
                .backgroundColor(0xE6FFFFFF)
                .backdropBlur(14.0)
                .borderRadius(12)
                .borderWidth(1)
                .borderColor(0x59FFFFFF)
                .padding(12)
                .fontSize(14)
                .onChange({
                    value: String => this.promptText = value
                })

            Text("排除内容（可选）").fontSize(14).fontColor(0xFF86868B).margin(top: 12, bottom: 6)

            TextInput(placeholder: "例如：多余手指、水印、文字")
                .height(44)
                .width(100.percent)
                .backgroundColor(0xE6FFFFFF)
                .backdropBlur(14.0)
                .borderRadius(12)
                .borderWidth(1)
                .borderColor(0x59FFFFFF)
                .padding(left: 12, right: 12)
                .fontSize(14)
                .onChange({
                    value: String => this.negativePrompt = value
                })

            Text("将作为排除说明附加在提示词后发送给模型。")
                .fontSize(12)
                .fontColor(0xFF86868B)
                .margin(top: 4, bottom: 16)

            if (this.isProcessing) {
                Button(this.getEditButtonLabel())
                    .shape(ButtonType.Capsule)
                    .width(100.percent)
                    .height(48)
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .enabled(false)
                    .fontColor(0x99FFFFFF)
                    .backgroundColor(0xFF86868B)
                    .onClick({
                        _: ClickEvent => this.handleEditImage()
                    })
            } else {
                Button(this.getEditButtonLabel())
                    .shape(ButtonType.Capsule)
                    .width(100.percent)
                    .height(48)
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(0xFF10305C)
                    .linearGradient(
                        direction: GradientDirection.RightBottom,
                        colors: [(0xFFDBEEFF, 0.0), (0xFFB8CEFF, 1.0)]
                    )
                    .borderWidth(1)
                    .borderColor(0x55FFFFFF)
                    .onClick({
                        _: ClickEvent => this.handleEditImage()
                    })
            }

            if (this.isProcessing) {
                this.buildProgressBar()
            }
        }.width(100.percent)
    }

    @Builder
    func buildEditModeSelector() {
        Row {
            this.buildEditModeChip("风格化", "style")
            this.buildEditModeChip("高清增强", "upscale")
            this.buildEditModeChip("背景重绘", "background")
        }.width(100.percent).margin(top: 12, bottom: 8)
    }

    @Builder
    func buildEditModeChip(label: String, mode: String) {
        Button(label)
            .height(36)
            .fontSize(13)
            .fontWeight(FontWeight.Medium)
            .fontColor(if (this.editorEditWorkflow == mode) {
                0xFFFFFFFF
            } else {
                0xFF63636B
            })
            .backgroundColor(if (this.editorEditWorkflow == mode) {
                0xFF007AFF
            } else {
                0xE8FFFFFF
            })
            .borderRadius(16)
            .borderWidth(1)
            .borderColor(if (this.editorEditWorkflow == mode) {
                0xFF0A84FF
            } else {
                0x66FFFFFF
            })
            .shadow(
                radius: if (this.editorEditWorkflow == mode) {
                    10.0
                } else {
                    0.0
                },
                color: 0x22007AFF,
                offsetX: 0.0,
                offsetY: 3.0
            )
            .margin(right: 8)
            .onClick({ _: ClickEvent => this.applyEditWorkflowTap(mode) })
    }

    @Builder
    func buildEditModeBanner() {
        Text(this.getEditModeBannerText())
            .fontSize(12)
            .fontColor(0xFF86868B)
            .padding(12)
            .width(100.percent)
            .backgroundColor(0xE6FFFFFF)
            .backdropBlur(14.0)
            .borderRadius(8)
            .borderWidth(1)
            .borderColor(0x59FFFFFF)
            .margin(bottom: 12)
    }

    @Builder
    func buildUploadArea() {
        Column {
            if (!this.hasImage) {
                Column {
                    Button("加载演示图片（需网络）")
                        .height(44)
                        .fontSize(14)
                        .fontColor(0xFF10305C)
                        .linearGradient(
                            direction: GradientDirection.Right,
                            colors: [(0xFFE3F0FF, 0.0), (0xFFC7DEFF, 1.0)]
                        )
                        .borderRadius(12)
                        .borderWidth(1)
                        .borderColor(0x55FFFFFF)
                        .onClick({ _: ClickEvent => this.loadDemoEditImage() })

                    Text("或粘贴图片 URL").fontSize(12).fontColor(0xFF86868B).margin(top: 12, bottom: 6)

                    TextInput(placeholder: "https://…", text: "${this.pasteImageUrl}")
                        .height(44)
                        .width(100.percent)
                        .backgroundColor(0xE8FFFFFF)
                        .borderRadius(12)
                        .borderWidth(1)
                        .borderColor(0x55FFFFFF)
                        .padding(left: 12, right: 12)
                        .fontSize(14)
                        .onChange({
                            value: String => this.pasteImageUrl = value
                        })

                    Button("加载此链接")
                        .height(40)
                        .width(100.percent)
                        .fontSize(14)
                        .fontColor(0xFF10305C)
                        .margin(top: 8)
                        .linearGradient(
                            direction: GradientDirection.Right,
                            colors: [(0xFFEAF4FF, 0.0), (0xFFD0E4FF, 1.0)]
                        )
                        .borderRadius(12)
                        .borderWidth(1)
                        .borderColor(0x55FFFFFF)
                        .onClick({ _: ClickEvent => this.applyPastedImageUrl() })
                }
                    .width(100.percent)
                    .padding(16)
                    .linearGradient(
                        direction: GradientDirection.Bottom,
                        colors: [(0xFFF4FAFF, 0.0), (0xFFE8F0FC, 1.0)]
                    )
                    .backdropBlur(18.0)
                    .borderRadius(16)
                    .borderWidth(2)
                    .borderColor(0x66FFFFFF)
                    .borderStyle(BorderStyle.Dashed)
                    .alignItems(HorizontalAlign.Center)
            } else {
                Column {
                    if (!this.sourceImageUrl.isEmpty()) {
                        Image(this.sourceImageUrl)
                            .width(100.percent)
                            .height(140)
                            .borderRadius(12)
                            .objectFit(ImageFit.Cover)
                    }
                    Text("已选择图片").fontSize(14).fontColor(0xFF34C759).margin(top: 8, bottom: 8)

                    Button("移除")
                        .shape(ButtonType.Capsule)
                        .height(32)
                        .backgroundColor(0xFFFF3B30)
                        .fontColor(0xFFFFFFFF)
                        .fontSize(13)
                        .onClick({
                            _: ClickEvent =>
                                this.clearLoadedImage()
                                this.pasteImageUrl = ""
                        })
                }
                    .width(100.percent)
                    .padding(12)
                    .justifyContent(FlexAlign.Center)
                    .alignItems(HorizontalAlign.Center)
                    .linearGradient(
                        direction: GradientDirection.Right,
                        colors: [(0xFFFFFFFF, 0.0), (0xFFEEF4FC, 1.0)]
                    )
                    .backdropBlur(18.0)
                    .borderRadius(16)
                    .borderWidth(1)
                    .borderColor(0x62FFFFFF)
            }
        }
    }

    @Builder
    func buildPresetChips() {
        Column {
            Text("预设提示词").fontSize(14).fontColor(0xFF86868B).margin(top: 12, bottom: 8)

            Row {
                this.buildPresetButton("人像精修")
                this.buildPresetButton("复古胶片")
                this.buildPresetButton("证件照清爽")
            }
        }.width(100.percent).alignItems(HorizontalAlign.Start)
    }

    @Builder
    func buildPresetButton(label: String) {
        Button(label)
            .height(34)
            .fontSize(12)
            .fontColor(0xFF007AFF)
            .backgroundColor(0xEAFFFFFF)
            .borderRadius(14)
            .borderWidth(1)
            .borderColor(0x5EFFFFFF)
            .margin(right: 8)
            .shadow(radius: 8.0, color: 0x10007AFF, offsetX: 0.0, offsetY: 2.0)
            .onClick({ _: ClickEvent => this.applyPresetLabel(label) })
    }

    @Builder
    func buildGeneratePage() {
        Column {
            Text("图片描述").fontSize(16).fontWeight(FontWeight.Medium).fontColor(0xFF1D1D1F).margin(top: 12, bottom: 8)

            TextArea(placeholder: "描述你想生成的图片...", text: "${this.genPrompt}")
                .height(120)
                .width(100.percent)
                .backgroundColor(0xE6FFFFFF)
                .backdropBlur(14.0)
                .borderRadius(12)
                .borderWidth(1)
                .borderColor(0x59FFFFFF)
                .padding(12)
                .fontSize(14)
                .onChange({
                    value: String => this.genPrompt = value
                })

            this.buildSceneChips()

            this.buildGenerateParams()

            Button(this.getGenerateButtonLabel())
                .shape(ButtonType.Capsule)
                .width(100.percent)
                .height(48)
                .backgroundColor(if (this.isProcessing) {
                    0xFF86868B
                } else {
                    0xFF007AFF
                })
                .fontColor(0xFFFFFFFF)
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .margin(top: 16)
                .enabled(!this.isProcessing)
                .onClick({
                    _: ClickEvent => this.handleGenerate()
                })

            if (this.isProcessing) {
                this.buildProgressBar()
            }
        }.width(100.percent)
    }

    @Builder
    func buildSceneChips() {
        Column {
            Text("场景预设").fontSize(14).fontColor(0xFF86868B).margin(top: 12, bottom: 8)

            Flex(wrap: FlexWrap.Wrap) {
                ForEach(this.sceneLabels, itemGenerator: {
                    scene: String, _: Int64 =>
                        Button(scene)
                            .height(34)
                            .fontSize(12)
                            .fontColor(0xFF2C4A7C)
                            .backgroundColor(0xE6F0FFFF)
                            .borderRadius(14)
                            .borderWidth(1)
                            .borderColor(0x55A8C7FF)
                            .margin(right: 8, bottom: 8)
                            .shadow(radius: 6.0, color: 0x0C004488, offsetX: 0.0, offsetY: 2.0)
                            .onClick({ _: ClickEvent => this.applyScenePrompt(scene) })
                })
            }
        }.width(100.percent).alignItems(HorizontalAlign.Start)
    }

    @Builder
    func buildGenerateParams() {
        Column {
            Row {
                Text("宽度").fontSize(14).fontColor(0xFF1D1D1F).width(60)
                TextInput(text: "${this.genWidth}")
                    .height(40)
                    .layoutWeight(1)
                    .backgroundColor(0xE6FFFFFF)
                    .backdropBlur(10.0)
                    .borderRadius(8)
                    .borderWidth(1)
                    .borderColor(0x4DFFFFFF)
                    .padding(left: 12, right: 12)
                    .fontSize(14)
                    .onChange({
                        value: String => if (let Some(v) <- Int64.tryParse(value.trimAscii()) && v > 0) {
                            this.genWidth = v
                        }
                    })
            }.width(100.percent).margin(top: 12)

            Row {
                Text("高度").fontSize(14).fontColor(0xFF1D1D1F).width(60)
                TextInput(text: "${this.genHeight}")
                    .height(40)
                    .layoutWeight(1)
                    .backgroundColor(0xE6FFFFFF)
                    .backdropBlur(10.0)
                    .borderRadius(8)
                    .borderWidth(1)
                    .borderColor(0x4DFFFFFF)
                    .padding(left: 12, right: 12)
                    .fontSize(14)
                    .onChange({
                        value: String => if (let Some(v) <- Int64.tryParse(value.trimAscii()) && v > 0) {
                            this.genHeight = v
                        }
                    })
            }.width(100.percent).margin(top: 8)

            Row {
                Text("步数").fontSize(14).fontColor(0xFF1D1D1F).width(60)
                TextInput(text: "${this.genSteps}")
                    .height(40)
                    .layoutWeight(1)
                    .backgroundColor(0xE6FFFFFF)
                    .backdropBlur(10.0)
                    .borderRadius(8)
                    .borderWidth(1)
                    .borderColor(0x4DFFFFFF)
                    .padding(left: 12, right: 12)
                    .fontSize(14)
                    .onChange({
                        value: String => if (let Some(v) <- Int64.tryParse(value.trimAscii()) && v > 0) {
                            this.genSteps = v
                        }
                    })
            }.width(100.percent).margin(top: 8)

            Row {
                Text("CFG").fontSize(14).fontColor(0xFF1D1D1F).width(60)
                TextInput(text: "${this.genCfg}")
                    .height(40)
                    .layoutWeight(1)
                    .backgroundColor(0xE6FFFFFF)
                    .backdropBlur(10.0)
                    .borderRadius(8)
                    .borderWidth(1)
                    .borderColor(0x4DFFFFFF)
                    .padding(left: 12, right: 12)
                    .fontSize(14)
                    .onChange({
                        value: String => if (let Some(v) <- Float64.tryParse(value.trimAscii()) && v > 0.0) {
                            this.genCfg = v
                        }
                    })
            }.width(100.percent).margin(top: 8)
        }.width(100.percent)
    }

    @Builder
    func buildResultSection() {
        Column {
            Text("结果")
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor(0xFF1D1D1F)
                .width(100.percent)
                .textAlign(TextAlign.Center)
                .margin(top: 24, bottom: 12)

            if (!this.resultImageUrl.isEmpty()) {
                Column {
                    Image(this.resultImageUrl)
                        .width(100.percent)
                        .height(440)
                        .borderRadius(16)
                        .objectFit(ImageFit.Contain)
                        .interpolation(ImageInterpolation.High)
                }
                    .width(100.percent)
                    .padding(10)
                    .backgroundColor(0xFFFFFFFF)
                    .borderRadius(18)
                    .borderWidth(1)
                    .borderColor(0xFFE5E5EA)
                    .shadow(radius: 16.0, color: 0x14000000, offsetX: 0.0, offsetY: 6.0)
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
                    .onClick({ _: ClickEvent => this.handleDownloadResult() })

                Button("再次生成")
                    .shape(ButtonType.Capsule)
                    .height(40)
                    .backgroundColor(0xE6FFFFFF)
                    .backdropBlur(14.0)
                    .fontColor(0xFF007AFF)
                    .fontSize(14)
                    .borderWidth(1)
                    .borderColor(0x66FFFFFF)
                    .layoutWeight(1)
                    .onClick({ _: ClickEvent => this.resetGenerateResult() })
            }.width(100.percent).margin(top: 16, bottom: 24)
        }.width(100.percent)
    }

    @Builder
    func buildProgressBar() {
        Column {
            Progress(value: Float64(this.progress), total: 100.0).width(100.percent).margin(top: 12)

            Text("${this.progress}%").fontSize(14).fontColor(0xFF007AFF).margin(top: 4)
        }.width(100.percent).alignItems(HorizontalAlign.Center)
    }

    func applyMainModeTap(mode: String): Unit {
        this.onEditorMainModeChange(mode)
        this.taskMessage = ""
        this.isTaskError = false
    }

    func applyEditWorkflowTap(mode: String): Unit {
        this.onEditorEditWorkflowChange(mode)
        this.taskMessage = ""
    }

    func loadDemoEditImage(): Unit {
        this.sourceImageUrl = IMAGE_FORGE_DEMO_EDIT_URL
        this.hasImage = true
        this.taskMessage = ""
    }

    func clearLoadedImage(): Unit {
        this.hasImage = false
        this.sourceImageUrl = ""
    }

    func applyScenePrompt(scene: String): Unit {
        this.genPrompt = scene
        this.taskMessage = ""
    }

    func resetGenerateResult(): Unit {
        this.showResult = false
        this.resultImageUrl = ""
        this.resultRemoteUrl = ""
    }

    func forgeDisplayUri(filesPath: String): String {
        "file://${filesPath}"
    }

    func stripFileUriPath(uri: String): String {
        if (uri.startsWith("file://")) {
            uri[7..uri.size]
        } else {
            uri
        }
    }

    func primaryResultRemote(r: ImageTaskResult): String {
        if (!r.imageUrl.isEmpty()) {
            r.imageUrl
        } else {
            r.thumbnailUrl
        }
    }

    func historyCardTitleGenerate(): String {
        if (this.currentLang == "zh") {
            return "生成图片"
        } else {
            return "Generated image"
        }
    }

    func historyCardTitleEdit(): String {
        if (this.currentLang == "zh") {
            return "编辑图片"
        } else {
            return "Edited image"
        }
    }

    func applyGenerateRemoteFallback(r: ImageTaskResult): Unit {
        let remote = this.primaryResultRemote(r)
        this.resultRemoteUrl = remote
        this.progress = 100
        this.isProcessing = false
        this.showResult = true
        this.resultImageUrl = remote
        this.taskMessage = "生成完成"
        this.isTaskError = false
        this.onCreditsChange(r.creditsRemaining)
        imageForgeHistoryAppendRecord(this.historyCardTitleGenerate(), this.genPrompt, remote)
    }

    func finalizeGeneratePreview(r: ImageTaskResult, remote: String): Unit {
        this.genPreviewSeq += 1
        let fname = "ImageForge_gen_${this.genPreviewSeq}.png"
        this.taskMessage = "正在载入预览…"
        apiDownloadImageBytes(
            remote,
            {
                bytes: Array<Byte> =>
                    if (bytes.size == 0) {
                        this.applyGenerateRemoteFallback(r)
                        return
                    }
                    match (forgeTrySaveImageBytes(bytes, fname)) {
                        case Some(path) =>
                            this.progress = 100
                            this.isProcessing = false
                            this.showResult = true
                            this.resultImageUrl = this.forgeDisplayUri(path)
                            this.taskMessage = "生成完成"
                            this.isTaskError = false
                            this.onCreditsChange(r.creditsRemaining)
                            imageForgeHistoryAppendRecord(
                                this.historyCardTitleGenerate(), this.genPrompt, this.resultRemoteUrl)
                        case None =>
                            this.applyGenerateRemoteFallback(r)
                    }
            },
            {
                _: String =>
                    this.applyGenerateRemoteFallback(r)
            }
        )
    }

    func applyPresetLabel(label: String): Unit {
        if (label == "人像精修") {
            this.promptText = "人像精修：均匀肤色、自然眼神光、轻微锐化，保持五官与姿态不变。"
        } else if (label == "复古胶片") {
            this.promptText = "复古胶片感：暖调褪色阴影、细腻颗粒、略降对比度，保持构图不变。"
        } else {
            this.promptText = "证件照风格：背景简洁中性、面部光线均匀、色彩自然、淡妆感，主体不变。"
        }
        this.taskMessage = ""
    }

    func getEditModeBannerText(): String {
        if (this.editorEditWorkflow == "style") {
            return "当前：风格化 · 约 1MP、4 步、nearest 缩放 · 模板 img2img_style"
        } else if (this.editorEditWorkflow == "upscale") {
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
        if (this.editorEditWorkflow == "style") {
            return "img2img_style"
        } else if (this.editorEditWorkflow == "upscale") {
            return "image_upscale"
        } else {
            return "background_repaint"
        }
    }

    func composeEditPrompt(): String {
        var p: String = this.promptText.trimAscii()
        let neg: String = this.negativePrompt.trimAscii()
        if (!neg.isEmpty()) {
            p = p + "（排除：" + neg + "）"
        }
        return p
    }

    func applyPastedImageUrl(): Unit {
        let u: String = this.pasteImageUrl.trimAscii()
        if (u.isEmpty()) {
            this.taskMessage = "请先输入图片链接"
            this.isTaskError = true
            return
        }
        if (!u.startsWith("http://") && !u.startsWith("https://")) {
            this.taskMessage = "链接需以 http:// 或 https:// 开头"
            this.isTaskError = true
            return
        }
        this.sourceImageUrl = u
        this.hasImage = true
        this.taskMessage = ""
        this.isTaskError = false
    }

    func handleEditImage() {
        let fullPrompt: String = this.composeEditPrompt()
        if (fullPrompt.isEmpty()) {
            this.taskMessage = "请输入编辑指令"
            this.isTaskError = true
            return
        }
        if (!this.hasImage || this.sourceImageUrl.isEmpty()) {
            this.taskMessage = "请先加载演示图或输入有效图片 URL"
            this.isTaskError = true
            return
        }
        if (this.accessCode.isEmpty()) {
            this.taskMessage = "访问码为空，请重新登录"
            this.isTaskError = true
            return
        }

        this.isProcessing = true
        this.progress = 5
        this.showResult = false
        this.resultImageUrl = ""
        this.resultRemoteUrl = ""
        this.taskMessage = "正在下载原图…"
        this.isTaskError = false

        let dlUrl: String = this.sourceImageUrl
        let tpl: String = this.getWorkflowTemplate()
        let code: String = this.accessCode

        apiDownloadImageBytes(
            dlUrl,
            {
                bytes: Array<Byte> =>
                    if (bytes.size == 0) {
                        this.isProcessing = false
                        this.progress = 0
                        this.taskMessage = "下载图片失败"
                        this.isTaskError = true
                        return
                    }
                    this.progress = 38
                    this.taskMessage = "正在提交 AI 编辑…"
                    apiEditImage(
                        code,
                        fullPrompt,
                        tpl,
                        bytes,
                        {
                            result: ImageTaskResult =>
                                this.progress = 100
                                this.isProcessing = false
                                this.showResult = true
                                this.resultRemoteUrl = this.primaryResultRemote(result)
                                this.resultImageUrl = if (!result.imageUrl.isEmpty()) {
                                    result.imageUrl
                                } else {
                                    result.thumbnailUrl
                                }
                                this.taskMessage = "编辑完成"
                                this.isTaskError = false
                                this.onCreditsChange(result.creditsRemaining)
                                imageForgeHistoryAppendRecord(
                                    this.historyCardTitleEdit(), fullPrompt, this.resultRemoteUrl
                                )
                        },
                        {
                            message: String =>
                                this.isProcessing = false
                                this.progress = 0
                                this.showResult = false
                                this.resultImageUrl = ""
                                this.resultRemoteUrl = ""
                                this.taskMessage = message
                                this.isTaskError = true
                        }
                    )
            },
            {
                message: String =>
                    this.isProcessing = false
                    this.progress = 0
                    this.taskMessage = message
                    this.isTaskError = true
            }
        )
    }

    func handleDownloadResult(): Unit {
        let fetchUrl = if (!this.resultRemoteUrl.isEmpty()) {
            this.resultRemoteUrl
        } else {
            let u = this.resultImageUrl
            if (u.startsWith("http://") || u.startsWith("https://")) {
                u
            } else {
                ""
            }
        }
        if (!fetchUrl.isEmpty()) {
            this.taskMessage = "正在保存到应用目录…"
            this.isTaskError = false
            apiDownloadImageBytes(
                fetchUrl,
                {
                    bytes: Array<Byte> =>
                        let saved = forgeTrySaveImageBytes(bytes, "ImageForge_download.png")
                        match (saved) {
                            case Some(path) =>
                                this.taskMessage = "已保存：${path}"
                                this.isTaskError = false
                            case None =>
                                this.taskMessage = "保存失败：未配置文件目录或写入被拒"
                                this.isTaskError = true
                        }
                },
                {
                    message: String =>
                        this.taskMessage = message
                        this.isTaskError = true
                }
            )
            return
        }
        let localPath = this.stripFileUriPath(this.resultImageUrl)
        if (localPath.isEmpty()) {
            return
        }
        this.taskMessage = "正在写入下载文件…"
        this.isTaskError = false
        try {
            let bytes = File.readFrom(localPath)
            match (forgeTrySaveImageBytes(bytes, "ImageForge_download.png")) {
                case Some(path) =>
                    this.taskMessage = "已保存：${path}"
                    this.isTaskError = false
                case None =>
                    this.taskMessage = "保存失败：未配置文件目录或写入被拒"
                    this.isTaskError = true
            }
        } catch (_: Exception) {
            this.taskMessage = "读取预览文件失败"
            this.isTaskError = true
        }
    }

    func handleGenerate() {
        this.genPrompt = this.genPrompt.trimAscii()
        if (this.genPrompt.isEmpty()) {
            this.taskMessage = "请输入图片描述"
            this.isTaskError = true
            return
        }
        if (this.accessCode.isEmpty()) {
            this.taskMessage = "访问码为空，请重新登录"
            this.isTaskError = true
            return
        }

        this.isProcessing = true
        this.progress = 8
        this.resultImageUrl = ""
        this.resultRemoteUrl = ""
        this.showResult = false
        this.taskMessage = "已提交生成任务，等待服务端返回…"
        this.isTaskError = false

        apiGenerateImage(
            this.accessCode,
            this.genPrompt,
            this.genWidth,
            this.genHeight,
            this.genSteps,
            this.genCfg,
            {
                result: ImageTaskResult =>
                    let remote = this.primaryResultRemote(result)
                    if (remote.isEmpty()) {
                        this.isProcessing = false
                        this.progress = 0
                        this.showResult = false
                        this.taskMessage = "生成成功但未返回图片地址"
                        this.isTaskError = true
                        return
                    }
                    this.progress = 60
                    this.resultRemoteUrl = remote
                    this.finalizeGeneratePreview(result, remote)
            },
            {
                message: String =>
                    this.isProcessing = false
                    this.progress = 0
                    this.showResult = false
                    this.resultImageUrl = ""
                    this.resultRemoteUrl = ""
                    this.taskMessage = message
                    this.isTaskError = true
            }
        )
    }
}
