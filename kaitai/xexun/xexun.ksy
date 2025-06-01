meta:
  id: xexun
  title: Xexun GPS Tracking Protocol
  license: MIT
  ks-version: 0.11
  endian: be

doc: |
  Xexun GPS tracking protocol supporting basic and full message formats.
  Based on NMEA GPRMC sentence with additional fields for device status,
  power information, and cellular network data.

seq:
  - id: messages
    type: message_wrapper
    repeat: eos

types:
  message_wrapper:
    seq:
      - id: message
        type:
          switch-on: is_full_format
          cases:
            true: full_message
            false: basic_message
    instances:
      is_full_format:
        value: |
          _io.read_bytes(6).to_s('ASCII').match('[0-9]{6}') != null
        io: _io

  basic_message:
    doc: Basic format without serial and phone number
    seq:
      - id: gprmc_prefix
        type: str
        size: 6
        encoding: ASCII
      - id: time
        type: str
        terminator: 0x2C  # ','
        encoding: ASCII
      - id: validity
        type: str
        terminator: 0x2C  # ','
        encoding: ASCII
      - id: latitude
        type: str
        terminator: 0x2C  # ','
        encoding: ASCII
      - id: lat_hemisphere
        type: str
        terminator: 0x2C  # ','
        encoding: ASCII
      - id: longitude
        type: str
        terminator: 0x2C  # ','
        encoding: ASCII
      - id: lon_hemisphere
        type: str
        terminator: 0x2C  # ','
        encoding: ASCII
      - id: speed
        type: str
        terminator: 0x2C  # ','
        encoding: ASCII
      - id: course
        type: str
        terminator: 0x2C  # ','
        encoding: ASCII
      - id: date
        type: str
        terminator: 0x2C  # ','
        encoding: ASCII
      - id: nmea_remainder
        type: str
        terminator: 0x2A  # '*'
        encoding: ASCII
      - id: checksum
        type: str
        size: 2
        encoding: ASCII
      - id: cr_lf
        size: 2
        if: _io.read_u1 == 0x0D
      - id: comma1
        contents: [',']
      - id: signal
        type: str
        terminator: 0x2C  # ','
        encoding: ASCII
      - id: alarm
        type: str
        terminator: 0x2C  # ','
        encoding: ASCII
        if: _io.read_u1 != 0x69  # not 'i' (imei)
      - id: additional_data
        type: str
        encoding: ASCII
        terminator: 0x2C
        consume: false
        if: alarm.length > 0
      - id: imei_prefix
        type: str
        size: 5
        encoding: ASCII
      - id: imei
        type: str
        terminator: 0x2C  # ','
        encoding: ASCII
      - id: remaining
        size-eos: true
    instances:
      is_valid:
        value: validity == "A"
      latitude_degrees:
        value: latitude.substring(0, latitude.length - 8).to_i
      latitude_minutes:
        value: latitude.substring(latitude.length - 8).to_f
      longitude_degrees:
        value: longitude.substring(0, longitude.length - 8).to_i
      longitude_minutes:
        value: longitude.substring(longitude.length - 8).to_f
      speed_knots:
        value: speed.to_f
      course_degrees:
        value: course.to_f

  full_message:
    doc: Full format with serial, phone number, and extended data
    seq:
      - id: serial
        type: str
        terminator: 0x2C  # ','
        encoding: ASCII
      - id: phone_number
        type: str
        terminator: 0x2C  # ','
        encoding: ASCII
      - id: gprmc_prefix
        type: str
        size: 6
        encoding: ASCII
      - id: time
        type: str
        terminator: 0x2C  # ','
        encoding: ASCII
      - id: validity
        type: str
        terminator: 0x2C  # ','
        encoding: ASCII
      - id: latitude
        type: str
        terminator: 0x2C  # ','
        encoding: ASCII
      - id: lat_hemisphere
        type: str
        terminator: 0x2C  # ','
        encoding: ASCII
      - id: longitude
        type: str
        terminator: 0x2C  # ','
        encoding: ASCII
      - id: lon_hemisphere
        type: str
        terminator: 0x2C  # ','
        encoding: ASCII
      - id: speed
        type: str
        terminator: 0x2C  # ','
        encoding: ASCII
      - id: course
        type: str
        terminator: 0x2C  # ','
        encoding: ASCII
      - id: date
        type: str
        terminator: 0x2C  # ','
        encoding: ASCII
      - id: nmea_remainder
        type: str
        terminator: 0x2A  # '*'
        encoding: ASCII
      - id: checksum
        type: str
        size: 2
        encoding: ASCII
      - id: comma1
        contents: [',']
      - id: signal
        type: str
        terminator: 0x2C  # ','
        encoding: ASCII
      - id: alarm
        type: str
        terminator: 0x2C  # ','
        encoding: ASCII
        if: _io.pos < _io.size - 20
      - id: space_imei
        type: str
        encoding: ASCII
        terminator: 0x2C
        consume: false
        if: alarm.length > 0 and alarm.substring(alarm.length - 5) == " imei"
      - id: imei_prefix
        type: str
        size: 5
        encoding: ASCII
      - id: imei
        type: str
        terminator: 0x2C  # ','
        encoding: ASCII
      - id: satellites
        type: str
        terminator: 0x2C  # ','
        encoding: ASCII
      - id: altitude
        type: str
        terminator: 0x2C  # ','
        encoding: ASCII
      - id: power_prefix
        type: str
        size: 2
        encoding: ASCII
      - id: power_voltage
        type: str
        terminator: 0x56  # 'V'
        encoding: ASCII
      - id: voltage_sep
        contents: ['V']
      - id: comma2
        contents: [',']
      - id: charging
        type: str
        terminator: 0x2C  # ','
        encoding: ASCII
      - id: gsm_signal
        type: str
        terminator: 0x2C  # ','
        encoding: ASCII
      - id: mileage
        type: str
        terminator: 0x2C  # ','
        encoding: ASCII
        if: _io.pos < _io.size - 10
      - id: mcc
        type: str
        terminator: 0x2C  # ','
        encoding: ASCII
      - id: mnc
        type: str
        terminator: 0x2C  # ','
        encoding: ASCII
      - id: lac
        type: str
        terminator: 0x2C  # ','
        encoding: ASCII
      - id: cell_id
        type: str
        encoding: ASCII
        size-eos: true
        if: _io.pos < _io.size
    instances:
      is_valid:
        value: validity == "A"
      latitude_value:
        value: |
          (latitude.substring(0, latitude.length - 8).to_i + 
           latitude.substring(latitude.length - 8).to_f / 60.0) *
          (lat_hemisphere == "S" ? -1 : 1)
      longitude_value:
        value: |
          (longitude.substring(0, longitude.length - 8).to_i + 
           longitude.substring(longitude.length - 8).to_f / 60.0) *
          (lon_hemisphere == "W" ? -1 : 1)
      speed_knots:
        value: speed.to_f
      course_degrees:
        value: course.to_f
      satellites_count:
        value: satellites.to_i
      altitude_meters:
        value: altitude.to_f
      power_type:
        value: power_prefix
      voltage_value:
        value: power_voltage.to_f
      is_low_battery:
        value: power_prefix == "L:"
      is_charging_on:
        value: charging == "1"
      gsm_signal_strength:
        value: gsm_signal.to_i
      mileage_value:
        value: mileage.to_f if mileage.length > 0

enums:
  signal_types:
    70: full_signal     # 'F'
    76: low_signal      # 'L'

  alarm_types:
    'acc on': ignition_on
    'accstart': ignition_on
    'acc off': ignition_off
    'accstop': ignition_off
    'help me!': sos
    'help me': sos
    'low battery': low_battery
    'move!': movement
    'moved!': movement