meta:
  id: meitrack
  title: Meitrack GPS Tracking Protocol
  license: MIT
  ks-version: 0.11
  endian: le

doc: |
  Meitrack GPS tracking protocol supporting both ASCII text and binary formats.
  Used by various Meitrack GPS tracker devices with extensive telemetry capabilities
  including vehicle diagnostics, temperature sensors, and camera integration.

seq:
  - id: messages
    type: message_wrapper
    repeat: eos

types:
  message_wrapper:
    seq:
      - id: message
        type:
          switch-on: format_type
          cases:
            'text': text_message
            'binary': binary_message
    instances:
      format_type:
        value: |
          _io.size >= 2 and _io.read_bytes(2) == [0x24, 0x24] ? "text" : "binary"

  text_message:
    seq:
      - id: header
        contents: ['$', '$']
      - id: message_data
        type: str
        encoding: ASCII
        terminator: 0x0d  # '\r'
      - id: line_ending
        contents: [0x0a]  # '\n'
        if: _io.size > _io.pos
    instances:
      parsed_data:
        value: message_data.split(",")
      flag:
        value: parsed_data.size > 0 ? parsed_data[0].substring(0, 1) : ""
      length:
        value: parsed_data.size > 0 ? parsed_data[0].substring(1).to_i : 0
      imei:
        value: parsed_data.size > 1 ? parsed_data[1] : ""
      command:
        value: parsed_data.size > 2 ? parsed_data[2] : ""
      event_code:
        value: parsed_data.size > 4 ? parsed_data[4].to_i : 0
      latitude:
        value: parsed_data.size > 5 ? parsed_data[5].to_f : 0.0
      longitude:
        value: parsed_data.size > 6 ? parsed_data[6].to_f : 0.0
      date_time:
        value: parsed_data.size > 7 ? parsed_data[7] : ""
      validity:
        value: parsed_data.size > 8 ? parsed_data[8] : ""
      satellites:
        value: parsed_data.size > 9 ? parsed_data[9].to_i : 0
      rssi:
        value: parsed_data.size > 10 ? parsed_data[10].to_i : 0
      speed:
        value: parsed_data.size > 11 ? parsed_data[11].to_f : 0.0
      course:
        value: parsed_data.size > 12 ? parsed_data[12].to_f : 0.0
      hdop:
        value: parsed_data.size > 13 ? parsed_data[13].to_f : 0.0
      altitude:
        value: parsed_data.size > 14 ? parsed_data[14].to_f : 0.0
      odometer:
        value: parsed_data.size > 15 ? parsed_data[15].to_i : 0
      runtime:
        value: parsed_data.size > 16 ? parsed_data[16] : ""
      cell_info:
        value: parsed_data.size > 17 ? parsed_data[17] : ""
      input_status:
        value: parsed_data.size > 18 ? parsed_data[18] : ""
      output_status:
        value: parsed_data.size > 19 ? parsed_data[19] : ""
      battery_power:
        value: parsed_data.size > 20 ? parsed_data[20] : ""

  binary_message:
    seq:
      - id: header
        contents: ['$', '$']
      - id: flag
        type: str
        size: 1
        encoding: ASCII
      - id: length
        type: u2
      - id: imei
        type: str
        size: 15
        encoding: ASCII
      - id: separator1
        contents: [',']
      - id: command
        type: str
        size: 3
        encoding: ASCII
      - id: separator2
        contents: [',']
      - id: payload
        size: length - 19  # Total length minus header and IMEI parts
        type:
          switch-on: command
          cases:
            '"AAC"': aac_payload
            '"CCC"': ccc_payload
            '"CCE"': cce_payload
            '"D00"': d00_payload
            '"D03"': d03_payload
            '"D82"': d82_payload
            _: raw_payload
      - id: checksum
        type: str
        size: 3
        encoding: ASCII

  aac_payload:
    seq:
      - id: data
        size-eos: true

  ccc_payload:
    seq:
      - id: unknown_field1
        type: u4
      - id: count
        type: u1
      - id: data_records
        type: ccc_record
        repeat: expr
        repeat-expr: count

  cce_payload:
    seq:
      - id: unknown_field1
        type: u4
      - id: count
        type: u2
      - id: data_records
        type: cce_record
        repeat: expr
        repeat-expr: count

  d00_payload:
    seq:
      - id: filename
        type: str
        encoding: ASCII
        terminator: 0x2c  # ','
      - id: total_packets
        type: str
        encoding: ASCII
        terminator: 0x2c  # ','
      - id: current_packet
        type: str
        encoding: ASCII
        terminator: 0x2c  # ','
      - id: photo_data
        size-eos: true

  d03_payload:
    seq:
      - id: response
        type: str
        encoding: ASCII
        size-eos: true

  d82_payload:
    seq:
      - id: response_data
        type: str
        encoding: ASCII
        size-eos: true

  raw_payload:
    seq:
      - id: data
        size-eos: true

  ccc_record:
    seq:
      - id: event_code
        type: u1
      - id: latitude_raw
        type: s4
      - id: longitude_raw
        type: s4
      - id: timestamp
        type: u4
      - id: validity
        type: u1
      - id: satellites
        type: u1
      - id: rssi
        type: u1
      - id: speed_raw
        type: u2
      - id: course
        type: u2
      - id: hdop_raw
        type: u2
      - id: altitude
        type: u2
      - id: odometer
        type: u4
      - id: runtime
        type: u4
      - id: cell_info
        type: cell_tower_info
      - id: status
        type: u2
      - id: adc1
        type: u2
      - id: battery_raw
        type: u2
      - id: power_raw
        type: u2
      - id: geofence
        type: u4
    instances:
      latitude:
        value: latitude_raw * 0.000001
      longitude:
        value: longitude_raw * 0.000001
      speed_kmh:
        value: speed_raw
      hdop:
        value: hdop_raw * 0.1
      battery_voltage:
        value: battery_raw * 0.01
      power_voltage:
        value: power_raw
      is_valid:
        value: validity == 1
      timestamp_epoch:
        value: timestamp + 946684800  # Add offset for 2000-01-01

  cce_record:
    seq:
      - id: record_length
        type: u2
      - id: record_index
        type: u2
      - id: byte_params
        type: byte_parameter
        repeat: expr
        repeat-expr: byte_param_count
      - id: word_params
        type: word_parameter
        repeat: expr
        repeat-expr: word_param_count
      - id: dword_params
        type: dword_parameter
        repeat: expr
        repeat-expr: dword_param_count
      - id: variable_params
        type: variable_parameter
        repeat: expr
        repeat-expr: variable_param_count
    instances:
      byte_param_count:
        value: _io.read_u1
        io: _io
      word_param_count:
        value: _io.read_u1
        io: _io
      dword_param_count:
        value: _io.read_u1
        io: _io
      variable_param_count:
        value: _io.read_u1
        io: _io

  byte_parameter:
    seq:
      - id: id
        type:
          switch-on: is_extended
          cases:
            true: u2
            false: u1
      - id: value
        type: u1
    instances:
      is_extended:
        value: _io.peek_u1 == 0xfe

  word_parameter:
    seq:
      - id: id
        type:
          switch-on: is_extended
          cases:
            true: u2
            false: u1
      - id: value
        type: u2
    instances:
      is_extended:
        value: _io.peek_u1 == 0xfe

  dword_parameter:
    seq:
      - id: id
        type:
          switch-on: is_extended
          cases:
            true: u2
            false: u1
      - id: value
        type: u4
    instances:
      is_extended:
        value: _io.peek_u1 == 0xfe

  variable_parameter:
    seq:
      - id: id
        type:
          switch-on: is_extended
          cases:
            true: u2
            false: u1
      - id: length
        type: u1
      - id: data
        size: length
    instances:
      is_extended:
        value: _io.peek_u1 == 0xfe

  cell_tower_info:
    seq:
      - id: mcc
        type: u2
      - id: mnc
        type: u2
      - id: lac
        type: u2
      - id: cell_id
        type: u2

enums:
  message_types:
    0x41414143: aac  # "AAC"
    0x43434343: ccc  # "CCC" 
    0x43434543: cce  # "CCE"
    0x44303000: d00  # "D00"
    0x44303300: d03  # "D03"
    0x44383200: d82  # "D82"

  event_codes:
    1: sos_alarm
    17: low_battery
    18: low_power
    19: overspeed
    20: geofence_enter
    21: geofence_exit
    22: power_restored
    23: power_cut
    36: tow_alarm
    37: driver_id
    44: jamming_alarm
    78: accident_alarm
    90: cornering_left
    91: cornering_right
    129: harsh_braking
    130: harsh_acceleration
    135: fatigue_driving

  parameter_ids:
    0x01: event_code
    0x02: latitude
    0x03: longitude
    0x04: timestamp
    0x05: validity
    0x06: satellites
    0x07: rssi
    0x08: speed
    0x09: course
    0x0a: hdop
    0x0b: altitude
    0x0c: odometer
    0x0d: runtime
    0x14: output_status
    0x15: input_status
    0x16: adc1
    0x17: adc2
    0x19: battery_voltage
    0x1a: power_voltage
    0x25: driver_id
    0x29: fuel_level
    0x40: event_data
    0x47: lock_state
    0x91: obd_speed
    0x92: obd_speed_alt
    0x97: throttle_position
    0x98: fuel_used
    0x99: rpm
    0x9b: obd_odometer
    0x9c: coolant_temperature
    0x9d: fuel_level_alt
    0x9f: temperature1
    0xa0: fuel_used_total
    0xa2: fuel_consumption
    0xc9: fuel_consumption_alt
    0xfe69: battery_level
    0xfef4: engine_hours
    0xfe31: alarm_data
    0xfe73: tag_sensor
    0xfea8: multi_battery