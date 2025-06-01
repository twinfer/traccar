# GPS103/TK103 Protocol Documentation

## Overview

The GPS103/TK103 protocol is one of the most widely cloned GPS tracker protocols. It's a text-based protocol using comma-separated values with many variations implemented by different manufacturers.

## Device Identification

### Manufacturers
The TK103 protocol is implemented by numerous manufacturers worldwide:
- **Xexun** - Original TK102/TK103 manufacturer
- **Coban** - Major manufacturer of GPS103-compatible devices
- Various Chinese, Thai, and other Asian manufacturers
- Numerous white-label and rebranded versions

### Commercial Device Models

#### Primary Models
- **TK102** / **TK102B** - Original basic tracker
- **TK103** / **TK103A** / **TK103B** - Most common vehicle tracker
- **GPS103** / **GPS103A** / **GPS103B** - Alternative naming
- **TK104** - Enhanced version
- **TK106** - Advanced features variant
- **TK110** - Motorcycle/vehicle tracker

#### Regional Variants
The protocol is especially popular in:
- **Africa**: Egypt, Nigeria, South Africa
- **Latin America**: Argentina, Peru, Brazil, Mexico
- **Asia**: India, Thailand, Indonesia, Philippines

### IMEI Patterns
- Standard 15-digit IMEI format
- Example patterns from real devices:
  - `865456055519122`
  - `864035052942928`
  - `359586015829802`
- Format in protocol: `imei:123456789012345`

### Device Identification Methods

1. **Login Handshake**
   ```
   Device: ##,imei:359586015829802,A
   Server: LOAD
   ```

2. **Message Pattern Analysis**
   - Standard format devices use `F/L` for GPS status
   - Alternative format devices use numeric GPS status
   - OBD-capable devices send `OBD` messages

3. **Alarm Type Support**
   Different models support different alarm sets:
   - Basic: `help me`, `low battery`, `move`, `speed`
   - Advanced: `door alarm`, `acc on/off`, `sensor alarm`
   - Professional: `DTC`, `oil`, temperature readings

### Feature Matrix by Model

| Model | GPS | LBS | OBD | Photo | Fuel | Temp | RFID | Voice |
|-------|-----|-----|-----|-------|------|------|------|-------|
| TK102 | ✓ | | | | | | | |
| TK103A | ✓ | ✓ | | | ✓ | | | |
| TK103B | ✓ | ✓ | | | ✓ | ✓ | | ✓ |
| GPS103 Pro | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |

### Common Features

#### All Models
- Real-time GPS tracking
- GSM/GPRS connectivity (2G)
- SOS panic button
- Geo-fence support
- Speed alerts
- Remote engine cut-off

#### Model-Specific Features

**TK102 Series**
- Basic tracking
- Built-in battery
- Portable design
- Personal/pet tracking

**TK103 Series**
- Vehicle installation
- Multiple I/O ports
- Fuel monitoring option
- Door/ACC detection
- External antenna connections

**Advanced Models**
- OBD-II interface
- Dual fuel tank monitoring
- Temperature sensors (T:+28.0)
- RFID driver identification
- Photo transmission (vt/vr packets)
- Voice monitoring
- CAN bus data reading

### Port Configuration
- Default port: 5001 (Traccar)
- Protocol: gps103
- Alternative ports: 5002, 5006 (some variants)

### Important Notes

⚠️ **Warning**: Due to extensive cloning, devices sold as "TK103" or "GPS103" can vary significantly:
- Protocol implementation differences
- Feature availability
- Command compatibility
- Message format variations

### Clone Identification Tips

1. **Test Core Features**
   ```
   ##,imei:123456789012345,A  (Check login response)
   imei:123456789012345,tracker  (Check position format)
   ```

2. **Command Compatibility**
   - Test basic commands: B, C, D
   - Advanced commands may not work on all clones

3. **Message Format Variants**
   - Standard: Uses `F/L` status, semicolon terminator
   - Alternative: Uses numeric status, asterisk terminator
   - Mixed: Some devices support both formats

4. **Quality Indicators**
   - Consistent IMEI reporting
   - Stable connection maintenance
   - Accurate GPS reporting
   - Proper alarm functionality

### Known Variants and Quirks

1. **Login Variations**
   - Some devices skip login handshake
   - Others use modified LOAD response

2. **Coordinate Formats**
   - Most use DDMM.MMMM format
   - Some clones use decimal degrees

3. **Time Zones**
   - Original calculates UTC from longitude
   - Some clones send local time
   - Others always send UTC

4. **Command Responses**
   - Not all devices acknowledge commands
   - Response format varies by manufacturer

## Connection Flow

1. **Login**: Device sends `##,imei:359586015829802,A`
2. **Server Response**: `LOAD`
3. **Heartbeat**: Device sends IMEI only: `359586015829802`
4. **Server Response**: `ON`

## Message Formats

### Standard Position Message
```
imei:{imei},{alarm},{date}{time},{contact},F/L,{time}.{ms},{validity},{lat},{lat_hem},{lon},{lon_hem},{speed},{course},{date2},{unknown}*{checksum}
```

Example:
```
imei:359586015829802,tracker,0809231429,13554900601,F,062947.294,A,2234.4026,N,11354.3277,E,0.00,;
```

### Alternative Format
```
imei:{imei},{name},{event},{sensor_id},{voltage},{time},{date},{area},{gps_status},{lat},{lon},{speed},{course},{altitude},{hdop},{satellites},{ignition},{charge},{error},*
```

Example:
```
imei:861359038609986,Equipo 1,---,------,----,214734,241018,26,1,-33.42317,-70.61930,067,229,0674,1.00,08,0,1,---,*
```

### OBD Format
```
imei:{imei},OBD,{datetime},{odometer},{fuel_instant},{fuel_avg},{hours},{speed},{power},{temp},{throttle},{rpm},{battery},{dtcs};
```

Example:
```
imei:868683027758113,OBD,180905200218,,,,0,0,0.39%,70,9.41%,494,0.00,P0137,P0430,;
```

## Field Descriptions

### Common Fields
- **imei**: 15-digit device identifier
- **F/L**: GPS status (F=Fixed/valid, L=Last known position)
- **validity**: A=Active/valid, V=Void/invalid
- **lat_hem**: N=North, S=South
- **lon_hem**: E=East, W=West
- **speed**: Speed in knots
- **course**: Direction in degrees (0-360)

### Alarm/Event Types
| Code | Description |
|------|-------------|
| `help me` | SOS emergency button |
| `low battery` | Low battery warning |
| `stockade` | Geofence violation |
| `move` | Movement detected |
| `speed` | Overspeed alarm |
| `acc on` | Ignition turned on |
| `acc off` | Ignition turned off |
| `door alarm` | Door opened |
| `ac alarm` | Power cut |
| `accident alarm` | Impact detected |
| `sensor alarm` | Vibration detected |
| `bonnet alarm` | Hood/bonnet opened |
| `footbrake alarm` | Brake pressed |
| `DTC` | Diagnostic trouble code |
| `tracker` | Normal position report |

### Special Data Types
- **T:{value}**: Temperature (e.g., `T:+28.0`)
- **oil {value}**: Fuel percentage (e.g., `oil 45.50`)
- **oil1/oil2**: Dual fuel tank readings
- **rfid**: RFID tag number

## Commands

### Command Format
```
**,imei:{imei},{command}
```

### Supported Commands
| Command | Description | Example |
|---------|-------------|---------|
| `B` | Request current location | `**,imei:123456789012345,B` |
| `C,{interval}` | Set tracking interval | `**,imei:123456789012345,C,05m` |
| `D` | Stop periodic tracking | `**,imei:123456789012345,D` |
| `J` | Stop engine | `**,imei:123456789012345,J` |
| `K` | Resume engine | `**,imei:123456789012345,K` |
| `L` | Arm alarm | `**,imei:123456789012345,L` |
| `M` | Disarm alarm | `**,imei:123456789012345,M` |
| `E` | SOS response | Sent automatically |
| `160` | Request photo | `**,imei:123456789012345,160` |

### Interval Format
- Minutes: `05m` (5 minutes)
- Hours: `02h` (2 hours)
- Seconds: `30s` (30 seconds)

## Photo Transmission

Photos are transmitted in multiple packets:

1. **Announcement**: `imei:123456,vt14,{datetime},...` (14 packets to follow)
2. **Data Packets**: `imei:123456,vr,{base64_data},{sequence},*`
3. Server reconstructs photo from all packets

## Cell Tower Fallback

When GPS fix is unavailable (L status), location includes cell tower data:
```
imei:123456,tracker,,,L,,,0000.0000,N,00000.0000,W,0.00,,{mcc},{mnc},{lac},{cellid}
```

## Time Handling

- Device sends local time
- Time zone calculated from longitude
- Format: `HHMMSS.SSS` (time) and `DDMMYY` (date)

## Message Terminators

Messages can end with:
- `;` - Standard terminator
- `*` - Alternative format
- `\r\n` or `\n` - Line endings

## Validation

- Some messages include checksum after `*`
- Checksum format varies by manufacturer
- Not all devices send checksums

## Example Messages

### Normal Position
```
imei:868683028569612,tracker,181018165830,,F,165824.000,A,5126.1187,N,00660.8629,W,0.01,0.00,,0,0,0.00%,,;
```

### SOS Alert
```
imei:359586015829802,help me,0809231429,13554900601,F,062947.294,A,2234.4026,N,11354.3277,E,0.00,;
```

### Temperature Report
```
imei:352696044884952,tracker,1708121748,,F,104828.000,A,0444.3301,N,07606.9783,W,0.61,11.61,,1,0,0.03%,,T:+19.0;
```

### Cell Tower Only
```
imei:864895030279986,tracker,190619173327,,L,,,1906.0,,,,0,0,0.0,,262,2,280B,D20E;
```