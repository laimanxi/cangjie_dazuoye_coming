package ohos_app_cangjie_entry

import kit.NetworkKit.*
import kit.ArkUI.*
import ohos.base.*
import ohos.business_exception.BusinessException
import std.collection.*
import std.convert.*

let API_BASE_URL: String = "https://ptp.matrixlabs.cn" // cjlint-ignore !G.OTH.03 deployed BFF endpoint
let AUTH_API_PATH: String = "/api/auth"

func runOnMainThread(task: () -> Unit): Unit {
    launch {
        task()
    }
}

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
            case ImgToImgStyle =>
                if (lang == "zh") {
                    "风格化修图"
                } else {
                    "Stylized edit"
                }
            case ImageUpscale =>
                if (lang == "zh") {
                    "高清增强"
                } else {
                    "HD enhance"
                }
            case BackgroundRepaint =>
                if (lang == "zh") {
                    "背景重绘"
                } else {
                    "Background repaint"
                }
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
        if (lang == "zh") {
            this.promptZh
        } else {
            this.promptEn
        }
    }

    public func getName(lang: String): String {
        if (lang == "zh") {
            this.nameZh
        } else {
            this.nameEn
        }
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

class ImageTaskResult {
    public var imageUrl: String = ""
    public var thumbnailUrl: String = ""
    public var prompt: String = ""
    public var creditsUsed: Int64 = 0
    public var creditsRemaining: Int64 = -1

    public init() {}
}

func apiLogin(
    accessCode: String,
    onSuccess: (UserInfo) -> Unit,
    onError: (String) -> Unit
): Unit {
    apiPost(
        AUTH_API_PATH,
        "{\"accessCode\":\"${jsonEscape(accessCode)}\"}",
        {
            body: String => if (apiJsonBool(body, "success") ?? false) {
                onSuccess(parseUserInfo(body))
            } else {
                onError(apiJsonString(body, "error") ?? "登录失败")
            }
        },
        onError
    )
}

func apiGenerateImage(
    accessCode: String,
    prompt: String,
    width: Int64,
    height: Int64,
    steps: Int64,
    cfg: Float64,
    onSuccess: (ImageTaskResult) -> Unit,
    onError: (String) -> Unit
): Unit {
    let body = "{" + "\"accessCode\":\"${jsonEscape(accessCode)}\"," + "\"prompt\":\"${jsonEscape(prompt)}\"," +
        "\"width\":${width}," + "\"height\":${height}," + "\"steps\":${steps}," + "\"cfg\":${cfg}" + "}"

    apiPost(
        "/api/generate",
        body,
        {
            response: String => if (apiJsonBool(response, "success") ?? false) {
                onSuccess(parseImageTaskResult(response))
            } else {
                onError(apiJsonString(response, "error") ?? "生成失败")
            }
        },
        onError
    )
}

func apiCheckHealth(
    onSuccess: (HealthCheckResult) -> Unit,
    onError: (String) -> Unit
): Unit {
    apiGet(
        "/api/health",
        {
            body: String =>
                let result = HealthCheckResult()
                result.serverStatus = apiJsonString(body, "status") ?? "unknown"
                result.comfyuiStatus = apiJsonString(body, "comfyui") ?? "unknown"
                result.isHealthy = result.serverStatus == "ok" && result.comfyuiStatus == "connected"
                onSuccess(result)
        },
        onError
    )
}

func apiFetchVersion(
    onSuccess: (VersionInfo) -> Unit,
    onError: (String) -> Unit
): Unit {
    apiGet(
        "/api/version",
        {
            body: String =>
                let info = VersionInfo()
                info.name = apiJsonString(body, "name") ?? ""
                info.version = apiJsonString(body, "version") ?? ""
                info.role = apiJsonString(body, "role") ?? ""
                info.comfyuiUrl = apiJsonString(body, "comfyuiUrl") ?? ""
                info.hint = apiJsonString(body, "hint") ?? ""
                onSuccess(info)
        },
        onError
    )
}

func apiGet(
    path: String,
    onSuccess: (String) -> Unit,
    onError: (String) -> Unit
): Unit {
    apiRequest(RequestMethod.Get, path, "", onSuccess, onError)
}

func apiPost(
    path: String,
    body: String,
    onSuccess: (String) -> Unit,
    onError: (String) -> Unit
): Unit {
    apiRequest(RequestMethod.Post, path, body, onSuccess, onError)
}

func apiRequest(
    method: RequestMethod,
    path: String,
    body: String,
    onSuccess: (String) -> Unit,
    onError: (String) -> Unit
): Unit {
    try {
        let request = createHttp()
        let headers = HashMap<String, String>()
        headers.add("Content-Type", "application/json")
        headers.add("Accept", "application/json")

        let options = HttpRequestOptions(
            method: method,
            extraData: HttpData.StringData(body),
            expectDataType: HttpDataType.StringValue,
            usingCache: false,
            header: headers,
            readTimeout: 180000u32,
            connectTimeout: 15000u32
        )

        try {
            request.request(
                apiUrl(path),
                options,
                {
                    err, resp =>
                        if (let Some(e) <- err) {
                            let message = e.message
                            runOnMainThread({
                                => onError(message)
                            })
                            safeDestroyHttpRequest(request)
                            return
                        }

                        if (let Some(r) <- resp) {
                            let responseBody = httpDataToString(r.result)
                            if (r.responseCode >= 200u32 && r.responseCode < 300u32) {
                                runOnMainThread({
                                    => onSuccess(responseBody)
                                })
                            } else {
                                let message = apiJsonString(responseBody, "error") ?? "HTTP ${r.responseCode}"
                                runOnMainThread({
                                    => onError(message)
                                })
                            }
                        } else {
                            runOnMainThread({
                                => onError("服务端没有返回响应")
                            })
                        }
                        safeDestroyHttpRequest(request)
                }
            )
        } catch (e: BusinessException) {
            safeDestroyHttpRequest(request)
            let message = e.message
            runOnMainThread({
                => onError(message)
            })
        }
    } catch (e: BusinessException) {
        let message = e.message
        runOnMainThread({
            => onError(message)
        })
    }
}

func safeDestroyHttpRequest(request: HttpRequest): Unit {
    try {
        request.destroy()
    } catch (_: BusinessException) {}
}

func httpDataToString(data: HttpData): String {
    match (data) {
        case HttpData.StringData(value) => value
        case HttpData.ArrayData(bytes) => String.fromUtf8(bytes)
        case _ => ""
    }
}

func apiUrl(path: String): String {
    if (path.isEmpty()) {
        return ""
    }
    if (path.startsWith("http://") || path.startsWith("https://")) {
        return path
    }
    if (path.startsWith("/")) {
        return "${API_BASE_URL}${path}"
    }
    return "${API_BASE_URL}/${path}"
}

func parseUserInfo(body: String): UserInfo {
    let user = UserInfo()
    user.userId = apiJsonString(body, "userId") ?? ""
    user.username = apiJsonString(body, "username") ?? "User"
    user.email = apiJsonString(body, "email") ?? ""
    user.plan = apiJsonString(body, "plan") ?? "free"
    user.planName = apiJsonString(body, "planName") ?? user.plan
    user.credits = apiJsonInt(body, "credits") ?? 0
    user.usedCredits = apiJsonInt(body, "usedCredits") ?? 0
    user.editCreditCost = apiJsonInt(body, "edit") ?? 2
    user.generateCreditCost = apiJsonInt(body, "generate") ?? 1
    return user
}

func parseImageTaskResult(body: String): ImageTaskResult {
    let result = ImageTaskResult()
    result.imageUrl = apiUrl(apiJsonString(body, "image") ?? "")
    result.thumbnailUrl = apiUrl(apiJsonString(body, "thumbnail") ?? "")
    result.prompt = apiJsonString(body, "prompt") ?? ""
    result.creditsUsed = apiJsonInt(body, "creditsUsed") ?? 0
    result.creditsRemaining = apiJsonInt(body, "creditsRemaining") ?? -1
    return result
}

func jsonEscape(value: String): String {
    value.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r")
}

func jsonUnescape(value: String): String {
    value.replace("\\n", "\n").replace("\\r", "\r").replace("\\\"", "\"").replace("\\\\", "\\")
}

func apiJsonString(body: String, key: String): ?String {
    if (let Some(start) <- apiJsonValueStart(body, key)) {
        if (start >= body.size || body[start] != b'\"') {
            return None<String>
        }

        var index = start + 1
        var escaped = false
        while (index < body.size) {
            let current = body[index]
            if (escaped) {
                escaped = false
            } else if (current == b'\\') {
                escaped = true
            } else if (current == b'\"') {
                return Some(jsonUnescape(body[(start + 1)..index]))
            }
            index += 1
        }
    }

    return None<String>
}

func apiJsonInt(body: String, key: String): ?Int64 {
    if (let Some(raw) <- apiJsonPrimitive(body, key)) {
        return Int64.tryParse(raw)
    }
    return None<Int64>
}

func apiJsonBool(body: String, key: String): ?Bool {
    if (let Some(raw) <- apiJsonPrimitive(body, key)) {
        if (raw.startsWith("true")) {
            return Some(true)
        }
        if (raw.startsWith("false")) {
            return Some(false)
        }
    }
    return None<Bool>
}

func apiJsonPrimitive(body: String, key: String): ?String {
    if (let Some(start) <- apiJsonValueStart(body, key)) {
        var end = start
        while (end < body.size && !isJsonValueTerminator(body[end])) {
            end += 1
        }
        if (end > start) {
            return Some(body[start..end].trimAscii())
        }
    }
    return None<String>
}

func apiJsonValueStart(body: String, key: String): ?Int64 {
    let token = "\"${key}\""
    if (let Some(keyIndex) <- body.indexOf(token)) {
        if (let Some(colonIndex) <- body.indexOf(":", keyIndex + token.size)) {
            var start = colonIndex + 1
            while (start < body.size && isJsonSpace(body[start])) {
                start += 1
            }
            return Some(start)
        }
    }
    return None<Int64>
}

func isJsonSpace(value: Byte): Bool {
    value == b' ' || value == b'\n' || value == b'\r' || value == b'\t'
}

func isJsonValueTerminator(value: Byte): Bool {
    value == b',' || value == b'}' || value == b']'
}

func getDefaultPresets(): ArrayList<EditPreset> {
    let presets = ArrayList<EditPreset>()

    presets.add(
        EditPreset(
            id: "style_portrait",
            nameZh: "人像精修",
            nameEn: "Portrait polish",
            promptZh: "人像精修：均匀肤色、自然眼神光、轻微锐化，保持五官与姿态不变。",
            promptEn: "Professional portrait retouch: even skin tone, natural catchlights, subtle sharpening, keep identity and pose unchanged."
        )
    )

    presets.add(
        EditPreset(
            id: "style_vintage",
            nameZh: "复古胶片",
            nameEn: "Vintage film",
            promptZh: "复古胶片感：暖调褪色阴影、细腻颗粒、略降对比度，保持构图不变。",
            promptEn: "Apply a subtle vintage film look: warm faded shadows, fine grain, slightly lowered contrast, keep composition unchanged."
        )
    )

    presets.add(
        EditPreset(
            id: "style_id",
            nameZh: "证件照清爽",
            nameEn: "ID photo clean",
            promptZh: "证件照风格：背景尽量简洁中性、面部光线均匀、色彩自然、淡妆感，主体不变。",
            promptEn: "Clean ID-photo style: neutral background if possible, even lighting on face, natural color, no heavy makeup, keep subject unchanged."
        )
    )

    presets.add(
        EditPreset(
            id: "upscale_main",
            nameZh: "高清增强",
            nameEn: "HD enhance",
            promptZh: "提升清晰度与细节：边缘更锐利、降噪，保持原构图与内容，不要凭空增加物体。",
            promptEn: "Enhance clarity and micro-detail: sharper edges, reduce noise, preserve original composition and content, avoid hallucinated new objects."
        )
    )

    presets.add(
        EditPreset(
            id: "background_main",
            nameZh: "背景重绘",
            nameEn: "Background repaint",
            promptZh: "仅替换或重绘背景，前景主体边缘干净、与背景自然融合，不改变主体形状。",
            promptEn: "Replace or repaint ONLY the background; keep the foreground subject pixel-accurate with clean edges; seamless blend."
        )
    )

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
        if (lang == "zh") {
            this.nameZh
        } else {
            this.nameEn
        }
    }
}

func getSubscriptionPlans(): ArrayList<SubscriptionPlan> {
    let plans = ArrayList<SubscriptionPlan>()

    plans.add(
        SubscriptionPlan(
            id: "free",
            nameZh: "免费版",
            nameEn: "Free",
            credits: 10,
            price: 0.0,
            featuresZh: ["10 积分/月", "基础画质", "标准支持"],
            featuresEn: ["10 credits/month", "Basic quality", "Standard support"]
        )
    )

    plans.add(
        SubscriptionPlan(
            id: "basic",
            nameZh: "基础版",
            nameEn: "Basic",
            credits: 100,
            price: 9.99,
            featuresZh: ["100 积分/月", "高清画质", "优先支持", "无水印"],
            featuresEn: ["100 credits/month", "High quality", "Priority support", "No watermark"]
        )
    )

    plans.add(
        SubscriptionPlan(
            id: "pro",
            nameZh: "专业版",
            nameEn: "Professional",
            credits: 500,
            price: 29.99,
            featuresZh: ["500 积分/月", "超高清画质", "24/7 支持", "API 访问", "商业授权"],
            featuresEn: ["500 credits/month", "Ultra quality", "24/7 support", "API access", "Commercial license"]
        )
    )

    plans.add(
        SubscriptionPlan(
            id: "enterprise",
            nameZh: "企业版",
            nameEn: "Enterprise",
            credits: 2000,
            price: 99.99,
            featuresZh: ["2000 积分/月", "最高画质", "专属支持", "定制 API", "白标服务", "SLA 保障"],
            featuresEn: ["2000 credits/month", "Maximum quality", "Dedicated support", "Custom API", "White label",
                "SLA guarantee"]
        )
    )

    return plans
}
