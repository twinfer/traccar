meta:
  id: suntech
  title: Suntech GPS Tracker Protocol
  file-extension: suntech
  endian: be
  encoding: ASCII

seq:
  - id: message
    type:
      switch-on: message_type_detection
      cases:
        0x02: zip_message
        _: text_or_binary_message
        
instances:
  message_type_detection:
    value: '_io.read_u1()'
    
types:
  text_or_binary_message:
    seq:
      - id: message_content
        type:
          switch-on: second_byte
          cases:
            0x00: binary_message
            _: text_message
    instances:
      second_byte:
        value: '_io.read_u1()'
  
  zip_message:
    seq:
      - id: header
        contents: [0x02]
      - id: length
        type: u2
      - id: device_id
        size: 5
      - id: timestamp
        size: 4
      - id: gps_data
        type: zip_gps_data
      - id: status_data
        type: zip_status_data
        
  zip_gps_data:
    seq:
      - id: latitude_degrees
        type: u1
      - id: latitude_minutes
        type: u1
      - id: latitude_minutes_decimal
        type: u2
      - id: longitude_degrees
        type: u1
      - id: longitude_minutes
        type: u1
      - id: longitude_minutes_decimal
        type: u2
      - id: course
        type: u2
      - id: speed
        type: u1
      - id: flags
        type: u1
        
  zip_status_data:
    seq:
      - id: voltage
        type: u1
      - id: io_status
        type: u1
      - id: satellites
        type: u1
      - id: gsm_signal
        type: u1
        
  binary_message:
    seq:
      - id: type
        type: u1
      - id: length
        type: u2
      - id: device_id
        size: 5
      - id: mask
        type: u3
      - id: fields
        type: binary_fields
        
  binary_fields:
    seq:
      - id: basic_data
        type: binary_basic_data
      - id: optional_data
        type: binary_optional_data
        if: _parent.mask[0] != 0 or _parent.mask[1] != 0 or _parent.mask[2] != 0
        
  binary_basic_data:
    seq:
      - id: timestamp
        type: u4
      - id: latitude
        type: s4
      - id: longitude
        type: s4
      - id: speed
        type: u2
      - id: course
        type: u2
      - id: satellites
        type: u1
      - id: voltage
        type: u1
        
  binary_optional_data:
    seq:
      - id: adc_values
        type: u2
        repeat: expr
        repeat-expr: 4
        if: _parent._parent.mask[0] & 0x01 != 0
      - id: rpm
        type: u2
        if: _parent._parent.mask[0] & 0x02 != 0
      - id: temperature
        type: s1
        if: _parent._parent.mask[0] & 0x04 != 0
      - id: digital_inputs
        type: u1
        if: _parent._parent.mask[0] & 0x08 != 0
        
  text_message:
    seq:
      - id: message_type_prefix
        type: str
        terminator: 0x3B  # semicolon
      - id: fields
        type: text_fields
        
  text_fields:
    seq:
      - id: device_id
        type: str
        terminator: 0x3B
      - id: sw_version
        type: str
        terminator: 0x3B
      - id: status
        type: str
        terminator: 0x3B
      - id: datetime_fields
        type: datetime_group
      - id: gps_fields
        type: gps_group
      - id: remaining_fields
        type: str
        terminator: 0x0D  # carriage return
        
  datetime_group:
    seq:
      - id: date
        type: str
        terminator: 0x3B
      - id: time
        type: str
        terminator: 0x3B
        
  gps_group:
    seq:
      - id: cell_id
        type: str
        terminator: 0x3B
      - id: mcc
        type: str
        terminator: 0x3B
      - id: mnc
        type: str
        terminator: 0x3B
      - id: lac
        type: str
        terminator: 0x3B
      - id: signal_strength
        type: str
        terminator: 0x3B
      - id: latitude
        type: str
        terminator: 0x3B
      - id: longitude
        type: str
        terminator: 0x3B
      - id: speed
        type: str
        terminator: 0x3B
      - id: course
        type: str
        terminator: 0x3B
      - id: satellites
        type: str
        terminator: 0x3B
      - id: gps_valid
        type: str
        terminator: 0x3B
        
enums:
  message_type:
    0x02: zip_format
    0x81: binary_standard
    0x82: binary_extended
    
  text_message_type:
    0: stt_location
    1: alt_alert
    2: ble_beacon
    3: res_response
    4: uex_universal
    5: cmd_command
    6: crr_crash