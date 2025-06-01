meta:
  id: totem
  title: Totem GPS Tracking Protocol
  license: MIT
  ks-version: 0.11
  endian: be

doc: |
  Totem GPS tracking protocol supporting multiple message formats.
  Used by various GPS tracking devices with features including OBD-II
  data, RFID support, and comprehensive alarm types.

seq:
  - id: messages
    type: message_wrapper
    repeat: eos

types:
  message_wrapper:
    seq:
      - id: header
        contents: ['$$']
      - id: message_body
        type:
          switch-on: message_type
          cases:
            _: totem_message
    instances:
      message_type:
        value: |
          _io.read_bytes(2).to_s('ASCII') == '01' ? 1 :
          _io.read_bytes(2).to_s('ASCII') == '02' ? 2 :
          _io.read_bytes(2).to_s('ASCII') == '03' ? 3 :
          _io.read_bytes(2).to_s('ASCII') == '04' ? 4 : 0
        io: _io
        ofs: 2

  totem_message:
    seq:
      - id: length_or_marker
        type: str
        size: 2
        encoding: ASCII
      - id: content
        type:
          switch-on: format_type
          cases:
            'pattern1': pattern1_message
            'pattern2': pattern2_message
            'pattern3': pattern3_message
            'pattern4': pattern4_message
            _: unknown_message
        size-eos: true
    instances:
      format_type:
        value: |
          content.to_s('ASCII').contains('$GPRMC') ? 'pattern1' :
          content.to_s('ASCII').substring(0, 2) == '00' ? 'pattern4' :
          content.to_s('ASCII').split('|').size == 3 and content.to_s('ASCII').split('|')[1].contains('|') ? 'pattern2' :
          'pattern3'

  pattern1_message:
    doc: Pattern 1 - Contains $GPRMC
    seq:
      - id: imei
        type: str
        terminator: 0x7C  # '|'
        encoding: ASCII
      - id: alarm_type
        type: str
        size: 2
        encoding: ASCII
      - id: gprmc_data
        type: str
        terminator: 0x7C  # '|'
        encoding: ASCII
      - id: pdop
        type: str
        terminator: 0x7C  # '|'
        encoding: ASCII
      - id: hdop
        type: str
        terminator: 0x7C  # '|'
        encoding: ASCII
      - id: vdop
        type: str
        terminator: 0x7C  # '|'
        encoding: ASCII
      - id: io_status
        type: str
        terminator: 0x7C  # '|'
        encoding: ASCII
      - id: battery_time
        type: str
        terminator: 0x7C  # '|'
        encoding: ASCII
      - id: charged
        type: str
        size: 1
        encoding: ASCII
      - id: battery_level
        type: str
        size: 3
        encoding: ASCII
      - id: power
        type: str
        terminator: 0x7C  # '|'
        encoding: ASCII
      - id: adc
        type: str
        terminator: 0x7C  # '|'
        encoding: ASCII
        if: _io.pos < _io.size - 10
      - id: lac
        type: str
        size: 4
        encoding: ASCII
        if: _io.pos < _io.size - 10
      - id: cid
        type: str
        terminator: 0x7C  # '|'
        encoding: ASCII
        if: _io.pos < _io.size - 10
      - id: temperature
        type: str
        terminator: 0x7C  # '|'
        encoding: ASCII
        if: _io.pos < _io.size - 10
      - id: odometer
        type: str
        terminator: 0x7C  # '|'
        encoding: ASCII
        if: _io.pos < _io.size - 10
      - id: serial_number
        type: str
        terminator: 0x7C  # '|'
        encoding: ASCII
        if: _io.pos < _io.size - 10
      - id: checksum
        type: str
        size: 4
        encoding: ASCII

  pattern2_message:
    doc: Pattern 2 - Alternative format
    seq:
      - id: imei
        type: str
        terminator: 0x7C  # '|'
        encoding: ASCII
      - id: alarm_type
        type: str
        size: 2
        encoding: ASCII
      - id: date
        type: str
        size: 6
        encoding: ASCII
      - id: time
        type: str
        terminator: 0x7C  # '|'
        encoding: ASCII
      - id: validity
        type: str
        terminator: 0x7C  # '|'
        encoding: ASCII
      - id: latitude
        type: str
        terminator: 0x7C  # '|'
        encoding: ASCII
      - id: lat_hemisphere
        type: str
        terminator: 0x7C  # '|'
        encoding: ASCII
      - id: longitude
        type: str
        terminator: 0x7C  # '|'
        encoding: ASCII
      - id: lon_hemisphere
        type: str
        terminator: 0x7C  # '|'
        encoding: ASCII
      - id: speed
        type: str
        terminator: 0x7C  # '|'
        encoding: ASCII
      - id: course
        type: str
        terminator: 0x7C  # '|'
        encoding: ASCII
      - id: hdop
        type: str
        terminator: 0x7C  # '|'
        encoding: ASCII
      - id: io_status
        type: str
        terminator: 0x7C  # '|'
        encoding: ASCII
      - id: charged
        type: str
        size: 1
        encoding: ASCII
      - id: battery_level
        type: str
        size: 2
        encoding: ASCII
      - id: external_power
        type: str
        terminator: 0x7C  # '|'
        encoding: ASCII
      - id: adc
        type: str
        terminator: 0x7C  # '|'
        encoding: ASCII
      - id: lac
        type: str
        size: 4
        encoding: ASCII
      - id: cid
        type: str
        terminator: 0x7C  # '|'
        encoding: ASCII
      - id: temperature
        type: str
        terminator: 0x7C  # '|'
        encoding: ASCII
      - id: odometer
        type: str
        terminator: 0x7C  # '|'
        encoding: ASCII
      - id: serial_number
        type: str
        terminator: 0x7C  # '|'
        encoding: ASCII
      - id: checksum
        type: str
        size: 4
        encoding: ASCII

  pattern3_message:
    doc: Pattern 3 - Compact format
    seq:
      - id: imei
        type: str
        terminator: 0x7C  # '|'
        encoding: ASCII
      - id: alarm_type
        type: str
        size: 2
        encoding: ASCII
      - id: date
        type: str
        size: 6
        encoding: ASCII
      - id: time
        type: str
        size: 6
        encoding: ASCII
      - id: io_status
        type: str
        size: 4
        encoding: ASCII
      - id: charging
        type: str
        size: 1
        encoding: ASCII
      - id: battery_level
        type: str
        size: 2
        encoding: ASCII
      - id: external_power
        type: str
        size: 2
        encoding: ASCII
      - id: adc1
        type: str
        size: 4
        encoding: ASCII
      - id: adc2
        type: str
        size: 4
        encoding: ASCII
      - id: temp1
        type: str
        size: 3
        encoding: ASCII
      - id: temp2
        type: str
        size: 3
        encoding: ASCII
      - id: lac
        type: str
        size: 4
        encoding: ASCII
      - id: cid
        type: str
        size: 4
        encoding: ASCII
      - id: validity
        type: str
        size: 1
        encoding: ASCII
      - id: satellites
        type: str
        size: 2
        encoding: ASCII
      - id: course
        type: str
        size: 3
        encoding: ASCII
      - id: speed
        type: str
        size: 3
        encoding: ASCII
      - id: pdop
        type: str
        size: 4
        encoding: ASCII
      - id: odometer
        type: str
        size: 7
        encoding: ASCII
      - id: latitude
        type: str
        size: 10
        encoding: ASCII
      - id: lat_hemisphere
        type: str
        size: 1
        encoding: ASCII
      - id: longitude
        type: str
        size: 11
        encoding: ASCII
      - id: lon_hemisphere
        type: str
        size: 1
        encoding: ASCII
      - id: serial_number
        type: str
        size: 4
        encoding: ASCII
      - id: checksum
        type: str
        size: 4
        encoding: ASCII

  pattern4_message:
    doc: Pattern 4 - Binary format with various subtypes
    seq:
      - id: message_length
        type: str
        size: 2
        encoding: ASCII
      - id: type_code
        type: str
        size: 2
        encoding: ASCII
      - id: content
        type:
          switch-on: type_code
          cases:
            '"E2"': e2_message
            '"E5"': e5_message
            _: standard_p4_message
        size-eos: true

  standard_p4_message:
    seq:
      - id: imei
        type: str
        terminator: 0x7C  # '|'
        encoding: ASCII
      - id: status
        type: str
        size: 8
        encoding: ASCII
      - id: date
        type: str
        size: 6
        encoding: ASCII
      - id: time
        type: str
        size: 6
        encoding: ASCII
      - id: battery_data
        type: battery_info
      - id: adc1
        type: str
        size: 4
        encoding: ASCII
      - id: adc2
        type: str
        size: 4
        encoding: ASCII
        if: _io.pos < _io.size - 30
      - id: adc3
        type: str
        size: 4
        encoding: ASCII
        if: _io.pos < _io.size - 30
      - id: adc4
        type: str
        size: 4
        encoding: ASCII
        if: _io.pos < _io.size - 30
      - id: temp1
        type: str
        size: 4
        encoding: ASCII
      - id: temp2
        type: str
        size: 4
        encoding: ASCII
        if: _io.pos < _io.size - 20
      - id: lac
        type: str
        size: 4
        encoding: ASCII
      - id: cid
        type: str
        size: 4
        encoding: ASCII
      - id: mcc
        type: str
        size: 2
        encoding: ASCII
        if: _io.pos < _io.size - 15
      - id: mnc
        type: str
        size: 3
        encoding: ASCII
        if: _io.pos < _io.size - 15
      - id: satellites
        type: str
        size: 2
        encoding: ASCII
      - id: gsm_signal
        type: str
        size: 2
        encoding: ASCII
      - id: course
        type: str
        size: 3
        encoding: ASCII
      - id: speed
        type: str
        size: 3
        encoding: ASCII
      - id: hdop
        type: str
        size: 4
        encoding: ASCII
      - id: odometer
        type: str
        size: 7
        encoding: ASCII
      - id: latitude
        type: str
        size: 10
        encoding: ASCII
      - id: lat_hemisphere
        type: str
        size: 1
        encoding: ASCII
      - id: longitude
        type: str
        size: 11
        encoding: ASCII
      - id: lon_hemisphere
        type: str
        size: 1
        encoding: ASCII
      - id: optional_temp
        type: str
        size: 4
        encoding: ASCII
        if: _io.pos < _io.size - 6
      - id: serial_number
        type: str
        size: 4
        encoding: ASCII
      - id: checksum
        type: str
        size: 2
        encoding: ASCII

  battery_info:
    seq:
      - id: data
        type: str
        encoding: ASCII
        size:
          switch-on: data.substring(0, 1) != '0'
          cases:
            true: 2
            false: 3

  e2_message:
    doc: E2 - RFID message
    seq:
      - id: imei
        type: str
        terminator: 0x7C  # '|'
        encoding: ASCII
      - id: date
        type: str
        size: 6
        encoding: ASCII
      - id: time
        type: str
        terminator: 0x2C  # ','
        encoding: ASCII
      - id: longitude
        type: str
        terminator: 0x2C  # ','
        encoding: ASCII
      - id: latitude
        type: str
        terminator: 0x2C  # ','
        encoding: ASCII
      - id: rfid
        type: str
        terminator: 0x7C  # '|'
        encoding: ASCII
      - id: checksum
        type: str
        size: 2
        encoding: ASCII

  e5_message:
    doc: E5 - OBD-II data message
    seq:
      - id: imei
        type: str
        terminator: 0x7C  # '|'
        encoding: ASCII
      - id: date
        type: str
        size: 6
        encoding: ASCII
      - id: time
        type: str
        terminator: 0x2C  # ','
        encoding: ASCII
      - id: longitude
        type: str
        terminator: 0x2C  # ','
        encoding: ASCII
      - id: latitude
        type: str
        terminator: 0x2C  # ','
        encoding: ASCII
      - id: obd_version
        type: str
        terminator: 0x2C  # ','
        encoding: ASCII
      - id: odometer
        type: str
        terminator: 0x2C  # ','
        encoding: ASCII
      - id: fuel_used
        type: str
        terminator: 0x2C  # ','
        encoding: ASCII
      - id: fuel_consumption
        type: str
        terminator: 0x2C  # ','
        encoding: ASCII
      - id: power
        type: str
        terminator: 0x2C  # ','
        encoding: ASCII
      - id: rpm
        type: str
        terminator: 0x2C  # ','
        encoding: ASCII
      - id: speed
        type: str
        terminator: 0x2C  # ','
        encoding: ASCII
      - id: intake_flow
        type: str
        terminator: 0x2C  # ','
        encoding: ASCII
      - id: intake_pressure
        type: str
        terminator: 0x2C  # ','
        encoding: ASCII
      - id: coolant_temp
        type: str
        terminator: 0x2C  # ','
        encoding: ASCII
      - id: intake_temp
        type: str
        terminator: 0x2C  # ','
        encoding: ASCII
      - id: engine_load
        type: str
        terminator: 0x2C  # ','
        encoding: ASCII
      - id: throttle
        type: str
        terminator: 0x2C  # ','
        encoding: ASCII
      - id: fuel_level
        type: str
        terminator: 0x2C  # ','
        encoding: ASCII
      - id: checksum_sep
        type: str
        size: 1
        encoding: ASCII
      - id: checksum
        type: str
        size: 2
        encoding: ASCII

  unknown_message:
    seq:
      - id: data
        size-eos: true

enums:
  alarm_type_123:
    0x01: sos
    0x10: low_battery
    0x11: overspeed
    0x30: parking
    0x42: geofence_exit
    0x43: geofence_enter

  alarm_type_4:
    0x01: sos
    0x02: overspeed
    0x04: geofence_exit
    0x05: geofence_enter
    0x06: tow
    0x07: gps_antenna_cut
    0x10: power_cut
    0x11: power_restored
    0x12: low_power
    0x13: low_battery
    0x40: vibration
    0x41: idle
    0x42: acceleration
    0x43: braking

  message_types:
    0xE2: rfid_data
    0xE5: obd_data