meta:
  id: ruptela
  title: Ruptela GPS Tracker Protocol
  license: MIT
  ks-version: 0.11
  endian: be

doc: |
  Ruptela protocol supporting GPS tracking devices with position records, extended
  I/O data, diagnostic trouble codes (DTC), and file/photo transmission. Features
  CRC16-KERMIT validation and support for both standard and extended record formats.

seq:
  - id: message
    type: ruptela_packet

types:
  ruptela_packet:
    seq:
      - id: data_length
        type: u2
        doc: Length of payload (excluding this field and CRC)
      - id: imei
        type: u8
        doc: Device IMEI as 64-bit integer
      - id: message_type
        type: u1
        enum: message_types
      - id: payload
        size: data_length - 9
        type:
          switch-on: message_type
          cases:
            message_types::msg_records: records_payload
            message_types::msg_dtcs: dtcs_payload
            message_types::msg_extended_records: extended_records_payload
            message_types::msg_files: files_payload
            message_types::msg_device_configuration: generic_payload
            message_types::msg_device_version: generic_payload
            message_types::msg_firmware_update: generic_payload
            message_types::msg_set_connection: generic_payload
            message_types::msg_set_odometer: generic_payload
            message_types::msg_sms_via_gprs_response: generic_payload
            message_types::msg_sms_via_gprs: generic_payload
            message_types::msg_identification: generic_payload
            message_types::msg_heartbeat: generic_payload
            message_types::msg_set_io: generic_payload
      - id: crc16
        type: u2
        doc: CRC16-KERMIT checksum
    instances:
      device_id:
        value: imei.to_s

  records_payload:
    seq:
      - id: records_left
        type: u1
        doc: Number of records remaining after this message
      - id: records_count
        type: u1
        doc: Number of records in this message
      - id: records
        type: position_record
        repeat: expr
        repeat-expr: records_count

  extended_records_payload:
    seq:
      - id: records_left
        type: u1
        doc: Number of records remaining after this message
      - id: records_count
        type: u1
        doc: Number of records in this message
      - id: records
        type: extended_position_record
        repeat: expr
        repeat-expr: records_count

  position_record:
    seq:
      - id: timestamp
        type: u4
        doc: Unix timestamp (seconds since epoch)
      - id: timestamp_extension
        type: u1
        doc: Additional timestamp precision
      - id: priority
        type: u1
        doc: Reserved/priority field
      - id: longitude_raw
        type: s4
      - id: latitude_raw
        type: s4
      - id: altitude_raw
        type: u2
      - id: course_raw
        type: u2
      - id: satellites
        type: u1
      - id: speed
        type: u2
        doc: Speed in km/h
      - id: hdop_raw
        type: u1
      - id: event_id
        type: u1
      - id: io_data
        type: io_element_1byte
    instances:
      valid_position:
        value: longitude_raw != -2147483648 and latitude_raw != -2147483648
      longitude:
        value: longitude_raw / 10000000.0
      latitude:
        value: latitude_raw / 10000000.0
      altitude:
        value: altitude_raw / 10.0
      course:
        value: course_raw / 100.0
      hdop:
        value: hdop_raw / 10.0
      unix_time:
        value: timestamp

  extended_position_record:
    seq:
      - id: timestamp
        type: u4
        doc: Unix timestamp (seconds since epoch)
      - id: timestamp_extension
        type: u1
        doc: Additional timestamp precision
      - id: record_extension
        type: u1
        doc: High nibble = merge count, low nibble = current record
      - id: priority
        type: u1
        doc: Reserved/priority field
      - id: longitude_raw
        type: s4
      - id: latitude_raw
        type: s4
      - id: altitude_raw
        type: u2
      - id: course_raw
        type: u2
      - id: satellites
        type: u1
      - id: speed
        type: u2
        doc: Speed in km/h
      - id: hdop_raw
        type: u1
      - id: event_id
        type: u2
      - id: io_data
        type: io_element_2byte
    instances:
      valid_position:
        value: longitude_raw != -2147483648 and latitude_raw != -2147483648
      longitude:
        value: longitude_raw / 10000000.0
      latitude:
        value: latitude_raw / 10000000.0
      altitude:
        value: altitude_raw / 10.0
      course:
        value: course_raw / 100.0
      hdop:
        value: hdop_raw / 10.0
      unix_time:
        value: timestamp
      merge_record_count:
        value: (record_extension >> 4) & 0x0F
      current_record_number:
        value: record_extension & 0x0F

  dtcs_payload:
    seq:
      - id: dtc_count
        type: u1
      - id: dtcs
        type: dtc_record
        repeat: expr
        repeat-expr: dtc_count

  dtc_record:
    seq:
      - id: reserved
        type: u1
      - id: timestamp
        type: u4
      - id: longitude_raw
        type: s4
      - id: latitude_raw
        type: s4
      - id: archive_flag
        type: u1
        doc: 2 indicates archived
      - id: dtc_code
        type: str
        encoding: ASCII
        size: 5
    instances:
      longitude:
        value: longitude_raw / 10000000.0
      latitude:
        value: latitude_raw / 10000000.0
      is_archived:
        value: archive_flag == 2

  files_payload:
    seq:
      - id: subtype
        type: u1
        doc: File operation type (2 for photo data)
      - id: source
        type: u1
        doc: File source identifier
      - id: filename
        size: 8
        if: subtype == 2
      - id: total_parts
        type: u2
        doc: Total number of file parts
      - id: current_part
        type: u2
        doc: Current part number (0-based)
      - id: data
        size-eos: true
        doc: File data chunk

  io_element_1byte:
    seq:
      - id: cnt_1byte
        type: u1
      - id: values_1byte
        type: io_value_1byte_id1
        repeat: expr
        repeat-expr: cnt_1byte
      - id: cnt_2byte
        type: u1
      - id: values_2byte
        type: io_value_2byte_id1
        repeat: expr
        repeat-expr: cnt_2byte
      - id: cnt_4byte
        type: u1
      - id: values_4byte
        type: io_value_4byte_id1
        repeat: expr
        repeat-expr: cnt_4byte
      - id: cnt_8byte
        type: u1
      - id: values_8byte
        type: io_value_8byte_id1
        repeat: expr
        repeat-expr: cnt_8byte

  io_element_2byte:
    seq:
      - id: cnt_1byte
        type: u1
      - id: values_1byte
        type: io_value_1byte_id2
        repeat: expr
        repeat-expr: cnt_1byte
      - id: cnt_2byte
        type: u1
      - id: values_2byte
        type: io_value_2byte_id2
        repeat: expr
        repeat-expr: cnt_2byte
      - id: cnt_4byte
        type: u1
      - id: values_4byte
        type: io_value_4byte_id2
        repeat: expr
        repeat-expr: cnt_4byte
      - id: cnt_8byte
        type: u1
      - id: values_8byte
        type: io_value_8byte_id2
        repeat: expr
        repeat-expr: cnt_8byte

  io_value_1byte_id1:
    seq:
      - id: parameter_id
        type: u1
      - id: value
        type: u1

  io_value_2byte_id1:
    seq:
      - id: parameter_id
        type: u1
      - id: value
        type: u2

  io_value_4byte_id1:
    seq:
      - id: parameter_id
        type: u1
      - id: value
        type: u4

  io_value_8byte_id1:
    seq:
      - id: parameter_id
        type: u1
      - id: value
        type: u8

  io_value_1byte_id2:
    seq:
      - id: parameter_id
        type: u2
      - id: value
        type: u1

  io_value_2byte_id2:
    seq:
      - id: parameter_id
        type: u2
      - id: value
        type: u2

  io_value_4byte_id2:
    seq:
      - id: parameter_id
        type: u2
      - id: value
        type: u4

  io_value_8byte_id2:
    seq:
      - id: parameter_id
        type: u2
      - id: value
        type: u8

  generic_payload:
    seq:
      - id: data
        size-eos: true

enums:
  message_types:
    0x01: msg_records
    0x02: msg_device_configuration
    0x03: msg_device_version
    0x04: msg_firmware_update
    0x05: msg_set_connection
    0x06: msg_set_odometer
    0x07: msg_sms_via_gprs_response
    0x08: msg_sms_via_gprs
    0x09: msg_dtcs
    0x0F: msg_identification
    0x10: msg_heartbeat
    0x11: msg_set_io
    0x25: msg_files
    0x44: msg_extended_records

  common_io_parameters:
    2: digital_input_1
    3: digital_input_2
    4: digital_input_3
    5: digital_input_4
    13: motion_detection
    20: analog_input_1
    21: analog_input_2
    22: analog_input_3
    23: analog_input_4
    29: power_voltage_mv
    30: battery_voltage_mv
    32: device_temperature
    65: odometer_value
    94: engine_rpm
    95: obd_speed
    98: fuel_level
    126: driver_id_part1
    127: driver_id_part2
    155: driver_id_alt_part1
    156: driver_id_alt_part2
    163: odometer_value_alt
    164: odometer_value_alt2
    165: obd_speed_alt
    166: engine_rpm_alt
    173: motion_detection_alt
    197: engine_rpm_alt2
    205: fuel_level_alt
    207: fuel_level_alt2
    251: ignition_status
    409: ignition_status_alt
    760: tag_id_part1
    761: tag_id_part2