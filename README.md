# JSON Configuration Comparison Script

A bash script that compares multiple JSON configuration files against a default configuration and identifies missing keys.

## Features

- Recursively traverses nested JSON structures
- Identifies keys present in `default.conf` but missing in other config files
- Supports dot notation for nested keys (e.g., `database.credentials.username`)
- Color-coded output for easy readability
- Validates JSON format before comparison
- Provides detailed summary of missing keys per file

## Requirements

- Bash shell
- `jq` - JSON processor for command line

### Installing jq

**Debian/Ubuntu:**
```bash
sudo apt-get install jq
```

**macOS:**
```bash
brew install jq
```

**CentOS/RHEL:**
```bash
sudo yum install jq
```

## Usage

1. Place your `default.conf` file in the directory
2. Place other JSON/conf files you want to compare in the same directory
3. Run the script:

```bash
./compare_json_configs.sh
```

## Example

Given these files:

**default.conf:**
```json
{
  "database": {
    "host": "localhost",
    "port": 5432,
    "credentials": {
      "username": "admin",
      "password": "secret"
    }
  },
  "server": {
    "port": 8080
  }
}
```

**production.conf:**
```json
{
  "database": {
    "host": "prod-db.example.com",
    "port": 5432
  },
  "server": {
    "port": 443
  }
}
```

**Output:**
```
=== JSON Configuration Comparison ===
Default file: default.conf

Extracting keys from default.conf...
Found 5 keys in default.conf

Configuration files to check:
  - production.conf

Checking: production.conf
  ⨯ Missing 2 key(s):
    - database.credentials.username
    - database.credentials.password

=== Summary ===
Total files checked: 1
Files with missing keys: 1
Files with all keys: 0
```

## How It Works

1. The script extracts all keys from `default.conf` using `jq`
2. Keys are converted to dot notation for nested objects
3. Each configuration file in the directory is checked against these keys
4. Missing keys are reported for each file
5. A summary shows overall comparison results

## Supported File Extensions

- `.json`
- `.conf`

## Sample Files

This repository includes sample configuration files for testing:
- `default.conf` - Default configuration with all keys
- `production.conf` - Production config missing some keys
- `staging.conf` - Staging config missing several keys

## Exit Codes

- `0` - Success
- `1` - Error (missing default.conf, jq not installed, invalid JSON)
