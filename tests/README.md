# Test Suite for HOCON Configuration Comparison Script

This directory contains a comprehensive test suite for the HOCON configuration comparison script.

## Test Structure

```
tests/
├── run_tests.sh          # Main test runner script
├── test-configs/         # Test configuration files
│   ├── default.conf      # Default configuration with all keys
│   ├── complete.conf     # Test: All keys present
│   ├── partial.conf      # Test: Some keys missing
│   ├── minimal.conf      # Test: Many keys missing
│   ├── invalid.conf      # Test: Invalid HOCON syntax
│   └── empty.conf        # Test: Empty configuration
└── README.md             # This file
```

## Running Tests

To run the full test suite:

```bash
./tests/run_tests.sh
```

Or from the tests directory:

```bash
cd tests
./run_tests.sh
```

## Test Cases

### 1. Complete Configuration Test
**File:** `complete.conf`
**Expected:** All keys present, no missing keys
**Validates:** Script correctly identifies complete configurations

### 2. Partial Configuration Test
**File:** `partial.conf`
**Expected:** Missing 5 specific keys:
- `database.credentials.password`
- `database.credentials.username`
- `logging.rotation.enabled`
- `logging.rotation.maxSize`
- `server.timeout`

**Validates:** Script correctly identifies partial missing keys

### 3. Minimal Configuration Test
**File:** `minimal.conf`
**Expected:** Missing 11 keys (most nested and some top-level keys)
**Validates:** Script handles configurations with many missing keys

### 4. Invalid HOCON Format Test
**File:** `invalid.conf`
**Expected:** Skipped with "Invalid HOCON format" message
**Validates:** Script gracefully handles invalid HOCON syntax

### 5. Empty Configuration Test
**File:** `empty.conf`
**Expected:** All 14 keys missing
**Validates:** Script handles empty configuration files

### 6-9. Summary Statistics Tests
**Validates:**
- Correct count of total files checked (4 valid files)
- Correct count of files with missing keys (3 files)
- Correct count of files with all keys present (1 file)
- Correct extraction of 14 keys from default.conf

## Test Output

### Successful Test Run
```
========================================
HOCON Configuration Comparison Test Suite
========================================

--- Basic Functionality Tests ---

Test 1: Complete config has all keys
  ✓ PASSED

Test 2: Partial config missing specific keys
  ✓ PASSED - All expected missing keys found

Test 3: Minimal config missing many keys
  ✓ PASSED - All expected missing keys found

Test 4: Invalid HOCON format detected
  ✓ PASSED

Test 5: Empty config has all keys missing
  ✓ PASSED

--- Summary Statistics Tests ---

Test 6: Correct number of files checked
  ✓ PASSED

Test 7: Correct count of files with missing keys
  ✓ PASSED

Test 8: Correct count of files with all keys
  ✓ PASSED

Test 9: Correct number of keys extracted from default.conf
  ✓ PASSED

========================================
Test Results Summary
========================================
Total tests run:    9
Tests passed:       9
Tests failed:       0

✓ All tests passed!
```

### Failed Test Example
When a test fails, detailed output is provided:
```
Test 2: Partial config missing specific keys
  ✗ FAILED
  Expected missing key not found: server.timeout
  Output:
  [detailed output from script]
```

## Adding New Tests

To add a new test case:

1. **Create a test configuration file** in `test-configs/`
2. **Add a test function** in `run_tests.sh` following the existing pattern
3. **Use helper functions:**
   - `check_missing_keys` - Validate specific missing keys
   - `run_test` - Run general pattern-matching tests

### Example: Adding a New Test

```bash
# In run_tests.sh, add:
check_missing_keys \
    "New test description" \
    "new-config.conf" \
    "expected.missing.key1" \
    "expected.missing.key2"
```

## Exit Codes

- `0` - All tests passed
- `1` - One or more tests failed

## Dependencies

The test suite requires the same dependencies as the main script:
- Bash
- `jq`
- Python 3
- `pyhocon`

## Continuous Integration

This test suite can be integrated into CI/CD pipelines:

```yaml
# Example GitHub Actions workflow
test:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v2
    - name: Install dependencies
      run: |
        sudo apt-get install jq
        pip3 install pyhocon
    - name: Run tests
      run: ./tests/run_tests.sh
```

## Test Coverage

The test suite covers:
- ✓ Complete configurations
- ✓ Partial configurations with missing nested keys
- ✓ Minimal configurations with many missing keys
- ✓ Invalid HOCON syntax handling
- ✓ Empty configuration files
- ✓ Correct file counting
- ✓ Accurate missing key detection
- ✓ Summary statistics accuracy
- ✓ Key extraction from default configuration

## Troubleshooting

**All tests fail immediately:**
- Ensure you're running from the project root or tests directory
- Check that `compare_json_configs.sh` is executable
- Verify all dependencies are installed

**Specific test fails:**
- Review the test output for details
- Check the corresponding test configuration file
- Run the script manually against the test config to debug

**Color codes in output:**
- Tests are designed to handle ANSI color codes
- If issues persist, check grep version and compatibility
