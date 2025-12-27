# Metals Scala LSP Plugin for Claude Code

A Language Server Protocol (LSP) integration for Scala using [Metals](https://scalameta.org/metals/).

## Features

- Code intelligence with go-to-definition
- Find all references to symbols
- Real-time error and warning diagnostics
- Hover tooltips with type information
- Document symbol navigation
- Scala 2.11, 2.12, 2.13, and Scala 3 support

## Current Status

✅ Plugin configuration files created
✅ Java installed (version 21)
⚠️  Metals LSP server needs to be installed

## Installation

### Prerequisites

**Java** is already installed! ✅
```bash
java -version
# openjdk version "21.0.9"
```

### Install Metals

You need to install the Metals language server. Choose one of these methods:

#### Option 1: Using Coursier (Recommended)

```bash
# Install coursier
curl -fL https://github.com/coursier/launchers/raw/master/cs-x86_64-pc-linux.gz | gunzip > cs
chmod +x cs
sudo mv cs /usr/local/bin/

# Install Metals
cs install metals

# Verify installation
metals --version
```

#### Option 2: Manual Installation

```bash
# Download and install metals directly
curl -L -o metals https://github.com/scalameta/metals/releases/latest/download/metals-x86_64-pc-linux
chmod +x metals
sudo mv metals /usr/local/bin/

# Verify installation
metals --version
```

#### Option 3: Using SDKMAN

```bash
# Install SDKMAN if not already installed
curl -s "https://get.sdkman.io" | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"

# Install Metals
sdk install metals

# Verify installation
metals --version
```

### Verify Setup

After installing Metals, run the verification script:

```bash
./hooks/check-metals.sh
```

You should see output like:
```
INFO: Found Java version: 21.0.9
INFO: Metals version: 1.x.x
```

## Plugin Structure

```
metals-scala-lsp-plugin/
├── .claude-plugin/
│   └── plugin.json          # Plugin metadata
├── .lsp.json                # LSP server configuration
├── hooks/
│   ├── hooks.json           # Hook configuration
│   └── check-metals.sh      # Verification script
├── examples/
│   ├── HelloWorld.scala     # Basic test file
│   └── build.sbt            # SBT build file
└── README.md                # This file
```

## Testing the Plugin

### Quick Test

1. **Install Metals** (see above)
2. **Open a Scala file** in Claude Code:
   ```bash
   claude code examples/HelloWorld.scala
   ```
3. **Test LSP features**:
   - Hover over variables to see type information
   - Click on function names to go to definition
   - Introduce a syntax error to see diagnostics

### What to Expect

When you open a `.scala` file:
- Metals LSP server will start automatically
- First-time setup may take 10-15 minutes (building classpath)
- You'll get code intelligence features like hover, go-to-definition, and diagnostics

### Troubleshooting

#### "No LSP server available" Error

1. Verify Metals is installed:
   ```bash
   which metals
   ```

2. Check the verification script:
   ```bash
   ./hooks/check-metals.sh
   ```

3. Check Claude Code logs for detailed error messages

#### LSP Server Not Starting

1. Make sure the `.lsp.json` file exists in the project root
2. Verify file permissions on the metals executable
3. Try running metals manually:
   ```bash
   metals
   ```

## Configuration

The plugin is configured via `.lsp.json`:

```json
{
  "scala": {
    "command": "metals",
    "args": ["-J-Dmetals.client=claude"],
    "extensionToLanguage": {
      ".scala": "scala",
      ".sbt": "scala",
      ".sc": "scala"
    },
    "transport": "stdio",
    "maxRestarts": 5
  }
}
```

## Supported File Types

- `.scala` - Scala source files
- `.sbt` - SBT build files
- `.sc` - Scala script files

## Resources

- [Metals Documentation](https://scalameta.org/metals/)
- [Metals GitHub](https://github.com/scalameta/metals)
- [Claude Code Documentation](https://code.claude.com/docs/)
- [Scala Official Site](https://www.scala-lang.org/)

## License

Apache-2.0
