meta:
  id: gt06
  title: GT06 GPS Tracker Protocol
  endian: be
  file-extension: gt06
  
doc: |
  GT06 binary protocol parser for Chinese GPS tracking devices.
  Supports standard (0x7878) and extended (0x7979) packet formats.
  Uses CRC16-X25 for error checking.

seq:
  - id: packets
    type: packet
    repeat: eos
    
types:
  packet:
    seq:
      - id: header
        contents: [0x78, 0x78]
        doc: Standard packet header
        
      - id: header_ext
        contents: [0x79, 0x79]
        if: _io.pos == 0 and _io.size >= 2 and _io.read_bytes(2) == [0x79, 0x79]
        doc: Extended packet header for longer messages
        
      - id: length
        type:
          switch-on: header
          cases:
            _: u1  # Standard length (1 byte)
        doc: Packet length excluding header and footer
        
      - id: length_ext
        type: u2
        if: header_ext
        doc: Extended packet length (2 bytes)
        
      - id: msg_type
        type: u1
        enum: message_type
        doc: Message type identifier
        
      - id: content
        type:
          switch-on: msg_type
          cases:
            'message_type::login': login_message
            'message_type::gps': gps_message
            'message_type::gps_lbs_1': gps_lbs_message
            'message_type::gps_lbs_2': gps_lbs_message
            'message_type::status': status_message
            'message_type::string': string_message
            'message_type::gps_lbs_status_1': gps_lbs_status_message
            'message_type::gps_lbs_status_2': gps_lbs_status_message
            'message_type::gps_lbs_status_3': gps_lbs_status_message
            'message_type::heartbeat': heartbeat_message
            'message_type::wifi': wifi_message
            'message_type::lbs_multiple': lbs_multiple_message
            'message_type::lbs_wifi': lbs_wifi_message
            'message_type::lbs_extend': lbs_extend_message
            'message_type::lbs_status': lbs_status_message
            'message_type::gps_phone': gps_phone_message
            'message_type::gps_lbs_extend': gps_lbs_extend_message
            'message_type::heartbeat': heartbeat_message
            'message_type::address_request': address_message
            'message_type::alarm': alarm_message
            'message_type::time_request': time_message
            'message_type::info': info_message
            'message_type::obd': obd_message
            _: generic_message
        doc: Message content based on type
        
      - id: serial
        type: u2
        doc: Message serial number for acknowledgment
        
      - id: crc
        type: u2
        doc: CRC16-X25 checksum
        
      - id: footer
        contents: [0x0d, 0x0a]
        doc: Packet footer (CRLF)
        
  # Login message
  login_message:
    seq:
      - id: imei
        size: 8
        doc: IMEI as BCD (8 bytes = 16 digits, ignore last digit)
        
      - id: type_id
        type: u2
        doc: Device type identifier
        
      - id: timezone
        type: u2
        if: _parent.length > 12
        doc: Time zone offset (optional)
        
  # GPS only message
  gps_message:
    seq:
      - id: gps_data
        type: gps_info
        
  # GPS + LBS message
  gps_lbs_message:
    seq:
      - id: gps_data
        type: gps_info
        
      - id: lbs_data
        type: lbs_info
        
  # GPS + LBS + Status message
  gps_lbs_status_message:
    seq:
      - id: gps_data
        type: gps_info
        
      - id: lbs_data
        type: lbs_info
        
      - id: status_data
        type: status_info
        
  # Status message
  status_message:
    seq:
      - id: terminal_info
        type: u1
        doc: Terminal information content
        
      - id: voltage_level
        type: u1
        doc: Battery voltage level
        
      - id: gsm_signal
        type: u1
        doc: GSM signal strength
        
      - id: alarm_lang
        type: u2
        doc: Alarm and language settings
        
  # String message
  string_message:
    seq:
      - id: length
        type: u1
        
      - id: server_flag
        type: u4
        
      - id: content
        type: str
        size: length - 4
        encoding: ASCII
        
  # Heartbeat message
  heartbeat_message:
    seq:
      - id: terminal_info
        type: u1
        doc: Terminal status byte
        
      - id: voltage_level
        type: u1
        doc: Battery voltage level
        
      - id: gsm_signal
        type: u1
        doc: GSM signal strength
        
      - id: alarm_lang
        type: u2
        doc: Alarm and language settings
        
  # WiFi message
  wifi_message:
    seq:
      - id: datetime
        type: datetime
        
      - id: mcc
        type: u2
        
      - id: mnc
        type: u1
        
      - id: wifi_count
        type: u1
        
      - id: wifi_points
        type: wifi_ap
        repeat: expr
        repeat-expr: wifi_count
        
  # LBS multiple cells
  lbs_multiple_message:
    seq:
      - id: datetime
        type: datetime
        
      - id: mcc
        type: u2
        
      - id: mnc
        type: u1
        
      - id: cell_count
        type: u1
        
      - id: cells
        type: cell_info
        repeat: expr
        repeat-expr: cell_count
        
  # LBS + WiFi combined
  lbs_wifi_message:
    seq:
      - id: datetime
        type: datetime
        
      - id: lbs_data
        type: lbs_info
        
      - id: wifi_count
        type: u1
        
      - id: wifi_points
        type: wifi_ap
        repeat: expr
        repeat-expr: wifi_count
        
  # LBS extended
  lbs_extend_message:
    seq:
      - id: datetime
        type: datetime
        
      - id: mcc
        type: u2
        
      - id: mnc
        type: u1
        
      - id: lac
        type: u4
        
      - id: cell_id
        type: u4
        
  # LBS + Status
  lbs_status_message:
    seq:
      - id: lbs_data
        type: lbs_info
        
      - id: status_data
        type: status_info
        
  # GPS + Phone number
  gps_phone_message:
    seq:
      - id: gps_data
        type: gps_info
        
      - id: phone_length
        type: u1
        
      - id: phone_number
        type: str
        size: phone_length
        encoding: ASCII
        
  # GPS + LBS extended
  gps_lbs_extend_message:
    seq:
      - id: gps_data
        type: gps_info
        
      - id: lbs_data
        type: lbs_extend_info
        
  # Address request
  address_message:
    seq:
      - id: address_length
        type: u1
        
      - id: address
        type: str
        size: address_length
        encoding: UTF-8
        
  # Alarm message
  alarm_message:
    seq:
      - id: gps_data
        type: gps_info
        
      - id: lbs_data
        type: lbs_info
        
      - id: status_data
        type: status_info
        
  # Time request
  time_message:
    seq:
      - id: reserved
        size: 0
        doc: Time request has no content
        
  # Info message
  info_message:
    seq:
      - id: info_type
        type: u1
        
      - id: info_content
        size-eos: true
        
  # OBD message
  obd_message:
    seq:
      - id: datetime
        type: datetime
        
      - id: obd_data
        size-eos: true
        doc: OBD data format varies by device
        
  # Generic message for unknown types
  generic_message:
    seq:
      - id: data
        size-eos: true
        
  # GPS information structure
  gps_info:
    seq:
      - id: datetime
        type: datetime
        
      - id: gps_info_length
        type: u1
        if: _parent._parent.msg_type == message_type::gps_lbs_extend
        
      - id: satellites
        type: u1
        doc: Number of satellites (lower 4 bits) and validity (upper 4 bits)
        
      - id: latitude_raw
        type: u4
        doc: Latitude in minutes * 30000
        
      - id: longitude_raw
        type: u4
        doc: Longitude in minutes * 30000
        
      - id: speed
        type: u1
        doc: Speed in km/h
        
      - id: course_flags
        type: u2
        doc: |
          Bits 0-9: Course (0-360 degrees)
          Bit 10: Latitude sign (0=positive, 1=negative)
          Bit 11: Longitude sign (0=positive, 1=negative)
          Bit 12: GPS validity (0=invalid, 1=valid)
          Bit 13: Real-time/Differential GPS
          Bits 14-15: Reserved
          
    instances:
      latitude:
        value: (latitude_raw / 30000.0 / 60.0) * ((course_flags & 0x0400) == 0 ? 1 : -1)
        doc: Latitude in decimal degrees
        
      longitude:
        value: (longitude_raw / 30000.0 / 60.0) * ((course_flags & 0x0800) == 0 ? 1 : -1)
        doc: Longitude in decimal degrees
        
      course:
        value: course_flags & 0x03FF
        doc: Course in degrees (0-360)
        
      is_valid:
        value: (course_flags & 0x1000) != 0
        doc: GPS validity flag
        
      satellite_count:
        value: satellites & 0x0F
        doc: Number of satellites used
        
  # LBS (Location Based Service) information
  lbs_info:
    seq:
      - id: mcc
        type: u2
        doc: Mobile Country Code
        
      - id: mnc
        type: u1
        doc: Mobile Network Code (1 byte variant)
        
      - id: lac
        type: u2
        doc: Location Area Code
        
      - id: cell_id
        type: b24
        doc: Cell ID (3 bytes)
        
  # Extended LBS information
  lbs_extend_info:
    seq:
      - id: mcc
        type: u2
        
      - id: mnc
        type: u2
        doc: Mobile Network Code (2 byte variant)
        
      - id: lac
        type: u4
        doc: Location Area Code (4 bytes)
        
      - id: cell_id
        type: u4
        doc: Cell ID (4 bytes)
        
      - id: signal_strength
        type: u1
        
  # Status information
  status_info:
    seq:
      - id: terminal_info
        type: u1
        doc: |
          Bit 0: Terminal info content
          Bit 1: Ignition (0=off, 1=on)
          Bit 2: GPS tracking on
          Bits 3-5: Alarm type
          Bit 6: Charge (0=charging, 1=not charging)
          Bit 7: ACC/Defense (0=off, 1=on)
          
      - id: voltage_level
        type: u1
        doc: Battery voltage level (0-6)
        
      - id: gsm_signal
        type: u1
        doc: GSM signal strength (0-4)
        
      - id: alarm
        type: u1
        enum: alarm_type
        
      - id: language
        type: u1
        doc: Language code (1=Chinese, 2=English)
        
    instances:
      ignition_on:
        value: (terminal_info & 0x02) != 0
        
      gps_tracking_on:
        value: (terminal_info & 0x04) != 0
        
      alarm_type:
        value: (terminal_info >> 3) & 0x07
        
      charging:
        value: (terminal_info & 0x40) == 0
        
      acc_on:
        value: (terminal_info & 0x80) != 0
        
  # Date/time structure
  datetime:
    seq:
      - id: year
        type: u1
        doc: Year (00-99, add 2000)
        
      - id: month
        type: u1
        
      - id: day
        type: u1
        
      - id: hour
        type: u1
        
      - id: minute
        type: u1
        
      - id: second
        type: u1
        
  # WiFi access point
  wifi_ap:
    seq:
      - id: mac_address
        size: 6
        doc: MAC address (6 bytes)
        
      - id: signal_strength
        type: u1
        doc: Signal strength (negative dBm)
        
  # Cell information
  cell_info:
    seq:
      - id: lac
        type: u2
        
      - id: cell_id
        type: u2
        
      - id: signal_strength
        type: u1
        
enums:
  message_type:
    0x01: login
    0x10: gps
    0x12: gps_lbs_1
    0x22: gps_lbs_2
    0x13: status
    0x15: string
    0x16: gps_lbs_status_1
    0x26: gps_lbs_status_2
    0x27: gps_lbs_status_3
    0x17: wifi
    0x18: lbs_extend
    0x19: lbs_status
    0x1a: gps_phone
    0x1e: gps_lbs_extend
    0x23: heartbeat
    0x28: lbs_multiple
    0x2a: address_request
    0x2c: lbs_wifi
    0x80: command_0
    0x81: command_1
    0x82: command_2
    0x8a: time_request
    0x8c: obd
    0x94: info
    0x95: alarm
    
  alarm_type:
    0: normal
    1: sos
    2: power_cut
    3: vibration
    4: enter_fence
    5: exit_fence
    6: over_speed
    7: movement