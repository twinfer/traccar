meta:
  id: fifotrack
  title: Fifotrack GPS Tracker Protocol
  license: MIT
  ks-version: 0.11
  endian: be

doc: |
  Fifotrack protocol supporting GPS tracking with text-based messages and binary
  photo transmission. Features location reporting, alarm notifications, cell tower
  data, WiFi positioning, RFID support, and incremental photo upload capability.

seq:
  - id: message
    type: fifotrack_packet

types:
  fifotrack_packet:
    seq:
      - id: prefix
        contents: "$$"
      - id: length
        type: str
        encoding: ASCII
        terminator: 0x2C  # ','
      - id: imei
        type: str
        encoding: ASCII
        terminator: 0x2C
      - id: message_index
        type: str
        encoding: ASCII
        terminator: 0x2C
      - id: message_type
        type: str
        encoding: ASCII
        size: 3
      - id: comma_after_type
        contents: ","
        if: message_type != "D06"
      - id: message_data
        type:
          switch-on: message_type
          cases:
            '"A01"': location_message_a01
            '"A03"': location_message_a03
            '"D05"': photo_request_message
            '"D06"': photo_data_message
            '"B01"': command_result_message
            '"B03"': command_result_message
            '"B11"': command_result_message
            _: generic_message
      - id: checksum_delimiter
        contents: "*"
      - id: checksum
        type: str
        encoding: ASCII
        size: 2
      - id: terminator
        contents: [0x0D, 0x0A]
    instances:
      device_id:
        value: imei
      sequence_number:
        value: message_index

  location_message_a01:
    seq:
      - id: alarm_code
        type: str
        encoding: ASCII
        terminator: 0x2C
        consume: false
      - id: alarm_separator
        contents: ","
        if: alarm_code.length > 0
      - id: datetime
        type: str
        encoding: ASCII
        size: 12
      - id: comma1
        contents: ","
      - id: validity
        type: str
        encoding: ASCII
        size: 1
      - id: comma2
        contents: ","
      - id: latitude
        type: str
        encoding: ASCII
        terminator: 0x2C
      - id: longitude
        type: str
        encoding: ASCII
        terminator: 0x2C
      - id: speed
        type: str
        encoding: ASCII
        terminator: 0x2C
      - id: course
        type: str
        encoding: ASCII
        terminator: 0x2C
      - id: altitude
        type: str
        encoding: ASCII
        terminator: 0x2C
      - id: odometer
        type: str
        encoding: ASCII
        terminator: 0x2C
      - id: engine_hours
        type: str
        encoding: ASCII
        terminator: 0x2C
      - id: status
        type: str
        encoding: ASCII
        terminator: 0x2C
      - id: inputs
        type: str
        encoding: ASCII
        terminator: 0x2C
      - id: outputs
        type: str
        encoding: ASCII
        terminator: 0x2C
      - id: cell_info
        type: str
        encoding: ASCII
        terminator: 0x2C
      - id: adc_values
        type: str
        encoding: ASCII
        terminator: 0x2C
        consume: false
      - id: optional_data
        type: str
        encoding: ASCII
        size-eos: true
    instances:
      valid_position:
        value: validity == "A"
      latitude_degrees:
        value: latitude.to_f
      longitude_degrees:
        value: longitude.to_f
      speed_kmh:
        value: speed.to_f
      speed_knots:
        value: speed.to_f * 0.539957
      course_degrees:
        value: course.to_f
      altitude_meters:
        value: altitude.to_f
      odometer_meters:
        value: odometer.to_f
      year:
        value: 2000 + datetime.substring(0, 2).to_i
      month:
        value: datetime.substring(2, 4).to_i
      day:
        value: datetime.substring(4, 6).to_i
      hour:
        value: datetime.substring(6, 8).to_i
      minute:
        value: datetime.substring(8, 10).to_i
      second:
        value: datetime.substring(10, 12).to_i
      alarm_type:
        value: |
          alarm_code == "2" ? alarm_types::sos :
          alarm_code == "14" ? alarm_types::low_power :
          alarm_code == "15" ? alarm_types::power_cut :
          alarm_code == "16" ? alarm_types::power_restored :
          alarm_code == "17" ? alarm_types::low_battery :
          alarm_code == "18" ? alarm_types::overspeed :
          alarm_code == "20" ? alarm_types::gps_antenna_cut :
          alarm_code == "21" ? alarm_types::vibration :
          alarm_code == "23" ? alarm_types::acceleration :
          alarm_code == "24" ? alarm_types::braking :
          alarm_code == "27" ? alarm_types::fatigue_driving :
          alarm_code == "30" ? alarm_types::jamming :
          alarm_code == "31" ? alarm_types::fall_down :
          alarm_code == "32" ? alarm_types::jamming :
          alarm_code == "33" ? alarm_types::geofence_exit :
          alarm_code == "34" ? alarm_types::geofence_enter :
          alarm_code == "35" ? alarm_types::idle :
          alarm_code == "40" ? alarm_types::temperature :
          alarm_code == "41" ? alarm_types::temperature :
          alarm_code == "53" ? alarm_types::power_on :
          alarm_code == "54" ? alarm_types::power_off :
          alarm_types::none
        enum: alarm_types

  location_message_a03:
    seq:
      - id: alarm_code
        type: str
        encoding: ASCII
        terminator: 0x2C
      - id: datetime
        type: str
        encoding: ASCII
        size: 12
      - id: comma1
        contents: ","
      - id: cell_info
        type: str
        encoding: ASCII
        terminator: 0x2C
      - id: battery
        type: str
        encoding: ASCII
        terminator: 0x2C
      - id: battery_level
        type: str
        encoding: ASCII
        terminator: 0x2C
      - id: status
        type: str
        encoding: ASCII
        terminator: 0x2C
      - id: location_type
        type: str
        encoding: ASCII
        size: 1
      - id: comma2
        contents: ","
      - id: location_data
        type:
          switch-on: location_type
          cases:
            '"0"': gps_location_data
            '"1"': wifi_location_data
            _: raw_location_data
    instances:
      year:
        value: 2000 + datetime.substring(0, 2).to_i
      month:
        value: datetime.substring(2, 4).to_i
      day:
        value: datetime.substring(4, 6).to_i
      hour:
        value: datetime.substring(6, 8).to_i
      minute:
        value: datetime.substring(8, 10).to_i
      second:
        value: datetime.substring(10, 12).to_i

  gps_location_data:
    seq:
      - id: validity
        type: str
        encoding: ASCII
        size: 1
      - id: comma1
        contents: ","
      - id: speed
        type: str
        encoding: ASCII
        terminator: 0x2C
      - id: satellites
        type: str
        encoding: ASCII
        terminator: 0x2C
      - id: latitude
        type: str
        encoding: ASCII
        terminator: 0x2C
      - id: longitude
        type: str
        encoding: ASCII
        size-eos: true
    instances:
      valid_position:
        value: validity == "A"
      speed_kmh:
        value: speed.to_f
      satellite_count:
        value: satellites.to_i
      latitude_degrees:
        value: latitude.to_f
      longitude_degrees:
        value: longitude.to_f

  wifi_location_data:
    seq:
      - id: wifi_aps
        type: str
        encoding: ASCII
        size-eos: true

  raw_location_data:
    seq:
      - id: data
        type: str
        encoding: ASCII
        size-eos: true

  photo_request_message:
    seq:
      - id: photo_length
        type: str
        encoding: ASCII
        terminator: 0x2C
      - id: photo_id
        type: str
        encoding: ASCII
        size-eos: true
    instances:
      photo_size_bytes:
        value: photo_length.to_i
      photo_identifier:
        value: photo_id

  photo_data_message:
    seq:
      - id: photo_id
        type: str
        encoding: ASCII
        terminator: 0x2C
      - id: offset
        type: str
        encoding: ASCII
        terminator: 0x2C
      - id: data_size
        type: str
        encoding: ASCII
        terminator: 0x2C
      - id: binary_data
        size: data_size.to_i
    instances:
      photo_identifier:
        value: photo_id
      data_offset:
        value: offset.to_i
      chunk_size:
        value: data_size.to_i

  command_result_message:
    seq:
      - id: result
        type: str
        encoding: ASCII
        size-eos: true

  generic_message:
    seq:
      - id: data
        type: str
        encoding: ASCII
        size-eos: true

  response_packet:
    seq:
      - id: prefix
        contents: "##"
      - id: length
        type: str
        encoding: ASCII
        terminator: 0x2C
      - id: imei
        type: str
        encoding: ASCII
        terminator: 0x2C
      - id: content
        type: str
        encoding: ASCII
        terminator: 0x2A  # '*'
      - id: checksum
        type: str
        encoding: ASCII
        size: 2
      - id: terminator
        contents: [0x0D, 0x0A]

enums:
  alarm_types:
    0: none
    2: sos
    14: low_power
    15: power_cut
    16: power_restored
    17: low_battery
    18: overspeed
    20: gps_antenna_cut
    21: vibration
    23: acceleration
    24: braking
    27: fatigue_driving
    30: jamming
    31: fall_down
    33: geofence_exit
    34: geofence_enter
    35: idle
    40: temperature
    53: power_on
    54: power_off

  message_types:
    0x4131: location_a01      # A01
    0x4133: location_a03      # A03
    0x4235: photo_request     # D05
    0x4236: photo_data        # D06
    0x4231: command_result    # B01
    0x4233: command_result    # B03
    0x4231: command_result    # B11

  status_bits:
    0x00000700: rssi_mask     # Bits 3-8
    0xF0000000: satellite_mask # Bits 28+