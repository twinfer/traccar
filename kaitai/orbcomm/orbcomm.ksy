meta:
  id: orbcomm
  title: ORBCOMM Satellite IoT Protocol
  license: MIT
  ks-version: 0.11
  endian: be

doc: |
  ORBCOMM satellite IoT protocol supporting global satellite tracking via HTTP/JSON API.
  The protocol uses HTTP polling to retrieve messages from the ORBCOMM Gateway service,
  processing JSON payloads with satellite terminal data including location, speed, and sensor information.

seq:
  - id: orbcomm_response
    type: orbcomm_json_response

types:
  orbcomm_json_response:
    doc: |
      JSON response from ORBCOMM Gateway REST API containing message metadata
      and payload data from satellite terminals.
    seq:
      - id: error_id
        type: u1
        doc: Error code (0 = success)
      - id: next_start_utc
        type: str
        encoding: UTF-8
        doc: Next polling start time in UTC format
      - id: messages
        type: orbcomm_message
        repeat: eos
        doc: Array of messages from satellite terminals
    instances:
      has_messages:
        value: messages.size > 0
      polling_interval:
        value: next_start_utc != ""

  orbcomm_message:
    doc: |
      Individual message from an ORBCOMM satellite terminal containing
      device identification, timestamps, and payload data.
    seq:
      - id: message_id
        type: u8
        doc: Unique message identifier
      - id: message_utc
        type: str
        encoding: UTF-8
        doc: Message timestamp in UTC format
      - id: receive_utc
        type: str
        encoding: UTF-8
        doc: Gateway receive timestamp in UTC format
      - id: sin
        type: u1
        doc: Service Identification Number
      - id: mobile_id
        type: str
        encoding: UTF-8
        doc: Satellite terminal identifier (IMEI-like)
      - id: payload
        type: orbcomm_payload
        doc: Message payload containing sensor data
      - id: region_name
        type: str
        encoding: UTF-8
        doc: Satellite coverage region
      - id: ota_message_size
        type: u1
        doc: Over-the-air message size in bytes
      - id: customer_id
        type: u4
        doc: Customer account identifier
      - id: transport
        type: u1
        doc: Transport method (1=satellite)
      - id: mobile_owner_id
        type: u4
        doc: Device owner identifier
    instances:
      device_id:
        value: mobile_id
      is_satellite_transport:
        value: transport == 1
      message_timestamp:
        value: message_utc

  orbcomm_payload:
    doc: |
      Message payload containing structured data fields from the satellite terminal.
      Different payload types support various IoT applications and sensor configurations.
    seq:
      - id: name
        type: str
        encoding: UTF-8
        doc: Payload type name (e.g., MovingIntervalSat, modemRegistration)
      - id: sin
        type: u1
        doc: Service Identification Number
      - id: min
        type: u1
        doc: Message Identification Number
      - id: fields
        type: payload_field
        repeat: eos
        doc: Array of data fields containing sensor/status information
    instances:
      is_position_payload:
        value: name == "MovingIntervalSat" or name == "StationaryIntervalSat"
      is_registration_payload:
        value: name == "modemRegistration"
      field_count:
        value: fields.size

  payload_field:
    doc: |
      Individual data field within the payload containing sensor readings,
      position data, or device status information.
    seq:
      - id: name
        type: str
        encoding: UTF-8
        doc: Field name identifier
      - id: value
        type: str
        encoding: UTF-8
        doc: Field value as string
    instances:
      is_latitude:
        value: name.to_s.downcase == "latitude"
      is_longitude:
        value: name.to_s.downcase == "longitude"
      is_speed:
        value: name.to_s.downcase == "speed"
      is_heading:
        value: name.to_s.downcase == "heading"
      is_event_time:
        value: name.to_s.downcase == "eventtime"
      numeric_value:
        value: value.to_i
      latitude_degrees:
        value: numeric_value / 60000.0
        if: is_latitude
      longitude_degrees:
        value: numeric_value / 60000.0
        if: is_longitude
      speed_kph:
        value: numeric_value
        if: is_speed
      heading_degrees:
        value: numeric_value <= 360 ? numeric_value : 0
        if: is_heading
      event_timestamp:
        value: numeric_value
        if: is_event_time

enums:
  message_types:
    0: modem_registration
    22: moving_interval_sat
    23: stationary_interval_sat
    126: position_report
    127: emergency_report

  service_types:
    0: registration
    1: user_data
    2: system_data
    126: tracking_data
    127: emergency_data

  transport_types:
    1: satellite
    2: cellular
    3: dual_mode

  region_names:
    1: americas
    2: europe_middle_east_africa
    3: asia_pacific
    4: global_coverage

  payload_types:
    modem_registration: device_registration
    moving_interval_sat: position_tracking
    stationary_interval_sat: asset_monitoring
    emergency_alert: panic_button
    sensor_data: iot_telemetry
    diagnostic_data: device_health

  field_types:
    # Position fields
    latitude: position_coordinate
    longitude: position_coordinate
    speed: velocity_kph
    heading: compass_bearing
    eventtime: unix_timestamp
    
    # Registration fields
    hardware_major_version: device_version
    hardware_minor_version: device_version
    software_major_version: firmware_version
    software_minor_version: firmware_version
    product: device_model
    wakeup_period: power_management
    last_reset_reason: diagnostic_info
    virtual_carrier: network_config
    beam: satellite_beam
    vain: satellite_parameter
    operator_tx_state: transmission_state
    user_tx_state: transmission_state
    broadcast_id_count: network_parameter
    
    # IoT sensor fields
    temperature: celsius_degrees
    pressure: pascal_units
    humidity: percentage
    voltage: millivolts
    current: milliamps
    fuel_level: percentage
    door_status: boolean_state
    motion_detected: boolean_state
    tamper_alert: boolean_state
    low_battery: boolean_state