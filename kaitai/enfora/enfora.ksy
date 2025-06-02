meta:
  id: enfora
  title: Enfora GPS Tracker Protocol
  license: MIT
  ks-version: 0.11
  endian: be

doc: |
  Enfora protocol supporting GPS tracking devices with NMEA GPRMC sentence transmission.
  Features length-prefixed binary frames containing device IMEI and standard NMEA GPS data.
  Used primarily by Enfora wireless modems and trackers.

seq:
  - id: message
    type: enfora_packet

types:
  enfora_packet:
    seq:
      - id: length
        type: u2
        doc: Total message length including this field
      - id: index
        type: u2
        doc: Message sequence number
      - id: command_type
        type: u1
        enum: command_types
      - id: optional_header
        type: u1
        if: _io.size >= 6
      - id: body
        size: length - 6
        if: optional_header.as<u1>? >= 0
        type:
          switch-on: command_type
          cases:
            command_types::gps_data: gps_data_body
            command_types::command: command_body
            command_types::data_08: data_body
            command_types::data_0a: data_body
      - id: body_no_header
        size: length - 5
        if: not (optional_header.as<u1>? >= 0)
        type:
          switch-on: command_type
          cases:
            command_types::gps_data: gps_data_body
            command_types::command: command_body
            command_types::data_08: data_body
            command_types::data_0a: data_body
    instances:
      message_size:
        value: length
      sequence_number:
        value: index
      has_optional_header:
        value: _io.size >= 6

  gps_data_body:
    seq:
      - id: raw_data
        size-eos: true
    instances:
      imei:
        value: extract_imei
      nmea_sentence:
        value: extract_nmea
      gprmc_data:
        value: parse_gprmc

  command_body:
    seq:
      - id: command_string
        type: str
        encoding: ASCII
        size-eos: true

  data_body:
    seq:
      - id: data
        size-eos: true

  gprmc_sentence:
    doc: Parsed GPRMC NMEA sentence data
    params:
      - id: sentence
        type: str
    instances:
      fields:
        value: sentence.split(",")
      time_str:
        value: fields[1]
        if: fields.length > 1
      status:
        value: fields[2]
        if: fields.length > 2
      latitude_str:
        value: fields[3]
        if: fields.length > 3
      lat_hemisphere:
        value: fields[4]
        if: fields.length > 4
      longitude_str:
        value: fields[5]
        if: fields.length > 5
      lon_hemisphere:
        value: fields[6]
        if: fields.length > 6
      speed_knots_str:
        value: fields[7]
        if: fields.length > 7
      course_str:
        value: fields[8]
        if: fields.length > 8
      date_str:
        value: fields[9]
        if: fields.length > 9
      valid_fix:
        value: status == "A"
      latitude:
        value: |
          latitude_str.length >= 9 ?
          (latitude_str.substring(0, 2).to_f + 
           latitude_str.substring(2, latitude_str.length).to_f / 60.0) *
          (lat_hemisphere == "S" ? -1 : 1) : 0
      longitude:
        value: |
          longitude_str.length >= 10 ?
          (longitude_str.substring(0, 3).to_f + 
           longitude_str.substring(3, longitude_str.length).to_f / 60.0) *
          (lon_hemisphere == "W" ? -1 : 1) : 0
      speed_knots:
        value: speed_knots_str.to_f
      speed_kmh:
        value: speed_knots * 1.852
      course:
        value: course_str.to_f
      hour:
        value: time_str.substring(0, 2).to_i
        if: time_str.length >= 6
      minute:
        value: time_str.substring(2, 4).to_i
        if: time_str.length >= 6
      second:
        value: time_str.substring(4, 6).to_i
        if: time_str.length >= 6
      day:
        value: date_str.substring(0, 2).to_i
        if: date_str.length >= 6
      month:
        value: date_str.substring(2, 4).to_i
        if: date_str.length >= 6
      year:
        value: 2000 + date_str.substring(4, 6).to_i
        if: date_str.length >= 6

  # Helper instances would need to be implemented in actual parser
  # These are conceptual representations of the extraction logic
  extract_imei:
    doc: |
      Extract 15 consecutive digits from the raw data.
      This would need custom parsing logic to find 15 consecutive
      ASCII digits (0x30-0x39) in the raw data.

  extract_nmea:
    doc: |
      Extract NMEA sentence starting from "GPRMC" to the end.
      This would need custom parsing logic to find the GPRMC
      substring and extract from there to the end of data.

  parse_gprmc:
    doc: |
      Parse the extracted GPRMC sentence.
      This would use the gprmc_sentence type with the extracted NMEA data.

enums:
  command_types:
    0x00: keep_alive
    0x02: gps_data
    0x04: command
    0x08: data_08
    0x0A: data_0a
    0x10: response
    0x11: acknowledgment