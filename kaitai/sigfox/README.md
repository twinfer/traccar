# Sigfox Protocol

The Sigfox protocol is an ultra-narrowband (UNB) wireless communication standard designed for low-power wide-area IoT networks. Developed by Sigfox S.A., a French company founded in 2009, Sigfox operates a global 0G network serving millions of IoT devices with minimal power consumption and long-range connectivity.

## Protocol Overview

**Type:** HTTP/JSON with binary payload  
**Manufacturer:** Sigfox S.A. (France)  
**Primary Use:** Low-power wide-area IoT, sensor networks  
**Data Format:** JSON over HTTP with hex-encoded binary payload  
**Network:** Ultra-narrowband (UNB) sub-GHz frequency bands  
**Coverage:** Global network in 75+ countries

## Message Structure

### HTTP Callback Format
```
POST /callback HTTP/1.1
Content-Type: application/json

{
  "device": "BFE47E",
  "time": 1590497040,
  "data": "10297eb01e621122070000be",
  "seqNumber": 8,
  "snr": "8.82",
  "rssi": "-141.00",
  "station": "140A",
  "lat": "52.0",
  "lng": "-8.0"
}
```

### Field Details
- **device**: 6-character hex device ID (32-bit unique identifier)
- **time**: Unix timestamp (seconds since epoch)
- **data**: Hex-encoded binary payload (0-24 hex chars = 0-12 bytes)
- **seqNumber**: 12-bit frame counter (0-4095, rolls over)
- **snr**: Signal-to-noise ratio in dB
- **rssi**: Received signal strength indicator in dBm
- **station**: Base station identifier
- **lat/lng**: Approximate location (Sigfox network geolocation)

### Alternative Fields
- **payload**: Alternative to "data" field
- **deviceId**: Alternative to "device" field
- **positionTime**: GPS fix timestamp
- **lastSeen**: Last communication timestamp
- **moving**: Motion detection boolean
- **magStatus**: Magnetic tamper detection
- **temperature**: Device temperature
- **battery**: Battery voltage

## Binary Payload Structure

### Payload Constraints
- **Maximum Size**: 12 bytes (96 bits)
- **Allowed Sizes**: 0, 4, 8, or 12 bytes only
- **Encoding**: Binary (not text) for efficiency
- **Transmission**: 3 repetitions on different frequencies

### Common Payload Formats

#### 1-Byte Payload (Event Only)
```
[Event Code:1]
```
- 0x22: SOS event
- 0x62: Panic button

#### 8-Byte Position Payload
```
[Header:1][Latitude:4][Longitude:4][Battery:1]
```
- Header 0x0F: Valid GPS position
- Header 0x1F: Valid GPS position (alternative)
- Coordinates: Signed magnitude format × 0.000001

#### 12-Byte Extended Payload
```
[Header:1][Flags:1][Lat:4][Lng:4][Course:1][Speed:1][Battery:1]
```
- Header 0x00-0x03: Position with motion data
- Little-endian coordinates × 0.0000001
- Course in 2-degree increments
- Speed in km/h

#### Amber Device Format
```
[Header:1][Flags:1][Battery:1][Temp:1][Latitude:4][Longitude:4]
```
- Motion flag in bit 1 of flags
- Battery voltage × 0.02V
- Temperature in Celsius (signed)
- Coordinates ÷ 60,000

#### Structured Payload (TLV)
```
[Event:1][Type:1][Data:N]...
```
- 0x01: Medium precision position (3+3 bytes)
- 0x02: Float precision position (4+4 bytes)
- 0x03: Temperature (1 byte × 0.5°C)
- 0x04: Battery voltage (1 byte × 0.1V)
- 0x05: Battery percentage (1 byte)
- 0x06: WiFi beacon (6+1 bytes)
- 0x09: Speed (1 byte km/h)

## Key Features

- **Ultra-Low Power**: Years of battery life
- **Long Range**: 10-50 km in rural areas, 3-10 km in cities
- **Low Data Rate**: 100 bps maximum
- **Message Limits**: 140 uplink messages/day, 4 downlink/day
- **Global Coverage**: Single subscription worldwide
- **No Infrastructure**: Uses existing base stations
- **Security**: AES encryption and authentication
- **Geolocation**: Network-based positioning (1-10 km accuracy)

## Device Identification

### Company Information
**Sigfox S.A.**  
- Founded: 2009 in Toulouse, France
- Founders: Ludovic Le Moan, Christophe Fourtet
- Headquarters: Labège, France
- Status: Acquired by UnaBiz (2022) after bankruptcy
- Legacy: Pioneer of LPWAN technology

### Global Network
- **Coverage**: 75+ countries
- **Base Stations**: 50,000+ worldwide
- **Devices**: 15+ million connected
- **Partners**: 600+ ecosystem partners
- **Frequency**: Sub-GHz ISM bands (868 MHz Europe, 902 MHz Americas)

### Regional Frequencies
- **Europe**: 868 MHz (ETSI)
- **North America**: 902 MHz (FCC)
- **Asia-Pacific**: 923 MHz (various)
- **Japan**: 920 MHz
- **South Korea**: 923 MHz

### Network Operators

#### Primary Operators
- **Sigfox France**: Original network operator
- **UnaBiz**: Current global operator (Singapore)
- **SIGFOX USA**: North American operations
- **SIGFOX Japan**: KCCS Mobile Engineering
- **SIGFOX Australia**: Thinxtra

#### Regional Partners
- **Germany**: WND Group
- **UK**: WND Group
- **Spain**: Sigfox Spain
- **Italy**: Sigfox Italy
- **Brazil**: WND Brasil
- **Mexico**: Sigfox Mexico

### Device Categories

#### Asset Trackers
- **Location**: GPS + Sigfox for remote assets
- **Battery Life**: 2-10 years depending on reporting frequency
- **Use Cases**: Containers, trailers, equipment tracking

#### Environmental Sensors
- **Temperature**: Cold chain monitoring
- **Humidity**: Agricultural applications
- **Air Quality**: Smart city deployments
- **Water**: Leak detection, quality monitoring

#### Utility Meters
- **Smart Water**: Remote meter reading
- **Smart Gas**: Consumption monitoring
- **Smart Electric**: Grid monitoring
- **Smart Heating**: Energy management

#### Security Devices
- **Panic Buttons**: Personal safety devices
- **Intrusion**: Building security
- **Fire Detection**: Smoke and heat sensors
- **Vehicle**: Anti-theft and tracking

### Technical Specifications

#### Radio Characteristics
- **Modulation**: DBPSK (Differential Binary Phase Shift Keying)
- **Bandwidth**: 100 Hz (ultra-narrowband)
- **Power**: +14 dBm Europe, +22 dBm Americas
- **Antenna**: Omnidirectional, typically 868/915 MHz
- **Range**: Up to 50 km line-of-sight

#### Protocol Stack
- **Physical**: UNB DBPSK modulation
- **MAC**: Frame repetition (3×) with frequency hopping
- **Network**: Device ID + sequence number
- **Application**: JSON/HTTP callbacks

#### Message Transmission
- **Redundancy**: 3 identical frames on different frequencies
- **Frequency Hopping**: Pseudo-random channel selection
- **Time Diversity**: Transmission delays between repeats
- **Error Correction**: No retransmission (fire-and-forget)

### Device Lifecycle

#### Registration
1. Device ID assignment (32-bit unique)
2. Network subscription activation
3. Callback URL configuration
4. Geolocation service setup

#### Operation
1. Device transmits binary payload
2. Multiple base stations receive signal
3. Backend processes and deduplicates
4. HTTP callback sent to application server
5. Optional downlink message queued

#### Power Management
- **Sleep Mode**: Microamp consumption
- **Wake Patterns**: Timer, interrupt, or sensor-triggered
- **Battery Types**: Primary lithium (non-rechargeable)
- **Lifetime**: 2-20 years typical

### Common Applications

- **Agriculture**: Soil monitoring, livestock tracking
- **Smart Cities**: Parking sensors, waste management
- **Industrial IoT**: Machine monitoring, predictive maintenance
- **Logistics**: Package tracking, supply chain visibility
- **Utilities**: Smart metering, infrastructure monitoring
- **Healthcare**: Patient monitoring, medication adherence
- **Environmental**: Air quality, noise monitoring
- **Security**: Intrusion detection, panic buttons

## Protocol Implementation

### Callback Processing
1. Receive HTTP POST with JSON payload
2. Extract device ID and timestamp
3. Decode hex data field to binary
4. Parse binary based on device type/configuration
5. Store position and sensor data
6. Respond with HTTP 200 OK

### Binary Payload Parsing
1. Determine payload length (0, 4, 8, or 12 bytes)
2. Identify format based on header byte or device type
3. Extract coordinates using appropriate scaling
4. Parse sensor data according to format
5. Handle invalid positions (0x80000000)

### Position Calculation
- **Signed Magnitude**: Special encoding for compact coordinates
- **Little-Endian**: Some devices use LE byte order
- **Scaling Factors**: Various (÷10000000, ÷60000, etc.)
- **Invalid Markers**: Specific values indicate no GPS fix

### Error Handling
- **Invalid Payload**: Malformed hex data
- **Unknown Device**: Unregistered device ID
- **Sequence Gaps**: Missing messages (normal)
- **Position Errors**: Use network geolocation fallback

## Market Impact

### Technology Innovation
- **LPWAN Pioneer**: First global LPWAN network
- **0G Concept**: Ultra-low-power "0G" network paradigm
- **Ecosystem**: Enabled thousands of IoT device manufacturers
- **Standards**: Influenced 3GPP NB-IoT development

### Business Model
- **Network-as-a-Service**: Simplified IoT connectivity
- **Global Roaming**: Single subscription worldwide
- **Partner Ecosystem**: Chip vendors, device makers, integrators
- **Vertical Solutions**: Industry-specific offerings

## Current Status (2024)

### Post-Bankruptcy Recovery
- **New Owner**: UnaBiz (Singapore-based)
- **Network Operations**: Continued global service
- **Technology Evolution**: Focus on hybrid solutions
- **Market Position**: Established LPWAN provider

### Competitive Landscape
- **LoRaWAN**: Open standard alternative
- **NB-IoT**: Cellular LPWAN technology
- **LTE-M**: Cellular IoT standard
- **Wi-Fi HaLow**: Long-range Wi-Fi

## Traccar Configuration

```xml
<entry key='sigfox.port'>5080</entry>
```

### Callback Configuration
```
POST https://your-server.com:5080/
Content-Type: application/json

Callback data: 
{
  "device": "{device}",
  "time": "{time}",
  "data": "{data}",
  "seqNumber": "{seqNumber}"
}
```

### Protocol Features
- **HTTP/JSON API**: RESTful callback interface
- **Binary Payloads**: Efficient data encoding
- **Global Reach**: Worldwide IoT connectivity
- **Ultra-Low Power**: Multi-year battery life
- **Simple Integration**: No complex protocols

The Sigfox protocol represents a pioneering approach to global IoT connectivity, combining ultra-low power consumption with worldwide coverage for battery-powered devices that need to transmit small amounts of data infrequently.