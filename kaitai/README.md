# Kaitai Struct Definitions for Traccar GPS Protocols

This directory contains Kaitai Struct (.ksy) definitions for GPS tracking protocols supported by Traccar.

## Directory Structure

Each protocol has its own directory containing:
- `protocol_name.ksy` - Kaitai Struct definition
- `README.md` - Protocol documentation and implementation notes

## Implementation Priority

### Round 1 (Most Popular - Based on test coverage and usage)
- **gl200/** - Queclink GL200, text-based protocol (178 test cases)
- **gt06/** - Chinese GPS tracker binary protocol (167 test cases)
- **h02/** - Mixed text/binary protocol (87 test cases)
- **gps103/** - TK103 text-based protocol (81 test cases)
- **teltonika/** - European binary protocol (51 test cases)

### Round 2 (High Usage)
- **suntech/** - Latin American text protocol (79 test cases)
- **huabao/** - Chinese JT/T 808 standard (79 test cases)
- **watch/** - Kids' smartwatch protocol (52 test cases)
- **meiligao/** - Binary protocol (44 test cases)
- **castel/** - Binary protocol (50 test cases)

## Usage

```bash
# Compile a .ksy file to Java
kaitai-struct-compiler -t java gl200/gl200.ksy

# Compile to Python for analysis
kaitai-struct-compiler -t python gt06/gt06.ksy
```

## Protocol Selection Criteria

1. **Test Coverage** - Number of test cases in Traccar
2. **Bidirectional Support** - Has both encoder and decoder
3. **Implementation Complexity** - Lines of code and features
4. **Geographic Distribution** - Global market coverage