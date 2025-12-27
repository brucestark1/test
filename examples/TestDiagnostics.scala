package examples

/**
 * This file contains intentional errors to test Metals LSP diagnostics.
 *
 * When Metals is running, you should see red underlines and error messages
 * for the problems below.
 *
 * To test:
 * 1. Open this file with Metals running
 * 2. Observe the diagnostics (errors and warnings)
 * 3. Fix the errors one by one
 * 4. Watch diagnostics update in real-time
 */
object TestDiagnostics {

  // CORRECT CODE - No errors
  def workingFunction(x: Int): Int = x * 2

  // TODO: Uncomment the sections below to test diagnostics

  /*
  // ERROR 1: Type mismatch
  def typeMismatch(): String = {
    42 // Should return String, not Int
  }

  // ERROR 2: Undefined variable
  def undefinedVar(): Unit = {
    println(nonExistentVariable)
  }

  // ERROR 3: Wrong number of arguments
  def wrongArgs(): Unit = {
    workingFunction(1, 2) // workingFunction takes 1 argument, not 2
  }

  // ERROR 4: Syntax error - missing closing brace
  def syntaxError(): Unit = {
    val x = 10
    if (x > 5) {
      println("Greater")
    // Missing closing brace
  }

  // ERROR 5: Non-exhaustive pattern match
  def nonExhaustiveMatch(x: Option[Int]): String = x match {
    case Some(n) => s"Value: $n"
    // Missing None case - should trigger warning
  }

  // ERROR 6: Unreachable code
  def unreachableCode(): Int = {
    return 42
    println("This is unreachable") // Warning: unreachable code
    10
  }

  // ERROR 7: Unused import
  import scala.collection.mutable.ArrayBuffer // Warning: unused import

  // ERROR 8: Value not used
  def unusedValue(): Unit = {
    val x = 42 // Warning: value is never used
  }
  */

  // CORRECT: Fixed version of the above
  def correctTypedFunction(): String = {
    "42" // Returns String as expected
  }

  def correctVariable(): Unit = {
    val existentVariable = 10
    println(existentVariable)
  }

  def correctArgs(): Unit = {
    workingFunction(1) // Correct: 1 argument
  }

  def correctSyntax(): Unit = {
    val x = 10
    if (x > 5) {
      println("Greater")
    } // Properly closed
  }

  def exhaustiveMatch(x: Option[Int]): String = x match {
    case Some(n) => s"Value: $n"
    case None => "No value"
  }

  def reachableCode(): Int = {
    println("This is reachable")
    42 // Return at the end
  }

  def usedValue(): Unit = {
    val x = 42
    println(x) // Value is used
  }

  def main(args: Array[String]): Unit = {
    println("=== Testing Metals Diagnostics ===")
    println("1. Uncomment error sections to see diagnostics")
    println("2. Fix errors and watch diagnostics update")
    println("3. Hover over errors to see error messages")

    // Test the correct functions
    println(correctTypedFunction())
    correctVariable()
    correctArgs()
    println(exhaustiveMatch(Some(42)))
    println(reachableCode())
  }
}
