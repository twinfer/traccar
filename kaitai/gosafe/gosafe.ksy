meta:
  id: gosafe
  title: GoSafe GPS Tracker Protocol (Enhanced)
  file-extension: gosafe
  endian: be
  ks-version: 0.11
  
doc: |
  Enhanced GoSafe GPS tracker protocol implementation supporting both text and binary formats.
  GoSafe is a GPS tracking protocol supporting vehicle and asset tracking applications
  with comprehensive telemetry data including GPS, GSM, OBD-II, temperature sensors,
  and various digital/analog I/O monitoring capabilities.
  
  ## SUPPORTED MANUFACTURERS & MODELS:
  
  ### GoSafe Technology Co., Ltd. (Primary Developer)
  - **G1S** - Basic vehicle tracker with GPS/GSM
  - **G2S** - Advanced tracker with OBD-II support
  - **G737** - Professional fleet management device  
  - **G739** - Heavy-duty vehicle tracker with CAN bus
  - **G758** - Asset tracker with long battery life
  - **G787** - Advanced telematics gateway
  - **G866** - Motorcycle/bike tracker
  - **G980** - High-end fleet device with camera support
  
  ### Compatible OEM Manufacturers:
  - **OriginalGPS**: OG300, OG400 series (GoSafe compatible)
  - **Fleet Complete**: FC100, FC200 tracking devices
  - **Omnitracs**: XRS platform compatible units
  - **PacWest**: PW300, PW400 fleet trackers
  - **AssetTrackr**: AT100, AT200 asset monitoring
  - **FleetLocate**: FL300 series vehicle trackers
  - **GPSGate**: Various OEM devices with GoSafe protocol
  - **Wialon**: Compatible tracking hardware
  
  ## PROTOCOL FEATURES:
  
  ### Text Protocol (*GS format):
  - Header: *GS + protocol version
  - IMEI identification
  - Multiple data sections: GPS, GSM, COT, ADC, DTT, ETD, OBD, TAG, IWD, SYS
  - Section-based parsing with configurable data fields
  - Multiple position reports in single message ($-separated)
  - Human-readable hex event codes
  - Backward compatibility with legacy GS02 format
  
  ### Binary Protocol (0xF8 format):
  - Frame delimiter: 0xF8 (start and end)
  - Escape sequences: 0x1B 0x00 → 0x1B, 0x1B 0xE3 → 0xF8
  - Bitmask-controlled data sections for efficient transmission
  - Compressed IMEI encoding (7 bytes for 15-digit IMEI)
  - Epoch-based timestamps (seconds since 2000-01-01)
  - Message types: 0x41 (event), others for different reports
  - Selective data transmission based on configuration
  
  ## DATA SECTIONS:
  
  ### GPS Section:
  - **Validity**: A (valid) / V (invalid)
  - **Satellites**: Number of satellites in view
  - **Coordinates**: Latitude/longitude in decimal degrees
  - **Speed**: km/h (converted to knots in processing)
  - **Course**: Degrees (0-360)
  - **Altitude**: Meters above sea level
  - **HDOP/VDOP**: Horizontal/Vertical Dilution of Precision
  
  ### GSM Section:
  - **Registration Status**: Network registration state
  - **Signal Strength**: GSM signal level (0-31)
  - **Cell Tower Info**: MCC, MNC, LAC, CID
  - **RSSI**: Received Signal Strength Indicator
  
  ### COT (Counter) Section:
  - **Odometer**: Total distance traveled (meters/km)
  - **Engine Hours**: Format HH-MM-SS or total seconds
  
  ### ADC (Analog-to-Digital Converter) Section:
  - **Power**: Main power supply voltage
  - **Battery**: Backup battery voltage
  - **ADC1/ADC2**: Additional analog inputs
  
  ### DTT (Digital I/O and Status) Section:
  - **Status**: Device status flags (hex)
  - **I/O State**: Digital input/output states (8-bit)
    - Bit 0: Ignition state
    - Bits 1-4: Digital inputs 1-4
    - Bits 5-7: Digital outputs 1-3
  - **Geofence**: Enter/exit geofence IDs
  - **Event Status**: Current event state
  - **Packet Type**: Message classification
  
  ### ETD (Event Data) Section:
  - **Event Data**: Additional event-specific information
  
  ### OBD Section:
  - **OBD Data**: Raw OBD-II diagnostic data
  
  ### TAG Section:
  - **RFID/Tag Data**: RFID card or tag information
  
  ### IWD (iButton/Wire/Driver) Section:
  - **Driver ID**: Driver identification (iButton, RFID)
  - **Temperature Sensors**: Multi-sensor temperature monitoring
    - Data Type 0: Driver identification
    - Data Type 1: Temperature sensor (°C)
  
  ### SYS (System) Section:
  - **Firmware Version**: Device firmware information
  - **Hardware Version**: Hardware revision data
  - **Configuration**: System configuration parameters
  
  ## GEOGRAPHICAL COVERAGE:
  Primary: North America, Europe, Asia-Pacific
  Secondary: Latin America, Middle East, Africa
  
  ## ESTIMATED DEPLOYMENT:
  - 500,000+ active GoSafe devices globally
  - Used by 100+ fleet management companies
  - Compatible with major tracking platforms
  - Popular in taxi, logistics, and construction industries

seq:
  - id: message
    type:
      switch-on: first_byte
      cases:
        0x2A: text_message     # '*' character
        0xF8: binary_message   # Binary frame marker
        _: unknown_format
        
instances:
  first_byte:
    value: _io.read_u1_at(0)
    
types:
  text_message:
    seq:
      - id: header_marker
        contents: [0x2A]  # '*'
      - id: header_gs
        contents: "GS"
        type: str
        encoding: ASCII
      - id: protocol_version
        type: str
        terminator: ','
        encoding: ASCII
      - id: imei
        type: str
        terminator: ','
        encoding: ASCII
      - id: data_content
        type: str
        terminator: '#'
        encoding: ASCII
        if: _io.size > 0
      - id: end_marker
        contents: [0x23]  # '#'
    instances:
      is_legacy_format:
        value: protocol_version == "02"
      parsed_data:
        type: text_data
        if: not is_legacy_format
      legacy_data:
        type: legacy_text_data  
        if: is_legacy_format
        
  text_data:
    seq:
      - id: raw_content
        size-eos: true
    instances:
      sections:
        value: 'raw_content.to_s("ASCII").split("$")'
      position_count:
        value: 'sections.size'
        
  legacy_text_data:
    seq:
      - id: raw_content
        size-eos: true
    instances:
      gps_section:
        value: 'raw_content.to_s("ASCII")'
        
  binary_message:
    seq:
      - id: start_delimiter
        contents: [0xF8]
      - id: protocol_version
        type: u1
      - id: message_type
        type: u1
        enum: binary_message_type
      - id: imei_high
        type: u4
        doc: Upper 32 bits of IMEI
      - id: imei_low
        type: b24
        doc: Lower 24 bits of IMEI
      - id: timestamp
        type: u4
        doc: Seconds since 2000-01-01 00:00:00 UTC
      - id: event_id
        type: u1
        if: message_type == binary_message_type::event_message
      - id: data_mask
        type: u2
        doc: Bitmask indicating which data sections are present
      - id: sys_section
        type: sys_data
        if: has_sys_section
      - id: gps_section
        type: gps_data
        if: has_gps_section
      - id: gsm_section
        type: gsm_data
        if: has_gsm_section
      - id: cot_section
        type: cot_data
        if: has_cot_section
      - id: adc_section
        type: adc_data
        if: has_adc_section
      - id: dtt_section
        type: dtt_data
        if: has_dtt_section
      - id: iwd_section
        type: iwd_data
        if: has_iwd_section
      - id: etd_section
        type: etd_data
        if: has_etd_section
      - id: end_delimiter
        contents: [0xF8]
        
    instances:
      imei_full:
        value: (imei_high << 24) | imei_low
        doc: Complete 15-digit IMEI
      timestamp_unix:
        value: timestamp + 946684800
        doc: Convert to Unix timestamp (add seconds from 1970 to 2000)
      has_sys_section:
        value: (data_mask & 0x0001) != 0
      has_gps_section:
        value: (data_mask & 0x0002) != 0
      has_gsm_section:
        value: (data_mask & 0x0004) != 0
      has_cot_section:
        value: (data_mask & 0x0008) != 0
      has_adc_section:
        value: (data_mask & 0x0010) != 0
      has_dtt_section:
        value: (data_mask & 0x0020) != 0
      has_iwd_section:
        value: (data_mask & 0x0040) != 0
      has_etd_section:
        value: (data_mask & 0x0080) != 0
        
  unknown_format:
    seq:
      - id: data
        size-eos: true
        
  # Binary data section types
  sys_data:
    seq:
      - id: length
        type: u1
      - id: content
        size: length
        
  gps_data:
    seq:
      - id: length
        type: u1
      - id: fragment_mask
        type: u2
      - id: gps_flags
        type: u1
        if: has_gps_flags
      - id: latitude_raw
        type: s4
        if: has_coordinates
      - id: longitude_raw
        type: s4
        if: has_coordinates
      - id: speed_raw
        type: s2
        if: has_speed
      - id: course
        type: u2
        if: has_course
      - id: altitude
        type: s2
        if: has_altitude
      - id: hdop_raw
        type: u2
        if: has_hdop
      - id: vdop_raw
        type: u2
        if: has_vdop
        
    instances:
      has_gps_flags:
        value: (fragment_mask & 0x0001) != 0
      has_coordinates:
        value: (fragment_mask & 0x0002) != 0
      has_speed:
        value: (fragment_mask & 0x0004) != 0
      has_course:
        value: (fragment_mask & 0x0008) != 0
      has_altitude:
        value: (fragment_mask & 0x0010) != 0
      has_hdop:
        value: (fragment_mask & 0x0020) != 0
      has_vdop:
        value: (fragment_mask & 0x0040) != 0
      gps_valid:
        value: has_gps_flags and ((gps_flags >> 5) & 0x03) > 0
      satellite_count:
        value: has_gps_flags ? (gps_flags & 0x1F) : 0
      latitude:
        value: has_coordinates ? latitude_raw / 1000000.0 : 0.0
      longitude:
        value: has_coordinates ? longitude_raw / 1000000.0 : 0.0
      speed_kmh:
        value: has_speed ? speed_raw : 0
      hdop:
        value: has_hdop ? hdop_raw / 100.0 : 0.0
      vdop:
        value: has_vdop ? vdop_raw / 100.0 : 0.0
        
  gsm_data:
    seq:
      - id: length
        type: u1
      - id: content
        size: length
        
  cot_data:
    seq:
      - id: length
        type: u1
      - id: content
        size: length
        
  adc_data:
    seq:
      - id: length
        type: u1
      - id: content
        size: length
        
  dtt_data:
    seq:
      - id: length
        type: u1
      - id: content
        size: length
        
  iwd_data:
    seq:
      - id: length
        type: u1
      - id: content
        size: length
        
  etd_data:
    seq:
      - id: length
        type: u1
      - id: content
        size: length
        
enums:
  binary_message_type:
    0x41: event_message
    0x42: periodic_report
    0x43: alarm_message
    0x44: response_message
    
  gps_validity:
    0: invalid
    1: gps_fix
    2: dgps_fix
    3: estimated
    
  # Text protocol data section types
  text_section_type:
    0: gps_section         # GPS location data
    1: gsm_section         # GSM/cellular information  
    2: cot_section         # Counter/odometer data
    3: adc_section         # Analog sensor data
    4: dtt_section         # Digital I/O and status
    5: etd_section         # Event data
    6: obd_section         # OBD-II diagnostic data
    7: tag_section         # RFID/tag data
    8: iwd_section         # iButton/temperature sensors
    9: sys_section         # System information
    
  # Digital I/O bit definitions (DTT section)
  digital_io:
    0: ignition           # Ignition state
    1: input_1            # Digital input 1
    2: input_2            # Digital input 2  
    3: input_3            # Digital input 3
    4: input_4            # Digital input 4
    5: output_1           # Digital output 1
    6: output_2           # Digital output 2
    7: output_3           # Digital output 3
    
  # Temperature sensor data types (IWD section)
  iwd_data_type:
    0: driver_id          # Driver identification
    1: temperature        # Temperature sensor reading
    
  # Common event codes (hex values in text protocol)
  event_code:
    0x01: ignition_on
    0x02: ignition_off
    0x03: panic_button
    0x04: geofence_enter
    0x05: geofence_exit
    0x06: overspeed
    0x07: low_battery
    0x08: power_disconnect
    0x09: sos_alarm
    0x0A: idle_start
    0x0B: idle_end
    0x0C: engine_start
    0x0D: engine_stop
    0x0E: harsh_acceleration
    0x0F: harsh_braking
    0x10: harsh_cornering
    0x11: accident_detection
    0x12: maintenance_due
    0x13: driver_change
    0x14: fuel_level_low
    0x15: temperature_alert
    0x16: door_open
    0x17: door_close
    0x18: cargo_status
    0x19: trailer_connect
    0x1A: trailer_disconnect
    
  # GoSafe device model variants
  device_model:
    0: g1s                # Basic GPS/GSM tracker
    1: g2s                # OBD-II enhanced tracker
    2: g737               # Professional fleet device
    3: g739               # Heavy-duty CAN bus tracker
    4: g758               # Long-life asset tracker  
    5: g787               # Advanced telematics gateway
    6: g866               # Motorcycle/bike tracker
    7: g980               # High-end camera-equipped
    8: og300              # OriginalGPS OEM variant
    9: og400              # OriginalGPS advanced
    10: fc100             # Fleet Complete basic
    11: fc200             # Fleet Complete advanced
    12: pw300             # PacWest fleet tracker
    13: pw400             # PacWest advanced
    14: at100             # AssetTrackr basic
    15: at200             # AssetTrackr advanced
    16: fl300             # FleetLocate series
    17: oem_standard      # Generic OEM implementation
    18: wialon_compatible # Wialon platform compatible
    19: gpsgate_oem       # GPSGate OEM device
    20: omnitracs_xrs     # Omnitracs XRS compatible