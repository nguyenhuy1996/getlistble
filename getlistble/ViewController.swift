import CoreBluetooth
import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CBCentralManagerDelegate, CBPeripheralDelegate
{
   
    @IBOutlet weak var discoveredDevices: UILabel!
    @IBOutlet weak var connected: UILabel!
    @IBOutlet weak var foundBLE: UILabel!
    @IBOutlet weak var coreBluetooth: UILabel!
    var centralManager: CBCentralManager!
    var serviceInObject: Array<CBPeripheral> = Array<CBPeripheral>()
    var UUID = [CBUUID]()
    var ser = [CBService]()
    var peripheralList = [CBPeripheral]()
    var TagList = [Tag]()
    //
    var blueToothReady = false
    var connectingPeripheral:CBPeripheral!
    var imageTag = [String]()
    @IBOutlet weak var tableView: UITableView!

    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //Initialise CoreBluetooth Central Manager
         startUpCentralManager()
    }
    
    func startUpCentralManager() {
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    /////////////////////////
    //CoreBluetooth methods
 
    func centralManagerDidUpdateState(central: CBCentralManager)
    {
        switch (central.state) {
        case .Unsupported:
            print("BLE is unsupported")
        case .Unauthorized:
            print("BLE is unauthorized")
        case .Unknown:
            print("BLE is unknown")
        case .Resetting:
            print("BLE is resetting")
        case .PoweredOff:
            print("BLE is powered off")
        case .PoweredOn:
            print("BLE is powered on")
            print("Start scanning ... ")
            central.scanForPeripheralsWithServices(nil, options: nil)
        }
    }
   
    @IBAction func ScanBLE(sender: AnyObject) {
        if (centralManager.state == CBCentralManagerState.PoweredOn )
        {
            ScanDevices()
        }
     }
    func ScanDevices()
    {
        centralManager.scanForPeripheralsWithServices(nil, options: nil)
    }
    func CancelDevice(peripheral: CBPeripheral){
        centralManager.cancelPeripheralConnection(peripheral)
    }
    // neu tim thay mot thiet bi, thi ham nay se duoc goi
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber)
    {
        peripheralList.append(peripheral)// them phan tu vao mang
        var tag = Tag(name: peripheral.name!, imageName: "null.jpg")
        TagList.append(tag)
        print("---------- Da tim thay \(peripheral.name)")
        print("Rssi:\(RSSI)")
        print("Du lieu la: \(advertisementData)")
        print("So luong du lieu: \(advertisementData.count)")
     //   print(advertisementData.description)
        print("Service: \(peripheral.services)")
        tableView.reloadData() // load lai table view
        
    }
    
//    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
//        discoveredDevices.text = "Discovered \(peripheral.name)"
//        print("Discovered: \(peripheral.name)")
//        centralManager.stopScan()
//        
//        
//            print("ok")
//            centralManager.connectPeripheral(peripheral, options: nil)
//            self.connectingPeripheral = peripheral
//    }
    
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        peripheral.delegate = self;
        print("\(peripheral.name) connected")
      //  print(peripheral.identifier)
        let uuidString = peripheral.identifier.UUIDString
        print(peripheral.identifier)
        print("Bat dau kham pha dich vu: ")
      //  peripheral.discoverServices([bleServiceUUID])
        peripheral.discoverServices(nil)
        // kham pha dich vu cho thiet vi co uuuidString
      // peripheral.readRSSI()
       
    }
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("did_Disconnect")
        // Khi tat bluetooth tren IPHONE, tag se keu
        // Khi Tag bi tat hoac mat ket noi, IPhone se thuc hien ham nay.
        peripheral.discoverServices(nil)
    }

    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        print("&&&&&&&&Services:\(peripheral.services) and error\(error)")
        print("dich vu")
        if let services = peripheral.services {
            for service in services {
                peripheral.discoverCharacteristics(nil, forService: service)
                print()
            }
        }
    }
    
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?)
    {
        print("peripheral name:\(peripheral)")
        print("service:\(service)")
        print(">")
        for characteristic in service.characteristics!
        {
            peripheral.setNotifyValue(true, forCharacteristic: characteristic)
            print("ok")

        //peripheral.readValueForCharacteristic(characteristic)
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?)
    {
                print("characteristic changed:\(characteristic)")
         var data : NSData = characteristic.value!
        peripheral.writeValue(data, forCharacteristic: characteristic, type: CBCharacteristicWriteType.WithResponse)
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        print("did update notifi \(characteristic)")
        var data : NSData = characteristic.UUID.data
      
     
        
              print("day roi haha: \(data)")
            print()
        peripheral.writeValue(data, forCharacteristic: characteristic, type: CBCharacteristicWriteType.WithResponse)
        
    }
    
    //UITableView methods
    /*
    .
 .
 .
 .
 .
 .
 */
//--
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell : TagTableViewCell = self.tableView.dequeueReusableCellWithIdentifier("CellTag")! as! TagTableViewCell
        print(indexPath.row)
       // let peripheral = peripherals[indexPath.row]

        if (indexPath.row % 2 == 0)
        {
            cell.backgroundColor = UIColor.brownColor()
        }
        else
        {
            cell.backgroundColor = UIColor.blueColor()
        }
 
        let tag = TagList[indexPath.row]
        cell.setCell(tag.name, imageName: tag.imageName)
     
        return cell
    }
//-
    func action(sender: UIButton)   {
        print(sender.titleLabel)
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return TagList.count
    }
//--
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete
        {
            TagList.removeAtIndex(indexPath.row)
            peripheralList.removeAtIndex(indexPath.row)
            self.tableView.reloadData()
        }
    }
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if let selectedCell = sender as? UITableViewCell {
//            let indexPath = tableView.indexPathForCell(selectedCell)
//        centralManager.connectPeripheral(peripheralList[indexPath!.row], options: nil)
//            
//        }
//    }
//    
    func Alert(dataAlert: NSData, peripheral: CBPeripheral,characteristic: CBCharacteristic)  {
        peripheral.writeValue(dataAlert, forCharacteristic: characteristic, type: CBCharacteristicWriteType.WithResponse)
        // ham bao dong
    }
}