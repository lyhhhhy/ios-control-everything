import CoreBluetooth
import Foundation
import SwiftUI

@main
struct FS01RemoteApp: App {
    @StateObject private var remote = FS01Remote()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                List {
                    ForEach(ApplianceType.allCases) { type in
                        NavigationLink {
                            BrandList(type: type, brands: InfraredCatalog.entries?[type.rawValue] ?? [:], remote: remote)
                        } label: {
                            Label(type.title, systemImage: type == .television ? "tv" : "snowflake")
                        }
                    }
                    if InfraredCatalog.entries == nil {
                        Text("公开码库目录读取失败。")
                    }
                }
                .navigationTitle("选择电器类型")
            }
        }
    }
}

private enum ApplianceType: String, CaseIterable, Identifiable {
    case television = "TVs"
    case airConditioner = "ACs"

    var id: Self { self }
    var title: String { self == .television ? "电视" : "空调" }

    var buttons: [String] {
        switch self {
        case .television:
            ["电源", "信号源", "静音", "音量加", "频道加", "菜单", "音量减", "频道减", "返回"]
        case .airConditioner:
            ["电源", "模式", "风速", "温度加", "温度减", "扫风"]
        }
    }
}

private enum InfraredCatalog {
    typealias Brands = [String: [String]]

    static let entries: [String: Brands]? = {
        guard let url = Bundle.main.url(forResource: "InfraredCatalog", withExtension: "json"),
              let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode([String: Brands].self, from: data)
    }()

    static func brandName(_ brand: String) -> String {
        let translations = [
            "Admiral": "海军上将",
            "Airfel": "艾尔菲尔",
            "Airmax": "艾尔麦克斯",
            "Airmet": "艾尔梅特",
            "Airwell": "艾尔威尔",
            "Akai": "雅佳",
            "Aldi": "奥乐齐",
            "Amazon": "亚马逊",
            "AmazonBasics": "亚马逊基础",
            "Amcor": "安姆科",
            "Android": "安卓",
            "Apex": "艾派克斯",
            "Arctic_King": "北极王",
            "Argo": "阿尔戈",
            "Ariston": "阿里斯顿",
            "AWA": "艾达布尔艾",
            "Baird": "贝尔德",
            "Ballu": "巴鲁",
            "Bauhn": "鲍恩",
            "BBK": "步步高",
            "Beko": "倍科",
            "BGH": "比吉艾奇",
            "Black_and_Decker": "百得",
            "Blaupunkt": "蓝宝",
            "Blitzwolf": "闪电狼",
            "Bolva": "博尔瓦",
            "Bonaire": "博奈尔",
            "Bose": "博士",
            "Boston_Bay": "波士顿湾",
            "Botti": "博蒂",
            "Boulanger": "布朗热",
            "Brandt": "白朗",
            "Bush": "布什",
            "Cadillac": "凯迪拉克",
            "Carrier": "开利",
            "CCE": "西西易",
            "Chigo": "志高",
            "Ciatronic": "西亚特罗尼克",
            "Comfort_Aire": "康福艾尔",
            "ContinentalEdison": "大陆爱迪生",
            "Corlitec": "科利泰克",
            "COTech": "科泰克",
            "Cranker": "克兰克",
            "Crown": "皇冠",
            "Daewoo": "大宇",
            "Daikin": "大金",
            "Danby": "丹比",
            "DeLonghi": "德龙",
            "Denver": "丹佛",
            "Devant": "德万特",
            "Digihome": "迪吉家",
            "Dual": "杜尔",
            "Dynex": "戴奈克斯",
            "DYON": "戴昂",
            "Eberg": "伊贝格",
            "Ecofort": "艾科福特",
            "EdenWood": "伊甸木",
            "Electra": "伊莱克特拉",
            "electriQ": "伊莱克特里克",
            "Electrolux": "伊莱克斯",
            "Element": "元素",
            "Elements": "元素系列",
            "Elitelux": "艾利特卢克斯",
            "Emerson": "艾默生",
            "Enseo": "恩西奥",
            "Erisson": "艾里森",
            "EssentielB": "艾森谢尔比",
            "Eurom": "欧罗姆",
            "Ferroli": "法罗力",
            "Fetch": "费奇",
            "Ffalcon": "雷鸟",
            "FINLUX": "芬卢克斯",
            "Firstline": "弗斯特莱恩",
            "Frico": "弗里科",
            "Friedrich": "弗里德里希",
            "Frigidaire": "富及第",
            "Fujidenzo": "富士电藏",
            "Fujitsu": "富士通",
            "Funai": "船井",
            "Furrion": "弗里昂",
            "General_Electric": "通用电气",
            "Gigabyte": "技嘉",
            "Gogen": "戈根",
            "GoodHome": "好家居",
            "GPX": "吉皮艾克斯",
            "Grandin": "格兰丹",
            "GREE": "格力",
            "Grundig": "根德",
            "GuestTek": "盖斯特泰克",
            "GVA": "吉维艾",
            "Haier": "海尔",
            "Hisense": "海信",
            "Hitachi": "日立",
            "Honeywell": "霍尼韦尔",
            "Hotels": "酒店通用",
            "Innova": "伊诺瓦",
            "Insigna": "英西格纳",
            "Insignia": "英西格尼亚",
            "Inventum": "因文图姆",
            "JVC": "杰伟世",
            "Kelon": "科龙",
            "Kendo": "肯多",
            "Kenmore": "肯莫尔",
            "Klarstein": "克拉斯坦",
            "Kogan": "科根",
            "Koldfront": "科尔德弗朗特",
            "Kraft": "克拉夫特",
            "Lamborghini": "兰博基尼",
            "Legion": "拯救者",
            "Lennox": "伦诺克斯",
            "LG": "乐金",
            "Lifetime Air": "莱夫泰姆艾尔",
            "LodgeNet": "洛奇网",
            "Loewe": "罗意威",
            "Logik": "洛吉克",
            "Magnavox": "麦格纳沃克斯",
            "Manta": "曼塔",
            "Matsui": "松井",
            "MayTag": "美泰克",
            "Medion": "麦迪昂",
            "Midea": "美的",
            "Mitsubishi": "三菱",
            "Mivar": "米瓦尔",
            "Moretti": "莫雷蒂",
            "NEC": "日本电气",
            "Neo": "尼奥",
            "Nevir": "内维尔",
            "OK": "欧凯",
            "Oky": "欧凯伊",
            "Onn": "昂恩",
            "Oreck": "奥雷克",
            "Osaka": "大阪",
            "Panasonic": "松下",
            "PDi": "皮迪艾",
            "Philips": "飞利浦",
            "Pioneer": "先锋",
            "Platinum": "铂金",
            "Princess": "公主",
            "PrismPlus": "棱镜加",
            "RCA": "美国无线电",
            "Remko": "雷姆科",
            "Rinnai": "林内",
            "Roku": "罗库",
            "Royal_Clima": "皇家克利马",
            "Samsung": "三星",
            "Sankey": "桑基",
            "Sanyo": "三洋",
            "Sceptre": "赛普特",
            "SEG": "艾斯易吉",
            "Seiki": "赛吉",
            "Sencor": "森科",
            "SereneLife": "赛琳生活",
            "Sharp": "夏普",
            "Shivaki": "希瓦基",
            "Silver": "希尔弗",
            "Sinclair": "辛克莱",
            "SkyVue": "斯凯维尤",
            "SoleusAir": "索利斯艾尔",
            "Soniq": "索尼克",
            "Sony": "索尼",
            "Strong": "斯特朗",
            "Subtropic": "萨布特罗皮克",
            "SuedwindAmbientika": "苏德温德安比恩蒂卡",
            "Sunbrite": "桑布莱特",
            "Suntec": "桑泰克",
            "Supra": "苏普拉",
            "Sweex": "斯威克斯",
            "Symphonic": "辛福尼克",
            "Syntax-Brillian": "辛泰克斯布里连",
            "TCL": "王牌",
            "Technika": "泰克尼卡",
            "Telecontrole": "泰勒康特罗尔",
            "Telefunken": "德律风根",
            "Telekom": "德国电信",
            "Tevion": "泰维昂",
            "Thomson": "汤姆逊",
            "Timberk": "廷伯克",
            "Tora": "托拉",
            "Toshiba": "东芝",
            "Tosot": "大松",
            "Tropic": "特罗皮克",
            "Trotec": "特罗泰克",
            "United": "尤奈特",
            "Viano": "维亚诺",
            "ViewSonic": "优派",
            "Viore": "维奥雷",
            "Vitec": "维泰克",
            "Vizio": "维齐奥",
            "Vornado": "沃拿多",
            "Waltham": "沃尔瑟姆",
            "Watson": "沃森",
            "Wbox": "达布尔盒子",
            "Westinghouse": "西屋",
            "Whynter": "温特",
            "Windfree": "无风感",
            "Xiaomi": "小米",
            "York": "约克",
            "Zenith": "真力时",
            "Zephir": "泽菲尔"
        ]
        return translations[brand] ?? brand.replacingOccurrences(of: "_", with: " ")
    }
}

private struct BrandList: View {
    let type: ApplianceType
    let brands: InfraredCatalog.Brands
    @ObservedObject var remote: FS01Remote
    @State private var query = ""

    var body: some View {
        List {
            if type == .television, query.isEmpty {
                Section("可以控制") {
                    NavigationLink("已验证的电视") {
                        RemotePad(type: type, title: "已验证的电视", setCount: 1, verified: true, remote: remote)
                    }
                }
            }
            Section("品牌") {
                ForEach(brands.keys.sorted().filter {
                    query.isEmpty || $0.localizedCaseInsensitiveContains(query)
                        || InfraredCatalog.brandName($0).localizedCaseInsensitiveContains(query)
                }, id: \.self) { brand in
                    NavigationLink(InfraredCatalog.brandName(brand)) {
                        RemotePad(
                            type: type,
                            title: InfraredCatalog.brandName(brand),
                            setCount: (brands[brand]?.count ?? 0) + (type == .television && brand == "Sony" ? 1 : 0),
                            verified: type == .television && brand == "Sony",
                            remote: remote
                        )
                    }
                }
            }
        }
        .searchable(text: $query, prompt: "搜索品牌")
        .navigationTitle("选择\(type.title)品牌")
    }
}

private struct RemotePad: View {
    let type: ApplianceType
    let title: String
    let setCount: Int
    let verified: Bool
    @ObservedObject var remote: FS01Remote
    @State private var selectedSet = 0

    private var canTestSet: Bool { verified && selectedSet == 0 }

    var body: some View {
        List {
            Section("码组") {
                LabeledContent("当前", value: setCount == 0 ? "无" : "\(selectedSet + 1) / \(setCount)")
                Button("下一套") {
                    selectedSet = (selectedSet + 1) % setCount
                }
                .disabled(setCount < 2)
                if !canTestSet {
                    Text("这一套码组尚未适配 FS01，暂时只能切换预览。")
                        .foregroundStyle(.secondary)
                }
            }
            if canTestSet {
                Section("红外发射器") {
                    LabeledContent("状态", value: remote.connectionStatus)
                    Button("搜索并连接", action: remote.connect)
                        .disabled(!remote.canConnect)
                    if let result = remote.lastResult {
                        Text(result)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            if canTestSet {
                Section("发码实验 · 每次预期音量加") {
                    Text("先用正常的音量加确认连接，再分别试 A、B、C。每次看电视音量有没有升高。")
                        .font(.footnote)
                    ForEach(PacketProbe.allCases) { probe in
                        Button(probe.rawValue) {
                            remote.send(payload: probe.payload, label: probe.rawValue)
                        }
                        .disabled(!remote.canSend)
                    }
                }
            }
            Section("遥控按键") {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                    ForEach(type.buttons, id: \.self) { label in
                        let command = canTestSet ? RemoteCommand(rawValue: label) : nil
                        Button {
                            if let command { remote.send(command) }
                        } label: {
                            Text(label)
                                .frame(maxWidth: .infinity, minHeight: 48)
                        }
                        .buttonStyle(.bordered)
                        .disabled(command == nil || !remote.canSend)
                    }
                }
                .padding(.vertical, 8)
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

enum RemoteCommand: String, CaseIterable, Identifiable {
    case volumeUp = "音量加"
    case volumeDown = "音量减"
    case mute = "静音"
    case power = "电源"
    case channelUp = "频道加"

    var id: Self { self }

    var payload: Data {
        switch self {
        case .volumeUp:
            Data([
                0x14, 0x00, 0x1f, 0xfb, 0x00, 0x29, 0x4c, 0x33, 0x26, 0xc5, 0x0a, 0x94,
                0x01, 0x28, 0x23, 0x28, 0x49, 0x28, 0x23, 0xf6, 0x0c, 0x01, 0x21, 0x12,
                0x11, 0x21, 0x11, 0x30, 0x12, 0x11, 0x21, 0x12, 0x11, 0x13, 0x01, 0x21,
                0x12, 0x11, 0x21, 0x11, 0x30, 0x12, 0x11, 0x21, 0x12, 0x11, 0x13
            ])
        case .volumeDown:
            Data([
                0x14, 0x00, 0x01, 0xc8, 0x00, 0x29, 0x4c, 0x33, 0x26, 0xc5, 0x0a, 0x94,
                0x01, 0x28, 0x49, 0x28, 0x23, 0x28, 0x23, 0xd1, 0x0c, 0x01, 0x12, 0x21,
                0x22, 0x12, 0x22, 0x30, 0x11, 0x22, 0x12, 0x21, 0x22, 0x23, 0x01, 0x12,
                0x21, 0x22, 0x12, 0x22, 0x30, 0x11, 0x22, 0x12, 0x21, 0x22, 0x23
            ])
        case .power:
            Data([
                0x14, 0x00, 0x2d, 0x39, 0x00, 0x29, 0x4c, 0x33, 0x26, 0xc5, 0x0a, 0x94,
                0x01, 0x28, 0x49, 0x28, 0x23, 0x28, 0x23, 0xd0, 0x0c, 0x01, 0x21, 0x21,
                0x22, 0x12, 0x22, 0x30, 0x12, 0x12, 0x12, 0x21, 0x22, 0x23, 0x01, 0x21,
                0x21, 0x22, 0x12, 0x22, 0x30, 0x12, 0x12, 0x12, 0x21, 0x22, 0x23
            ])
        case .channelUp:
            Data([
                0x14, 0x00, 0x8f, 0x26, 0x00, 0x29, 0x4c, 0x33, 0x26, 0xc5, 0x0a, 0x94,
                0x01, 0x28, 0x23, 0x28, 0x49, 0x28, 0x23, 0x9c, 0x0d, 0x01, 0x11, 0x12,
                0x11, 0x21, 0x11, 0x30, 0x11, 0x11, 0x21, 0x12, 0x11, 0x13, 0x01, 0x11,
                0x12, 0x11, 0x21, 0x11, 0x30, 0x11, 0x11, 0x21, 0x12, 0x11, 0x13
            ])
        case .mute:
            Data([
                0x14, 0x00, 0x55, 0xec, 0x00, 0x29, 0x4c, 0x33, 0x26, 0xc5, 0x0a, 0x94,
                0x01, 0x28, 0x23, 0x28, 0x49, 0x28, 0x23, 0xf5, 0x0c, 0x01, 0x12, 0x12,
                0x11, 0x21, 0x11, 0x30, 0x11, 0x21, 0x21, 0x12, 0x11, 0x13, 0x01, 0x12,
                0x12, 0x11, 0x21, 0x11, 0x30, 0x11, 0x21, 0x21, 0x12, 0x11, 0x13
            ])
        }
    }
}

private enum PacketProbe: String, CaseIterable, Identifiable {
    case zeroTag = "实验 A · 标记归零"
    case borrowedTag = "实验 B · 换用静音标记"
    case swappedTag = "实验 C · 交换标记字节"

    var id: Self { self }

    var payload: Data {
        var packet = RemoteCommand.volumeUp.payload
        // Keep the captured IR body intact while testing the two unknown header bytes.
        switch self {
        case .zeroTag:
            packet[2] = 0
            packet[3] = 0
        case .borrowedTag:
            let mute = RemoteCommand.mute.payload
            packet[2] = mute[2]
            packet[3] = mute[3]
        case .swappedTag:
            let first = packet[2]
            packet[2] = packet[3]
            packet[3] = first
        }
        return packet
    }
}

final class FS01Remote: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    static let deviceName = "IR2023_"
    private let serviceID = CBUUID(string: "FFF0")
    private let commandID = CBUUID(string: "FFF2")

    @Published private(set) var connectionStatus = "等待蓝牙"
    @Published private(set) var lastResult: String?
    @Published private(set) var bluetoothReady = false
    @Published private(set) var ready = false
    @Published private var pending: String?

    private var central: CBCentralManager!
    private var peripheral: CBPeripheral?
    private var commandCharacteristic: CBCharacteristic?
    private var connectionTimeout: DispatchWorkItem?

    var canConnect: Bool { bluetoothReady && !ready && connectionTimeout == nil }
    var canSend: Bool { ready && pending == nil }

    override init() {
        super.init()
        central = CBCentralManager(delegate: self, queue: nil)
    }

    func connect() {
        guard canConnect else { return }
        resetConnection()
        lastResult = nil
        if let connected = central.retrieveConnectedPeripherals(withServices: [serviceID])
            .first(where: { $0.name?.hasPrefix(Self.deviceName) == true }) {
            select(connected)
        } else {
            connectionStatus = "正在搜索"
            central.scanForPeripherals(withServices: nil)
        }

        let timeout = DispatchWorkItem { [weak self] in
            guard let self, !self.ready else { return }
            self.fail("连接超时。请确认红外头已供电，并退出原遥控 App。")
        }
        connectionTimeout = timeout
        DispatchQueue.main.asyncAfter(deadline: .now() + 20, execute: timeout)
    }

    func send(_ command: RemoteCommand) {
        send(payload: command.payload, label: command.rawValue)
    }

    func send(payload: Data, label: String) {
        guard canSend, let peripheral, let commandCharacteristic else { return }
        guard payload.count <= peripheral.maximumWriteValueLength(for: .withResponse) else {
            lastResult = "蓝牙连接允许的写入长度不足。"
            return
        }
        pending = label
        lastResult = "正在发送：\(label)"
        peripheral.writeValue(payload, for: commandCharacteristic, type: .withResponse)
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        bluetoothReady = central.state == .poweredOn
        if bluetoothReady {
            connectionStatus = "可以连接"
        } else {
            resetConnection()
            switch central.state {
            case .poweredOff: connectionStatus = "请打开蓝牙"
            case .unauthorized: connectionStatus = "请在设置中允许蓝牙访问"
            case .unsupported: connectionStatus = "此设备不支持低功耗蓝牙"
            default: connectionStatus = "等待蓝牙"
            }
        }
    }

    func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any],
        rssi RSSI: NSNumber
    ) {
        guard self.peripheral == nil else { return }
        let advertisedName = advertisementData[CBAdvertisementDataLocalNameKey] as? String
        guard peripheral.name?.hasPrefix(Self.deviceName) == true || advertisedName?.hasPrefix(Self.deviceName) == true else { return }
        select(peripheral)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        guard self.peripheral === peripheral else { return }
        connectionStatus = "正在查找发码特征"
        peripheral.discoverServices(nil)
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        guard self.peripheral === peripheral else { return }
        fail("建立蓝牙连接失败：\(error?.localizedDescription ?? "无详细信息")")
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        guard self.peripheral === peripheral else { return }
        fail(error?.localizedDescription ?? "配件已断开，可以重新连接。")
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard self.peripheral === peripheral else { return }
        let services = peripheral.services ?? []
        guard let service = services.first(where: { $0.uuid == serviceID }) else {
            let discovered = services.map { $0.uuid.uuidString }.joined(separator: ", ")
            fail("找不到 FFF0 服务。已发现：\(discovered.isEmpty ? "无" : discovered)。\(error?.localizedDescription ?? "")")
            return
        }
        connectionStatus = "正在查找 FFF2 特征"
        peripheral.discoverCharacteristics(nil, for: service)
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard self.peripheral === peripheral else { return }
        let characteristics = service.characteristics ?? []
        guard let characteristic = characteristics.first(where: { $0.uuid == commandID }),
              characteristic.properties.contains(.write) else {
            let discovered = characteristics.map { $0.uuid.uuidString }.joined(separator: ", ")
            fail("找不到可写入的 FFF2 特征。已发现：\(discovered.isEmpty ? "无" : discovered)。\(error?.localizedDescription ?? "")")
            return
        }
        commandCharacteristic = characteristic
        connectionTimeout?.cancel()
        connectionTimeout = nil
        connectionStatus = "已连接"
        ready = true
        if characteristic.properties.contains(.notify) {
            peripheral.setNotifyValue(true, for: characteristic)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        guard self.peripheral === peripheral, characteristic === commandCharacteristic else { return }
        if let error {
            lastResult = "回包订阅失败，仍可试发：\(error.localizedDescription)"
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        guard self.peripheral === peripheral, characteristic === commandCharacteristic, let pending else { return }
        self.pending = nil
        lastResult = error?.localizedDescription ?? "已写入：\(pending)"
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard self.peripheral === peripheral, characteristic === commandCharacteristic else { return }
        if let error {
            lastResult = error.localizedDescription
        } else if let data = characteristic.value {
            let hex = data.map { String(format: "%02X", $0) }.joined(separator: " ")
            lastResult = "配件回包：\(hex)"
        }
    }

    private func select(_ peripheral: CBPeripheral) {
        central.stopScan()
        self.peripheral = peripheral
        peripheral.delegate = self
        connectionStatus = "正在连接"
        if peripheral.state == .connected {
            self.centralManager(central, didConnect: peripheral)
        } else {
            central.connect(peripheral)
        }
    }

    private func fail(_ message: String) {
        resetConnection()
        connectionStatus = "未连接"
        lastResult = message
    }

    private func resetConnection() {
        connectionTimeout?.cancel()
        connectionTimeout = nil
        ready = false
        pending = nil
        commandCharacteristic = nil
        let previous = peripheral
        peripheral = nil
        guard central.state == .poweredOn else { return }
        central.stopScan()
        if let previous { central.cancelPeripheralConnection(previous) }
    }
}
