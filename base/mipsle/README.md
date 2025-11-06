# SubConverter MIPS Little Endian Build

This directory contains the MIPS Little Endian (mipsel) build of subconverter.

## Build Information

- **Architecture**: MIPS 32-bit Little Endian
- **MIPS ISA**: MIPS32 Release 2
- **ABI**: o32 (32-bit ABI)
- **Target**: GNU/Linux 3.2.0+

## Executable

- **File**: `subconverter-mipsle`
- **Size**: ~6.1 MB (stripped)
- **Type**: ELF 32-bit LSB executable

## Runtime Requirements

The executable is dynamically linked and requires the following libraries on the target system:

- libc (glibc 2.3+)
- libpthread
- libdl
- libm
- libatomic (for atomic operations support)

## How to Build

### Method 1: Using the build script

```bash
chmod +x scripts/build.mipsle.release.sh
bash scripts/build.mipsle.release.sh
```

The build script will:
1. Install all required dependencies
2. Cross-compile all libraries for MIPS LE
3. Build subconverter
4. Place the executable in `base/mipsle/subconverter-mipsle`

### Method 2: Using GitHub Actions

The repository includes a GitHub Actions workflow (`.github/workflows/build-mipsle.yml`) that automatically builds the MIPS LE version on push/PR to main/master branches.

## Dependencies Built

The following libraries are cross-compiled for MIPS LE:

1. **zlib** (v1.3.1) - Compression library
2. **mbedTLS** (v3.5.2) - Cryptographic library
3. **PCRE2** (v10.44) - Regular expression library
4. **curl** (v8.6.0) - HTTP client library
5. **RapidJSON** - JSON parser (header-only)
6. **yaml-cpp** (v0.8.0) - YAML parser library
7. **QuickJS** - JavaScript engine
8. **toml11** (v4.3.0) - TOML parser (header-only)
9. **libcron** - Cron expression parser

## Usage on MIPS Device

1. Transfer the executable to your MIPS device:
   ```bash
   scp base/mipsle/subconverter-mipsle user@mips-device:/path/to/destination/
   ```

2. Make it executable (if needed):
   ```bash
   chmod +x subconverter-mipsle
   ```

3. Run the executable:
   ```bash
   ./subconverter-mipsle
   ```

## Testing

To verify the build is correct:
```bash
file base/mipsle/subconverter-mipsle
```

Expected output:
```
subconverter-mipsle: ELF 32-bit LSB executable, MIPS, MIPS32 rel2 version 1 (GNU/Linux), dynamically linked, interpreter /lib/ld.so.1, for GNU/Linux 3.2.0, stripped
```

## Notes

- This build is intended for MIPS Little Endian routers and devices
- Common use cases include OpenWrt routers with MIPS LE processors
- The executable requires MIPS32 Release 2 or later processor support
- For older MIPS32 Release 1 devices, the build script would need modification

## Troubleshooting

### Missing libatomic
If you get errors about missing atomic operations:
```bash
# On OpenWrt
opkg update
opkg install libatomic

# On Debian-based MIPS systems
apt-get install libatomic1
```

### Incompatible with device
Verify your device's architecture:
```bash
uname -m  # Should show "mips" or similar
cat /proc/cpuinfo | grep cpu  # Check for MIPS32 Release 2 support
```

## Build Time

Approximate build time on GitHub Actions runners: 20-30 minutes

## Size Optimization

The executable is stripped to reduce size. If you need debug symbols:
- Don't run the strip command in the build script
- The unstripped binary will be approximately 6.8 MB

## License

Same as the main subconverter project.
