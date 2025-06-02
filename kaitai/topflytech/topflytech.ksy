meta:
  id: topflytech
  title: Topflytech GPS Tracker Protocol
  license: MIT
  ks-version: 0.11
  endian: be

doc: |
  Topflytech GPS tracker protocol supporting text-based positioning messages.
  Features vehicle tracking, asset monitoring, and solar-powered devices
  with BLE sensor integration and comprehensive fleet management capabilities.

seq:
  - id: message
    type: topflytech_message

types:
  topflytech_message:
    seq:
      - id: start_marker
        size: 1
        type: str
        encoding: ASCII
        doc: Opening parenthesis '('
      - id: imei
        type: str
        encoding: ASCII
        doc: Device IMEI identifier
        terminator: 0x42  # 'B' character
      - id: message_type
        size: 1
        type: str
        encoding: ASCII
        doc: Message type indicator
      - id: protocol_version
        size: 2
        type: str
        encoding: ASCII
        doc: Protocol version (00, XG, etc.)
      - id: device_type
        size: 1
        type: str
        encoding: ASCII
        doc: Device type identifier
      - id: data_section
        type: str
        encoding: ASCII
        doc: Message data content
        terminator: 0x29  # ')' character
    instances:
      device_id:
        value: imei
      is_valid_start:
        value: start_marker == "("
      parsed_data:
        value: parse_data_section(data_section)

  position_data:
    doc: GPS position information extracted from data section
    params:
      - id: data_string
        type: str
    seq:
      - id: date_part
        type: str
        encoding: ASCII
        doc: Date in YYMMDD format
      - id: time_part
        type: str
        encoding: ASCII
        doc: Time in HHMMSS format
      - id: validity
        size: 1
        type: str
        encoding: ASCII
        doc: GPS validity (A=valid, V=invalid)
      - id: latitude_degrees
        type: str
        encoding: ASCII
        doc: Latitude degrees (DD)
      - id: latitude_minutes
        type: str
        encoding: ASCII
        doc: Latitude minutes (MM.MMMM)
      - id: latitude_hemisphere
        size: 1
        type: str
        encoding: ASCII
        doc: Latitude hemisphere (N/S)
      - id: longitude_degrees
        type: str
        encoding: ASCII
        doc: Longitude degrees (DDD)
      - id: longitude_minutes
        type: str
        encoding: ASCII
        doc: Longitude minutes (MM.MMMM)
      - id: longitude_hemisphere
        size: 1
        type: str
        encoding: ASCII
        doc: Longitude hemisphere (E/W)
      - id: speed_knots
        type: str
        encoding: ASCII
        doc: Speed in knots (DDD.D format)
      - id: course_degrees
        type: str
        encoding: ASCII
        doc: Course in degrees (D+.D+ format)
    instances:
      is_valid_position:
        value: validity == "A"
      latitude_decimal:
        value: >-
          (latitude_degrees.to_i + latitude_minutes.to_f / 60.0) *
          (latitude_hemisphere == "N" ? 1 : -1)
      longitude_decimal:
        value: >-
          (longitude_degrees.to_i + longitude_minutes.to_f / 60.0) *
          (longitude_hemisphere == "E" ? 1 : -1)
      speed_kmh:
        value: speed_knots.to_f * 1.852
      heading:
        value: course_degrees.to_f
      timestamp:
        value: >-
          "20" + date_part.substring(0, 2) + "-" +
          date_part.substring(2, 4) + "-" +
          date_part.substring(4, 6) + " " +
          time_part.substring(0, 2) + ":" +
          time_part.substring(2, 4) + ":" +
          time_part.substring(4, 6)

  device_status:
    doc: Device status and diagnostic information
    seq:
      - id: battery_level
        type: u1
        doc: Battery level percentage
      - id: signal_strength
        type: u1
        doc: Cellular signal strength
      - id: satellite_count
        type: u1
        doc: Number of GPS satellites
      - id: device_temperature
        type: s1
        doc: Internal device temperature
      - id: external_power
        type: u1
        doc: External power voltage level
      - id: solar_voltage
        type: u2
        if: has_solar_panel
        doc: Solar panel voltage (mV)
    instances:
      has_solar_panel:
        value: false  # Determined by device model
      battery_percentage:
        value: battery_level
      signal_bars:
        value: (signal_strength * 4) / 255
      gps_satellites:
        value: satellite_count

  sensor_data:
    doc: BLE sensor data for temperature, humidity, and other monitoring
    seq:
      - id: sensor_count
        type: u1
        doc: Number of connected BLE sensors
      - id: sensors
        type: ble_sensor
        repeat: expr
        repeat-expr: sensor_count

  ble_sensor:
    seq:
      - id: sensor_id
        size: 6
        doc: BLE sensor MAC address
      - id: sensor_type
        type: u1
        enum: sensor_types
      - id: temperature_raw
        type: s2
        if: sensor_type == sensor_types::temperature_humidity
        doc: Temperature in 0.1°C units
      - id: humidity_raw
        type: u2
        if: sensor_type == sensor_types::temperature_humidity
        doc: Humidity in 0.1% units
      - id: door_status
        type: u1
        if: sensor_type == sensor_types::door_sensor
        doc: Door open/closed status
      - id: fuel_level
        type: u2
        if: sensor_type == sensor_types::fuel_sensor
        doc: Fuel level percentage
    instances:
      temperature_celsius:
        value: temperature_raw * 0.1
        if: sensor_type == sensor_types::temperature_humidity
      humidity_percent:
        value: humidity_raw * 0.1
        if: sensor_type == sensor_types::temperature_humidity
      door_open:
        value: door_status > 0
        if: sensor_type == sensor_types::door_sensor

  vehicle_data:
    doc: Vehicle-specific data for hardwired and OBD-II trackers
    seq:
      - id: ignition_status
        type: u1
        doc: Ignition on/off status
      - id: engine_rpm
        type: u2
        doc: Engine RPM
      - id: vehicle_speed
        type: u1
        doc: Vehicle speed from OBD-II
      - id: fuel_level
        type: u1
        doc: Fuel level percentage
      - id: engine_load
        type: u1
        doc: Engine load percentage
      - id: coolant_temperature
        type: s1
        doc: Engine coolant temperature
      - id: vin_number
        size: 17
        type: str
        encoding: ASCII
        if: has_vin_data
        doc: Vehicle Identification Number
      - id: odometer
        type: u4
        if: has_odometer_data
        doc: Vehicle odometer reading
    instances:
      has_vin_data:
        value: false  # Set based on device capabilities
      has_odometer_data:
        value: false  # Set based on device capabilities
      ignition_on:
        value: ignition_status > 0
      engine_running:
        value: engine_rpm > 0

  io_data:
    doc: Digital input/output data for hardwired trackers
    seq:
      - id: digital_inputs
        type: u1
        doc: Digital input states (bit field)
      - id: digital_outputs
        type: u1
        doc: Digital output states (bit field)
      - id: analog_input_1
        type: u2
        doc: Analog input 1 voltage (mV)
      - id: analog_input_2
        type: u2
        doc: Analog input 2 voltage (mV)
      - id: relay_status
        type: u1
        doc: Relay output status
    instances:
      input_1_active:
        value: (digital_inputs & 0x01) != 0
      input_2_active:
        value: (digital_inputs & 0x02) != 0
      input_3_active:
        value: (digital_inputs & 0x04) != 0
      input_4_active:
        value: (digital_inputs & 0x08) != 0
      output_1_active:
        value: (digital_outputs & 0x01) != 0
      output_2_active:
        value: (digital_outputs & 0x02) != 0
      relay_activated:
        value: relay_status > 0

  wifi_data:
    doc: WiFi access point data for positioning assistance
    seq:
      - id: wifi_count
        type: u1
        doc: Number of detected WiFi access points
      - id: access_points
        type: wifi_access_point
        repeat: expr
        repeat-expr: wifi_count

  wifi_access_point:
    seq:
      - id: mac_address
        size: 6
        doc: WiFi MAC address
      - id: signal_strength
        type: s1
        doc: Signal strength in dBm
      - id: ssid_length
        type: u1
        doc: SSID name length
      - id: ssid
        size: ssid_length
        type: str
        encoding: UTF-8
        doc: WiFi network name

  alarm_data:
    doc: Alarm and event information
    seq:
      - id: alarm_type
        type: u1
        enum: alarm_types
      - id: alarm_status
        type: u1
        doc: Alarm active/inactive status
      - id: trigger_timestamp
        type: u4
        doc: Alarm trigger time (Unix timestamp)
      - id: alarm_data
        size-eos: true
        doc: Additional alarm-specific data
    instances:
      alarm_active:
        value: alarm_status > 0
      trigger_time:
        value: trigger_timestamp

enums:
  message_types:
    B: basic_position
    P: positioning_data
    S: status_report
    A: alarm_message
    C: command_response
    H: heartbeat
    L: location_request

  device_types:
    0: asset_tracker
    1: vehicle_tracker
    2: obd_tracker
    3: solar_tracker
    4: personal_tracker

  protocol_versions:
    00: basic_protocol
    XG: extended_protocol
    SF: solar_family
    BL: battery_life
    
  sensor_types:
    0x01: temperature_humidity
    0x02: door_sensor
    0x03: fuel_sensor
    0x04: pressure_sensor
    0x05: motion_sensor
    0x06: light_sensor

  alarm_types:
    0x01: power_on
    0x02: power_off
    0x03: sos_alarm
    0x04: low_battery
    0x05: geofence_enter
    0x06: geofence_exit
    0x07: overspeed
    0x08: movement_detected
    0x09: tamper_alert
    0x0A: temperature_alarm
    0x0B: door_open
    0x0C: fuel_theft
    0x0D: panic_button
    0x0E: maintenance_due
    0x0F: unauthorized_use

  device_models:
    # Asset Trackers (Battery-Powered)
    knightx_300: knight_x_300_4g_cat_m1
    knightx_100: knight_x_100_rechargeable
    warriorx_300: warrior_x_300_rugged
    warriorx_100: warrior_x_100_outdoor
    
    # Solar-Powered Trackers
    solarx_310: solar_x_310_4g_cat_m1
    solarx_110: solar_x_110_4g_cat_1
    solarx_120: solar_x_120_basic
    solarguardx_200: solar_guard_x_200_padlock
    solarguardx_100: solar_guard_x_100_4g_cat_m1
    
    # Vehicle Trackers (Hardwired)
    tlw2_6bl: tlw2_6bl_hardwired_advanced
    tlw2_2bl: tlw2_2bl_hardwired_basic
    tlw2_12b: tlw2_12b_popular_model
    
    # OBDII Trackers
    torchx_100: torch_x_100_fleet_tracker
    
    # Other Models
    tlp1_sf: tlp1_sf_popular
    tlp2_sfb: tlp2_sfb_4g_cat_m1

  battery_types:
    rechargeable_4800mah: rechargeable_4800
    rechargeable_9600mah: rechargeable_9600
    non_rechargeable_4000mah: non_rechargeable_4000
    non_rechargeable_8000mah: non_rechargeable_8000

  positioning_methods:
    gps: global_positioning_system
    wifi: wifi_positioning
    lbs: location_based_service
    hybrid: combined_positioning