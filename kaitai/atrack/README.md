# Atrack Protocol

The Atrack protocol is a sophisticated GPS tracking protocol developed by ATrack Technology Inc., a Taiwan-based company established in 2009. This protocol supports both binary and text message formats with extensive customization capabilities for vehicle telematics and asset tracking applications.

## Protocol Overview

**Type:** Mixed Binary/Text  
**Manufacturer:** ATrack Technology Inc.  
**Primary Use:** Vehicle tracking, fleet management, asset monitoring  
**Data Format:** Binary frames with optional text commands  
**Bidirectional:** Yes (commands and responses)

## Message Structure

### Binary Format
```
Header: @? (2 bytes) + Checksum (2) + Length (2) + Sequence (2) + Device ID (8)
Data: Timestamp + GPS + Status + Custom Fields
```

### Text Format
```
@P,checksum,length,sequence,device_id,timestamp,rtc_time,device_time,
longitude,latitude,course,report_id,odometer,hdop,inputs,speed,
outputs,adc,driver,temp1,temp2,message,custom_data
```

## Key Features

- **Dual Protocol Support**: Both binary and ASCII text formats
- **Extensive Custom Fields**: OBD-II, CAN Bus, sensor data integration
- **Photo Transmission**: Image data support (@R prefix)
- **Beacon Integration**: BLE beacon data parsing
- **Configurable Format**: Custom data field definitions
- **Keep-alive Messages**: Heartbeat with 0xfe02 prefix

## Device Identification

### Commercial Device Models

#### Vehicle Tracking Series
- **AK Series** (Professional Fleet)
  - AK1: Quad-band GSM, 8-40V power supply
  - AK11: 4G LTE flagship with 3G/2G fallback
- **AT Series** (Advanced Vehicle)
  - AT5/AT5i: Multi-functional GPS/GLONASS with AES-128
  - AT1: Professional real-time tracker
- **AX Series** (OBD-II Plug-and-Play)
  - AX5: OBD-II connector with CAN support
  - AX7: Vehicle telematics unit
  - AX9: 2G/3G with J1939 CAN Bus data
- **AL Series** (Economical Fleet)
  - AL1: Basic vehicle GPS tracker
  - AL7: IP66 waterproof for motorcycles

#### Asset Monitoring Series
- **AS Series**
  - AS1: Mobile asset monitoring, IP67, 3-year battery
  - AS3: Vehicle/trailer monitoring

### Physical Identification
- **Compact Design**: Nearly invisible when installed
- **Military-Grade Construction**: IP66/IP67 rated enclosures
- **Professional Installation**: Hardwired or OBD-II connector
- **Model Labels**: Clear marking with series/model numbers
- **IMEI Sticker**: 15-digit identifier usually on device chassis

### IMEI Patterns
- **Format**: Standard 15-digit IMEI (35xxxxxxxxxxxxx)
- **Location**: Physical sticker with barcode on device
- **Verification**: Can be queried via $INFO command
- **Example Response**: `$INFO=358683066267395,AX7,Rev.0.61...`

### Protocol Detection Methods

#### Binary Frame Identification
```
Keep-alive: 0xfe02 prefix
Position: @? binary header or @P text format
Photo: @R prefix for image data
Response: Acknowledgment frames with sequence numbers
```

#### Text Command Patterns
```
Info Query: $INFO=device_id,model,firmware,...
Position: @P,checksum,length,sequence,device_id,...
Error: $ERROR=error_code
OK: $OK
```

### Configuration Indicators
- **Custom Data Support**: Extensive %CI format strings
- **OBD-II Integration**: Vehicle diagnostics via CAN Bus
- **Multi-format Messages**: Binary and text in same session
- **Beacon Data**: BLE sensor integration capability

## Common Applications

- **Fleet Management**: Commercial vehicle tracking
- **Asset Protection**: Trailers, containers, equipment
- **Vehicle Security**: Anti-theft and recovery systems
- **Motorcycle Tracking**: Compact waterproof solutions
- **Heavy Equipment**: Construction and agricultural machinery

## Clone Device Warning

⚠️ **Genuine Device Verification**
- Official "ATrack" or "ATrack Technology" branding
- Superior build quality with proper certifications (FCC, CE)
- Authentic firmware version strings in responses
- Consistent pricing through authorized dealers

Avoid devices with suspicious pricing, poor construction, missing certifications, or misspelled branding that may not be compatible with this protocol implementation.

## Traccar Configuration

```xml
<entry key='atrack.port'>5002</entry>
<entry key='atrack.longDate'>false</entry>
<entry key='atrack.custom'>true</entry>
<entry key='atrack.form'>%CI%MV%BV%SA...</entry>
```

The Atrack protocol's flexibility and extensive feature set make it suitable for professional fleet management applications requiring detailed vehicle diagnostics and telemetry data.