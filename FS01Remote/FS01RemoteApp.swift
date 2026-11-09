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
            "Samsung": "三星", "Sony": "索尼", "Panasonic": "松下", "Sharp": "夏普",
            "Hisense": "海信", "Toshiba": "东芝", "Philips": "飞利浦", "Skyworth": "创维",
            "Xiaomi": "小米", "Haier": "海尔", "Gree": "格力", "Midea": "美的",
            "Daikin": "大金", "Hitachi": "日立", "Fujitsu": "富士通", "Mitsubishi": "三菱",
            "AUX": "奥克斯", "Changhong": "长虹", "Konka": "康佳", "TCL": "TCL", "LG": "LG"
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
                            setCount: brands[brand]?.count ?? 0,
                            verified: false,
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

    var body: some View {
        List {
            Section("码组") {
                LabeledContent("当前", value: setCount == 0 ? "无" : "\(selectedSet + 1) / \(setCount)")
                Button("下一套") {
                    selectedSet = (selectedSet + 1) % setCount
                }
                .disabled(setCount < 2)
                if !verified {
                    Text("此品牌的码组尚未适配 FS01，暂时只能切换预览。")
                        .foregroundStyle(.secondary)
                }
            }
            if verified {
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
            Section("遥控按键") {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                    ForEach(type.buttons, id: \.self) { label in
                        let command = verified ? RemoteCommand(rawValue: label) : nil
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

final class FS01Remote: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    static let deviceName = "IR2023_"
    private let serviceID = CBUUID(string: "FFF0")
    private let commandID = CBUUID(string: "FFF2")

    @Published private(set) var connectionStatus = "等待蓝牙"
    @Published private(set) var lastResult: String?
    @Published private(set) var bluetoothReady = false
    @Published private(set) var ready = false
    @Published private var pending: RemoteCommand?

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
        guard canSend, let peripheral, let commandCharacteristic else { return }
        let payload = command.payload
        guard payload.count <= peripheral.maximumWriteValueLength(for: .withResponse) else {
            lastResult = "蓝牙连接允许的写入长度不足。"
            return
        }
        pending = command
        lastResult = "正在发送：\(command.rawValue)"
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
        lastResult = error?.localizedDescription ?? "已写入：\(pending.rawValue)"
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
