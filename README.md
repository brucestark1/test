# HOCON Configuration Comparison Script

A bash script that compares multiple HOCON (Human-Optimized Config Object Notation) configuration files against a default configuration and identifies missing keys.

## Features

- Recursively traverses nested HOCON structures
- Identifies keys present in `default.conf` but missing in other config files
- Supports dot notation for nested keys (e.g., `database.credentials.username`)
- Color-coded output for easy readability
- Validates HOCON format before comparison
- Provides detailed summary of missing keys per file

## Requirements

- Bash shell
- `jq` - JSON processor for command line
- Python 3
- `pyhocon` - Python HOCON parser library

### Installing Dependencies

**jq:**

Debian/Ubuntu:
```bash
sudo apt-get install jq
```

macOS:
```bash
brew install jq
```

CentOS/RHEL:
```bash
sudo yum install jq
```

**Python 3:**

Most systems come with Python 3 pre-installed. If not:

Debian/Ubuntu:
```bash
sudo apt-get install python3 python3-pip
```

macOS:
```bash
brew install python3
```

**pyhocon:**
```bash
pip3 install pyhocon
```

## Usage

1. Place your `default.conf` file (in HOCON format) in the directory
2. Place other HOCON `.conf` files you want to compare in the same directory
3. Run the script:

```bash
./compare_json_configs.sh
```

## HOCON Format

HOCON (Human-Optimized Config Object Notation) is a JSON superset that's easier to read and write. Key features:

- Uses `key = value` syntax instead of `"key": value`
- No commas between fields
- Curly braces for nested objects
- More human-readable than JSON

### Example HOCON File:

```hocon
database {
  host = "localhost"
  port = 5432
  credentials {
    username = "admin"
    password = "secret"
  }
}

server {
  host = "0.0.0.0"
  port = 8080
  timeout = 30
}
```

## Example

Given these files:

**default.conf:**
```hocon
database {
  host = "localhost"
  port = 5432
  credentials {
    username = "admin"
    password = "secret"
  }
}

server {
  port = 8080
  timeout = 30
}
```

**production.conf:**
```hocon
database {
  host = "prod-db.example.com"
  port = 5432
}

server {
  port = 443
}
```

**Output:**
```
=== HOCON Configuration Comparison ===
Default file: default.conf

Extracting keys from default.conf...
Found 5 keys in default.conf

Configuration files to check:
  - production.conf

Checking: production.conf
  ⨯ Missing 3 key(s):
    - database.credentials.username
    - database.credentials.password
    - server.timeout

=== Summary ===
Total files checked: 1
Files with missing keys: 1
Files with all keys: 0
```

## How It Works

1. The script converts HOCON files to JSON using pyhocon
2. Extracts all keys from `default.conf` using `jq`
3. Keys are converted to dot notation for nested objects
4. Each configuration file in the directory is checked against these keys
5. Missing keys are reported for each file
6. A summary shows overall comparison results

## Supported File Extensions

- `.conf` (HOCON format)

## Sample Files

This repository includes sample HOCON configuration files for testing:
- `default.conf` - Default configuration with all keys
- `production.conf` - Production config missing some keys (server.timeout, logging.rotation)
- `staging.conf` - Staging config missing several keys (credentials, features, logging rotation)

## Testing

A comprehensive test suite is included to verify the script works correctly.

### Running Tests

```bash
./tests/run_tests.sh
```

The test suite includes 9 tests covering:
- Complete configurations (all keys present)
- Partial configurations (some missing keys)
- Minimal configurations (many missing keys)
- Invalid HOCON syntax handling
- Empty configuration files
- Summary statistics accuracy

See [tests/README.md](tests/README.md) for detailed test documentation.

## Exit Codes

- `0` - Success
- `1` - Error (missing default.conf, dependencies not installed, invalid HOCON)

## Troubleshooting

**Error: pyhocon is not installed**
```bash
pip3 install pyhocon
```

**Error: jq is not installed**
```bash
# Debian/Ubuntu
sudo apt-get install jq

# macOS
brew install jq
```

**Error: Invalid HOCON format**

Make sure your HOCON files are properly formatted. Common issues:
- Missing closing braces
- Invalid syntax (HOCON uses `=` not `:`)
- Unquoted strings with special characters
