# Eelink Protocol

The Eelink protocol is a comprehensive GPS tracking protocol developed by Shenzhen Eelink Communication Technology Co., Ltd. This protocol supports both legacy and modern message formats with extensive telemetry capabilities including cellular network positioning, WiFi location services, OBD-II diagnostics, and environmental monitoring.

## Protocol Overview

**Type:** Binary  
**Manufacturer:** Shenzhen Eelink Communication Technology Co., Ltd.  
**Primary Use:** Vehicle tracking, asset monitoring, personal safety  
**Data Format:** Binary packets with type-length-value structure  
**Bidirectional:** Yes (commands and responses)

## Message Structure

### Standard Format
```
Header: 0x6767 (2 bytes)
Type: Message type (1 byte)
Length: Payload length (2 bytes)
Sequence: Message sequence number (2 bytes)
Payload: Variable length data
```

### UDP Format (Some models)
```
UDP Header: "EL" + Length (2) + Reserved (2) + Device ID (8)
Message: Standard format follows
```

## Key Features

- **Dual Message Format**: Legacy (simple) and modern (extended) protocols
- **Network Positioning**: Cellular tower triangulation and WiFi MAC scanning
- **Environmental Sensors**: Temperature, humidity, illuminance, CO2 monitoring
- **Beacon Support**: BLE beacon detection and sensor data integration
- **OBD-II Integration**: Vehicle diagnostics and telematics data
- **LTE/4G Support**: Modern cellular network compatibility

## Device Identification

### Commercial Device Models

#### Vehicle GPS Trackers
- **TK Series** (Basic to Advanced)
  - TK115, TK116: Basic vehicle trackers (TK116 marketed as "low cost")
  - TK119: Basic vehicle tracker with temperature monitoring (TK119-T variant)
  - TK121, TK121-S: Compact vehicle trackers, "smallest in class"
  - TK319, TK319-H, TK319-L: Advanced 3G/4G vehicle trackers
  - TK418, TK419: Latest 4G GPS tracker models with fleet management

#### Portable/Personal Trackers
- **GPT Series** (Personal/Portable)
  - GPT06-3G: 3G portable tracker
  - GPT09: Magnetic GPS tracker with 14,500mAh battery (3-year standby)
  - GPT12, GPT12-L: Super long standby trackers (NB-IoT/LTE-M)
  - GPT15, GPT18: Personal/luggage trackers (GPT18 is watch tracker)
  - GPT19, GPT19-H: 3G long standby trackers
  - GPT26, PT26: Magnetic trackers with 30-day rechargeable battery
  - GPT46, GPT49: 4G GPS trackers with smart alerts
- **K30**: Portable tracker with WiFi positioning

#### OBD Trackers
- **GOT Series** (OBD-II)
  - GOT08, GOT10: Vehicle telematics units for OBD-II port

#### Specialized Devices
- **Temperature Monitoring**: TK108, GPT06-T, TK119-T, TPT02
- **IoT Sensors**: BTT01 with BLE 5.0 and temperature sensors

### Physical Identification Features
- **Size Example**: TK319-H: 89mm × 37mm × 12mm
- **LED Indicators**: RED LED flashing patterns
  - Fast flicker (1 second): Searching for GSM network
  - Slow flicker (5 seconds): Connected to network
- **Magnetic Mounting**: Many models with anti-removal sensors
- **Waterproof**: IP65 rating on newer models
- **Materials**: Plastic housing, various colors available

### IMEI and Device Identification
- **Primary ID**: Standard 15-digit IMEI
- **Location**: Printed on device casing or packaging
- **Protocol ID**: 8-byte device identifier derived from IMEI
- **No specific IMEI ranges**: Manufactured by Eelink Technology

### Protocol Detection Methods

#### Message Type Identification
```
0x01: LOGIN - Device registration
0x02: GPS (old) - Basic GPS data
0x03: HEARTBEAT - Keep-alive message
0x04: ALARM (old) - Alarm conditions
0x12: NORMAL (new) - Extended GPS data
0x14: WARNING (new) - Modern alarm format
0x80: DOWNLINK - Server response
```

#### Unique Features
- **UDP Header**: "EL" signature for some models
- **Extended Data**: WiFi MAC addresses, cellular tower info
- **Environmental**: Temperature, humidity, illuminance, CO2
- **Beacon Integration**: BLE sensor data parsing
- **LTE Support**: Advanced cellular network information

### Alarm Codes (Eelink-Specific)
```
0x01: Power off        0x81: Low speed
0x02: SOS panic        0x82: Overspeed
0x03: Low battery      0x83: Geofence enter
0x04: Vibration        0x84: Geofence exit
0x08: GPS antenna cut  0x85: Accident
0x25: Device removal   0x86: Fall down
```

## Common Applications

- **Fleet Management**: Commercial vehicle tracking and telematics
- **Personal Safety**: Family member and elderly monitoring
- **Asset Protection**: Valuable equipment and vehicle security
- **Cold Chain**: Temperature-sensitive cargo monitoring
- **Logistics**: Package and shipment tracking

## Clone Device Warning

⚠️ **Genuine Device Verification**
- Official Eelink branding and model numbers (TK, GPT, GOT series)
- Characteristic LED flashing patterns as described
- Quality construction with proper certifications
- Available through authorized Eelink distributors

Many generic GPS trackers use Eelink hardware/firmware through OEM arrangements. These devices may be compatible but verify protocol compatibility before purchase.

## Traccar Configuration

```xml
<entry key='eelink.port'>5013</entry>
```

The Eelink protocol's comprehensive feature set and multiple device formats make it suitable for diverse tracking applications from basic vehicle monitoring to advanced environmental sensor networks.