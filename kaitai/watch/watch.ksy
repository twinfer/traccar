meta:
  id: watch
  title: Watch GPS Tracker Protocol (Smartwatch/Wearables)
  file-extension: watch
  endian: be
  encoding: ASCII

seq:
  - id: message
    type: watch_frame

types:
  watch_frame:
    seq:
      - id: start_bracket
        contents: "[" 
      - id: escaped_content
        type: escaped_message_data
      - id: end_bracket
        contents: "]"
        
  escaped_message_data:
    seq:
      - id: raw_data
        type: str
        terminator: 0x5D  # ']' but we need to handle escapes
        include: false
    instances:
      unescaped_data:
        value: 'unescape_watch_data(raw_data)'
      parsed_message:
        type: message_content
        io: '_io_from_string(unescaped_data)'
        
  message_content:
    seq:
      - id: manufacturer
        type: str
        terminator: 0x2A  # '*'
      - id: device_id
        type: str
        terminator: 0x2A  # '*'
      - id: index_or_length
        type: str
        terminator: 0x2A  # '*'
      - id: remaining_fields
        type: message_fields
        
  message_fields:
    seq:
      - id: length_or_content
        type: str
        terminator: 0x2A  # '*'
        if: has_index
      - id: content
        type: str
        size-eos: true
        
    instances:
      has_index:
        value: '_parent.index_or_length.length == 4 and is_hex(_parent.index_or_length)'
      actual_length:
        value: 'has_index ? length_or_content : _parent.index_or_length'
      actual_content:
        value: 'has_index ? content : length_or_content + "*" + content'
      parsed_content:
        type:
          switch-on: message_type
          cases:
            'init': init_message
            'lk': heartbeat_message
            'tkq': acknowledgment_message
            'tkq2': acknowledgment_message
            'ud': position_message
            'ud2': position_message
            'ud_lte': position_message
            'ud_wcdma': position_message
            'al': alarm_position_message
            'wt': watch_position_message
            'pulse': pulse_message
            'heart': heart_rate_message
            'blood': blood_pressure_message
            'bphrt': blood_pressure_message
            'temp': temperature_message
            'btemp2': temperature_message
            'oxygen': oxygen_message
            'img': image_message
            'tk': audio_message
            'jxtk': multi_audio_message
            _: generic_message
        io: '_io_from_string(actual_content)'
      message_type:
        value: 'actual_content.split(",")[0].to_lower()'
        
  init_message:
    seq:
      - id: init_data
        type: str
        size-eos: true
        
  heartbeat_message:
    seq:
      - id: type
        type: str
        terminator: 0x2C  # ','
        if: _io.size > 2
      - id: battery_level
        type: str
        terminator: 0x2C  # ','
        if: has_battery_data
      - id: steps
        type: str
        terminator: 0x2C  # ','
        if: has_steps_data
      - id: remaining_data
        type: str
        size-eos: true
        if: has_remaining_data
        
    instances:
      has_battery_data:
        value: '_io.size > type.length + 1'
      has_steps_data:
        value: '_io.size > type.length + battery_level.length + 2'
      has_remaining_data:
        value: '_io.size > type.length + battery_level.length + steps.length + 3'
        
  acknowledgment_message:
    seq:
      - id: ack_data
        type: str
        size-eos: true
        
  position_message:
    seq:
      - id: message_type
        type: str
        terminator: 0x2C  # ','
      - id: date
        type: str
        terminator: 0x2C  # ','
      - id: time
        type: str
        terminator: 0x2C  # ','
      - id: validity
        type: str
        terminator: 0x2C  # ','
      - id: latitude
        type: str
        terminator: 0x2C  # ','
      - id: lat_hemisphere
        type: str
        terminator: 0x2C  # ','
      - id: longitude
        type: str
        terminator: 0x2C  # ','
      - id: lon_hemisphere
        type: str
        terminator: 0x2C  # ','
      - id: speed
        type: str
        terminator: 0x2C  # ','
      - id: course
        type: str
        terminator: 0x2C  # ','
      - id: altitude
        type: str
        terminator: 0x2C  # ','
      - id: satellites
        type: str
        terminator: 0x2C  # ','
      - id: rssi
        type: str
        terminator: 0x2C  # ','
      - id: battery
        type: str
        terminator: 0x2C  # ','
      - id: steps
        type: str
        terminator: 0x2C  # ','
      - id: tumbles
        type: str
        terminator: 0x2C  # ','
      - id: status
        type: str
        terminator: 0x2C  # ','
      - id: extended_data
        type: extended_position_data
        if: has_extended_data
        
    instances:
      has_extended_data:
        value: '_io.pos < _io.size'
        
  extended_position_data:
    seq:
      - id: cell_data
        type: cell_tower_info
        if: has_cell_data
      - id: wifi_data
        type: wifi_info
        if: has_wifi_data
        
    instances:
      has_cell_data:
        value: '_io.pos < _io.size'
      has_wifi_data:
        value: '_io.pos < _io.size'
        
  cell_tower_info:
    seq:
      - id: cell_count
        type: str
        terminator: 0x2C  # ','
      - id: timing_advance
        type: str
        terminator: 0x2C  # ','
      - id: mcc
        type: str
        terminator: 0x2C  # ','
      - id: mnc
        type: str
        terminator: 0x2C  # ','
      - id: cell_towers
        type: cell_tower_entry
        repeat: expr
        repeat-expr: cell_count.to_i
        
  cell_tower_entry:
    seq:
      - id: lac
        type: str
        terminator: 0x2C  # ','
      - id: cell_id
        type: str
        terminator: 0x2C  # ','
      - id: rssi
        type: str
        terminator: 0x2C  # ','
        
  wifi_info:
    seq:
      - id: wifi_count
        type: str
        terminator: 0x2C  # ','
      - id: wifi_aps
        type: wifi_access_point
        repeat: expr
        repeat-expr: wifi_count.to_i
        
  wifi_access_point:
    seq:
      - id: name
        type: str
        terminator: 0x2C  # ','
      - id: mac_address
        type: str
        terminator: 0x2C  # ','
      - id: rssi
        type: str
        terminator: 0x2C  # ','
        
  alarm_position_message:
    seq:
      - id: alarm_type
        type: str
        terminator: 0x2C  # ','
      - id: position_data
        type: position_message
        
  watch_position_message:
    seq:
      - id: watch_data
        type: position_message
        
  pulse_message:
    seq:
      - id: type
        type: str
        terminator: 0x2C  # ','
      - id: pulse_rate
        type: str
        size-eos: true
        
  heart_rate_message:
    seq:
      - id: type
        type: str
        terminator: 0x2C  # ','
      - id: heart_rate
        type: str
        size-eos: true
        
  blood_pressure_message:
    seq:
      - id: type
        type: str
        terminator: 0x2C  # ','
      - id: systolic
        type: str
        terminator: 0x2C  # ','
      - id: diastolic
        type: str
        size-eos: true
        
  temperature_message:
    seq:
      - id: type
        type: str
        terminator: 0x2C  # ','
      - id: temperature
        type: str
        size-eos: true
        
  oxygen_message:
    seq:
      - id: type
        type: str
        terminator: 0x2C  # ','
      - id: oxygen_level
        type: str
        size-eos: true
        
  image_message:
    seq:
      - id: type
        type: str
        terminator: 0x2C  # ','
      - id: image_data
        size-eos: true
        
  audio_message:
    seq:
      - id: type
        type: str
        terminator: 0x2C  # ','
      - id: audio_format
        type: str
        terminator: 0x7B  # '{'
      - id: audio_data
        size-eos: true
        
  multi_audio_message:
    seq:
      - id: type
        type: str
        terminator: 0x2C  # ','
      - id: sequence_info
        type: str
        terminator: 0x2C  # ','
      - id: audio_data
        size-eos: true
        
  generic_message:
    seq:
      - id: message_data
        type: str
        size-eos: true

enums:
  manufacturer_code:
    0: unknown
    1: "3G"      # 3G watches
    2: "SG"      # Setracker watches  
    3: "CS"      # Generic Chinese watches
    4: "ZJ"      # Zhongjing devices
    5: "GH"      # Generic manufacturer
    6: "ZG"      # Alternative manufacturer
    
  message_type_enum:
    0: init
    1: lk        # Link/heartbeat
    2: tkq       # Acknowledgment
    3: tkq2      # Acknowledgment variant
    4: ud        # Upload data
    5: ud2       # Upload data variant 2
    6: ud_lte    # Upload data LTE
    7: ud_wcdma  # Upload data WCDMA
    8: al        # Alarm
    9: wt        # Watch
    10: pulse    # Pulse rate
    11: heart    # Heart rate
    12: blood    # Blood pressure
    13: bphrt    # Blood pressure heart rate
    14: temp     # Temperature
    15: btemp2   # Temperature variant
    16: oxygen   # Blood oxygen
    17: img      # Image
    18: tk       # Audio message
    19: jxtk     # Multi-part audio
    
  status_alarm_flags:
    0x0001: low_battery
    0x0002: geofence_exit
    0x0004: geofence_enter
    0x0008: moving
    0x0010: fall_down
    0x4000: power_cut
    0x10000: sos_alarm
    0x20000: sos_alarm_auto
    0x100000: device_removal
    0x200000: fall_detection_level1
    0x400000: fall_detection_level2
    
  validity_status:
    0: valid_gps      # 'A'
    1: invalid_gps    # 'V'
    
  hemisphere:
    0: north_east     # 'N', 'E'  
    1: south_west     # 'S', 'W'