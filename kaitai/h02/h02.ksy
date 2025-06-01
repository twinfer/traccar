meta:
  id: h02
  title: H02 GPS Tracker Protocol
  endian: be
  file-extension: h02
  
doc: |
  H02 protocol parser supporting both text and binary formats.
  Messages start with * (text), $ (binary), or X (special binary).
  Widely used by various GPS tracking devices.

seq:
  - id: message
    type:
      switch-on: message_type_byte
      cases:
        0x2A: text_message    # '*' ASCII
        0x24: binary_message  # '$' ASCII
        0x58: special_binary  # 'X' ASCII
    doc: Message content based on first byte

instances:
  message_type_byte:
    pos: 0
    type: u1
    
types:
  # Text message parser
  text_message:
    seq:
      - id: start_marker
        contents: "*"
        
      - id: manufacturer
        type: str
        encoding: ASCII
        terminator: 0x2C  # ','
        
      - id: device_id
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: message_type
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: content
        type:
          switch-on: message_type
          cases:
            '"V1"': v1_message
            '"V4"': v4_message
            '"NBR"': nbr_message
            '"LINK"': link_message
            '"V3"': v3_message
            '"VP1"': vp1_message
            '"HTBT"': htbt_message
            _: generic_text_content
            
      - id: end_marker
        contents: "#"
        
  # V1/V4 position message
  v1_message:
    seq:
      - id: time
        type: str
        size: 6
        encoding: ASCII
        doc: HHMMSS format
        
      - id: comma1
        contents: ","
        
      - id: validity
        type: str
        size: 1
        encoding: ASCII
        doc: A=valid, V=invalid
        
      - id: comma2
        contents: ","
        
      - id: latitude
        type: str
        encoding: ASCII
        terminator: 0x2C
        doc: Latitude value
        
      - id: lat_hemisphere
        type: str
        size: 1
        encoding: ASCII
        doc: N=North, S=South
        
      - id: comma3
        contents: ","
        
      - id: longitude
        type: str
        encoding: ASCII
        terminator: 0x2C
        doc: Longitude value
        
      - id: lon_hemisphere
        type: str
        size: 1
        encoding: ASCII
        doc: E=East, W=West
        
      - id: comma4
        contents: ","
        
      - id: speed
        type: str
        encoding: ASCII
        terminator: 0x2C
        doc: Speed in knots
        
      - id: course
        type: str
        encoding: ASCII
        terminator: 0x2C
        doc: Course in degrees
        
      - id: date
        type: str
        size: 6
        encoding: ASCII
        doc: DDMMYY format
        
      - id: comma5
        contents: ","
        
      - id: status
        type: str
        encoding: ASCII
        terminator: 0x23  # '#'
        doc: Hex status value
        
  # V4 message extends V1
  v4_message:
    seq:
      - id: v1_data
        type: v1_message
        
      # Additional V4 fields would go here
        
  # NBR (Network Based Report) message
  nbr_message:
    seq:
      - id: time
        type: str
        size: 6
        encoding: ASCII
        
      - id: comma1
        contents: ","
        
      - id: mcc
        type: str
        encoding: ASCII
        terminator: 0x2C
        doc: Mobile Country Code
        
      - id: mnc
        type: str
        encoding: ASCII
        terminator: 0x2C
        doc: Mobile Network Code
        
      - id: delay
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: count
        type: str
        encoding: ASCII
        terminator: 0x2C
        doc: Number of cell towers
        
      - id: cells
        type: cell_info_text
        repeat: expr
        repeat-expr: count.to_i
        
      - id: date
        type: str
        size: 6
        encoding: ASCII
        
      - id: comma_last
        contents: ","
        
      - id: status
        type: str
        encoding: ASCII
        terminator: 0x23
        
  # LINK status message
  link_message:
    seq:
      - id: time
        type: str
        size: 6
        encoding: ASCII
        
      - id: comma1
        contents: ","
        
      - id: rssi
        type: str
        encoding: ASCII
        terminator: 0x2C
        doc: Signal strength
        
      - id: satellites
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: battery
        type: str
        encoding: ASCII
        terminator: 0x2C
        doc: Battery percentage
        
      - id: steps
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: turnovers
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: date
        type: str
        size: 6
        encoding: ASCII
        
      - id: comma_last
        contents: ","
        
      - id: status
        type: str
        encoding: ASCII
        terminator: 0x23
        
  # V3 cell tower message
  v3_message:
    seq:
      - id: time
        type: str
        size: 6
        encoding: ASCII
        
      - id: comma1
        contents: ","
        
      - id: mcc_mnc
        type: str
        encoding: ASCII
        terminator: 0x2C
        doc: Combined MCC+MNC
        
      - id: count
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: cell_data
        type: str
        encoding: ASCII
        terminator: 0x2C
        doc: Cell tower information
        
      - id: battery
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: reboot
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: x_marker
        type: str
        size: 1
        encoding: ASCII
        
      - id: comma_last
        contents: ","
        
      - id: date
        type: str
        size: 6
        encoding: ASCII
        
      - id: comma_final
        contents: ","
        
      - id: status
        type: str
        encoding: ASCII
        terminator: 0x23
        
  # VP1 alternative position format
  vp1_message:
    seq:
      - id: validity
        type: str
        size: 1
        encoding: ASCII
        
      - id: comma1
        contents: ","
        
      - id: latitude
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: lat_hemisphere
        type: str
        size: 1
        encoding: ASCII
        
      - id: comma2
        contents: ","
        
      - id: longitude
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: lon_hemisphere
        type: str
        size: 1
        encoding: ASCII
        
      - id: comma3
        contents: ","
        
      - id: speed
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: course
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: date
        type: str
        size: 6
        encoding: ASCII
        terminator: 0x23
        
  # HTBT heartbeat message
  htbt_message:
    seq:
      - id: battery
        type: str
        encoding: ASCII
        terminator: 0x23
        doc: Battery percentage
        
  # Generic text content
  generic_text_content:
    seq:
      - id: data
        type: str
        encoding: ASCII
        terminator: 0x23
        
  # Cell info for NBR messages
  cell_info_text:
    seq:
      - id: lac
        type: str
        encoding: ASCII
        terminator: 0x2C
        doc: Location Area Code
        
      - id: cell_id
        type: str
        encoding: ASCII
        terminator: 0x2C
        doc: Cell ID
        
      - id: signal
        type: str
        encoding: ASCII
        terminator: 0x2C
        doc: Signal strength
        
  # Binary message parser
  binary_message:
    seq:
      - id: marker
        contents: "$"
        
      - id: device_id_length
        type: u1
        doc: Check if device ID is 5 or 8 bytes
        
      # Rewind to read full message
      - id: message_data
        type:
          switch-on: is_long_format
          cases:
            true: binary_long
            false: binary_short
        pos: 0
        
    instances:
      is_long_format:
        value: _io.size >= 45
        
  # Short binary format (32 bytes total)
  binary_short:
    seq:
      - id: marker
        type: u1
        
      - id: device_id
        size: 5
        doc: 5-byte device ID
        
      - id: datetime
        type: bcd_datetime
        
      - id: latitude
        type: bcd_coordinate
        
      - id: battery
        type: u1
        doc: Battery level
        
      - id: longitude
        type: bcd_coordinate_long
        
      - id: flags
        type: u1
        doc: Validity and hemisphere flags
        
      - id: speed
        type: bcd_value
        size: 3
        
      - id: course
        type: bcd_value
        size: 3
        
      - id: status
        type: u4
        doc: 32-bit status field
        
    instances:
      is_valid:
        value: (flags & 0x04) != 0
        
      latitude_sign:
        value: (flags & 0x02) == 0 ? 1 : -1
        
      longitude_sign:
        value: (flags & 0x01) == 0 ? 1 : -1
        
  # Long binary format (45 bytes total)
  binary_long:
    seq:
      - id: marker
        type: u1
        
      - id: device_id
        size: 8
        doc: 8-byte extended device ID
        
      - id: datetime
        type: bcd_datetime
        
      - id: latitude
        type: bcd_coordinate
        
      - id: battery
        type: u1
        
      - id: longitude
        type: bcd_coordinate_long
        
      - id: flags
        type: u1
        
      - id: speed
        type: bcd_value
        size: 3
        
      - id: course
        type: bcd_value
        size: 3
        
      - id: status
        type: u4
        
  # Special binary format
  special_binary:
    seq:
      - id: data
        size: 32
        doc: Fixed 32-byte special format
        
  # BCD encoded datetime
  bcd_datetime:
    seq:
      - id: hour
        type: u1
        doc: BCD encoded hour
        
      - id: minute
        type: u1
        doc: BCD encoded minute
        
      - id: second
        type: u1
        doc: BCD encoded second
        
      - id: day
        type: u1
        doc: BCD encoded day
        
      - id: month
        type: u1
        doc: BCD encoded month
        
      - id: year
        type: u1
        doc: BCD encoded year (00-99)
        
    instances:
      hour_dec:
        value: ((hour >> 4) * 10) + (hour & 0x0F)
        
      minute_dec:
        value: ((minute >> 4) * 10) + (minute & 0x0F)
        
      second_dec:
        value: ((second >> 4) * 10) + (second & 0x0F)
        
      day_dec:
        value: ((day >> 4) * 10) + (day & 0x0F)
        
      month_dec:
        value: ((month >> 4) * 10) + (month & 0x0F)
        
      year_dec:
        value: 2000 + ((year >> 4) * 10) + (year & 0x0F)
        
  # BCD coordinate (latitude - 9 bytes)
  bcd_coordinate:
    seq:
      - id: degrees
        type: u1
        
      - id: minutes
        type: u1
        
      - id: decimal_1
        type: u1
        
      - id: decimal_2
        type: u1
        
      - id: decimal_3
        type: u1
        
      - id: decimal_4
        type: u1
        
      - id: zeros
        size: 3
        
    instances:
      value:
        value: |
          ((degrees >> 4) * 10 + (degrees & 0x0F)) +
          ((minutes >> 4) * 10 + (minutes & 0x0F)) / 60.0 +
          ((decimal_1 >> 4) * 10000 + (decimal_1 & 0x0F) * 1000 +
           (decimal_2 >> 4) * 100 + (decimal_2 & 0x0F) * 10 +
           (decimal_3 >> 4) * 1 + (decimal_3 & 0x0F) * 0.1 +
           (decimal_4 >> 4) * 0.01 + (decimal_4 & 0x0F) * 0.001) / 3600000.0
           
  # BCD coordinate (longitude - 10 bytes)
  bcd_coordinate_long:
    seq:
      - id: degrees_1
        type: u1
        
      - id: degrees_2
        type: u1
        
      - id: minutes
        type: u1
        
      - id: decimal_1
        type: u1
        
      - id: decimal_2
        type: u1
        
      - id: decimal_3
        type: u1
        
      - id: decimal_4
        type: u1
        
      - id: zeros
        size: 3
        
    instances:
      value:
        value: |
          ((degrees_1 >> 4) * 100 + (degrees_1 & 0x0F) * 10 + 
           (degrees_2 >> 4) * 1 + (degrees_2 & 0x0F) * 0.1) +
          ((minutes >> 4) * 10 + (minutes & 0x0F)) / 60.0 +
          ((decimal_1 >> 4) * 10000 + (decimal_1 & 0x0F) * 1000 +
           (decimal_2 >> 4) * 100 + (decimal_2 & 0x0F) * 10 +
           (decimal_3 >> 4) * 1 + (decimal_3 & 0x0F) * 0.1 +
           (decimal_4 >> 4) * 0.01 + (decimal_4 & 0x0F) * 0.001) / 3600000.0
           
  # Generic BCD value parser
  bcd_value:
    params:
      - id: len
        type: u4
    seq:
      - id: bytes
        size: len
        
    instances:
      value:
        value: |
          bytes.reduce(0, |acc, b| acc * 100 + ((b >> 4) * 10) + (b & 0x0F))