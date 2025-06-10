meta:
  id: jt600
  title: JT600 GPS Tracking Protocol
  license: MIT
  ks-version: 0.11
  endian: be

doc: |
  JT600 GPS tracking protocol supporting both binary and text message formats.
  Used by various Chinese GPS tracker devices with features including RFID,
  temperature sensors, and multiple positioning modes.
  
  ## JT701 PADLOCK SUPPORT:
  The JT701 GPS padlock is fully supported through enhanced P45 message parsing
  and extended status flag interpretation for padlock-specific functionality:
  - RFID unlock events with card validation
  - Remote lock/unlock commands
  - Tamper detection and security alarms
  - Unauthorized access monitoring
  - Lock mechanism status tracking

seq:
  - id: messages
    type: message_wrapper
    repeat: eos

types:
  message_wrapper:
    seq:
      - id: message
        type:
          switch-on: message_type
          cases:
            0x24: binary_message    # '$'
            0x28: text_message      # '('

    instances:
      message_type:
        value: _io.read_u1
        io: _io

  binary_message:
    seq:
      - id: header
        contents: ['$']
      - id: device_id_bcd
        size: 5
      - id: protocol_version
        type: u1
        if: is_long_format
      - id: packet_info
        type: u1
      - id: length
        type: u2
      - id: data_records
        type: binary_record
        repeat: until
        repeat-until: _io.size - _io.pos <= 1
      - id: sequence_index
        type: u1
    instances:
      is_long_format:
        value: _io.read_u1 == 0
        io: _io
        ofs: 8
      format_version:
        value: (packet_info >> 4) & 0x0f

  binary_record:
    seq:
      - id: date_time
        type: date_time_bcd
      - id: latitude_raw
        type: bcd_coordinate
        size: 4
      - id: longitude_raw
        type: bcd_coordinate
        size: 4.5
      - id: flags
        type: u1
      - id: speed_bcd
        size: 1
      - id: course_raw
        type: u1
      - id: extended_data
        type:
          switch-on: _parent.is_long_format
          cases:
            true: long_format_data
            false: short_format_data
    instances:
      is_valid:
        value: (flags & 0x01) != 0
      latitude_sign:
        value: (flags & 0x02) != 0
      longitude_sign:
        value: (flags & 0x04) != 0
      latitude:
        value: |
          latitude_sign ? 
          bcd_to_coordinate(latitude_raw) : 
          -bcd_to_coordinate(latitude_raw)
      longitude:
        value: |
          longitude_sign ?
          bcd_to_coordinate(longitude_raw) :
          -bcd_to_coordinate(longitude_raw)
      speed_kmh:
        value: bcd_to_int(speed_bcd)
      course:
        value: course_raw * 2.0

  long_format_data:
    seq:
      - id: odometer
        type: u4
      - id: satellites
        type: u1
      - id: vehicle_id_combined
        type: u4
      - id: status_flags
        type: u2
      - id: battery_level
        type: u1
      - id: cell_info
        type: cell_tower_info
      - id: geofence_data
        size: 4
        if: _parent._parent.protocol_version == 0x17 or _parent._parent.protocol_version == 0x19
      - id: remaining_data
        size-eos: true
        if: _parent._parent.protocol_version == 0x17 or _parent._parent.protocol_version == 0x19
    instances:
      geofence_enter:
        value: (status_flags & 0x0002) != 0
      geofence_exit:
        value: (status_flags & 0x0004) != 0
      power_cut:
        value: (status_flags & 0x0008) != 0
      vibration_alarm:
        value: (status_flags & 0x0010) != 0
      response_required:
        value: (status_flags & 0x0020) != 0
      device_blocked:
        value: (status_flags & 0x0080) != 0
      low_battery:
        value: (status_flags & 0x0800) != 0
      fault_alarm:
        value: (status_flags & 0x4000) != 0
      is_charging:
        value: battery_level == 0xff
      battery_percent:
        value: battery_level != 0xff ? battery_level : 0

  short_format_data:
    seq:
      - id: version_specific_data
        type:
          switch-on: _parent._parent.format_version
          cases:
            1: version1_data
            2: version2_data
            3: version3_data
            _: raw_data

  version1_data:
    seq:
      - id: satellites
        type: u1
      - id: power_voltage
        type: u1
      - id: sensor_flags
        type: u1
      - id: altitude
        type: u2
      - id: cell_info
        type: cell_tower_info
    instances:
      has_cell_info:
        value: cell_info.cid != 0 and cell_info.lac != 0

  version2_data:
    seq:
      - id: fuel_high
        type: u1
      - id: status_byte1
        type: u1
      - id: status_byte2
        type: u1
      - id: status_byte3
        type: u1
      - id: status_byte4
        type: u1
      - id: odometer
        type: u4
      - id: fuel_low
        type: u1
    instances:
      fuel_level:
        value: (fuel_high << 8) + fuel_low
      ignition_on:
        value: (status_byte1 & 0x01) != 0
      door_open:
        value: (status_byte1 & 0x40) != 0
      is_charging:
        value: (status_byte2 & 0x01) != 0
      device_blocked:
        value: (status_byte2 & 0x02) != 0
      sos_alarm:
        value: (status_byte2 & 0x04) != 0
      gps_antenna_cut:
        value: (status_byte2 & 0x08) != 0 or (status_byte2 & 0x10) != 0
      overspeed_alarm:
        value: (status_byte2 & 0x10) != 0
      # JT701 padlock-specific: tamper detection
      tamper_detected:
        value: (status_byte2 & 0x20) != 0
      fatigue_driving:
        value: (status_byte3 & 0x04) != 0
      tow_alarm:
        value: (status_byte3 & 0x08) != 0
      # JT701 padlock-specific: unauthorized access attempt
      unauthorized_access:
        value: (status_byte3 & 0x10) != 0
      # JT701 padlock-specific: lock mechanism fault
      lock_mechanism_fault:
        value: (status_byte3 & 0x20) != 0

  version3_data:
    seq:
      - id: fuel_data
        size: 4.5
      - id: status_data
        size: 3
    instances:
      fuel1:
        value: extract_bits(fuel_data, 0, 12)
      fuel2:
        value: extract_bits(fuel_data, 12, 12)
      fuel3:
        value: extract_bits(fuel_data, 24, 12)
      odometer:
        value: extract_bits(fuel_data, 36, 20) * 1000
      ignition_on:
        value: (extract_bits(status_data, 0, 1) & 0x01) != 0

  raw_data:
    seq:
      - id: data
        size-eos: true

  text_message:
    seq:
      - id: opening_paren
        contents: ['(']
      - id: message_content
        type: str
        encoding: ASCII
        terminator: 0x29  # ')'
      - id: closing_paren
        contents: [')']
    instances:
      parsed_fields:
        value: message_content.split(",")
      device_id:
        value: parsed_fields.size > 0 ? parsed_fields[0] : ""
      message_type:
        value: parsed_fields.size > 1 ? parsed_fields[1] : ""
      is_w01_message:
        value: message_content.contains("W01")
      is_p45_message:
        value: message_content.contains("P45")
      is_peripherals_message:
        value: message_content.contains("WLNET,5,")

  date_time_bcd:
    seq:
      - id: day
        size: 1
      - id: month
        size: 1
      - id: year
        size: 1
      - id: hour
        size: 1
      - id: minute
        size: 1
      - id: second
        size: 1

  bcd_coordinate:
    seq:
      - id: data
        size-eos: true

  cell_tower_info:
    seq:
      - id: cid
        type: u2
      - id: lac
        type: u2
      - id: signal_strength
        type: u1

  w01_message:
    seq:
      - id: longitude_degrees
        type: str
        size: 3
        encoding: ASCII
      - id: longitude_minutes
        type: str
        encoding: ASCII
        terminator: 0x2c  # ','
      - id: longitude_hemisphere
        type: str
        size: 1
        encoding: ASCII
      - id: latitude_degrees
        type: str
        size: 2
        encoding: ASCII
      - id: latitude_minutes
        type: str
        encoding: ASCII
        terminator: 0x2c  # ','
      - id: latitude_hemisphere
        type: str
        size: 1
        encoding: ASCII
      - id: validity
        type: str
        size: 1
        encoding: ASCII
      - id: date_day
        type: str
        size: 2
        encoding: ASCII
      - id: date_month
        type: str
        size: 2
        encoding: ASCII
      - id: date_year
        type: str
        size: 2
        encoding: ASCII
      - id: time_hour
        type: str
        size: 2
        encoding: ASCII
      - id: time_minute
        type: str
        size: 2
        encoding: ASCII
      - id: time_second
        type: str
        size: 2
        encoding: ASCII
      - id: speed
        type: str
        encoding: ASCII
        terminator: 0x2c
      - id: course
        type: str
        encoding: ASCII
        terminator: 0x2c
      - id: power
        type: str
        encoding: ASCII
        terminator: 0x2c
      - id: gps_signal
        type: str
        encoding: ASCII
        terminator: 0x2c
      - id: gsm_signal
        type: str
        encoding: ASCII
        terminator: 0x2c
      - id: alert_type
        type: str
        encoding: ASCII
        terminator: 0x2c

  u_message:
    doc: U01, U02, U03, U06 message types
    seq:
      - id: type
        type: str
        size: 3
        encoding: ASCII
      - id: alarm
        type: str
        encoding: ASCII
        terminator: 0x2c
        if: has_alarm
      - id: date_time
        type: str
        size: 12
        encoding: ASCII
      - id: validity
        type: str
        size: 1
        encoding: ASCII
      - id: latitude
        type: str
        encoding: ASCII
        terminator: 0x2c
      - id: latitude_hemisphere
        type: str
        size: 1
        encoding: ASCII
      - id: longitude
        type: str
        encoding: ASCII
        terminator: 0x2c
      - id: longitude_hemisphere
        type: str
        size: 1
        encoding: ASCII
      - id: speed
        type: str
        encoding: ASCII
        terminator: 0x2c
      - id: course
        type: str
        encoding: ASCII
        terminator: 0x2c
      - id: satellites
        type: str
        encoding: ASCII
        terminator: 0x2c
      - id: battery_percent
        type: str
        encoding: ASCII
        terminator: 0x25  # '%'
      - id: status_bits
        type: str
        encoding: ASCII
        terminator: 0x2c
      - id: cid
        type: str
        encoding: ASCII
        terminator: 0x2c
      - id: lac
        type: str
        encoding: ASCII
        terminator: 0x2c
      - id: gsm_signal
        type: str
        encoding: ASCII
        terminator: 0x2c
      - id: odometer
        type: str
        encoding: ASCII
        terminator: 0x2c
      - id: serial_number
        type: str
        encoding: ASCII
        terminator: 0x2c
        if: not has_checksum
      - id: checksum
        type: str
        size: 2
        encoding: ASCII
        if: has_checksum
    instances:
      has_alarm:
        value: type == "U06"
      has_checksum:
        value: _io.size - _io.pos >= 2

  p45_message:
    seq:
      - id: date_time
        type: str
        size: 12
        encoding: ASCII
      - id: latitude
        type: str
        encoding: ASCII
        terminator: 0x2c
      - id: latitude_hemisphere
        type: str
        size: 1
        encoding: ASCII
      - id: longitude
        type: str
        encoding: ASCII
        terminator: 0x2c
      - id: longitude_hemisphere
        type: str
        size: 1
        encoding: ASCII
      - id: validity
        type: str
        size: 1
        encoding: ASCII
      - id: speed
        type: str
        encoding: ASCII
        terminator: 0x2c
      - id: course
        type: str
        encoding: ASCII
        terminator: 0x2c
      - id: event_source
        type: str
        encoding: ASCII
        terminator: 0x2c
      - id: unlock_verification
        type: str
        encoding: ASCII
        terminator: 0x2c
      - id: rfid
        type: str
        encoding: ASCII
        terminator: 0x2c
      - id: password_verification
        type: str
        encoding: ASCII
        terminator: 0x2c
      - id: incorrect_password_count
        type: str
        encoding: ASCII
        terminator: 0x2c
      - id: index
        type: str
        encoding: ASCII
        size-eos: true
    instances:
      # JT701 padlock-specific: enhanced event source interpretation
      event_type:
        value: |
          event_source == "1" ? "rfid_unlock" :
          event_source == "2" ? "manual_unlock" :
          event_source == "3" ? "remote_unlock" :
          event_source == "4" ? "unauthorized_access" :
          event_source == "5" ? "tamper_detected" :
          "general"
      # JT701 padlock-specific: RFID card validation
      rfid_valid:
        value: rfid != "0000000000"
      # JT701 padlock-specific: lock status indication
      lock_status:
        value: rfid_valid ? "unlocked" : "locked"
      # JT701 padlock-specific: security event detection
      is_security_event:
        value: event_source == "4" or event_source == "5"

  peripherals_message:
    seq:
      - id: device_id
        type: str
        size: 10
        encoding: ASCII
      - id: header_data
        type: str
        encoding: ASCII
        terminator: 0x2c
        repeat: expr
        repeat-expr: 6
      - id: location_data
        type: binary_record
      - id: sensor_time
        size: 6
      - id: sensor_id
        size: 5
      - id: sensor_index
        type: u1
      - id: sensor_battery_raw
        type: u2
      - id: sensor_battery_level
        type: u1
      - id: sensor_rssi_raw
        type: u1
      - id: sensor_type
        type: u1
      - id: sensor_specific_data
        type:
          switch-on: sensor_type
          cases:
            1: temperature_sensor_data
            _: raw_sensor_data
    instances:
      sensor_battery_voltage:
        value: sensor_battery_raw / 100.0
      sensor_rssi:
        value: -sensor_rssi_raw

  temperature_sensor_data:
    seq:
      - id: temperature_raw
        type: u2
      - id: humidity
        type: u1
      - id: data_count
        type: u2
      - id: status
        type: u1
    instances:
      has_temperature:
        value: temperature_raw != 0xffff
      temperature_celsius:
        value: |
          has_temperature ?
          ((temperature_raw & 0xf000) > 0 ? 
           -(temperature_raw & 0xfff) / 10.0 :
           (temperature_raw & 0xfff) / 10.0) :
          0.0

  raw_sensor_data:
    seq:
      - id: data
        size-eos: true

enums:
  message_types:
    0x57303031: w01  # "W01"
    0x55303031: u01  # "U01"
    0x55303032: u02  # "U02"
    0x55303033: u03  # "U03"
    0x55303036: u06  # "U06"
    0x50343035: p45  # "P45"

  alert_types:
    0: normal
    1: sos
    2: power_cut
    3: vibration
    4: geofence_enter
    5: geofence_exit
    6: overspeed
    7: movement
    8: low_battery
    # JT701 padlock-specific alert types
    9: tamper_detected
    10: unauthorized_access
    11: lock_mechanism_fault

  status_flags:
    0x0001: valid_position
    0x0002: geofence_enter
    0x0004: geofence_exit
    0x0008: power_cut_alarm
    0x0010: vibration_alarm
    0x0020: response_required
    0x0080: device_blocked
    0x0800: low_battery_alarm
    0x4000: fault_alarm
    # JT701 padlock-specific status flags
    0x0040: lock_status_unlocked
    0x1000: tamper_alarm
    0x2000: unauthorized_access_alarm
    0x8000: lock_mechanism_fault
    
  # JT701 padlock-specific P45 event sources
  p45_event_sources:
    1: rfid_unlock
    2: manual_unlock
    3: remote_unlock
    4: unauthorized_access
    5: tamper_detected
    6: low_battery_padlock
    7: lock_mechanism_error