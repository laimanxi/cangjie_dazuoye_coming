package ohos_app_cangjie_entry

import std.collection.*

let API_BASE_URL: String = "https://ptp.matrixlabs.cn"

enum EditTemplate {
    | ImgToImgStyle
    | ImageUpscale
    | BackgroundRepaint

    public func toApiValue(): String {
        match (this) {
            case ImgToImgStyle => "img2img_style"
            case ImageUpscale => "image_upscale"
            case BackgroundRepaint => "background_repaint"
        }
    }

    public func getDisplayName(lang: String): String {
        match (this) {
            case ImgToImgStyle => if (lang == "zh") { "风格化修图" } else { "Stylized edit" }
            case ImageUpscale => if (lang == "zh") { "高清增强" } else { "HD enhance" }
            case BackgroundRepaint => if (lang == "zh") { "背景重绘" } else { "Background repaint" }
        }
    }
}

class UserInfo {
    public var userId: String = ""
    public var username: String = ""
    public var email: String = ""
    public var plan: String = "free"
    public var planName: String = "Free"
    public var credits: Int64 = 0
    public var usedCredits: Int64 = 0
    public var editCreditCost: Int64 = 2
    public var generateCreditCost: Int64 = 1

    public init() {}

    public init(
        userId!: String,
        username!: String,
        plan!: String,
        credits!: Int64
    ) {
        this.userId = userId
        this.username = username
        this.plan = plan
        this.credits = credits
    }
}

class EditPreset {
    public var id: String
    public var nameZh: String
    public var nameEn: String
    public var promptZh: String
    public var promptEn: String

    public init(
        id!: String,
        nameZh!: String,
        nameEn!: String,
        promptZh!: String,
        promptEn!: String
    ) {
        this.id = id
        this.nameZh = nameZh
        this.nameEn = nameEn
        this.promptZh = promptZh
        this.promptEn = promptEn
    }

    public func getPrompt(lang: String): String {
        if (lang == "zh") { this.promptZh } else { this.promptEn }
    }

    public func getName(lang: String): String {
        if (lang == "zh") { this.nameZh } else { this.nameEn }
    }
}

class HistoryEntry {
    public var id: String = ""
    public var mode: String = "edit"
    public var taskType: String = ""
    public var prompt: String = ""
    public var timestamp: String = ""
    public var resultUrl: String = ""
    public var thumbnailUrl: String = ""

    public init() {}

    public init(
        id!: String,
        mode!: String,
        taskType!: String,
        prompt!: String,
        timestamp!: String,
        resultUrl!: String
    ) {
        this.id = id
        this.mode = mode
        this.taskType = taskType
        this.prompt = prompt
        this.timestamp = timestamp
        this.resultUrl = resultUrl
    }
}

class HealthCheckResult {
    public var serverStatus: String = "unknown"
    public var comfyuiStatus: String = "unknown"
    public var isHealthy: Bool = false

    public init() {}
}

class VersionInfo {
    public var name: String = ""
    public var version: String = ""
    public var role: String = ""
    public var comfyuiUrl: String = ""
    public var hint: String = ""

    public init() {}
}

func getDefaultPresets(): ArrayList<EditPreset> {
    let presets = ArrayList<EditPreset>()

    presets.add(EditPreset(
        id: "style_portrait",
        nameZh: "人像精修",
        nameEn: "Portrait polish",
        promptZh: "人像精修：均匀肤色、自然眼神光、轻微锐化，保持五官与姿态不变。",
        promptEn: "Professional portrait retouch: even skin tone, natural catchlights, subtle sharpening, keep identity and pose unchanged."
    ))

    presets.add(EditPreset(
        id: "style_vintage",
        nameZh: "复古胶片",
        nameEn: "Vintage film",
        promptZh: "复古胶片感：暖调褪色阴影、细腻颗粒、略降对比度，保持构图不变。",
        promptEn: "Apply a subtle vintage film look: warm faded shadows, fine grain, slightly lowered contrast, keep composition unchanged."
    ))

    presets.add(EditPreset(
        id: "style_id",
        nameZh: "证件照清爽",
        nameEn: "ID photo clean",
        promptZh: "证件照风格：背景尽量简洁中性、面部光线均匀、色彩自然、淡妆感，主体不变。",
        promptEn: "Clean ID-photo style: neutral background if possible, even lighting on face, natural color, no heavy makeup, keep subject unchanged."
    ))

    presets.add(EditPreset(
        id: "upscale_main",
        nameZh: "高清增强",
        nameEn: "HD enhance",
        promptZh: "提升清晰度与细节：边缘更锐利、降噪，保持原构图与内容，不要凭空增加物体。",
        promptEn: "Enhance clarity and micro-detail: sharper edges, reduce noise, preserve original composition and content, avoid hallucinated new objects."
    ))

    presets.add(EditPreset(
        id: "background_main",
        nameZh: "背景重绘",
        nameEn: "Background repaint",
        promptZh: "仅替换或重绘背景，前景主体边缘干净、与背景自然融合，不改变主体形状。",
        promptEn: "Replace or repaint ONLY the background; keep the foreground subject pixel-accurate with clean edges; seamless blend."
    ))

    return presets
}

class SubscriptionPlan {
    public var id: String
    public var nameZh: String
    public var nameEn: String
    public var credits: Int64
    public var price: Float64
    public var featuresZh: Array<String>
    public var featuresEn: Array<String>

    public init(
        id!: String,
        nameZh!: String,
        nameEn!: String,
        credits!: Int64,
        price!: Float64,
        featuresZh!: Array<String>,
        featuresEn!: Array<String>
    ) {
        this.id = id
        this.nameZh = nameZh
        this.nameEn = nameEn
        this.credits = credits
        this.price = price
        this.featuresZh = featuresZh
        this.featuresEn = featuresEn
    }

    public func getName(lang: String): String {
        if (lang == "zh") { this.nameZh } else { this.nameEn }
    }
}

func getSubscriptionPlans(): ArrayList<SubscriptionPlan> {
    let plans = ArrayList<SubscriptionPlan>()

    plans.add(SubscriptionPlan(
        id: "free",
        nameZh: "免费版",
        nameEn: "Free",
        credits: 10,
        price: 0.0,
        featuresZh: ["10 积分/月", "基础画质", "标准支持"],
        featuresEn: ["10 credits/month", "Basic quality", "Standard support"]
    ))

    plans.add(SubscriptionPlan(
        id: "basic",
        nameZh: "基础版",
        nameEn: "Basic",
        credits: 100,
        price: 9.99,
        featuresZh: ["100 积分/月", "高清画质", "优先支持", "无水印"],
        featuresEn: ["100 credits/month", "High quality", "Priority support", "No watermark"]
    ))

    plans.add(SubscriptionPlan(
        id: "pro",
        nameZh: "专业版",
        nameEn: "Professional",
        credits: 500,
        price: 29.99,
        featuresZh: ["500 积分/月", "超高清画质", "24/7 支持", "API 访问", "商业授权"],
        featuresEn: ["500 credits/month", "Ultra quality", "24/7 support", "API access", "Commercial license"]
    ))

    plans.add(SubscriptionPlan(
        id: "enterprise",
        nameZh: "企业版",
        nameEn: "Enterprise",
        credits: 2000,
        price: 99.99,
        featuresZh: ["2000 积分/月", "最高画质", "专属支持", "定制 API", "白标服务", "SLA 保障"],
        featuresEn: ["2000 credits/month", "Maximum quality", "Dedicated support", "Custom API", "White label", "SLA guarantee"]
    ))

    return plans
}
