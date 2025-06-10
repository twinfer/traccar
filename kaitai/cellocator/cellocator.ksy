meta:
  id: cellocator
  title: Cellocator GPS Tracker Protocol
  license: MIT
  ks-version: 0.11
  endian: le

doc: |
  Cellocator protocol supporting multiple message types with sophisticated
  binary format. Used by Israeli security and fleet management systems with
  advanced emergency features, driver identification, and vehicle monitoring.

seq:
  - id: message
    type: cellocator_message

instances:
  # Mathematical constant pi for coordinate conversions
  pi:
    value: 3.14159265359

types:
  cellocator_message:
    seq:
      - id: system_code
        size: 4
        contents: ["MCGP"]
        if: not is_alternative
      - id: alternative_code
        size: 4
        if: is_alternative
      - id: message_type
        type: u1
        enum: message_types
      - id: device_id
        type: u4
      - id: communication_control
        type: u2
        if: message_type != message_types::serial
      - id: packet_number
        type: u1
      - id: authentication_code
        type: u4
        if: message_type != message_types::serial
      - id: data
        type:
          switch-on: message_type
          cases:
            message_types::status: status_message
            message_types::modular_ext: modular_message
            message_types::programming: programming_message
            message_types::serial_log: serial_log_message
            message_types::serial: serial_message
            message_types::modular: modular_legacy_message
        size: data_length
      - id: checksum
        type: u1
    instances:
      is_alternative:
        value: _io.read_bytes(4)[3] != 0x50  # Not 'P'
        io: _root._io
      data_length:
        value: |
          message_type == message_types::status ? 52 :
          message_type == message_types::programming ? 18 :
          message_type == message_types::serial_log ? 57 :
          message_type == message_types::modular ? _io.read_u1_at(_io.pos + 13) :
          message_type == message_types::modular_ext ? _io.read_u2le_at(_io.pos + 13) :
          0

  status_message:
    seq:
      - id: hardware_version
        type: u1
      - id: firmware_version
        type: u1
      - id: protocol_version
        type: u1
      - id: status
        type: u1
      - id: operator_flags
        type: u1
      - id: reason_data
        type: u1
      - id: event_code
        type: u1
      - id: mode
        type: u1
      - id: input_status
        type: u4
      - id: adc_data
        type:
          switch-on: is_alternative
          cases:
            true: alternative_adc_data
            false: standard_adc_data
      - id: odometer
        type: u4
        # Actually u3 but reading as u4 and masking
      - id: driver_id
        size: 6
      - id: fix_time
        type: u2
      - id: location_status
        type: u1
      - id: mode1
        type: u1
      - id: mode2
        type: u1
      - id: satellites
        type: u1
      - id: position_data
        type:
          switch-on: is_alternative
          cases:
            true: alternative_position_data
            false: standard_position_data
      - id: datetime
        type: datetime_data
    instances:
      is_alternative:
        value: _parent.is_alternative
      status_flags:
        value: status & 0x0f
      ignition_on:
        value: (input_status >> (3 * 8 + 5)) & 1 != 0
      door_open:
        value: (input_status >> (3 * 8)) & 1 != 0
      charge_status:
        value: (input_status >> 7) & 1 != 0
      odometer_km:
        value: (odometer & 0xffffff) / 1000.0
      alarm_type:
        value: |
          event_code == 70 ? "sos" :
          event_code == 80 ? "power_cut" :
          event_code == 81 ? "low_power" : 
          "unknown"

  standard_adc_data:
    seq:
      - id: operator
        type: u1
      - id: adc1
        type: u1
      - id: adc2
        type: u1
      - id: adc3
        type: u1
      - id: adc4
        type: u1

  alternative_adc_data:
    seq:
      - id: input
        type: u1
      - id: adc1
        type: u2
      - id: adc2
        type: u2

  standard_position_data:
    seq:
      - id: longitude_raw
        type: s4
      - id: latitude_raw
        type: s4
      - id: altitude_raw
        type: s4
      - id: speed_raw
        type: u4
      - id: course_raw
        type: u2
    instances:
      longitude:
        value: longitude_raw / _root.pi * 180.0 / 100000000.0
      latitude:
        value: latitude_raw / _root.pi * 180.0 / 100000000.0
      altitude_meters:
        value: altitude_raw * 0.01
      speed_mps:
        value: speed_raw * 0.01
      speed_kmh:
        value: speed_mps * 3.6
      speed_knots:
        value: speed_mps * 1.943844
      course_degrees:
        value: course_raw / _root.pi * 180.0 / 1000.0

  alternative_position_data:
    seq:
      - id: longitude_raw
        type: s4
      - id: latitude_raw
        type: s4
      - id: altitude_raw
        type: s4
      - id: speed_raw
        type: u4
      - id: course_raw
        type: u2
    instances:
      longitude:
        value: longitude_raw / 10000000.0
      latitude:
        value: latitude_raw / 10000000.0
      altitude_meters:
        value: altitude_raw * 0.01
      speed_kmh:
        value: speed_raw / 1000.0
      speed_knots:
        value: speed_kmh * 0.539957
      course_degrees:
        value: course_raw / 1000.0

  datetime_data:
    seq:
      - id: hour
        type: u1
      - id: minute
        type: u1
      - id: second
        type: u1
      - id: day
        type: u1
      - id: month
        type: u1
      - id: year
        type: u2
    instances:
      timestamp:
        value: |
          year * 10000000000 + month * 100000000 + 
          day * 1000000 + hour * 10000 + minute * 100 + second

  modular_message:
    seq:
      - id: packet_control
        type: u1
      - id: total_length
        type: u2
      - id: reserved1
        type: u2
      - id: reserved2
        type: u2
      - id: modules
        type: module_data
        repeat: eos

  module_data:
    seq:
      - id: module_type
        type: u1
        enum: module_types
      - id: module_length
        type: u2
      - id: module_content
        type:
          switch-on: module_type
          cases:
            module_types::io_module: io_module_data
            module_types::gps_module: gps_module_data
            module_types::time_module: time_module_data
        size: module_length

  io_module_data:
    seq:
      - id: operator_id
        type: u2
      - id: pl_signature
        type: u4
      - id: io_count
        type: u1
      - id: io_values
        type: io_value_entry
        repeat: expr
        repeat-expr: io_count

  io_value_entry:
    seq:
      - id: io_id
        type: u2
      - id: variable_length
        type: u1
      - id: io_value
        type: u4

  gps_module_data:
    seq:
      - id: hdop
        type: u1
      - id: mode1
        type: u1
      - id: mode2
        type: u1
      - id: satellites
        type: u1
      - id: longitude_raw
        type: s4
      - id: latitude_raw
        type: s4
      - id: altitude_raw
        type: s4
      - id: speed_raw
        type: u1
      - id: course_raw
        type: u2
    instances:
      longitude:
        value: longitude_raw / _root.pi * 180.0 / 100000000.0
      latitude:
        value: latitude_raw / _root.pi * 180.0 / 100000000.0
      altitude_meters:
        value: altitude_raw * 0.01
      speed_mps:
        value: speed_raw * 0.01
      speed_knots:
        value: speed_mps * 1.943844
      course_degrees:
        value: course_raw / _root.pi * 180.0 / 1000.0

  time_module_data:
    seq:
      - id: valid
        type: u1
      - id: hour
        type: u1
      - id: minute
        type: u1
      - id: second
        type: u1
      - id: day
        type: u1
      - id: month
        type: u1
      - id: year
        type: u1

  programming_message:
    seq:
      - id: programming_data
        size-eos: true

  serial_log_message:
    seq:
      - id: serial_log_data
        size-eos: true

  serial_message:
    seq:
      - id: serial_length
        type: u2
      - id: serial_data
        size: serial_length

  modular_legacy_message:
    seq:
      - id: legacy_data
        size-eos: true

enums:
  message_types:
    0: status
    3: programming
    7: serial_log
    8: serial
    9: modular
    11: modular_ext

  module_types:
    2: io_module
    6: gps_module
    7: time_module

  alarm_types:
    70: sos_alarm
    80: power_cut_alarm
    81: low_power_alarm

  status_values:
    0x00: inactive
    0x01: active
    0x02: emergency
    0x03: panic
    0x04: vehicle_disabled
    0x05: test_mode
    0x06: service_mode
    0x07: programming_mode
    0x08: warehouse_mode
    0x09: demo_mode
    0x0a: sleep_mode
    0x0b: unknown_mode
    0x0c: manual_mode
    0x0d: automatic_mode
    0x0e: engine_on
    0x0f: reserved

  input_flags:
    0: input_1
    1: input_2
    2: input_3
    3: input_4
    4: input_5
    5: input_6
    6: input_7
    7: charge_status
    8: tamper_switch
    9: engine_status
    10: acc_status
    11: door_1
    12: door_2
    13: door_3
    14: door_4
    15: trunk
    16: hood
    17: panic_button
    18: aux_1
    19: aux_2
    20: aux_3
    21: aux_4
    22: aux_5
    23: aux_6
    24: door_status
    25: engine_block
    26: fuel_sensor
    27: temperature
    28: humidity
    29: ignition