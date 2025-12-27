# Testing Guide: Metals Scala LSP Plugin

This guide walks you through testing the Metals LSP integration with Claude Code.

## Prerequisites

Before testing, you MUST install Metals. Run:

```bash
# Option 1: Install Coursier first, then Metals
curl -fL https://github.com/coursier/launchers/raw/master/cs-x86_64-pc-linux.gz | gunzip > cs
chmod +x cs
sudo mv cs /usr/local/bin/
cs install metals

# Option 2: Direct Metals installation
curl -L -o metals https://github.com/scalameta/metals/releases/latest/download/metals-x86_64-pc-linux
chmod +x metals
sudo mv metals /usr/local/bin/

# Verify installation
metals --version
```

## Step 1: Verify Setup

Run the verification script:

```bash
./hooks/check-metals.sh
```

Expected output:
```
INFO: Found Java version: 21.0.9
INFO: Metals version: <version>
```

If you see warnings, install Metals first (see above).

## Step 2: Test File Structure

Verify all plugin files exist:

```bash
tree -a -L 3
```

You should see:
```
.
├── .claude-plugin/
│   └── plugin.json
├── .lsp.json
├── hooks/
│   ├── hooks.json
│   └── check-metals.sh
├── examples/
│   ├── HelloWorld.scala
│   ├── AdvancedFeatures.scala
│   └── TestDiagnostics.scala
├── build.sbt
├── README.md
└── TESTING_GUIDE.md
```

## Step 3: Open a Scala File in Claude Code

Open one of the test files:

```bash
# If using Claude Code CLI
claude code examples/HelloWorld.scala

# Or open in your editor that supports Claude Code
```

### What Should Happen

1. **Metals LSP server starts automatically**
   - Check Claude Code logs/console for: "LSP server (scala) starting: metals"

2. **First-time initialization (10-15 minutes)**
   - Metals will import the build configuration
   - Download dependencies
   - Build the classpath
   - Subsequent loads will be much faster

3. **LSP Features become available**
   - Once initialization completes, all LSP features work

## Step 4: Test LSP Features

### Test 1: Hover (Type Information)

1. Open `examples/HelloWorld.scala`
2. Hover your mouse over these elements:
   - `message` variable (line ~34) → Should show type `String`
   - `result` variable (line ~38) → Should show type `Int`
   - `numbers` variable (line ~42) → Should show type `List[Int]`
   - `doubled` variable (line ~43) → Should show type `List[Int]`

**Expected**: Tooltip appears showing the inferred type and documentation.

### Test 2: Go to Definition

1. In `examples/HelloWorld.scala`
2. Click on these symbols (usually Ctrl+Click or Cmd+Click):
   - `greet` function call (line ~34) → Jumps to definition at line ~18
   - `factorial` function call (line ~38) → Jumps to definition at line ~27
   - `Person` class (line ~64) → Jumps to definition at line ~56

**Expected**: Cursor jumps to the definition of the symbol.

### Test 3: Find References

1. Right-click on `introduce` method (line ~57)
2. Select "Find References" or use keyboard shortcut
3. Should show all usages:
   - Line 57: method definition
   - Line 65: first call (alice.introduce())
   - Line 69: second call (bob.introduce())

**Expected**: List of all references to the method.

### Test 4: Document Symbols

1. Open `examples/AdvancedFeatures.scala`
2. Use "Go to Symbol" feature (usually Ctrl+Shift+O or Cmd+Shift+O)
3. Should see outline of all symbols:
   - trait Show
   - object Show
   - sealed trait Shape
   - case classes: Circle, Rectangle, Triangle
   - object ShapeCalculator
   - etc.

**Expected**: Hierarchical list of all symbols in the file.

### Test 5: Diagnostics (Errors & Warnings)

1. Open `examples/TestDiagnostics.scala`
2. Uncomment the "ERROR 1: Type mismatch" section
3. Save the file

**Expected**:
- Red underline appears under line with type mismatch
- Error message shows: "type mismatch; found: Int(42) required: String"

4. Fix the error by changing `42` to `"42"`
5. Save the file

**Expected**:
- Red underline disappears
- No errors shown

### Test 6: Real-time Error Detection

1. Open `examples/HelloWorld.scala`
2. Edit line 34, change:
   ```scala
   val message = greet("Claude")
   ```
   to:
   ```scala
   val message = greet(42)  // Wrong type!
   ```

**Expected**:
- Error appears immediately (or within a few seconds)
- Shows: "type mismatch; found: Int(42) required: String"

3. Fix it back to `greet("Claude")`

**Expected**:
- Error disappears

### Test 7: Advanced Type Inference

1. Open `examples/AdvancedFeatures.scala`
2. Hover over these elements:
   - `areas` variable (line ~92) → Should show `List[Double]`
   - `result` variable (line ~95) → Should show `List[Shape]`
   - `doubled` variable (line ~102) → Should show `Container[Int]`
   - `addOneThenDouble` (line ~107) → Should show `Int => Int`

**Expected**: Complex inferred types are displayed correctly.

## Step 5: Performance Testing

### Test Large File Handling

1. Create a large Scala file:
   ```bash
   # Generate a file with many classes
   for i in {1..100}; do
     echo "case class TestClass$i(value: Int)" >> examples/LargeFile.scala
   done
   ```

2. Open `examples/LargeFile.scala`
3. Test hover and go-to-definition still work

**Expected**: LSP features work even with larger files.

### Test Multiple Files

1. Open multiple Scala files simultaneously:
   - `examples/HelloWorld.scala`
   - `examples/AdvancedFeatures.scala`
   - `examples/TestDiagnostics.scala`

2. Test LSP features in each file

**Expected**: All features work across all open files.

## Step 6: Error Scenarios

### Test Invalid Scala Code

Create a file with severe syntax errors:

```scala
// examples/Broken.scala
object Broken {
  def broken( = {
    val x
    println(
  }
```

**Expected**:
- Multiple error markers appear
- Error messages help identify issues
- LSP server doesn't crash

### Test LSP Server Recovery

1. Kill the Metals process manually:
   ```bash
   pkill -9 metals
   ```

2. Make an edit to a Scala file

**Expected**:
- Metals automatically restarts (up to 5 times, per `maxRestarts` in `.lsp.json`)
- LSP features resume working

## Troubleshooting

### Issue: "No LSP server available"

**Solutions**:
1. Check Metals is installed: `which metals`
2. Check Java is installed: `java -version`
3. Review `.lsp.json` configuration
4. Check Claude Code logs for error messages

### Issue: LSP Features Not Working

**Solutions**:
1. Wait for build import to complete (first time: 10-15 minutes)
2. Check Claude Code console for Metals status
3. Verify file has `.scala` extension
4. Restart Claude Code

### Issue: Slow Performance

**Solutions**:
1. First-time build import is slow - be patient
2. Subsequent loads are much faster
3. Close unused files
4. Check system resources (CPU/memory)

### Issue: Type Information Not Showing

**Solutions**:
1. Ensure Metals has finished indexing
2. Save the file to trigger re-analysis
3. Check if build.sbt is valid
4. Try restarting LSP server

## Success Criteria

✅ **Plugin is working correctly if**:

1. Opening `.scala` files doesn't show "No LSP server available"
2. Hovering over variables shows type information
3. Go-to-definition navigates correctly
4. Errors appear in real-time when you introduce them
5. Find references shows all usages
6. Document symbols shows file outline

## Next Steps

Once testing is complete:

1. **Commit your changes**:
   ```bash
   git add .
   git commit -m "Add Metals Scala LSP plugin for Claude Code"
   ```

2. **Push to remote**:
   ```bash
   git push -u origin claude/metals-scala-lsp-plugin-XI45q
   ```

3. **Share the plugin**:
   - Create a GitHub repository
   - Add documentation
   - Share with the community

## Additional Resources

- [Metals Documentation](https://scalameta.org/metals/)
- [LSP Specification](https://microsoft.github.io/language-server-protocol/)
- [Claude Code Documentation](https://code.claude.com/docs/)
- [Scala Documentation](https://docs.scala-lang.org/)

## Feedback

If you encounter issues with the plugin:
1. Check the troubleshooting section above
2. Review Claude Code logs
3. Check Metals logs (usually in `.metals/` directory)
4. Report issues to the Claude Code team using `/feedback`

Happy testing! 🎉
