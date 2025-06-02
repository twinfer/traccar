meta:
  id: coban
  title: Coban GPS Tracker Protocol (GPS103/TK103 Compatible)
  license: MIT
  ks-version: 0.11
  endian: be

doc: |
  Coban GPS tracker protocol supporting popular budget tracking devices.
  Based on GPS103/TK103 text protocol with comma-separated fields.
  Widely used by budget tracker manufacturers and clone devices.

seq:
  - id: message
    type: coban_message

types:
  coban_message:
    seq:
      - id: imei
        type: str
        encoding: ASCII
        doc: Device IMEI identifier
        terminator: 0x2C  # Comma separator
      - id: command
        type: str
        encoding: ASCII
        doc: Command type (tracker, help_me, etc.)
        terminator: 0x2C  # Comma separator
      - id: message_content
        type: str
        encoding: ASCII
        doc: Message data fields
        terminator: 0x3B  # Semicolon terminator
    instances:
      device_id:
        value: imei
      command_type:
        value: command
      parsed_fields:
        value: message_content.split(",")
      is_position_report:
        value: >-
          command == "tracker" or command == "T1" or 
          command == "help_me" or command == "alarm"

  position_message:
    doc: GPS position data from Coban tracker
    params:
      - id: field_data
        type: str
    seq:
      - id: date_time
        type: str
        encoding: ASCII
        doc: Timestamp in various formats
      - id: validity
        type: str
        encoding: ASCII
        doc: GPS validity (F=valid, L=invalid)
      - id: latitude
        type: str
        encoding: ASCII
        doc: Latitude in DDMM.MMMM format
      - id: latitude_hemisphere
        type: str
        encoding: ASCII
        doc: N/S hemisphere indicator
      - id: longitude
        type: str
        encoding: ASCII
        doc: Longitude in DDDMM.MMMM format
      - id: longitude_hemisphere
        type: str
        encoding: ASCII
        doc: E/W hemisphere indicator
      - id: speed
        type: str
        encoding: ASCII
        doc: Speed in km/h
      - id: course
        type: str
        encoding: ASCII
        doc: Course in degrees
      - id: altitude
        type: str
        encoding: ASCII
        doc: Altitude in meters
      - id: battery
        type: str
        encoding: ASCII
        doc: Battery level
      - id: signal
        type: str
        encoding: ASCII
        doc: GSM signal strength
    instances:
      latitude_decimal:
        value: convert_coordinate(latitude, latitude_hemisphere)
      longitude_decimal:
        value: convert_coordinate(longitude, longitude_hemisphere)
      speed_kmh:
        value: speed.to_f
      heading:
        value: course.to_f
      is_valid_fix:
        value: validity == "F"
      battery_level:
        value: battery.to_i
      signal_strength:
        value: signal.to_i

  status_message:
    doc: Device status and diagnostic information
    seq:
      - id: device_status
        type: str
        encoding: ASCII
        doc: Device operational status
      - id: battery_voltage
        type: str
        encoding: ASCII
        doc: Battery voltage level
      - id: gsm_signal
        type: str
        encoding: ASCII
        doc: GSM signal quality
      - id: gps_satellites
        type: str
        encoding: ASCII
        doc: Number of GPS satellites
      - id: internal_temperature
        type: str
        encoding: ASCII
        if: has_temperature_data
        doc: Internal device temperature
    instances:
      has_temperature_data:
        value: false  # Set based on message length
      battery_volts:
        value: battery_voltage.to_f
      satellites:
        value: gps_satellites.to_i
      temperature:
        value: internal_temperature.to_f
        if: has_temperature_data

  alarm_message:
    doc: Alarm and emergency notifications
    seq:
      - id: alarm_type
        type: str
        encoding: ASCII
        doc: Type of alarm triggered
      - id: position_data
        type: position_message
        doc: Location when alarm occurred
      - id: additional_info
        type: str
        encoding: ASCII
        if: has_additional_info
        doc: Extra alarm-specific data
    instances:
      has_additional_info:
        value: false  # Determined by message parsing
      alarm_description:
        value: map_alarm_type(alarm_type)

  heartbeat_message:
    doc: Regular keep-alive message
    seq:
      - id: heartbeat_data
        type: str
        encoding: ASCII
        doc: Heartbeat payload
      - id: device_info
        type: str
        encoding: ASCII
        if: has_device_info
        doc: Device identification information
    instances:
      has_device_info:
        value: heartbeat_data.length > 10

  command_response:
    doc: Response to server commands
    seq:
      - id: response_type
        type: str
        encoding: ASCII
        doc: Type of command response
      - id: response_data
        type: str
        encoding: ASCII
        doc: Response payload data
      - id: execution_status
        type: str
        encoding: ASCII
        doc: Command execution result
    instances:
      command_successful:
        value: execution_status == "OK" or execution_status == "1"

  lbs_message:
    doc: Location-based service positioning data
    seq:
      - id: cell_data
        type: cellular_info
      - id: wifi_data
        type: wifi_info
        if: has_wifi_data
    instances:
      has_wifi_data:
        value: false  # Determined by message content

  cellular_info:
    seq:
      - id: mcc
        type: str
        encoding: ASCII
        doc: Mobile Country Code
      - id: mnc
        type: str
        encoding: ASCII
        doc: Mobile Network Code
      - id: lac
        type: str
        encoding: ASCII
        doc: Location Area Code
      - id: cell_id
        type: str
        encoding: ASCII
        doc: Cell tower identifier
      - id: signal_strength
        type: str
        encoding: ASCII
        doc: Cellular signal strength
    instances:
      mcc_value:
        value: mcc.to_i
      mnc_value:
        value: mnc.to_i
      lac_value:
        value: lac.to_i
      cell_id_value:
        value: cell_id.to_i

  wifi_info:
    seq:
      - id: wifi_count
        type: str
        encoding: ASCII
        doc: Number of WiFi access points
      - id: access_points
        type: wifi_access_point
        repeat: expr
        repeat-expr: wifi_count.to_i

  wifi_access_point:
    seq:
      - id: mac_address
        type: str
        encoding: ASCII
        doc: WiFi MAC address
      - id: signal_strength
        type: str
        encoding: ASCII
        doc: WiFi signal strength
      - id: ssid
        type: str
        encoding: ASCII
        if: has_ssid
        doc: Network name (optional)
    instances:
      has_ssid:
        value: false  # Usually not transmitted
      signal_dbm:
        value: signal_strength.to_i

  photo_message:
    doc: Photo transmission notification
    seq:
      - id: photo_id
        type: str
        encoding: ASCII
        doc: Photo identifier
      - id: photo_size
        type: str
        encoding: ASCII
        doc: Photo file size
      - id: position_data
        type: position_message
        doc: Location where photo was taken
    instances:
      photo_identifier:
        value: photo_id
      file_size_bytes:
        value: photo_size.to_i

  vehicle_data:
    doc: Vehicle-specific diagnostic information
    seq:
      - id: ignition_status
        type: str
        encoding: ASCII
        doc: Engine ignition state
      - id: fuel_level
        type: str
        encoding: ASCII
        doc: Fuel level percentage
      - id: odometer
        type: str
        encoding: ASCII
        doc: Vehicle odometer reading
      - id: engine_hours
        type: str
        encoding: ASCII
        if: has_engine_hours
        doc: Engine operation hours
    instances:
      has_engine_hours:
        value: false  # Not all devices support this
      ignition_on:
        value: ignition_status == "1" or ignition_status == "on"
      fuel_percentage:
        value: fuel_level.to_f
      odometer_km:
        value: odometer.to_f

enums:
  command_types:
    tracker: position_report
    help_me: emergency_sos
    alarm: alarm_notification
    T1: periodic_report
    login: device_login
    heartbeat: keep_alive
    help: emergency_call
    move: movement_alarm
    speed: overspeed_alarm
    stockade: geofence_alarm
    door: door_alarm
    acc: ignition_alarm
    ac_alarm: power_alarm
    low_battery: battery_alarm
    sos: panic_button

  validity_indicators:
    F: gps_valid_fix
    L: gps_invalid_fix
    A: gps_valid_nmea
    V: gps_invalid_nmea

  alarm_types:
    help_me: sos_emergency
    move: movement_detected
    speed: overspeed_violation
    stockade: geofence_violation
    door: door_open_close
    acc: ignition_change
    ac_alarm: power_disconnected
    low_battery: battery_low
    sensor: external_sensor
    shake: vibration_detected
    drop: fall_detection

  device_models:
    # Popular Coban Models
    tk103a: tk103a_basic
    tk103b: tk103b_enhanced
    gps103: gps103_standard
    coban_103: coban_103_clone
    coban_104: coban_104_advanced
    coban_106: coban_106_vehicle
    coban_203: coban_203_personal
    coban_303: coban_303_motorcycle
    
    # Budget Clone Models
    gt02: gt02_compatible
    gt06: gt06_compatible
    h02: h02_compatible
    gps_tracker: generic_gps_tracker

  message_formats:
    standard: comma_separated_fields
    extended: enhanced_field_format
    compact: minimal_data_format
    alarm: emergency_format

  positioning_methods:
    gps: global_positioning
    lbs: location_based_service
    wifi: wifi_positioning
    agps: assisted_gps

  power_sources:
    vehicle_power: 12v_24v_input
    internal_battery: lithium_battery
    external_battery: removable_battery
    solar: solar_panel_charging

  connectivity_options:
    gsm_2g: gsm_gprs_edge
    gsm_3g: umts_hspa
    gsm_4g: lte_cat_m1
    gsm_quad_band: global_coverage