# SubConverter MIPS Little Endian Build

This directory contains the MIPS Little Endian (mipsel) build of subconverter.

## Build Information

- **Architecture**: MIPS 32-bit Little Endian
- **MIPS ISA**: MIPS32 Release 2
- **ABI**: o32 (32-bit ABI)
- **Target**: GNU/Linux 3.2.0+
- **Linking**: **Statically linked** (no runtime dependencies required)

## Executable

- **File**: `subconverter-mipsle`
- **Size**: ~8.4 MB (stripped, statically linked)
- **Type**: ELF 32-bit LSB executable, statically linked

## Runtime Requirements

### Current Build (Statically Linked)
The executable is **statically linked** and includes all required libraries. It can run on any MIPS LE device without additional dependencies.

**No runtime libraries are required for the statically linked build!**

### Alternative: Dynamically Linked Build
If you need a smaller executable size, a dynamically linked version can be built by modifying the build script. The dynamically linked version would require the following libraries on the target system:

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
subconverter-mipsle: ELF 32-bit LSB executable, MIPS, MIPS32 rel2 version 1 (GNU/Linux), statically linked, for GNU/Linux 3.2.0, stripped
```

## Notes

- This build is **statically linked** and does not require any runtime libraries
- It can run on any MIPS Little Endian device with MIPS32 Release 2 support
- Common use cases include OpenWrt routers with MIPS LE processors
- The executable is larger (~8.4 MB) than the dynamically linked version due to included libraries, but provides better compatibility

## Build Time

Approximate build time on GitHub Actions runners: 20-30 minutes

## Troubleshooting

### For Statically Linked Build (Current)
The statically linked executable should run without any additional libraries. If you encounter issues:

1. Verify your device's architecture:
   ```bash
   uname -m  # Should show "mips" or similar
   cat /proc/cpuinfo | grep cpu  # Check for MIPS32 Release 2 support
   ```

2. Check file permissions:
   ```bash
   chmod +x subconverter-mipsle
   ```

### For Dynamically Linked Build (If Built)
If you build a dynamically linked version and get errors about missing libraries:

#### Missing libatomic
```bash
# On OpenWrt
opkg update
opkg install libatomic

# On Debian-based MIPS systems
apt-get install libatomic1
```

#### Missing other libraries
```bash
# On OpenWrt
opkg update
opkg install libc libpthread

# On Debian-based MIPS systems
apt-get install libc6 libpthread-stubs0-dev
```

## Size Optimization

The executable is statically linked and stripped to balance size and compatibility:
- Statically linked: ~8.4 MB (stripped) - **Current version**
- Dynamically linked: ~6.1 MB (stripped) - Requires runtime libraries

The larger size of the static version is offset by not requiring any runtime library dependencies, making it much easier to deploy on embedded devices.

## License

Same as the main subconverter project.
