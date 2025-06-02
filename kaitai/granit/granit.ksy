meta:
  id: granit
  title: Granit GPS Tracker Protocol
  license: MIT
  ks-version: 0.11
  endian: le

doc: |
  Granit protocol supporting GPS tracking devices with ASCII headers and binary
  data. Features current position reports, archive data transmission, bidirectional
  commands, and XOR checksum validation. Used primarily in Eastern European markets.

seq:
  - id: message
    type: granit_packet

types:
  granit_packet:
    seq:
      - id: header
        size: 6
        type: str
        encoding: ASCII
      - id: message_body
        type:
          switch-on: header
          cases:
            '"+RRCB~"': current_position_message
            '"+DDAT~"': archive_data_message
            '"BB+UGR"': current_response_message  # BB+UGRC~
            '"BB+ARC"': archive_response_message  # BB+ARCF~
            '"BB+IDN"': command_message           # BB+IDNT
            '"BB+RES"': command_message           # BB+RESET
            '"BB+RRC"': command_message           # BB+RRCD
            _: text_message
    instances:
      message_type:
        value: |
          header == "+RRCB~" ? message_types::current_position :
          header == "+DDAT~" ? message_types::archive_data :
          header.substring(0, 6) == "BB+UGR" ? message_types::current_response :
          header.substring(0, 6) == "BB+ARC" ? message_types::archive_response :
          header.substring(0, 6) == "BB+IDN" ? message_types::identification_command :
          header.substring(0, 6) == "BB+RES" ? message_types::reset_command :
          header.substring(0, 6) == "BB+RRC" ? message_types::position_request :
          message_types::text_message
        enum: message_types

  current_position_message:
    seq:
      - id: data_length
        type: u2
        doc: Always 26 (0x1A) for current position
      - id: device_id
        type: u2
      - id: timestamp
        type: u4
        doc: Unix timestamp (seconds since epoch)
      - id: position
        type: position_record
      - id: checksum_delimiter
        contents: "*"
      - id: checksum
        size: 2
        type: str
        encoding: ASCII
      - id: terminator
        contents: [0x0D, 0x0A]
    instances:
      unix_time:
        value: timestamp
      device_identifier:
        value: device_id.to_s

  archive_data_message:
    seq:
      - id: data_length
        type: u2
      - id: device_id
        type: u2
      - id: format
        type: u1
        doc: Must be 4
      - id: num_blocks
        type: u1
      - id: pack_number
        type: u2
      - id: data_blocks
        type: archive_block
        repeat: expr
        repeat-expr: num_blocks
      - id: checksum_delimiter
        contents: "*"
      - id: checksum
        size: 2
        type: str
        encoding: ASCII
      - id: terminator
        contents: [0x0D, 0x0A]
    instances:
      device_identifier:
        value: device_id.to_s

  archive_block:
    seq:
      - id: base_timestamp
        type: u4
        doc: Unix timestamp for first position in block
      - id: positions
        type: position_record
        repeat: expr
        repeat-expr: 6
      - id: time_increment
        type: u2
        doc: Seconds between consecutive positions

  current_response_message:
    seq:
      - id: header_suffix
        contents: "C~"
      - id: data_length
        type: u2
        doc: Always 6 (0x0600)
      - id: timestamp
        type: u4
      - id: device_id
        type: u2
      - id: checksum_delimiter
        contents: "*"
      - id: checksum
        size: 2
        type: str
        encoding: ASCII
      - id: terminator
        contents: [0x0D, 0x0A]

  archive_response_message:
    seq:
      - id: header_suffix
        contents: "F~"
      - id: data_length
        type: u2
        doc: Always 4 (0x0400)
      - id: pack_number
        type: u2
      - id: device_id
        type: u2
      - id: checksum_delimiter
        contents: "*"
      - id: checksum
        size: 2
        type: str
        encoding: ASCII
      - id: terminator
        contents: [0x0D, 0x0A]

  command_message:
    seq:
      - id: command_data
        size-eos: true
        type: str
        encoding: ASCII

  text_message:
    seq:
      - id: text_data
        size-eos: true
        type: str
        encoding: ASCII

  position_record:
    seq:
      - id: flags
        type: u1
      - id: sat_pdop
        type: u1
        if: flags != 0xFE
      - id: lon_degrees
        type: u1
        if: flags != 0xFE
      - id: lat_degrees
        type: u1
        if: flags != 0xFE
      - id: lon_minutes
        type: u2
        if: flags != 0xFE
      - id: lat_minutes
        type: u2
        if: flags != 0xFE
      - id: speed
        type: u1
        if: flags != 0xFE
      - id: course_low
        type: u1
        if: flags != 0xFE
      - id: distance
        type: u2
        if: flags != 0xFE
      - id: adc1_low
        type: u1
        if: flags != 0xFE
      - id: adc2_low
        type: u1
        if: flags != 0xFE
      - id: adc3_low
        type: u1
        if: flags != 0xFE
      - id: adc4_low
        type: u1
        if: flags != 0xFE
      - id: adc_high_bits
        type: u1
        if: flags != 0xFE
      - id: altitude_raw
        type: u1
        if: flags != 0xFE
      - id: outputs
        type: u1
        if: flags != 0xFE
      - id: status
        type: u1
        if: flags != 0xFE
      - id: empty_padding
        size: 19
        if: flags == 0xFE
    instances:
      is_empty:
        value: flags == 0xFE
      valid_position:
        value: 'is_empty ? false : (flags & 0x80) != 0'
      course_high_bit:
        value: 'is_empty ? false : (flags & 0x40) != 0'
      longitude_negative:
        value: 'is_empty ? false : (flags & 0x20) == 0'
      latitude_negative:
        value: 'is_empty ? false : (flags & 0x10) == 0'
      alarm:
        value: 'is_empty ? false : (flags & 0x02) != 0'
      satellites:
        value: 'is_empty ? 0 : (sat_pdop >> 4) & 0x0F'
      pdop:
        value: 'is_empty ? 0 : sat_pdop & 0x0F'
      longitude:
        value: 'is_empty ? 0 : (longitude_negative ? -1 : 1) * (lon_degrees + lon_minutes / 60000.0)'
      latitude:
        value: 'is_empty ? 0 : (latitude_negative ? -1 : 1) * (lat_degrees + lat_minutes / 60000.0)'
      speed_kmh:
        value: 'is_empty ? 0 : speed'
      speed_knots:
        value: 'is_empty ? 0 : speed * 0.539957'
      course:
        value: 'is_empty ? 0 : course_low + (course_high_bit ? 256 : 0)'
      altitude_meters:
        value: 'is_empty ? 0 : altitude_raw * 10'
      adc1:
        value: 'is_empty ? 0 : adc1_low + ((adc_high_bits >> 6) & 0x03) * 256'
      adc2:
        value: 'is_empty ? 0 : adc2_low + ((adc_high_bits >> 4) & 0x03) * 256'
      adc3:
        value: 'is_empty ? 0 : adc3_low + ((adc_high_bits >> 2) & 0x03) * 256'
      adc4:
        value: 'is_empty ? 0 : adc4_low + (adc_high_bits & 0x03) * 256'
      output1:
        value: 'is_empty ? false : (outputs & 0x01) != 0'
      output2:
        value: 'is_empty ? false : (outputs & 0x02) != 0'
      output3:
        value: 'is_empty ? false : (outputs & 0x04) != 0'
      output4:
        value: 'is_empty ? false : (outputs & 0x08) != 0'
      output5:
        value: 'is_empty ? false : (outputs & 0x10) != 0'
      output6:
        value: 'is_empty ? false : (outputs & 0x20) != 0'
      output7:
        value: 'is_empty ? false : (outputs & 0x40) != 0'
      output8:
        value: 'is_empty ? false : (outputs & 0x80) != 0'

enums:
  message_types:
    0x01: current_position
    0x02: archive_data
    0x03: current_response
    0x04: archive_response
    0x05: identification_command
    0x06: reset_command
    0x07: position_request
    0x08: text_message

  flag_bits:
    0x80: valid_position
    0x40: course_high_bit
    0x20: longitude_positive
    0x10: latitude_positive
    0x02: alarm

  adc_high_mask:
    0xC0: adc1_bits_9_8  # bits 7-6
    0x30: adc2_bits_9_8  # bits 5-4
    0x0C: adc3_bits_9_8  # bits 3-2
    0x03: adc4_bits_9_8  # bits 1-0

  output_mask:
    0x01: output1
    0x02: output2
    0x04: output3
    0x08: output4
    0x10: output5
    0x20: output6
    0x40: output7
    0x80: output8