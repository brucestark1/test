package examples

/**
 * A simple Hello World example to test Metals LSP integration.
 *
 * Test the following LSP features:
 * 1. Hover over variables to see type information
 * 2. Click on method names to go to definition
 * 3. Introduce syntax errors to test diagnostics
 * 4. Use find references on methods
 */
object HelloWorld {

  /**
   * Greets a person by name.
   * @param name The name of the person to greet
   * @return A greeting message
   */
  def greet(name: String): String = {
    s"Hello, $name! Welcome to Scala with Metals LSP."
  }

  /**
   * Calculates the factorial of a number.
   * @param n The number to calculate factorial for
   * @return The factorial of n
   */
  def factorial(n: Int): Int = {
    if (n <= 1) 1
    else n * factorial(n - 1)
  }

  /**
   * Main entry point.
   * Try hovering over variables to see their inferred types!
   */
  def main(args: Array[String]): Unit = {
    // Hover over 'message' to see its type (String)
    val message = greet("Claude")
    println(message)

    // Hover over 'result' to see its type (Int)
    val result = factorial(5)
    println(s"Factorial of 5 is: $result")

    // Test with a list - hover to see type inference
    val numbers = List(1, 2, 3, 4, 5)
    val doubled = numbers.map(_ * 2)
    println(s"Doubled numbers: $doubled")

    // Test pattern matching
    val value = 42
    value match {
      case 0 => println("Zero")
      case n if n > 0 => println(s"Positive: $n")
      case _ => println("Negative")
    }
  }
}

// Test class for LSP features
case class Person(name: String, age: Int) {
  def introduce(): String = s"Hi, I'm $name and I'm $age years old"
}

object PersonExample {
  def main(args: Array[String]): Unit = {
    // Create a person - test go-to-definition on Person
    val alice = Person("Alice", 30)
    println(alice.introduce())

    // Test find references on 'introduce' method
    val bob = Person("Bob", 25)
    println(bob.introduce())
  }
}
