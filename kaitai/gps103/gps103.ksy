meta:
  id: gps103
  title: GPS103/TK103 GPS Tracker Protocol
  endian: be
  file-extension: gps103
  
doc: |
  GPS103/TK103 protocol parser for text-based GPS tracking messages.
  One of the most widely cloned protocols with many variations.
  Messages are comma-separated with various formats.

seq:
  - id: message
    type:
      switch-on: message_start
      cases:
        '"##"': handshake_message
        '"imei:"': data_message
        _: heartbeat_message
    doc: Message type based on start pattern
    
instances:
  message_start:
    pos: 0
    size: 2
    type: str
    encoding: ASCII
    if: _io.size >= 2
    
  message_start_long:
    pos: 0
    size: 5
    type: str
    encoding: ASCII
    if: _io.size >= 5
    
types:
  # Handshake message: ##,imei:123456789012345,A
  handshake_message:
    seq:
      - id: prefix
        contents: "##,imei:"
        
      - id: imei
        type: str
        encoding: ASCII
        terminator: 0x2C  # ','
        
      - id: command
        type: str
        encoding: ASCII
        size-eos: true
        
  # Heartbeat: just IMEI number
  heartbeat_message:
    seq:
      - id: imei
        type: str
        encoding: ASCII
        size: 15
        if: _io.size == 15 or _io.size == 17  # With CRLF
        
      - id: other_data
        size-eos: true
        if: _io.size > 17
        
  # Main data messages starting with "imei:"
  data_message:
    seq:
      - id: imei_prefix
        contents: "imei:"
        
      - id: imei
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: message_content
        type:
          switch-on: message_type
          cases:
            '"OBD"': obd_message
            '"vt"': photo_announce
            '"vr"': photo_data
            _: position_message
            
    instances:
      message_type:
        value: |
          message_content.as<str>.substring(0, 2) == "vt" ? "vt" :
          message_content.as<str>.substring(0, 2) == "vr" ? "vr" :
          message_content.as<str>.substring(0, 3)
          
  # Standard position message
  position_message:
    seq:
      - id: alarm_or_type
        type: str
        encoding: ASCII
        terminator: 0x2C
        doc: Alarm type or message type
        
      - id: has_datetime
        type: check_datetime
        
      - id: datetime
        type: str
        encoding: ASCII
        terminator: 0x2C
        if: has_datetime.is_datetime
        
      - id: contact
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: gps_status
        type: str
        size: 1
        encoding: ASCII
        doc: F=Fixed/valid, L=Last known
        
      - id: comma1
        contents: ","
        
      # Different formats based on device variant
      - id: location_data
        type:
          switch-on: detect_format
          cases:
            0: standard_location
            1: alternative_location
            
      - id: terminator
        type: str
        encoding: ASCII
        size-eos: true
        doc: Can be ; or * with optional checksum
        
    instances:
      detect_format:
        value: |
          location_data.as<str>.index_of(",1,") >= 0 ? 1 : 0
          
  # Check if field is datetime or other data
  check_datetime:
    seq:
      - id: peek_data
        type: str
        size: 10
        encoding: ASCII
        
    instances:
      is_datetime:
        value: |
          peek_data.length >= 10 and
          peek_data.substring(0, 10).to_i >= 0
          
  # Standard location format
  standard_location:
    seq:
      - id: time
        type: str
        encoding: ASCII
        terminator: 0x2C
        doc: HHMMSS.SSS format
        
      - id: validity
        type: str
        size: 1
        encoding: ASCII
        doc: A=Active/valid, V=Void
        
      - id: comma1
        contents: ","
        
      - id: latitude
        type: str
        encoding: ASCII
        terminator: 0x2C
        doc: DDMM.MMMM format
        
      - id: lat_hemisphere
        type: str
        size: 1
        encoding: ASCII
        doc: N=North, S=South
        
      - id: comma2
        contents: ","
        
      - id: longitude
        type: str
        encoding: ASCII
        terminator: 0x2C
        doc: DDDMM.MMMM format
        
      - id: lon_hemisphere
        type: str
        size: 1
        encoding: ASCII
        doc: E=East, W=West
        
      - id: comma3
        contents: ","
        
      - id: speed
        type: str
        encoding: ASCII
        terminator: 0x2C
        doc: Speed in knots
        
      - id: course
        type: str
        encoding: ASCII
        terminator: 0x2C
        doc: Course in degrees
        
      - id: remaining_fields
        type: str
        encoding: ASCII
        size-eos: true
        doc: Date and optional fields
        
  # Alternative format (used by some clones)
  alternative_location:
    seq:
      - id: event
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: sensor_id
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: voltage
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: time
        type: str
        size: 6
        encoding: ASCII
        doc: HHMMSS format
        
      - id: comma1
        contents: ","
        
      - id: date
        type: str
        size: 6
        encoding: ASCII
        doc: DDMMYY format
        
      - id: comma2
        contents: ","
        
      - id: area_code
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: gps_valid
        type: str
        encoding: ASCII
        terminator: 0x2C
        doc: 1=valid, 0=invalid
        
      - id: latitude
        type: str
        encoding: ASCII
        terminator: 0x2C
        doc: Decimal degrees with sign
        
      - id: longitude
        type: str
        encoding: ASCII
        terminator: 0x2C
        doc: Decimal degrees with sign
        
      - id: speed
        type: str
        encoding: ASCII
        terminator: 0x2C
        doc: Speed in km/h
        
      - id: course
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: altitude
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: hdop
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: satellites
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: ignition
        type: str
        encoding: ASCII
        terminator: 0x2C
        doc: 0=off, 1=on
        
      - id: charge
        type: str
        encoding: ASCII
        terminator: 0x2C
        doc: 0=not charging, 1=charging
        
      - id: error_code
        type: str
        encoding: ASCII
        terminator: 0x2C
        
  # OBD message format
  obd_message:
    seq:
      - id: type_obd
        contents: "OBD"
        
      - id: comma1
        contents: ","
        
      - id: datetime
        type: str
        encoding: ASCII
        terminator: 0x2C
        doc: YYMMDDHHmmss format
        
      - id: odometer
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: fuel_instant
        type: str
        encoding: ASCII
        terminator: 0x2C
        doc: Instant fuel consumption
        
      - id: fuel_average
        type: str
        encoding: ASCII
        terminator: 0x2C
        doc: Average fuel consumption
        
      - id: hours
        type: str
        encoding: ASCII
        terminator: 0x2C
        doc: Engine hours
        
      - id: speed_obd
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: power_load
        type: str
        encoding: ASCII
        terminator: 0x2C
        doc: Engine load percentage
        
      - id: temperature
        type: str
        encoding: ASCII
        terminator: 0x2C
        doc: Coolant temperature
        
      - id: throttle
        type: str
        encoding: ASCII
        terminator: 0x2C
        doc: Throttle position percentage
        
      - id: rpm
        type: str
        encoding: ASCII
        terminator: 0x2C
        doc: Engine RPM
        
      - id: battery_obd
        type: str
        encoding: ASCII
        terminator: 0x2C
        doc: Battery voltage
        
      - id: dtc_codes
        type: str
        encoding: ASCII
        size-eos: true
        doc: Diagnostic trouble codes
        
  # Photo announcement message
  photo_announce:
    seq:
      - id: packet_count
        type: str
        encoding: ASCII
        terminator: 0x2C
        doc: Format vtNN where NN is packet count
        
      - id: remaining_data
        type: str
        encoding: ASCII
        size-eos: true
        
  # Photo data packet
  photo_data:
    seq:
      - id: type_vr
        contents: "vr"
        
      - id: comma1
        contents: ","
        
      - id: photo_data
        type: str
        encoding: ASCII
        terminator: 0x2C
        doc: Base64 encoded photo data
        
      - id: sequence
        type: str
        encoding: ASCII
        terminator: 0x2C
        doc: Packet sequence number
        
      - id: terminator
        type: str
        encoding: ASCII
        size-eos: true
        
# Alarm type enumeration
enums:
  alarm_type:
    help_me: sos
    low_battery: battery
    stockade: geofence
    move: movement
    speed: overspeed
    acc_on: ignition_on
    acc_off: ignition_off
    door_alarm: door
    ac_alarm: power_cut
    accident_alarm: accident
    sensor_alarm: vibration
    bonnet_alarm: bonnet
    footbrake_alarm: footbrake
    DTC: diagnostic
    tracker: normal