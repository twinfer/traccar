meta:
  id: tk103
  title: TK103 GPS Tracking Protocol
  license: MIT
  ks-version: 0.11
  endian: be

doc: |
  TK103 GPS tracking protocol supporting multiple message types including
  standard position reports, battery status, cell tower information,
  LBS+WiFi positioning, and vehicle diagnostics data.

seq:
  - id: messages
    type: message_wrapper
    repeat: eos

types:
  message_wrapper:
    seq:
      - id: opening_paren
        contents: ['(']
        if: _io.read_u1 == 0x28
      - id: message
        type: tk103_message
      - id: closing_paren
        contents: [')']
        if: opening_paren._sizeof > 0

  tk103_message:
    seq:
      - id: device_id
        type: str
        terminator: 0x2C  # ','
        encoding: ASCII
        if: message_type != msg_cell
      - id: device_id_fixed
        type: str
        size: 12
        encoding: ASCII
        if: message_type == msg_cell
      - id: command
        type: str
        size: 4
        encoding: ASCII
      - id: content
        type:
          switch-on: message_type
          cases:
            msg_standard: standard_message
            msg_battery: battery_message
            msg_cell: cell_message
            msg_network: network_message
            msg_lbs_wifi: lbs_wifi_message
            msg_command_result: command_result_message
            msg_vin: vin_message
            msg_bms: bms_message
            _: raw_message
        size-eos: true
    instances:
      message_type:
        value: |
          command == "BR00" or command == "BP00" or command == "BP02" or command == "BP05" ? msg_standard :
          command == "ZC20" ? msg_battery :
          command == "BP05" and content.to_s('ASCII').contains('{') ? msg_cell :
          command == "BZ00" ? msg_network :
          command.substring(0, 2) == "DW" or command.substring(0, 2) == "ZC" ? msg_lbs_wifi :
          command == "BQ81" ? msg_standard :
          command == "BV00" ? msg_vin :
          command.substring(0, 2) == "BS" ? msg_bms :
          msg_command_result
        enum: message_types

  standard_message:
    seq:
      - id: alarm_indicator
        type: str
        encoding: ASCII
        terminator: 0x2C
        consume: false
        if: _io.read_bytes(6).to_s('ASCII') == ",ALARM"
      - id: alarm_prefix
        type: str
        size: 7
        encoding: ASCII
        if: alarm_indicator.length > 0
      - id: alarm_type
        type: str
        terminator: 0x2C  # ','
        encoding: ASCII
        if: alarm_indicator.length > 0
      - id: alarm_data
        type: str
        terminator: 0x2C  # ','
        encoding: ASCII
        if: alarm_indicator.length > 0
      - id: date
        type: str
        size: 6
        encoding: ASCII
      - id: validity
        type: str
        terminator: 0x2C  # ','
        encoding: ASCII
        if: _io.pos < _io.size and _io.read_u1 != 0x41 and _io.read_u1 != 0x56
      - id: validity_single
        type: str
        size: 1
        encoding: ASCII
        if: validity.length == 0
      - id: latitude
        type: str
        encoding: ASCII
        terminator: 0x4E  # 'N'
        if: lat_hemisphere == "N"
      - id: latitude_s
        type: str
        encoding: ASCII
        terminator: 0x53  # 'S'
        if: lat_hemisphere == "S"
      - id: lat_hemisphere
        type: str
        size: 1
        encoding: ASCII
      - id: separator1
        size: 1
        if: _io.read_u1 == 0x2C or _io.read_u1 == 0x20
      - id: longitude
        type: str
        encoding: ASCII
        terminator: 0x45  # 'E'
        if: lon_hemisphere == "E"
      - id: longitude_w
        type: str
        encoding: ASCII
        terminator: 0x57  # 'W'
        if: lon_hemisphere == "W"
      - id: lon_hemisphere
        type: str
        size: 1
        encoding: ASCII
      - id: separator2
        size: 1
        if: _io.read_u1 == 0x2C or _io.read_u1 == 0x20
      - id: speed
        type: str
        encoding: ASCII
        size: 5
      - id: time
        type: str
        size: 6
        encoding: ASCII
      - id: extended_data
        type: extended_fields
        if: _io.pos < _io.size
    instances:
      is_valid:
        value: (validity.length > 0 and validity == "A") or validity_single == "A"
      latitude_value:
        value: latitude if lat_hemisphere == "N"
      longitude_value:
        value: longitude if lon_hemisphere == "E"

  extended_fields:
    seq:
      - id: course_or_ext
        type: str
        encoding: ASCII
        size: 6
        if: _io.size - _io.pos >= 6
      - id: charge
        type: str
        size: 1
        encoding: ASCII
        if: course_or_ext.length == 6 and course_or_ext.substring(5, 6) == ","
      - id: ignition
        type: str
        size: 1
        encoding: ASCII
        if: charge.length > 0
      - id: io1
        type: str
        size: 1
        encoding: ASCII
        if: ignition.length > 0
      - id: io2
        type: str
        size: 1
        encoding: ASCII
        if: io1.length > 0
      - id: io3
        type: str
        size: 1
        encoding: ASCII
        if: io2.length > 0
      - id: fuel
        type: str
        size: 3
        encoding: ASCII
        if: io3.length > 0
      - id: odometer_prefix
        contents: ['L']
        if: fuel.length > 0
      - id: odometer
        type: str
        encoding: ASCII
        terminator: 0x2C
        consume: false
        if: odometer_prefix._sizeof > 0
      - id: remaining
        size-eos: true
        if: _io.pos < _io.size

  battery_message:
    seq:
      - id: date
        type: str
        size: 6
        encoding: ASCII
      - id: comma1
        contents: [',']
      - id: time
        type: str
        size: 6
        encoding: ASCII
      - id: comma2
        contents: [',']
      - id: battery_level
        type: str
        terminator: 0x2C  # ','
        encoding: ASCII
      - id: battery_voltage
        type: str
        terminator: 0x2C  # ','
        encoding: ASCII
      - id: power_voltage
        type: str
        terminator: 0x2C  # ','
        encoding: ASCII
      - id: installed
        type: str
        encoding: ASCII
        size-eos: true

  cell_message:
    seq:
      - id: imei
        type: str
        terminator: 0x2C  # ','
        encoding: ASCII
        if: _io.pos < _io.size - 10
      - id: cell_data
        type: str
        terminator: 0x2C  # ','
        encoding: ASCII
      - id: odometer
        type: str
        size: 8
        encoding: ASCII

  network_message:
    seq:
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
      - id: cid
        type: str
        terminator: 0x2C  # ','
        encoding: ASCII
      - id: remaining
        size-eos: true

  lbs_wifi_message:
    seq:
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
      - id: cid
        type: str
        terminator: 0x2C  # ','
        encoding: ASCII
      - id: wifi_count
        type: str
        terminator: 0x2C  # ','
        encoding: ASCII
      - id: wifi_data
        type: str
        terminator: 0x2C  # ','
        encoding: ASCII
        if: wifi_count.to_i > 0
      - id: date
        type: str
        size: 6
        encoding: ASCII
      - id: comma
        contents: [',']
      - id: time
        type: str
        size: 6
        encoding: ASCII
      - id: remaining
        size-eos: true

  command_result_message:
    seq:
      - id: date
        type: str
        size: 6
        encoding: ASCII
      - id: comma1
        contents: [',']
      - id: time
        type: str
        size: 6
        encoding: ASCII
      - id: comma2
        contents: [',']
      - id: dollar1
        contents: ['$']
      - id: result
        type: str
        encoding: ASCII
        terminator: 0x24  # '$'
        if: _io.read_u1 != 0x24 at _io.pos + result.length
      - id: result_to_end
        type: str
        encoding: ASCII
        size-eos: true
        if: result.length == 0

  vin_message:
    seq:
      - id: vin
        type: str
        size: 17
        encoding: ASCII

  bms_message:
    seq:
      - id: data
        size-eos: true

  raw_message:
    seq:
      - id: data
        size-eos: true

enums:
  message_types:
    1: msg_standard
    2: msg_battery
    3: msg_cell
    4: msg_network
    5: msg_lbs_wifi
    6: msg_command_result
    7: msg_vin
    8: msg_bms

  command_types:
    'BR00': position_report
    'BP00': position_report_old
    'BP02': position_report_compact
    'BP05': position_report_alt
    'BQ81': alarm_report
    'ZC20': battery_status
    'BZ00': network_info
    'DW30': lbs_wifi_cold
    'DW31': lbs_wifi_move_alarm
    'DW32': lbs_wifi_low_battery
    'DW33': lbs_wifi_power_cut
    'DW35': lbs_wifi_ignition_on
    'DW36': lbs_wifi_ignition_off
    'DW37': lbs_wifi_removing
    'DW3E': lbs_wifi_sos
    'DW3F': lbs_wifi_tampering
    'DW40': lbs_wifi_low_power
    'DW42': lbs_wifi_ignition_on_alt
    'DW50': lbs_wifi_basic
    'DW51': lbs_wifi_move_alarm_alt
    'DW52': lbs_wifi_low_battery_alt
    'DW53': lbs_wifi_power_cut_alt
    'DW55': lbs_wifi_ignition_on_alt2
    'DW56': lbs_wifi_ignition_off_alt
    'DW57': lbs_wifi_removing_alt
    'DW5B': lbs_wifi_report
    'DW5E': lbs_wifi_sos_alt
    'DW5F': lbs_wifi_tampering_alt
    'DW60': lbs_wifi_low_power_alt
    'DW62': lbs_wifi_ignition_on_alt3
    'ZC11': status_move_alarm
    'ZC12': status_low_battery
    'ZC13': status_power_cut
    'ZC15': status_ignition_on
    'ZC16': status_ignition_off
    'ZC17': status_removing
    'ZC25': status_sos
    'ZC26': status_tampering
    'ZC27': status_low_power
    'ZC29': status_ignition_on_alt
    'BV00': vin_report
    'BS50': bms_data
    'BS51': bms_data_alt

  alarm_types:
    1: accident
    2: sos
    3: vibration
    4: low_speed
    5: overspeed
    6: geofence_exit