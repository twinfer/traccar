meta:
  id: wialon
  title: Wialon IPS Protocol
  license: MIT
  ks-version: 0.11
  endian: be

doc: |
  Wialon IPS (Internet Protocol for Sensors) is a text-based GPS tracking protocol
  developed by Gurtam for the Wialon tracking platform. It supports real-time data
  transmission, batch data upload, and extensive sensor/parameter integration.

seq:
  - id: messages
    type: wialon_message
    repeat: eos

types:
  wialon_message:
    seq:
      - id: version_prefix
        type: version_info
        if: has_version_prefix
      - id: device_id
        type: device_identifier
        if: not has_version_prefix or version_info.version == "2.0"
      - id: message_delimiter
        contents: ['#']
      - id: message_type
        type: str
        encoding: ASCII
        terminator: 0x23  # '#'
      - id: message_data
        type: str
        encoding: ASCII
        size-eos: true
    instances:
      has_version_prefix:
        value: _io.size > 3 and _io.read_str_byte_limit(3, "ASCII") == "2.0"

  version_info:
    seq:
      - id: version
        type: str
        encoding: ASCII
        terminator: 0x3b  # ';'

  device_identifier:
    seq:
      - id: imei
        type: str
        encoding: ASCII
        terminator: 0x23  # '#'

  login_message:
    seq:
      - id: login_data
        type: str
        encoding: ASCII
        size-eos: true
    instances:
      credentials:
        value: login_data.split(";")
      imei:
        value: |
          credentials.size >= 2 ?
          (credentials[0].index_of('.') >= 0 ? credentials[1] : credentials[0]) :
          credentials[0]

  position_data:
    seq:
      - id: position_fields
        type: str
        encoding: ASCII
        size-eos: true
    instances:
      parsed_fields:
        value: position_fields.split(";")
      date_day:
        value: parsed_fields.size > 0 and parsed_fields[0] != "NA" ? parsed_fields[0] : ""
      date_month:
        value: parsed_fields.size > 1 and parsed_fields[1] != "NA" ? parsed_fields[1] : ""
      date_year:
        value: parsed_fields.size > 2 and parsed_fields[2] != "NA" ? parsed_fields[2] : ""
      time_hour:
        value: parsed_fields.size > 3 and parsed_fields[3] != "NA" ? parsed_fields[3] : ""
      time_minute:
        value: parsed_fields.size > 4 and parsed_fields[4] != "NA" ? parsed_fields[4] : ""
      time_second:
        value: parsed_fields.size > 5 and parsed_fields[5] != "NA" ? parsed_fields[5] : ""
      latitude_degrees:
        value: parsed_fields.size > 6 and parsed_fields[6] != "NA" ? parsed_fields[6] : ""
      latitude_minutes:
        value: parsed_fields.size > 7 and parsed_fields[7] != "NA" ? parsed_fields[7] : ""
      latitude_hemisphere:
        value: parsed_fields.size > 8 and parsed_fields[8] != "NA" ? parsed_fields[8] : ""
      longitude_degrees:
        value: parsed_fields.size > 9 and parsed_fields[9] != "NA" ? parsed_fields[9] : ""
      longitude_minutes:
        value: parsed_fields.size > 10 and parsed_fields[10] != "NA" ? parsed_fields[10] : ""
      longitude_hemisphere:
        value: parsed_fields.size > 11 and parsed_fields[11] != "NA" ? parsed_fields[11] : ""
      speed_kmh:
        value: parsed_fields.size > 12 and parsed_fields[12] != "NA" ? parsed_fields[12] : ""
      course_degrees:
        value: parsed_fields.size > 13 and parsed_fields[13] != "NA" ? parsed_fields[13] : ""
      altitude_meters:
        value: parsed_fields.size > 14 and parsed_fields[14] != "NA" ? parsed_fields[14] : ""
      satellites_count:
        value: parsed_fields.size > 15 and parsed_fields[15] != "NA" ? parsed_fields[15] : ""
      hdop_value:
        value: parsed_fields.size > 16 and parsed_fields[16] != "NA" ? parsed_fields[16] : ""
      input_status:
        value: parsed_fields.size > 17 and parsed_fields[17] != "NA" ? parsed_fields[17] : ""
      output_status:
        value: parsed_fields.size > 18 and parsed_fields[18] != "NA" ? parsed_fields[18] : ""
      adc_values:
        value: parsed_fields.size > 19 and parsed_fields[19] != "NA" ? parsed_fields[19] : ""
      ibutton_id:
        value: parsed_fields.size > 20 and parsed_fields[20] != "NA" ? parsed_fields[20] : ""
      parameters:
        value: parsed_fields.size > 21 and parsed_fields[21] != "NA" ? parsed_fields[21] : ""

  batch_data:
    seq:
      - id: batch_content
        type: str
        encoding: ASCII
        size-eos: true
    instances:
      messages:
        value: batch_content.split("|")

  message_response:
    seq:
      - id: response_data
        type: str
        encoding: ASCII
        size-eos: true

  wialon_parameters:
    seq:
      - id: param_string
        type: str
        encoding: ASCII
        size-eos: true
    instances:
      parameter_list:
        value: param_string.split(",")

  cellular_info:
    seq:
      - id: cell_data
        type: str
        encoding: ASCII
        size-eos: true
    instances:
      has_mcc:
        value: cell_data.contains("mcc:")
      has_mnc:
        value: cell_data.contains("mnc:")
      has_lac:
        value: cell_data.contains("lac:")
      has_cell_id:
        value: cell_data.contains("cell_id:")

  sensor_data:
    seq:
      - id: sensor_values
        type: str
        encoding: ASCII
        size-eos: true
    instances:
      has_temperature:
        value: sensor_values.contains("temp:")
      has_battery:
        value: sensor_values.contains("bat:")
      has_fuel:
        value: sensor_values.contains("fuel:")
      has_engine_hours:
        value: sensor_values.contains("engine_hours:")
      has_odometer:
        value: sensor_values.contains("odo:")

enums:
  message_types:
    'L': login
    'P': ping_heartbeat
    'D': data_packet
    'SD': short_data_packet
    'B': batch_packet
    'M': message_response

  parameter_types:
    1: integer_value
    2: double_value
    3: string_value

  hemisphere_types:
    'N': north
    'S': south
    'E': east
    'W': west

instances:
  message_content:
    type:
      switch-on: message_type
      cases:
        '"L"': login_message
        '"P"': message_response
        '"D"': position_data
        '"SD"': position_data
        '"B"': batch_data
        '"M"': message_response
        _: message_response