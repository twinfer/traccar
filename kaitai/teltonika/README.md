# Teltonika Protocol Documentation

## Overview

Teltonika protocol is a sophisticated binary protocol used by European GPS tracking devices. It supports multiple codec types, extensive IO parameters, and advanced features like BLE beacons, photo transmission, and bidirectional communication.

## Device Identification

### Manufacturer
**Teltonika** (UAB Teltonika Telematics) - Based in Vilnius, Lithuania

### Device Model Series

#### FMB Series (2G Trackers with Bluetooth)
| Model | Description | Key Features |
|-------|-------------|--------------|
| **FMB001** | OBD tracker | Diagnostic data reading |
| **FMB003** | Smallest 2G tracker | Ultra-compact design |
| **FMB010** | Basic OBD tracker | Entry-level OBD |
| **FMB020** | Entry-level tracker | Basic tracking |
| **FMB120** | Advanced tracker | Backup battery, IP67 |
| **FMB125** | RS232/RS485 tracker | Serial interfaces |
| **FMB130** | Advanced tracker | Flexible inputs, CAN adapter support |
| **FMB140** | Ultimate tracker | CAN data reading |
| **FMB150** | CAN processor | Integrated CAN data processor |
| **FMB202/204/208** | Waterproof series | IP67 protection |
| **FMB640** | Professional | GNSS, GSM, Bluetooth |
| **FMB920** | Best-seller | Anti-theft, backup battery |
| **FMB930** | Advanced compact | Professional features |

#### FMC Series (4G LTE Cat 1 Trackers)
| Model | Description | Key Features |
|-------|-------------|--------------|
| **FMC001** | 4G OBD tracker | LTE connectivity |
| **FMC003** | Small 4G OBD | Compact design |
| **FMC125** | 4G with interfaces | RS232/RS485 |
| **FMC130** | Advanced 4G | Fleet management |
| **FMC150** | 4G CAN tracker | CAN data support |
| **FMC225/230/234** | Advanced 4G series | Multiple variants |
| **FMC640** | Professional 4G | Full features |
| **FMC920** | Compact 4G | Best-selling model |

#### FMM Series (4G LTE Cat M1/NB-IoT Trackers)
| Model | Description | Key Features |
|-------|-------------|--------------|
| **FMM001** | LTE-M OBD | Low power IoT |
| **FMM003** | Small LTE-M OBD | Compact IoT |
| **FMM125** | LTE-M interfaces | RS232/RS485 |
| **FMM130** | LTE-M tracker | CAT M1 connectivity |
| **FMM230/250** | Advanced LTE-M | Enhanced features |
| **FMM640** | Professional LTE-M | Full IoT features |
| **FMM920** | Compact LTE-M | Popular model |

#### FMU Series (3G Trackers)
| Model | Description | Key Features |
|-------|-------------|--------------|
| **FMU125** | 3G with interfaces | RS232/RS485 |
| **FMU126** | 3G variant | Enhanced 3G |
| **FMU130** | Professional 3G | GNSS, 3G/GSM |

#### Special Series
- **TAT Series** - Temperature monitoring devices
- **TST Series** - Specialized sensors
- **MTB Series** - Motorcycle trackers
- **FMT Series** - Terminal devices
- **GH Series** - GH3000 uses special codec

### IMEI Patterns
- Standard 15-digit IMEI format
- Example: `350424063817394` (from test data)
- Device identification primarily through IMEI in all messages

### Codec Identification

Different device capabilities are identified by codec type:

| Codec | Value | Typical Devices | Features |
|-------|-------|-----------------|----------|
| GH3000 | 0x07 | GH3000 | Special protocol |
| Codec 8 | 0x08 | All models | Standard AVL |
| Codec 8E | 0x8E | Newer models | Extended IO, BLE |
| Codec 12 | 0x0C | All models | Commands, photos |
| Codec 13 | 0x0D | All models | Command responses |
| Codec 16 | 0x10 | Advanced models | Generation type |

### Feature Support by Series

| Feature | FMB | FMC | FMM | FMU |
|---------|-----|-----|-----|-----|
| 2G GSM | ✓ | Fallback | Fallback | Fallback |
| 3G UMTS | | ✓ | | ✓ |
| 4G LTE Cat 1 | | ✓ | | |
| 4G LTE Cat M1 | | | ✓ | |
| NB-IoT | | | ✓ | |
| Bluetooth | ✓ | ✓ | ✓ | |
| CAN Bus | Select | Select | Select | Select |
| RS232/485 | Select | Select | Select | Select |
| 1-Wire | ✓ | ✓ | ✓ | ✓ |
| BLE Beacons | ✓ | ✓ | ✓ | |
| OBD-II | Select | Select | Select | |

### Common IO Elements by Device Type

#### All Devices
- Digital inputs (1-4)
- Analog inputs (9-10)
- Battery voltage (67)
- External voltage (66)
- Ignition (239)
- Movement (240)
- Odometer (16)

#### Advanced Models (FMB/C/M x30+)
- CAN data elements
- Driver ID (78)
- Accelerometer (17-19)
- VIN (256)
- DTCs (281)

#### BLE-Capable Models
- iBeacon data (385)
- Eddystone beacons
- BLE sensors (548, 10828-10831)
- Temperature/humidity sensors

### Port Configuration
- Default port: 5027 (Traccar)
- Protocol: teltonika
- UDP support: Yes (different packet structure)

### Device Configuration Tools
- **Teltonika Configurator** - Official configuration software
- Model-specific firmware versions
- Over-the-air (OTA) configuration support

### Identification Best Practices

1. **Check Codec Type**
   - Codec 8E indicates BLE support
   - Codec 16 indicates newest features

2. **Monitor IO Elements**
   - Different models report different IO sets
   - Advanced models have more IO elements

3. **Feature Detection**
   - BLE beacon support (IO 385)
   - CAN data availability
   - Photo transmission capability

4. **Network Technology**
   - FMB = 2G primary
   - FMC = 4G LTE Cat 1
   - FMM = LTE Cat M1/NB-IoT
   - FMU = 3G UMTS

## Protocol Structure

### TCP Mode Frame
```
+----------+--------+--------+------+--------+
| Preamble | Length | Codec  | Data | CRC    |
+----------+--------+--------+------+--------+
| 4 bytes  | 4 bytes| 1 byte | var  | 4 bytes|
+----------+--------+--------+------+--------+
```

- **Preamble**: Always `0x00000000`
- **Length**: Data field length (Big Endian)
- **Codec**: Message type (08, 8E, 0C, 0D, 10)
- **Data**: Codec-specific payload
- **CRC**: CRC16-IBM checksum

### UDP Mode Frame
```
+------+--------+--------+--------+--------+------+--------+
| Len  | Packet | Packet | Unused | IMEI   | Data | Unused |
|      | ID     | Type   |        |        |      |        |
+------+--------+--------+--------+--------+------+--------+
| 2 b  | 2 b    | 1 b    | 1 b    | 8 b    | var  | 2 b    |
+------+--------+--------+--------+--------+------+--------+
```

## Codec Types

| Codec | Value | Description |
|-------|-------|-------------|
| GH3000 | 0x07 | Special codec for GH3000 devices |
| Codec 8 | 0x08 | Standard AVL data |
| Codec 8 Extended | 0x8E | Extended AVL with variable IO |
| Codec 12 | 0x0C | Commands and serial data |
| Codec 13 | 0x0D | GPRS commands |
| Codec 16 | 0x10 | Enhanced with generation type |

## AVL Data Structure

### AVL Packet (Codec 8/8E/16)
```
+----------+--------+---------+----------+
| AVL Data | Record | Records | Record   |
| Count    | Count  | ...     | Count    |
+----------+--------+---------+----------+
| 1 byte   | 1 byte | var     | 1 byte   |
+----------+--------+---------+----------+
```

### AVL Record
```
+-----------+----------+------+-----------+
| Timestamp | Priority | GPS  | IO Data   |
+-----------+----------+------+-----------+
| 8 bytes   | 1 byte   | 15 b | variable  |
+-----------+----------+------+-----------+
```

### GPS Element
```
+----------+---------+---------+-------+-----------+-------+
| Longitude| Latitude| Altitude| Angle | Satellites| Speed |
+----------+---------+---------+-------+-----------+-------+
| 4 bytes  | 4 bytes | 2 bytes | 2 b   | 1 byte    | 2 b   |
+----------+---------+---------+-------+-----------+-------+
```

- **Longitude/Latitude**: Degrees × 10,000,000 (signed)
- **Altitude**: Meters
- **Angle**: Degrees (0-360)
- **Satellites**: Number of visible satellites
- **Speed**: km/h

### IO Element Structure

#### Standard (Codec 8)
```
+--------+--------+--------+--------+--------+
| Event  | Total  | 1-byte | 2-byte | 4-byte |
| ID     | Count  | IOs    | IOs    | IOs    |
+--------+--------+--------+--------+--------+
| 1 byte | 1 byte | var    | var    | var    |
+--------+--------+--------+--------+--------+
```

#### Extended (Codec 8E)
Adds support for:
- 8-byte IO elements
- X-byte (variable length) IO elements

#### Enhanced (Codec 16)
Adds:
- Generation type byte before Event ID
- 16-byte IO elements

## Common IO Elements

### Digital/Analog
| ID | Description | Unit |
|----|-------------|------|
| 1-4 | Digital Inputs | 0/1 |
| 9-10 | Analog Inputs | mV |
| 66 | External Voltage | mV |
| 67 | Battery Voltage | mV |
| 179-180 | Digital Outputs | 0/1 |

### Movement/Position
| ID | Description | Unit |
|----|-------------|------|
| 16 | Total Odometer | m |
| 17 | X Acceleration | mG |
| 18 | Y Acceleration | mG |
| 19 | Z Acceleration | mG |
| 24 | GPS Speed | km/h |
| 181 | PDOP | × 0.1 |
| 182 | HDOP | × 0.1 |

### Engine/Vehicle
| ID | Description | Unit |
|----|-------------|------|
| 12 | Fuel Used | L |
| 13 | Fuel Rate | L/h |
| 78 | Driver ID | RFID |
| 239 | Ignition | 0/1 |
| 240 | Movement | 0/1 |
| 256 | VIN | String |
| 281 | DTCs | String |

### Network
| ID | Description | Unit |
|----|-------------|------|
| 11 | ICCID | String |
| 21 | GSM Signal | dBm |
| 241 | Operator | Code |
| 636 | 4G Cell ID | ID |

### BLE/Sensors
| ID | Description | Format |
|----|-------------|--------|
| 385 | BLE Beacons | iBeacon |
| 548 | BLE Tags | Custom |
| 10828-10831 | BLE Sensor Data | Various |

## Commands

### Command Structure (Codec 12)
```
+--------+--------+--------+--------+--------+--------+
| Codec  | Cmd Qty| Type   | Cmd Len| Command| Cmd Qty|
+--------+--------+--------+--------+--------+--------+
| 0x0C   | 1 byte | 1 byte | 4 bytes| ASCII  | 1 byte |
+--------+--------+--------+--------+--------+--------+
```

### Supported Commands
- **Engine Stop**: `setdigout 1`
- **Engine Resume**: `setdigout 0`
- **Custom**: Any ASCII command or hex data

### Response Format (Codec 13)
```
+--------+--------+--------+--------+--------+--------+
| Codec  | Resp Q | Type   | Resp Ln| Response| Resp Q|
+--------+--------+--------+--------+--------+--------+
| 0x0D   | 1 byte | 1 byte | 4 bytes| ASCII  | 1 byte |
+--------+--------+--------+--------+--------+--------+
```

## Photo Transmission

Photos are transmitted using Codec 12 with special handling:

1. **Photo Start**: Contains image metadata
2. **Photo Data**: Chunks up to 2048 bytes
3. **Photo Done**: Marks completion
4. **Retransmission**: Server can request missing chunks

## BLE Beacon Formats

### iBeacon (IO 385)
```
UUID (16 bytes) + Major (2 bytes) + Minor (2 bytes) + RSSI (1 byte)
```

### Eddystone
```
Namespace (10 bytes) + Instance (6 bytes) + RSSI (1 byte)
```

### BLE Sensor Data
- Temperature (°C × 10)
- Humidity (%)
- Battery (mV)
- Movement counter

## CRC Calculation

Uses CRC16-IBM algorithm:
- Polynomial: 0xA001
- Initial value: 0x0000
- Calculated over Codec + Data fields

## Example Data

### Basic Position (Codec 8)
```
00000000 00000042 8E010000 016818D5 00580009 C28D9F1C B3757A00
BE00C60F 00530000 06F00115 03C80001 011D00FC 00074237 99180053
CDF80DCE 426F430F 88190BB8 560BB802 F100005A A1100028 87E00001
0000EE8D
```

### Extended with BLE (Codec 8E)
```
00000000 00000076 8E010000 018FDC4B 27CB015B 3E33CEEF A5290300
09013F0E 00000224 00010000 00000000 00000001 02240049 010F0001
C60106BA BBF36300 55020280 6D0F0001 CA010634 56555565 69020280
6B0F0001 D1010646 79754254 50020280 690B0001 C90106FA 54BA8D00
550B0001 CF0106CA BBF36300 55010000 5455
```

## Device Models

Teltonika manufactures various device series:
- **FMB**: Basic trackers (FMB120, FMB140, etc.)
- **FMC**: Advanced trackers with CAN
- **FMM**: Motorcycle/asset trackers
- **FMU**: Industrial/heavy machinery
- **TAT**: Temperature monitoring
- **TST**: Specialized sensors

Each model may have specific IO interpretations and features.