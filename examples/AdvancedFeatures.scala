package examples

/**
 * Advanced Scala features to test Metals LSP capabilities.
 *
 * This file demonstrates:
 * - Implicit parameters and conversions
 * - Type classes
 * - Higher-order functions
 * - Pattern matching
 * - For comprehensions
 */

// Type class example
trait Show[A] {
  def show(a: A): String
}

object Show {
  // Implicit instances
  implicit val intShow: Show[Int] = (a: Int) => s"Int($a)"
  implicit val stringShow: Show[String] = (a: String) => s"String($a)"

  // Syntax extension
  implicit class ShowOps[A](a: A) {
    def show(implicit s: Show[A]): String = s.show(a)
  }
}

// Sealed trait for algebraic data types
sealed trait Shape
case class Circle(radius: Double) extends Shape
case class Rectangle(width: Double, height: Double) extends Shape
case class Triangle(base: Double, height: Double) extends Shape

object ShapeCalculator {
  /**
   * Calculate area of a shape.
   * Test exhaustiveness checking in pattern matching.
   */
  def area(shape: Shape): Double = shape match {
    case Circle(r) => Math.PI * r * r
    case Rectangle(w, h) => w * h
    case Triangle(b, h) => 0.5 * b * h
  }

  /**
   * Calculate perimeter of a shape.
   * Hover over the return type to see inference.
   */
  def perimeter(shape: Shape): Double = shape match {
    case Circle(r) => 2 * Math.PI * r
    case Rectangle(w, h) => 2 * (w + h)
    case Triangle(_, _) => 0.0 // Simplified
  }
}

// Generic container with type parameters
class Container[+A](val value: A) {
  def map[B](f: A => B): Container[B] = new Container(f(value))

  def flatMap[B](f: A => Container[B]): Container[B] = f(value)

  override def toString: String = s"Container($value)"
}

object Container {
  def apply[A](value: A): Container[A] = new Container(value)
}

// Testing higher-order functions
object FunctionalExamples {

  /**
   * Compose two functions.
   * Test type inference on generic functions.
   */
  def compose[A, B, C](f: B => C, g: A => B): A => C =
    (a: A) => f(g(a))

  /**
   * Apply a function n times.
   */
  def applyN[A](f: A => A, n: Int)(a: A): A = {
    if (n <= 0) a
    else applyN(f, n - 1)(f(a))
  }

  /**
   * Test currying and partial application.
   */
  def add(x: Int)(y: Int): Int = x + y

  val add5 = add(5) _ // Partial application
}

// Main object to test features
object AdvancedFeaturesDemo {
  import Show._

  def main(args: Array[String]): Unit = {
    // Test type class
    println(42.show)
    println("Hello".show)

    // Test shapes
    val shapes = List(
      Circle(5.0),
      Rectangle(4.0, 6.0),
      Triangle(3.0, 4.0)
    )

    // Test map with type inference
    val areas = shapes.map(ShapeCalculator.area)
    println(s"Areas: $areas")

    // Test for comprehension
    val result = for {
      shape <- shapes
      if ShapeCalculator.area(shape) > 50
    } yield shape

    println(s"Large shapes: $result")

    // Test container
    val container = Container(42)
    val doubled = container.map(_ * 2)
    println(doubled)

    // Test function composition
    val addOne = (x: Int) => x + 1
    val double = (x: Int) => x * 2
    val addOneThenDouble = FunctionalExamples.compose(double, addOne)
    println(s"addOneThenDouble(5) = ${addOneThenDouble(5)}")

    // Test partial application
    println(s"add5(10) = ${FunctionalExamples.add5(10)}")
  }
}

// Try introducing errors to test diagnostics:
// 1. Remove a case from pattern matching in ShapeCalculator.area
// 2. Call a method with wrong argument types
// 3. Reference an undefined variable
// 4. Add a syntax error like missing parenthesis
