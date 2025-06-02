meta:
  id: starlink
  title: StarLink GPS Tracker Protocol
  license: MIT
  ks-version: 0.11
  endian: be

doc: |
  StarLink GPS tracker protocol supporting text-based and protobuf messaging.
  Features configurable field formats, comprehensive vehicle diagnostics,
  and temperature sensor integration with Dallas sensors.

seq:
  - id: message
    type: starlink_message

types:
  starlink_message:
    seq:
      - id: protocol_head
        type: u1
        doc: Protocol header character
      - id: message_head
        size: 3
        type: str
        encoding: ASCII
        doc: Message header "SLU"
      - id: device_id
        type: str
        encoding: ASCII
        doc: Device identifier (6 hex chars or 15 digits)
        terminator: 0x2C
      - id: message_type
        type: str
        encoding: ASCII
        doc: Message type identifier
        terminator: 0x2C
      - id: message_index
        type: str
        encoding: ASCII
        doc: Message sequence index
        terminator: 0x2C
      - id: data_fields
        type: str
        encoding: ASCII
        doc: Comma-separated data fields
        terminator: 0x2A
      - id: checksum
        size: 2
        type: str
        encoding: ASCII
        doc: Two-character hex checksum
    instances:
      is_valid_header:
        value: message_head == "SLU"
      is_event_report:
        value: message_type.to_i == 6
      device_identifier:
        value: device_id
      parsed_data:
        value: data_fields.split(",")

  starlink_data_parser:
    doc: |
      Configurable data parser supporting various StarLink field formats.
      Field mapping is configurable via format strings like "#EDT#,#EID#,#PDT#..."
    params:
      - id: format_string
        type: str
        doc: Format specification string
      - id: data_values
        type: str
        doc: Comma-separated data values
    seq:
      - id: parsed_fields
        type: field_value
        repeat: expr
        repeat-expr: format_tags.size
    instances:
      format_tags:
        value: format_string.split(",")
      data_array:
        value: data_values.split(",")

  field_value:
    params:
      - id: field_tag
        type: str
      - id: raw_value
        type: str
    instances:
      tag_name:
        value: field_tag
      value_string:
        value: raw_value
      numeric_value:
        value: raw_value.to_i
        if: is_numeric_field
      float_value:
        value: raw_value.to_f
        if: is_float_field
      coordinate_value:
        value: parse_coordinate(raw_value)
        if: is_coordinate_field
      timestamp_value:
        value: parse_timestamp(raw_value)
        if: is_timestamp_field
      boolean_value:
        value: raw_value.to_i > 0
        if: is_boolean_field
      is_numeric_field:
        value: >-
          field_tag.contains("#EID#") or field_tag.contains("#HEAD#") or
          field_tag.contains("#SATU#") or field_tag.contains("#CSS#") or
          field_tag.contains("#IN") or field_tag.contains("#OUT")
      is_float_field:
        value: >-
          field_tag.contains("#SPD#") or field_tag.contains("#ALT#") or
          field_tag.contains("#VIN#") or field_tag.contains("#VBAT#") or
          field_tag.contains("#TVI#")
      is_coordinate_field:
        value: field_tag.contains("#LAT#") or field_tag.contains("#LONG#")
      is_timestamp_field:
        value: field_tag.contains("#EDT#") or field_tag.contains("#PDT#")
      is_boolean_field:
        value: field_tag.contains("#IGN#") or field_tag.contains("#ENG#")

  position_data:
    doc: Position and timestamp information extracted from StarLink data
    seq:
      - id: device_time
        type: str
        encoding: ASCII
        doc: Device timestamp (EDT field)
      - id: fix_time
        type: str
        encoding: ASCII
        doc: GPS fix timestamp (PDT field)
      - id: latitude_str
        type: str
        encoding: ASCII
        doc: Latitude string with sign prefix
      - id: longitude_str
        type: str
        encoding: ASCII
        doc: Longitude string with sign prefix
      - id: speed
        type: f8
        doc: Speed value
      - id: heading
        type: u2
        doc: Heading/course in degrees
    instances:
      latitude:
        value: parse_coordinate(latitude_str)
      longitude:
        value: parse_coordinate(longitude_str)
      is_valid_position:
        value: latitude != 0.0 and longitude != 0.0

  vehicle_diagnostics:
    doc: Vehicle diagnostic and sensor data
    seq:
      - id: event_id
        type: u2
        doc: Event trigger identifier
      - id: odometer
        type: f8
        doc: Odometer reading
      - id: input_states
        type: u1
        repeat: expr
        repeat-expr: 4
        doc: Digital input states (IN1-IN4)
      - id: output_states
        type: u1
        repeat: expr
        repeat-expr: 4
        doc: Digital output states (OUT1-OUT4)
      - id: power_voltage
        type: f8
        doc: Main power voltage (VIN)
      - id: battery_voltage
        type: f8
        doc: Backup battery voltage (VBAT)
      - id: ignition_state
        type: u1
        doc: Ignition status (IGN)
      - id: engine_state
        type: u1
        doc: Engine status (ENG)
    instances:
      ignition_on:
        value: ignition_state > 0
      engine_running:
        value: engine_state > 0
      any_input_active:
        value: input_states[0] > 0 or input_states[1] > 0 or input_states[2] > 0 or input_states[3] > 0

  cellular_info:
    doc: Cellular network information
    seq:
      - id: lac
        type: u2
        doc: Location Area Code
      - id: cid
        type: u2
        doc: Cell ID
      - id: signal_strength
        type: u1
        doc: Cellular signal strength (CSS)
    instances:
      has_cellular_info:
        value: lac > 0 and cid > 0

  temperature_sensor:
    doc: Dallas temperature sensor data (TD1/TD2 fields)
    seq:
      - id: sensor_number
        type: u1
        doc: Sensor identifier number
      - id: sensor_id
        type: str
        encoding: ASCII
        doc: Sensor hardware ID
      - id: temperature_raw
        type: s2
        doc: Temperature value (×10)
      - id: humidity_raw
        type: u2
        doc: Humidity value (×10)
      - id: voltage_raw
        type: u2
        doc: Sensor voltage (×1000)
      - id: state_flags
        type: u1
        doc: Sensor state flags
    instances:
      temperature_celsius:
        value: temperature_raw * 0.1
      humidity_percent:
        value: humidity_raw * 0.1
      voltage_volts:
        value: voltage_raw * 0.001
      sensor_active:
        value: (state_flags & 0x01) != 0

enums:
  message_types:
    6: event_report
    16: wake_up
    42: i_button_read
    95: authenticate

  event_codes:
    1: position_report
    4: sos_panic
    6: overspeed
    7: geofence_enter
    8: geofence_exit
    9: power_cut
    11: low_battery
    16: rfid_unknown
    19: power_restore
    20: rfid_driver_id
    24: ignition_on
    25: ignition_off
    26: tow_detection
    33: external_device
    34: startup
    36: sos_button
    42: jamming_detected

  field_tags:
    # Timestamp fields
    edt: device_timestamp
    pdt: position_timestamp
    
    # Position fields
    lat: latitude
    long: longitude
    spd: speed_knots
    spdk: speed_kph
    head: heading
    alt: altitude
    altd: altitude_detailed
    
    # Event fields
    eid: event_id
    edsc: event_description
    
    # Vehicle fields
    odo: odometer
    odod: odometer_detailed
    ign: ignition
    ignl: ignition_logical
    eng: engine
    
    # Power fields
    vin: input_voltage
    vbat: battery_voltage
    batc: battery_charge
    bath: battery_health
    
    # I/O fields
    in1: digital_input_1
    in2: digital_input_2
    in3: digital_input_3
    in4: digital_input_4
    out1: digital_output_1
    out2: digital_output_2
    out3: digital_output_3
    out4: digital_output_4
    outa: digital_output_a
    outb: digital_output_b
    outc: digital_output_c
    outd: digital_output_d
    
    # GPS fields
    sat: satellites_visible
    satn: satellites_visible_alt
    satu: satellites_used
    pdop: position_dilution
    
    # Cellular fields
    lac: location_area_code
    cid: cell_id
    css: cellular_signal_strength
    
    # Sensor fields
    tvi: internal_temperature
    cfl: fuel_level
    cfl2: fuel_level_2
    tv1: sensor_voltage_1
    tv2: sensor_voltage_2
    tv3: sensor_voltage_3
    tv4: sensor_voltage_4
    ts1: sensor_state_1
    ts2: sensor_state_2
    ts3: sensor_state_3
    ts4: sensor_state_4
    td1: temperature_data_1
    td2: temperature_data_2
    
    # Driver fields
    dal: driver_alert
    did: driver_id
    drv: driver_status
    
    # Vehicle diagnostic fields
    dur: engine_hours
    tdur: total_duration
    rpm: engine_rpm
    dest: destination
    iarm: immobilizer_armed
    strt: starter_voltage
    
    # External fields
    edv1: external_device_1
    edv2: external_device_2
    edv3: external_device_3
    edv4: external_device_4

  alarm_types:
    overspeed: speed_violation
    geofence_enter: zone_entry
    geofence_exit: zone_exit
    power_cut: power_failure
    low_battery: battery_low
    tow: tow_detection
    sos: emergency_button
    jamming: signal_jamming

  input_types:
    0: door_sensor
    1: panic_button
    2: ignition_sense
    3: auxiliary_input

  output_types:
    0: engine_immobilizer
    1: siren_horn
    2: lights_flash
    3: auxiliary_output