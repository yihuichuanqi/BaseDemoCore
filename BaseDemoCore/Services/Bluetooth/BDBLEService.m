//
//  BDBLEService.m
//  BaseDemoCore
//
//  Created by scl on 2018/1/30.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import "BDBLEService.h"
#import <CoreBluetooth/CoreBluetooth.h>

//一代芯片
static NSString * const kServiceUUID_One = @"FFF0";//支持蓝牙通信的服务
static NSString * const kWriteCharacteristicUUID_One =@"FFF1";//支持写操作特性
static NSString * const kNotifyCharacteristicUUID_One =@"FFF2";//支持读操作
//二代芯片
static NSString * const kServiceUUID_Two = @"FFE5,FFE0";
static NSString * const kWriteCharacteristicUUID_Two =@"FFE9";
static NSString * const kNotifyCharacteristicUUID_Two =@"FFE4";

//蓝牙充电命令
typedef NS_ENUM(Byte,BlueChargeOrder) {
    
    kBlueChargeOrder_Login=0x31,
    kBlueChargeOrder_StartCharging=0x32,
    kBlueChargeOrder_StopCharging=0x33,
    kBlueChargeOrder_StartChargingResponse=0x34,
    kBlueChargeOrder_StopChargingResponse=0x35,
    kBlueChargeOrder_PriceInfo=0x36,
    kBlueChargeOrder_getOfflineOrder=0x37,
    kBlueChargeOrder_ControlLock=0x38,
};


@interface BDBLEService ()<CBCentralManagerDelegate,CBPeripheralDelegate>

@property (nonatomic,strong) CBCentralManager *centralManager; //中央管理
@property (nonatomic,strong) CBPeripheral *thePeripheral;//需要连接的外围设备
//读写特征
@property (nonatomic,strong) CBCharacteristic *theCharacteristic;
@property (nonatomic,strong) CBCharacteristic *theNotifyCharacteristic;
//回调Block
@property (nonatomic,copy) BlueResultBlock reslutBlock;
//设备
@property (nonatomic,copy) NSString *deviceName;
@property (nonatomic,copy) NSString *pinCode;//解锁码
@property (nonatomic,strong) NSMutableData *theReceiveData;//接收到数据
@property (nonatomic,copy) NSString *cardUUID;//用户卡号 用于蓝牙充电

@property (nonatomic,assign) BOOL isMulConnector;//多枪头桩
@property (nonatomic,strong) NSMutableArray *serviceUUIDs;//可用服务
//记录特征
@property (nonatomic,copy) NSString *writeCharacteristicUUID;
@property (nonatomic,copy) NSString *notifyCharacteristicUUID;

@end

@implementation BDBLEService

+(instancetype)sharedService
{
    static BDBLEService *service=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        service=[[BDBLEService alloc]init];
        
    });
    return service;
}
-(id)init
{
    if (self=[super init])
    {
        
    }
    return self;
}


-(void)connectDeviceName:(NSString *)deviceName resultBlock:(BlueResultBlock)block
{
    self.reslutBlock = block;
    self.deviceName=deviceName;
    
    //创建蓝牙
    self.centralManager=[[CBCentralManager alloc]initWithDelegate:self queue:dispatch_get_main_queue()];
    
    //获取供应商可用服务
    NSMutableArray *serviceUUIDs=[NSMutableArray array];
    NSArray *serviceArray=[[kServiceUUID_Two componentsSeparatedByString:@","] arrayByAddingObject:kServiceUUID_One];
    for (NSString *service in serviceArray)
    {
        CBUUID *serviceId=[CBUUID UUIDWithString:service];
        [serviceUUIDs addObject:serviceId];
    }
    self.serviceUUIDs=serviceUUIDs;
    
}
-(void)stopBluetoothService
{
    self.delegate=nil;
    
    [self.centralManager stopScan];
    self.centralManager=nil;
    self.thePeripheral=nil;
    self.theCharacteristic=nil;
    self.theNotifyCharacteristic=nil;
    
    self.reslutBlock = nil;
    [self.class cancelPreviousPerformRequestsWithTarget:self];
}

#pragma mark-CBCentralManagerDelegate
-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state==CBCentralManagerStatePoweredOn)
    {
        if (_reslutBlock)
        {
            _reslutBlock(kBlueStatus_StopWorking,nil);
        }
    }
    else if (central.state==CBCentralManagerStatePoweredOff||central.state==CBCentralManagerStateUnauthorized)
    {
        if (_reslutBlock)
        {
            _reslutBlock(kBlueStatus_StopWorking,@"蓝牙未打开!!!");
        }
    }
    else if (central.state==CBCentralManagerStateUnsupported)
    {
        if (_reslutBlock)
        {
            _reslutBlock(kBlueStatus_StopWorking,@"该设备不支持蓝牙!!!");
        }
    }
    //开始扫描外设
    [_centralManager scanForPeripheralsWithServices:nil options:nil];
}
-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"蓝牙断开!!!");
    if (_pinCode)
    {
        //排除第一次连接可能会断开的情况
        if (self.delegate&&[self.delegate respondsToSelector:@selector(bluetoothDidDisconnect)])
        {
            [self.delegate bluetoothDidDisconnect];
        }
    }
    else
    {
        //自动重连
        if (peripheral.identifier)
        {
            //外围设备
            NSArray *peripheralArray=[self.centralManager retrievePeripheralsWithIdentifiers:@[peripheral.identifier]];
            for (CBPeripheral *peripheral in peripheralArray)
            {
                [self.centralManager connectPeripheral:peripheral options:nil];
            }
        }
        else
        {
            [self connectDeviceName:_deviceName resultBlock:_reslutBlock];
        }
    }
}
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI
{
    //发现外围设备
    NSString *spotPeripheralName=nil;
    if([_deviceName length]>1)
    {
        spotPeripheralName=[_deviceName substringToIndex:_deviceName.length-1];
    }
    //是否多电头电桩
    BOOL isMulConnectorSpot=NO;
    if(spotPeripheralName)
    {
        if ([peripheral.name hasSuffix:spotPeripheralName])
        {
            isMulConnectorSpot=YES;
        }
    }
    if ([peripheral.name hasSuffix:_deviceName]||isMulConnectorSpot)
    {
        //停止扫描
        [central stopScan];
        peripheral.delegate=self;
        self.thePeripheral=peripheral;
        //连接外围设备
        [self.centralManager connectPeripheral:_thePeripheral options:nil];
    }
}
-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    //连接到外设
    self.isMulConnector=NO;
    if ([peripheral.name hasPrefix:@"CL"]||[peripheral.name hasPrefix:@"CD"])
    {
        //新版芯片
        self.isMulConnector=[peripheral.name hasPrefix:@"CD"];//双枪桩
        [_serviceUUIDs removeObject:[CBUUID UUIDWithString:kServiceUUID_One]];
        self.writeCharacteristicUUID=kWriteCharacteristicUUID_Two;
        self.notifyCharacteristicUUID=kNotifyCharacteristicUUID_Two;
    }
    else
    {
        //旧版芯片
        for (NSString *serviceStr in [kServiceUUID_Two componentsSeparatedByString:@","])
        {
            [_serviceUUIDs removeObject:[CBUUID UUIDWithString:serviceStr]];
        }
        self.writeCharacteristicUUID=kWriteCharacteristicUUID_One;
        self.notifyCharacteristicUUID=kNotifyCharacteristicUUID_One;
    }
    //发现服务
    [peripheral discoverServices:nil];
}
#pragma mark-CBPeripheralDelegate
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    //发现可用服务
    for (CBService *service in peripheral.services)
    {
        [peripheral discoverCharacteristics:nil forService:service];
    }
}
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    //发现服务特征
    if ([_serviceUUIDs containsObject:service.UUID])
    {
        for (CBCharacteristic *characteristic in service.characteristics)
        {
            BOOL isWriteCharac=[characteristic.UUID.UUIDString isEqualToString:_writeCharacteristicUUID];
            BOOL isNotifyCharac=[characteristic.UUID.UUIDString isEqualToString:_notifyCharacteristicUUID];
            if (((characteristic.properties&CBCharacteristicPropertyWrite)==CBCharacteristicPropertyWrite)&&isWriteCharac)
            {
                self.theCharacteristic=characteristic;
            }
            else if (((characteristic.properties&CBCharacteristicPropertyNotify)==CBCharacteristicPropertyNotify)&&isNotifyCharac)
            {
                self.theNotifyCharacteristic=characteristic;
                [peripheral setNotifyValue:YES forCharacteristic:_theNotifyCharacteristic];
            }
        }
        if (self.theCharacteristic&&self.theNotifyCharacteristic&&_reslutBlock)
        {
            _reslutBlock(kBlueStatus_ConnectSuccess,nil);
        }
    }
}
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (!error)
    {
        if (characteristic.value.length>0)
        {
            Byte firstByte;
            Byte lastByte;
            [characteristic.value getBytes:&firstByte range:NSMakeRange(0, 1)];
            [characteristic.value getBytes:&lastByte range:NSMakeRange(characteristic.value.length-1, 1)];
            if (firstByte == 0x7E)
            {
                [_theReceiveData setData:[NSData data]];
            }
            [_theReceiveData appendData:characteristic.value];
            if (lastByte == 0x7F)
            {
                NSDictionary *dataDic=[self decodeData:_theReceiveData];
                if (dataDic)
                {
                    BlueChargeOrder order=[dataDic[@"order"] charValue];
                    NSData *receiveData=dataDic[@"data"];
                    [self handleOrder:order data:receiveData];
                }
            }
        }
    }
}

#pragma mark-Private Method
//业务处理
-(void)handleOrder:(BlueChargeOrder)order data:(NSData *)data
{
    switch (order) {
        case kBlueChargeOrder_Login:
            {
                
            }
            break;
            
        default:
            break;
    }
}
//发送数据
-(void)sendBLEData:(NSData *)data
{
    if (_thePeripheral&&_theCharacteristic)
    {
        NSInteger leftLength=data.length;
        NSInteger pageLength=20;
        while (leftLength>0)
        {
            NSInteger beginLocation=data.length-leftLength;
            NSInteger sendLength=MIN(leftLength, pageLength);
            NSData *subData=[data subdataWithRange:NSMakeRange(beginLocation, sendLength)];
            leftLength=leftLength-sendLength;
            [self.thePeripheral writeValue:subData forCharacteristic:_theCharacteristic type:CBCharacteristicWriteWithResponse];
        }
    }
}
//发送命令
-(BOOL)sendOrder:(BlueChargeOrder)order
{
    NSMutableData *data = [NSMutableData data];
    BOOL success=YES;
    switch (order) {
        case kBlueChargeOrder_Login:
            {
                if ([self.cardUUID length]>0)
                {
                    [data setData:[self sendLoginBLEDataRequest]];
                }
                else
                {
                    success=NO;
                }
            }
            break;
        case kBlueChargeOrder_StartCharging:
        case kBlueChargeOrder_StopCharging:
        case kBlueChargeOrder_PriceInfo:
        {
            if (_cardUUID&&_pinCode.length>0)
            {
                [data setData:[self sendChargingBLEDataRequestWithOrder:order]];
            }
            else
            {
                success=NO;
            }
        }
            break;
        case kBlueChargeOrder_getOfflineOrder:
        {
            success=YES;
        }
            break;
        case kBlueChargeOrder_ControlLock:
        {
            if (_cardUUID&&_pinCode.length>0)
            {
                [data setData:[self sendControlLockBLEDataRequest]];
            }
            else
            {
                success=NO;
            }
        }
            break;
        case kBlueChargeOrder_StopChargingResponse:
        case kBlueChargeOrder_StartChargingResponse:
        {
            if (_isMulConnector)
            {
                [data appendData:[self deviceData]];
            }
        }
            break;
        default:
            break;
    }
    
    if (success)
    {
        NSData *sendData=[self encodeDataWithOrder:order data:data];
        
    }
    
    
}
//归档数据
-(NSData *)encodeDataWithOrder:(BlueChargeOrder)order data:(NSData *)data
{
    NSMutableData *packageData=[NSMutableData data];
    NSMutableData *mainData=[NSMutableData data];
    //地址码
    UInt32 addressCode=0x03000000;
    addressCode=NSSwapBigIntToHost(addressCode);
    [mainData appendData:[NSData dataWithBytes:&addressCode length:sizeof(addressCode)]];
    //命令码
    [mainData appendData:[NSData dataWithBytes:&order length:sizeof(order)]];
    //数据区
    [mainData appendData:data];
    //CRC
    short crc=gen_crc((char *)mainData.bytes, (int)mainData.length);
    crc=NSSwapHostShortToBig(crc);
    [mainData appendBytes:&crc length:sizeof(crc)];
    //转义
    NSUInteger len=mainData.length;
    Byte *output=mainData.mutableBytes;
    for (NSUInteger i=0; i<len; i++)
    {
        if (output[i]==0x7d)
        {
            memmove(&output[i+2], &output[i+1], len-i);
            output[i++]=0x7d;
            output[i]=0x0d;
            len++;
        }
        else if (output[i]==0x7e)
        {
            memmove(&output[i+2], &output[i+1], len-i);
            output[i++]=0x7d;
            output[i]=0x0e;
            len++;

        }
        else if (output[i]==0x7f)
        {
            memmove(&output[i+2], &output[i+1], len-i);
            output[i++]=0x7d;
            output[i]=0x0f;
            len++;
        }
    }
    mainData=[NSMutableData dataWithBytes:mainData.mutableBytes length:len];
    //封装
    Byte beginWord=0x7E;
    [packageData appendData:[NSData dataWithBytes:&beginWord length:sizeof(beginWord)]];
    [packageData appendData:mainData];
    Byte endWord=0x7F;
    [packageData appendData:[NSData dataWithBytes:&endWord length:sizeof(endWord)]];
    return packageData;
    
}
//解析数据
-(NSDictionary *)decodeData:(NSData *)data
{
    NSMutableDictionary *dict=nil;
    const Byte *dataBytes=data.bytes;
    NSUInteger len=data.length;
    if (data.length>2)
    {
        if (dataBytes[0] == 0x7E && dataBytes[len-1] == 0x7F)
        {
            NSMutableData *decodeData=[NSMutableData dataWithData:data];
            Byte *output=decodeData.mutableBytes;
            for (NSUInteger i=0; i<len; i++)
            {
                if ((output[i]==0x7d)&&(output[i+1]==0x0d))
                {
                    output[i]=0x7d;
                    memmove(&output[i+1], &output[i+2], len-i-1);
                    len--;
                }
                else if ((output[i]==0x7d)&&(output[i+1]==0x0e))
                {
                    output[i]=0x7e;
                    memmove(&output[i+1], &output[i+2], len-i-1);
                    len--;
                }
                else if ((output[i]==0x7d)&&(output[i+1]==0x0f))
                {
                    output[i]=0x7f;
                    memmove(&output[i+1], &output[i+2], len-i-1);
                    len--;
                }
            }
            decodeData=[NSMutableData dataWithBytes:decodeData.mutableBytes length:len];
            if (decodeData.length>=8)
            {
                BlueChargeOrder order;
                [decodeData getBytes:&order range:NSMakeRange(5, sizeof(order))];
                NSData *finalData=[decodeData subdataWithRange:NSMakeRange(6, decodeData.length-9)];
                if (finalData)
                {
                    dict=[NSMutableDictionary dictionary];
                    dict[@"order"]=@(order);
                    dict[@"data"]=finalData;
                }
            }
        }
    }
    return dict;
}
-(NSData *)deviceData
{
    const char * device=[_deviceName cStringUsingEncoding:NSASCIIStringEncoding];
    char deviceChar[16]={0};
    for (int i=0; i<_deviceName.length; i++)
    {
        deviceChar[i]=device[i];
    }
    return [NSData dataWithBytes:deviceChar length:16];
}
#pragma mark-不同业务功能
-(NSData *)sendLoginBLEDataRequest
{
    //卡号+二维码
    NSMutableData *data=[NSMutableData data];
    uuid_t uuid;
    [_cardUUID getBytes:&uuid maxLength:sizeof(uuid) usedLength:NULL encoding:NSASCIIStringEncoding options:NSStringEncodingConversionAllowLossy range:NSMakeRange(0, sizeof(uuid)) remainingRange:NULL];
    [data appendBytes:&uuid length:sizeof(uuid)];
    if (_isMulConnector)
    {
        [data appendData:[self deviceData]];
    }
    return data;
}
-(NSData *)sendChargingBLEDataRequestWithOrder:(BlueChargeOrder)order
{
    //卡号+pinCode+二维码
    NSMutableData *data=[NSMutableData data];
    uuid_t uuid;
    [_cardUUID getBytes:&uuid maxLength:sizeof(uuid) usedLength:NULL encoding:NSASCIIStringEncoding options:NSStringEncodingConversionAllowLossy range:NSMakeRange(0, sizeof(uuid)) remainingRange:NULL];
    [data appendBytes:&uuid length:sizeof(uuid)];
    [data appendBytes:[_pinCode cStringUsingEncoding:NSASCIIStringEncoding] length:2];
    if (order!=kBlueChargeOrder_PriceInfo)
    {
        if (_isMulConnector)
        {
            [data appendData:[self deviceData]];
        }
    }
    return data;
}
-(NSData *)sendControlLockBLEDataRequest
{
    //卡号16字节（ASCII）+2字节picode+1字节控制的地锁状态（0x01上锁 0x00解锁）
    NSMutableData *data=[NSMutableData data];
    uuid_t uuid;
    [_cardUUID getBytes:&uuid maxLength:sizeof(uuid) usedLength:NULL encoding:NSASCIIStringEncoding options:NSStringEncodingConversionAllowLossy range:NSMakeRange(0, sizeof(uuid)) remainingRange:NULL];
    [data appendBytes:&uuid length:sizeof(uuid)];
    [data appendBytes:[_pinCode cStringUsingEncoding:NSASCIIStringEncoding] length:2];
    Byte lockOrder=0x00;//J解锁
    [data appendBytes:&lockOrder length:sizeof(lockOrder)];
    if (_isMulConnector)
    {
        [data appendData:[self deviceData]];
    }
    return data;
}
-(void)handleLoginBLEOrderWithData:(NSData *)data
{
    //状态（1）+开始充电时间（4）+开始电量（4）+transaction_idtag(16)+transaction_id(8)+cpid(8)+position_id(1)+pindode(2)
    BlueDeviceStatus status;
    [data getBytes:&status range:NSMakeRange(0, sizeof(status))];
    UInt32 beginChargeTime;
    [data getBytes:&beginChargeTime range:NSMakeRange(1, sizeof(beginChargeTime))];
    UInt32 beginChargeElec;
    [data getBytes:&beginChargeElec range:NSMakeRange(1+4, sizeof(beginChargeElec))];
    uuid_t transaction_idtag;
    [data getBytes:&transaction_idtag range:NSMakeRange(1+4+4, sizeof(transaction_idtag))];
    UInt64 transcation_id;
    [data getBytes:&transcation_id range:NSMakeRange(1+4+4+16, sizeof(transcation_id))];
    transcation_id=NSSwapHostLongLongToBig(transcation_id);
    UInt64 cpid;
    [data getBytes:&cpid range:NSMakeRange(1+4+4+16+8, sizeof(cpid))];
    Byte position_id;
    [data getBytes:&position_id range:NSMakeRange(1+4+4+16+8+8, sizeof(position_id))];
    char pincode[2]={'\0'};
    [data getBytes:pincode range:NSMakeRange(1+4+4+16+8+8+1, sizeof(pincode))];
    self.pinCode=[[NSString alloc]initWithBytes:pincode length:2 encoding:NSASCIIStringEncoding];
    BOOL success=NO;
    NSString *errorMsg=nil;
    switch (status) {
        case kBlueDeviceStatus_Free:
            success=YES;
            break;
        case kBlueDeviceStatus_Charging:
        {
            NSString *lastLoginCardId=[[NSString alloc]initWithBytes:transaction_idtag length:sizeof(transaction_idtag) encoding:NSASCIIStringEncoding];
            success=[lastLoginCardId isEqualToString:_cardUUID];
            if (!success)
            {
                errorMsg=@"电桩充电中";
            }
        }
            break;
        case kBlueDeviceStatus_Maintain:
        {
            success=NO;
            errorMsg=@"电桩维护中";
        }
            break;
        case kBlueDeviceStatus_Error:
        case kBlueDeviceStatusUnknown:
        {
            success=NO;
            errorMsg=@"硬件错误";
        }
            
        default:
            break;
    }
    if(self.delegate)
    {
        
    }
}
-(void)handleStartChargingBLEOrderWithData:(NSData *)data
{
    //0x00标识可开启充电 0x01开启失败 在充电中或者维护中0x02pincode错误 0x03未登录
    Byte status;
    [data getBytes:&status range:NSMakeRange(0, sizeof(status))];
    BOOL success=NO;
    NSString *errorMsg=nil;
    switch (status) {
        case 0x00:
            success=YES;
            break;
        case 0x01:
        {
            success=NO;
            errorMsg=@"电桩充电中或正在维护";
        }
            break;
        case 0x02:
        case 0x03:
        {
            success=NO;
            errorMsg=@"无法开启充电";
        }
            break;
            
        default:
            break;
    }
    if (self.delegate)
    {
        
    }
}
-(void)handleStartChargingResponseBLEOrderWithData:(NSData *)data
{
    //开始充电时间（4）+开始电量（4）+transaction_idtag(16)+transaction_id(8)+cpid(8)
    UInt32 beginChargeTime;
    [data getBytes:&beginChargeTime range:NSMakeRange(0, sizeof(beginChargeTime))];
    beginChargeTime=NSSwapHostIntToBig(beginChargeTime);
    UInt32 beginChargeElec;
    [data getBytes:&beginChargeElec range:NSMakeRange(4, sizeof(beginChargeElec))];
    beginChargeElec=NSSwapHostIntToBig(beginChargeElec);
    uuid_t transaction_idtag;
    [data getBytes:&transaction_idtag range:NSMakeRange(4+4, sizeof(transaction_idtag))];
    UInt64 transaction_id;
    [data getBytes:&transaction_idtag range:NSMakeRange(4+4+16, sizeof(transaction_id))];
    transaction_id=NSSwapHostLongLongToBig(transaction_id);
    UInt64 cpid;
    [data getBytes:&cpid range:NSMakeRange(4+4+16+8, sizeof(cpid))];
    cpid=NSSwapHostLongLongToBig(cpid);
    if (self.delegate)
    {
        
    }
    [self sendOrder:kBlueChargeOrder_StartChargingResponse];
    [self performSelector:@selector(getOfflineOrder) withObject:nil afterDelay:0.5];
}
-(void)getOfflineOrder
{
    
}
#pragma mark-CRC
short gen_crc(char *data,int len)
{
    unsigned short crc=0;
    for (int i=0; i<len; i++)
    {
        crc=(crc<<8)^crc_ccitt_table[(crc>>8)^(unsigned char)data[i]];
    }
    return crc;
}
const unsigned short crc_ccitt_table[256]=
{
    0x0000,   0x1021,   0x2042,   0x3063,   0x4084,   0x50A5,   0x60C6,   0x70E7,
    0x8108,   0x9129,   0xA14A,   0xB16B,   0xC18C,   0xD1AD,   0xE1CE,   0xF1EF,
    0x1231,   0x0210,   0x3273,   0x2252,   0x52B5,   0x4294,   0x72F7,   0x62D6,
    0x9339,   0x8318,   0xB37B,   0xA35A,   0xD3BD,   0xC39C,   0xF3FF,   0xE3DE,
    0x2462,   0x3443,   0x0420,   0x1401,   0x64E6,   0x74C7,   0x44A4,   0x5485,
    0xA56A,   0xB54B,   0x8528,   0x9509,   0xE5EE,   0xF5CF,   0xC5AC,   0xD58D,
    0x3653,   0x2672,   0x1611,   0x0630,   0x76D7,   0x66F6,   0x5695,   0x46B4,
    0xB75B,   0xA77A,   0x9719,   0x8738,   0xF7DF,   0xE7FE,   0xD79D,   0xC7BC,
    0x48C4,   0x58E5,   0x6886,   0x78A7,   0x0840,   0x1861,   0x2802,   0x3823,
    0xC9CC,   0xD9ED,   0xE98E,   0xF9AF,   0x8948,   0x9969,   0xA90A,   0xB92B,
    0x5AF5,   0x4AD4,   0x7AB7,   0x6A96,   0x1A71,   0x0A50,   0x3A33,   0x2A12,
    0xDBFD,   0xCBDC,   0xFBBF,   0xEB9E,   0x9B79,   0x8B58,   0xBB3B,   0xAB1A,
    0x6CA6,   0x7C87,   0x4CE4,   0x5CC5,   0x2C22,   0x3C03,   0x0C60,   0x1C41,
    0xEDAE,   0xFD8F,   0xCDEC,   0xDDCD,   0xAD2A,   0xBD0B,   0x8D68,   0x9D49,
    0x7E97,   0x6EB6,   0x5ED5,   0x4EF4,   0x3E13,   0x2E32,   0x1E51,   0x0E70,
    0xFF9F,   0xEFBE,   0xDFDD,   0xCFFC,   0xBF1B,   0xAF3A,   0x9F59,   0x8F78,
    0x9188,   0x81A9,   0xB1CA,   0xA1EB,   0xD10C,   0xC12D,   0xF14E,   0xE16F,
    0x1080,   0x00A1,   0x30C2,   0x20E3,   0x5004,   0x4025,   0x7046,   0x6067,
    0x83B9,   0x9398,   0xA3FB,   0xB3DA,   0xC33D,   0xD31C,   0xE37F,   0xF35E,
    0x02B1,   0x1290,   0x22F3,   0x32D2,   0x4235,   0x5214,   0x6277,   0x7256,
    0xB5EA,   0xA5CB,   0x95A8,   0x8589,   0xF56E,   0xE54F,   0xD52C,   0xC50D,
    0x34E2,   0x24C3,   0x14A0,   0x0481,   0x7466,   0x6447,   0x5424,   0x4405,
    0xA7DB,   0xB7FA,   0x8799,   0x97B8,   0xE75F,   0xF77E,   0xC71D,   0xD73C,
    0x26D3,   0x36F2,   0x0691,   0x16B0,   0x6657,   0x7676,   0x4615,   0x5634,
    0xD94C,   0xC96D,   0xF90E,   0xE92F,   0x99C8,   0x89E9,   0xB98A,   0xA9AB,
    0x5844,   0x4865,   0x7806,   0x6827,   0x18C0,   0x08E1,   0x3882,   0x28A3,
    0xCB7D,   0xDB5C,   0xEB3F,   0xFB1E,   0x8BF9,   0x9BD8,   0xABBB,   0xBB9A,
    0x4A75,   0x5A54,   0x6A37,   0x7A16,   0x0AF1,   0x1AD0,   0x2AB3,   0x3A92,
    0xFD2E,   0xED0F,   0xDD6C,   0xCD4D,   0xBDAA,   0xAD8B,   0x9DE8,   0x8DC9,
    0x7C26,   0x6C07,   0x5C64,   0x4C45,   0x3CA2,   0x2C83,   0x1CE0,   0x0CC1,
    0xEF1F,   0xFF3E,   0xCF5D,   0xDF7C,   0xAF9B,   0xBFBA,   0x8FD9,   0x9FF8,
    0x6E17,   0x7E36,   0x4E55,   0x5E74,   0x2E93,   0x3EB2,   0x0ED1,   0x1EF0

};


@end
