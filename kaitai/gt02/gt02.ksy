meta:
  id: gt02
  title: GT02 GPS Tracker Protocol
  file-extension: gt02
  endian: be
  ks-version: 0.11
  
doc: |
  GT02 GPS tracker protocol implementation supporting binary vehicle tracking
  with basic telemetry including GPS positioning, system monitoring, and 
  command response capabilities for fleet management applications.
  
  ## PROTOCOL FEATURES:
  
  ### Binary Protocol Format:
  - Length-field based frame structure
  - Header: Variable (detected by frame decoder)
  - Length field: 1 byte indicating payload size
  - Message type identification (0x10, 0x1A, 0x1C)
  - IMEI device identification (8 bytes, hex format)
  - CRC checksum for data integrity
  - Compact binary encoding for efficient transmission
  
  ### Message Structure:
  ```
  [header(2)][length(1)][power(1)][gsm(1)][imei(8)][index(2)][type(1)][payload][crc(2)]
  ```
  
  ### Supported Message Types:
  - **0x10 (MSG_DATA)**: GPS position data with timestamp and coordinates
  - **0x1A (MSG_HEARTBEAT)**: Device status and connectivity monitoring  
  - **0x1C (MSG_RESPONSE)**: Command response with ASCII result data
  
  ### Supported Features:
  - **Real-time positioning**: GPS coordinates with validity flags
  - **System monitoring**: Power and GSM signal strength
  - **Heartbeat mechanism**: Regular status updates
  - **Command responses**: Two-way communication support
  - **Message indexing**: Sequence numbering for reliability
  - **Compact encoding**: Efficient binary protocol design
  
  ## MESSAGE TYPES:
  - 0x10: GPS Data - Location and movement information
  - 0x1A: Heartbeat - Device status and signal quality
  - 0x1C: Response - Command execution results
  
  ## GEOGRAPHICAL COVERAGE:
  Global deployment suitable for basic fleet tracking applications
  
  ## ESTIMATED DEPLOYMENT:
  - Entry-level GPS tracking devices
  - Basic fleet management systems
  - Cost-effective vehicle monitoring solutions

seq:
  - id: header
    type: u2
    doc: Protocol header (varies by implementation)
  - id: length
    type: u1
    doc: Message payload length
  - id: power_level
    type: u1
    doc: Power level indicator (0 for location messages)
  - id: gsm_signal
    type: u1
    doc: GSM signal strength
  - id: imei_bytes
    size: 8
    doc: Device IMEI in binary format
  - id: message_index
    type: u2
    doc: Message sequence number
  - id: message_type
    type: u1
    enum: message_types
    doc: Message type identifier
  - id: payload
    type:
      switch-on: message_type
      cases:
        message_types::data: gps_data
        message_types::heartbeat: heartbeat_data
        message_types::response: response_data
    doc: Message-specific payload data
  - id: checksum
    type: u2
    doc: CRC checksum for data integrity

instances:
  imei:
    value: imei_bytes.to_s("hex").substring(1)
    doc: IMEI as decimal string (remove leading digit)

types:
  gps_data:
    seq:
      - id: date_day
        type: u1
        doc: Day of month
      - id: date_month
        type: u1
        doc: Month
      - id: date_year
        type: u1
        doc: Year (YY format)
      - id: time_hour
        type: u1
        doc: Hour (24-hour format)
      - id: time_minute
        type: u1
        doc: Minute
      - id: time_second
        type: u1
        doc: Second
      - id: latitude_raw
        type: u4
        doc: Latitude in raw format
      - id: longitude_raw
        type: u4
        doc: Longitude in raw format
      - id: speed_kmh
        type: u1
        doc: Speed in km/h
      - id: course_raw
        type: u2
        doc: Course in raw format
      - id: reserved
        size: 3
        doc: Reserved bytes
      - id: flags
        type: u4
        doc: Status and validity flags
        
    instances:
      latitude_decimal:
        value: latitude_raw / (60.0 * 30000.0)
        doc: Latitude in decimal degrees (unsigned)
      longitude_decimal:
        value: longitude_raw / (60.0 * 30000.0)
        doc: Longitude in decimal degrees (unsigned)
      latitude_signed:
        value: |
          ((flags & 0x02) != 0) ? latitude_decimal : -latitude_decimal
        doc: Latitude with hemisphere correction
      longitude_signed:
        value: |
          ((flags & 0x04) != 0) ? longitude_decimal : -longitude_decimal
        doc: Longitude with hemisphere correction
      gps_valid:
        value: (flags & 0x01) != 0
        doc: GPS fix validity
      speed_knots:
        value: speed_kmh / 1.852
        doc: Speed converted to knots
      course_degrees:
        value: course_raw
        doc: Course in degrees
      datetime_string:
        value: |
          "20" + date_year.to_s + "-" + 
          date_month.to_s.rjust(2, "0") + "-" + 
          date_day.to_s.rjust(2, "0") + " " +
          time_hour.to_s.rjust(2, "0") + ":" + 
          time_minute.to_s.rjust(2, "0") + ":" + 
          time_second.to_s.rjust(2, "0")
        doc: Combined date and time string
        
  heartbeat_data:
    seq: []
    instances:
      power_status:
        value: _parent.power_level
        doc: Device power level
      signal_strength:
        value: _parent.gsm_signal
        doc: GSM signal quality
        
  response_data:
    seq:
      - id: response_length
        type: u1
        doc: Response data length
      - id: response_text
        size: response_length
        type: str
        encoding: ASCII
        doc: ASCII response data
        
    instances:
      result:
        value: response_text
        doc: Command execution result

enums:
  message_types:
    0x10: data
    0x1A: heartbeat
    0x1C: response
    
  gps_validity:
    0: invalid
    1: valid
    
  hemisphere_latitude:
    0: south
    1: north
    
  hemisphere_longitude:
    0: west
    1: east