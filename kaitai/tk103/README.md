# TK103 Protocol

The TK103 protocol is a versatile GPS tracking protocol used by various Chinese GPS tracker manufacturers. This protocol supports multiple message formats including standard position reports, battery monitoring, cell tower/WiFi positioning, and vehicle diagnostics. While commonly associated with Xexun TK103 devices, the protocol is used by many compatible trackers.

## Protocol Overview

**Type:** Text-based ASCII with parentheses framing  
**Manufacturer:** Multiple (Xexun, Coban, generic Chinese manufacturers)  
**Primary Use:** Vehicle tracking, personal tracking, asset monitoring  
**Data Format:** Parentheses-wrapped messages with various command types  
**Bidirectional:** Yes (commands and responses)

## Message Structure

All messages are wrapped in parentheses with comma-separated fields:

### Standard Position Format
```
([device_id],[command],[date],[validity],[latitude][NS],[longitude][EW],[speed][time][course/extended_data])
```

### Alternative Formats
- **Battery Status**: `([device_id],ZC20,[date],[time],[battery_level],[battery_voltage],[power_voltage],[installed])`
- **Cell Tower**: `([device_id]BP05[imei],{cell_data},[odometer])`
- **Network Info**: `([device_id],BZ00,[mcc],[mnc],[lac],[cid],...)`
- **LBS+WiFi**: `([device_id],[DWxx],[mcc],[mnc],[lac],[cid],[wifi_count],[wifi_data],[date],[time])`
- **VIN Report**: `([device_id]BV00[17-char-vin])`
- **BMS Data**: `([device_id]BS50[hex_data])`

## Key Features

- **Multiple Command Types**: 50+ command codes for different functions
- **Alarm System**: 6 alarm types with dedicated message formats
- **Cell Tower/WiFi**: LBS positioning with optional WiFi AP data
- **Battery Monitoring**: Detailed power status reporting
- **Vehicle Integration**: VIN reading, ignition status, fuel level
- **BMS Support**: Battery Management System data (BS50/BS51)
- **Extended I/O**: Multiple digital inputs/outputs

## Device Identification

### Commercial Device Models

#### Original TK103 Series
- **TK103A**: Basic vehicle GPS tracker
  - External GPS/GSM antennas
  - Remote control support
  - Engine cut-off relay
  - Backup battery
  - SOS button
  
- **TK103B**: Enhanced version
  - Improved GPS sensitivity
  - Additional I/O ports
  - SD card slot (some variants)
  - Microphone for voice monitoring

- **TK103-2**: Dual-SIM variant
  - Same features as TK103B
  - Dual SIM for network redundancy
  - Extended temperature range

#### Compatible Devices
Many manufacturers produce TK103-protocol compatible devices:
- **Coban TK103**: Popular clone series
- **GPS103**: Generic variants
- **TK103A/B clones**: Various manufacturers
- **Car GPS Tracker 103**: Budget models
- **Vehicle Tracker VT103**: Commercial variants

### Protocol Command Types

#### Position Report Commands
- **BR00**: Standard position report
- **BP00**: Legacy position format
- **BP02**: Compact position format  
- **BP05**: Alternative position format
- **BQ81**: Position with alarm data

#### Status Commands (ZC Series)
- **ZC11**: Movement alarm
- **ZC12**: Low battery alarm
- **ZC13**: Power cut alarm
- **ZC15**: Ignition on
- **ZC16**: Ignition off
- **ZC17**: Device removal alarm
- **ZC20**: Battery status report
- **ZC25**: SOS alarm
- **ZC26**: Tampering alarm
- **ZC27**: Low power alarm
- **ZC29**: Ignition on (alt)

#### LBS/WiFi Commands (DW Series)
- **DW30-DW3F**: Various LBS/WiFi reports with status
- **DW40-DW4F**: Extended LBS/WiFi formats
- **DW50-DW5F**: Alternative LBS/WiFi formats
- **DW60-DW6F**: Additional variants

#### Special Commands
- **BV00**: VIN number report
- **BS50/BS51**: BMS data packets
- **BZ00**: Network information

### Alarm Types
```
1: Accident/Shock alarm
2: SOS button pressed
3: Vibration detection
4: Low speed alert
5: Overspeed alert
6: Geofence exit
```

### Protocol Detection Features

#### Message Patterns
- Always wrapped in parentheses `()`
- Device ID: 10-15 digits or fixed 12 chars
- Command: 4 characters (e.g., BR00, ZC20)
- Date format: DDMMYY or YYMMDD
- Time format: HHMMSS
- Validity: A (valid) or V (invalid)

#### Extended Data Fields
After basic position data:
- 6 chars: Course or first extended byte
- Charge status (0/1)
- Ignition status (0/1)
- I/O states (3 hex digits)
- Fuel level (3 hex digits)
- Odometer with 'L' prefix

## Common Applications

- **Vehicle Security**: Anti-theft with engine cut-off
- **Fleet Management**: Commercial vehicle tracking
- **Personal Tracking**: Modified for portable use
- **Asset Monitoring**: Container and equipment tracking
- **Driver Behavior**: Speed and route monitoring
- **Maintenance**: Mileage and engine hours tracking

## SMS Command Interface

The TK103 supports extensive SMS commands (password default: 123456):
- **begin123456**: Initialize device
- **admin123456 [phone]**: Set admin number
- **tracker123456**: Start tracking mode
- **monitor123456**: Voice monitoring mode
- **check123456**: Query current location
- **reset123456**: Factory reset
- **reboot123456**: Restart device

## Platform Compatibility

- **Traccar**: Full protocol support with all variants
- **Gurtam Wialon**: TK103 profile available
- **GPSWOX**: Multiple TK103 variants supported
- **GPS-Server**: Compatible
- **OpenGTS**: Basic support
- **GPSGate**: TK103 protocol handler
- **Most Chinese platforms**: Native support

## Traccar Configuration

```xml
<entry key='tk103.port'>5002</entry>
<entry key='tk103.decodeLow'>false</entry>
```

The `decodeLow` parameter enables parsing of additional low-level protocol features.

### Protocol Handshake
Initial connection sequence:
1. Device sends: `##,imei:[IMEI],A;`
2. Server responds: `LOAD`
3. Device begins sending position data

Alternative handshake:
1. Device sends: `[IMEI];`
2. Server responds: `ON`

The TK103 protocol's widespread adoption and extensive command set make it one of the most common protocols in the GPS tracking industry, though implementations may vary slightly between manufacturers.