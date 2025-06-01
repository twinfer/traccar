meta:
  id: galileo
  title: Galileo GPS Tracking Protocol
  license: MIT
  ks-version: 0.11
  endian: le

doc: |
  Galileo GPS tracking protocol supporting standard messages, photo transmission,
  compressed messages, and Iridium satellite communication. Uses tag-based
  binary format with variable-length fields.

seq:
  - id: messages
    type: message_wrapper
    repeat: eos

types:
  message_wrapper:
    seq:
      - id: header
        type: u1
      - id: content
        type:
          switch-on: header
          cases:
            0x01: position_message
            0x07: photo_message
            0x08: compressed_message
            _: unknown_message

  position_message:
    seq:
      - id: length_and_flags
        type: u2
      - id: content
        type:
          switch-on: is_iridium
          cases:
            true: iridium_content
            false: standard_content
        size: length - 2
    instances:
      length:
        value: length_and_flags & 0x7fff
      is_archived:
        value: (length_and_flags & 0x8000) != 0
      is_iridium:
        value: |
          _io.read_u1 == 0x01 and _io.read_u1 == 0x00 and _io.read_u1 == 0x1c
            at _io.pos + 2

  standard_content:
    seq:
      - id: tags
        type: tag_data
        repeat: eos

  iridium_content:
    seq:
      - id: identification
        size: 3
      - id: index
        type: u4
      - id: imei
        type: str
        size: 15
        encoding: ASCII
      - id: session_status
        type: u1
      - id: reserved
        size: 4
      - id: timestamp
        type: u4
      - id: coordinates_header
        size: 3
      - id: flags
        type: u1
      - id: latitude_deg
        type: u1
      - id: latitude_min
        type: u2
      - id: longitude_deg
        type: u1
      - id: longitude_min
        type: u2
      - id: accuracy
        type: u4
      - id: data_tag_header
        type: u1
      - id: data_length
        type: u2
      - id: data
        size: data_length
    instances:
      latitude:
        value: |
          (latitude_deg + latitude_min / 60000.0) *
          ((flags & 0x02) != 0 ? -1 : 1)
      longitude:
        value: |
          (longitude_deg + longitude_min / 60000.0) *
          ((flags & 0x01) != 0 ? -1 : 1)

  photo_message:
    seq:
      - id: length
        type: u2
      - id: part_number
        type: u1
      - id: photo_data
        size: length - 1
        if: length > 1
      - id: checksum
        type: u2

  compressed_message:
    seq:
      - id: length
        type: u2
      - id: tags
        type: compressed_tag_data
        repeat: eos

  tag_data:
    seq:
      - id: tag
        type: u1
      - id: data
        type:
          switch-on: tag
          cases:
            0x03: device_id_data
            0x20: timestamp_data
            0x30: coordinates_data
            0x33: speed_course_data
            0x34: altitude_data
            0x40: status_data
            0x41: power_data
            0x42: battery_data
            0x43: device_temp_data
            0x44: acceleration_data
            0x45: output_data
            0x46: input_data
            0x5b: custom_data
            0x5c: driver_key_data
            0x90: driver_id_data
            0xc0: fuel_total_data
            0xc1: fuel_can_data
            0xd4: odometer_data
            0xe0: index_extended_data
            0xe1: command_result_data
            0xea: user_data_array
            _: generic_tag_data

  compressed_tag_data:
    seq:
      - id: minimal_data_set
        size: 10
      - id: tag_count
        type: u1
      - id: tags
        type: u1
        repeat: expr
        repeat-expr: tag_count & 0x0f
      - id: tag_data
        type: tag_data
        repeat: expr
        repeat-expr: tags.size

  device_id_data:
    seq:
      - id: device_id
        type: str
        size: 15
        encoding: ASCII

  timestamp_data:
    seq:
      - id: timestamp
        type: u4

  coordinates_data:
    seq:
      - id: status_and_satellites
        type: u1
      - id: latitude
        type: s4
      - id: longitude
        type: s4
    instances:
      is_valid:
        value: (status_and_satellites & 0xf0) == 0x00
      satellites:
        value: status_and_satellites & 0x0f
      latitude_degrees:
        value: latitude / 1000000.0
      longitude_degrees:
        value: longitude / 1000000.0

  speed_course_data:
    seq:
      - id: speed
        type: u2
      - id: course
        type: u2
    instances:
      speed_kmh:
        value: speed * 0.1
      course_degrees:
        value: course * 0.1

  altitude_data:
    seq:
      - id: altitude
        type: s2

  status_data:
    seq:
      - id: status
        type: u2

  power_data:
    seq:
      - id: power
        type: u2
    instances:
      voltage:
        value: power / 1000.0

  battery_data:
    seq:
      - id: battery
        type: u2
    instances:
      voltage:
        value: battery / 1000.0

  device_temp_data:
    seq:
      - id: temperature
        type: s1

  acceleration_data:
    seq:
      - id: acceleration
        type: u4

  output_data:
    seq:
      - id: outputs
        type: u2

  input_data:
    seq:
      - id: inputs
        type: u2

  custom_data:
    seq:
      - id: length
        type: u1
      - id: data
        size: length

  driver_key_data:
    seq:
      - id: driver_key
        size: 68

  driver_id_data:
    seq:
      - id: driver_id
        type: u4

  fuel_total_data:
    seq:
      - id: fuel_total
        type: u4
    instances:
      liters:
        value: fuel_total * 0.5

  fuel_can_data:
    seq:
      - id: fuel_level
        type: u1
      - id: temp1
        type: u1
      - id: rpm
        type: u2
    instances:
      fuel_percent:
        value: fuel_level * 0.4
      temperature:
        value: temp1 - 40
      rpm_value:
        value: rpm * 0.125

  odometer_data:
    seq:
      - id: odometer
        type: u4

  index_extended_data:
    seq:
      - id: index
        type: u4

  command_result_data:
    seq:
      - id: length
        type: u1
      - id: result
        type: str
        size: length
        encoding: ASCII

  user_data_array:
    seq:
      - id: length
        type: u1
      - id: data
        size: length

  generic_tag_data:
    seq:
      - id: data
        size: tag_length
    instances:
      tag_length:
        value: |
          _parent.tag == 0x01 or _parent.tag == 0x02 or _parent.tag == 0x35 or
          _parent.tag == 0x43 or (_parent.tag >= 0xc4 and _parent.tag <= 0xd2) or
          (_parent.tag >= 0x88 and _parent.tag <= 0x8c) or
          (_parent.tag >= 0xa0 and _parent.tag <= 0xaf) ? 1 :
          _parent.tag == 0x04 or _parent.tag == 0x10 or _parent.tag == 0x34 or
          (_parent.tag >= 0x40 and _parent.tag <= 0x46) or
          (_parent.tag >= 0x50 and _parent.tag <= 0x62) or
          (_parent.tag >= 0x70 and _parent.tag <= 0x77) or
          (_parent.tag >= 0xb0 and _parent.tag <= 0xb9) or
          (_parent.tag >= 0xd6 and _parent.tag <= 0xda) ? 2 :
          (_parent.tag >= 0x63 and _parent.tag <= 0x6f) or
          _parent.tag == 0x5d or _parent.tag == 0xfa ? 3 :
          _parent.tag == 0x20 or _parent.tag == 0x33 or _parent.tag == 0x44 or
          _parent.tag == 0x90 or (_parent.tag >= 0xc0 and _parent.tag <= 0xc3) or
          (_parent.tag >= 0xd3 and _parent.tag <= 0xdf) or
          (_parent.tag >= 0xf0 and _parent.tag <= 0xf9) or
          _parent.tag == 0x5a or _parent.tag == 0x47 or
          _parent.tag == 0xe2 or _parent.tag == 0xe9 ? 4 :
          _parent.tag == 0xfd or _parent.tag == 0xfe ? 8 :
          _parent.tag == 0x5c ? 68 : 0

  unknown_message:
    seq:
      - id: data
        size-eos: true

enums:
  message_types:
    0x01: position_data
    0x07: photo_data
    0x08: compressed_data

  tag_types:
    0x01: hardware_version
    0x02: firmware_version
    0x03: imei
    0x04: device_id
    0x10: record_index
    0x20: timestamp
    0x30: coordinates
    0x33: speed_and_course
    0x34: altitude
    0x35: hdop
    0x40: status
    0x41: power_voltage
    0x42: battery_voltage
    0x43: device_temperature
    0x44: acceleration
    0x45: output_status
    0x46: input_status
    0x48: status_extended
    0x50-0x57: adc_values
    0x58: rs232_0
    0x59: rs232_1
    0x5a: driver_key_code
    0x5b: custom_data_var
    0x5c: driver_key_68b
    0x5d: accelerometer_data
    0x60-0x62: fuel_values
    0x63-0x6f: can_data_3b
    0x70-0x77: can_b0_data
    0x88-0x8c: reserved_1b
    0x90: driver_id
    0xa0-0xaf: can_8bit_r15
    0xb0-0xb9: can_16bit_r5
    0xc0: fuel_total
    0xc1: fuel_can_data
    0xc2: can_b0
    0xc3: can_b1
    0xc4-0xd2: can_8bit_r0
    0xd3: odometer_can
    0xd4: odometer
    0xd5: can_fms
    0xd6-0xda: can_16bit_r0
    0xdb-0xdf: can_32bit_r0
    0xe0: record_index_ext
    0xe1: command_result
    0xe2-0xe9: user_data
    0xea: user_data_array
    0xf0-0xf9: can_32bit_r5
    0xfa: accelerometer_vector
    0xfd: reserved_8b_1
    0xfe: reserved_8b_2