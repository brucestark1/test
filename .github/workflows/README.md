# CI/CD Workflows

This directory contains GitHub Actions workflows for automated testing and validation.

## Workflows

### 1. CI Tests (`ci.yml`)

**Triggers:**
- Push to `main`, `master`, or any `claude/**` branch
- Pull requests to `main` or `master`

**What it does:**
- Runs on Ubuntu (latest)
- Installs dependencies (jq, Python 3, pyhocon)
- Executes the full test suite
- Runs the script on sample configurations

**Use case:** Quick validation on standard Linux environment

### 2. Multi-Platform Tests (`multi-platform.yml`)

**Triggers:**
- Push to `main`, `master`, or any `claude/**` branch
- Pull requests to `main` or `master`

**What it does:**
- Tests on multiple operating systems: Ubuntu, macOS
- Tests with multiple Python versions: 3.8, 3.9, 3.10, 3.11, 3.12
- Ensures cross-platform compatibility
- Validates dependencies installation on different platforms

**Use case:** Comprehensive validation across different environments

## Workflow Status

You can view the status of workflows:
- On the repository's **Actions** tab
- In the README badges (if configured)
- On pull requests (checks section)

## Local Testing

To simulate CI locally before pushing:

```bash
# Install dependencies
sudo apt-get install jq  # or: brew install jq
pip3 install pyhocon

# Run tests
./tests/run_tests.sh

# Run script
./compare_json_configs.sh
```

## Workflow Configuration

### Adding New Tests

To add new test steps to the workflow:

1. Edit `.github/workflows/ci.yml`
2. Add a new step under the `steps:` section
3. Test locally first
4. Commit and push

Example:
```yaml
- name: Your new test
  run: |
    echo "Running new test..."
    # your commands here
```

### Changing Trigger Conditions

To modify when workflows run, edit the `on:` section:

```yaml
on:
  push:
    branches: [ your-branch-pattern ]
  pull_request:
    branches: [ target-branches ]
  schedule:
    - cron: '0 0 * * 0'  # Weekly on Sunday
```

### Environment Variables

To add environment variables:

```yaml
env:
  MY_VAR: value

jobs:
  test:
    env:
      JOB_VAR: value
    steps:
    - name: Step with env
      env:
        STEP_VAR: value
      run: echo $STEP_VAR
```

## Troubleshooting CI Failures

### Dependency Installation Failures

**Problem:** `jq` or `pyhocon` fails to install

**Solution:** Check the package manager logs in the workflow output. May need to update package names or add repositories.

### Test Failures

**Problem:** Tests pass locally but fail in CI

**Solution:**
1. Check Python version compatibility
2. Verify file permissions are set correctly
3. Ensure all test files are committed
4. Check for environment-specific paths

### Permission Errors

**Problem:** Script not executable in CI

**Solution:** Ensure the workflow includes:
```yaml
- name: Make scripts executable
  run: chmod +x script.sh
```

### macOS-Specific Issues

**Problem:** Different behavior on macOS vs Ubuntu

**Solution:**
- Use conditional steps with `if: runner.os == 'macOS'`
- Check for macOS-specific tool versions (e.g., BSD vs GNU tools)

## Best Practices

1. **Keep workflows fast:** Use caching for dependencies
2. **Fail fast:** Use `fail-fast: false` in matrix to see all failures
3. **Test locally:** Always test changes locally before pushing
4. **Use specific versions:** Pin action versions (e.g., `@v4` not `@latest`)
5. **Add timeouts:** Prevent stuck jobs with `timeout-minutes`

## Adding Badges to README

To show workflow status in your README:

```markdown
![CI Tests](https://github.com/username/repo/workflows/CI%20Tests/badge.svg)
![Multi-Platform](https://github.com/username/repo/workflows/Multi-Platform%20Tests/badge.svg)
```

Replace `username/repo` with your GitHub repository path.

## Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Workflow Syntax Reference](https://docs.github.com/en/actions/reference/workflow-syntax-for-github-actions)
- [GitHub Actions Marketplace](https://github.com/marketplace?type=actions)
