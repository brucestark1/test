name := "metals-scala-lsp-plugin"

version := "1.0.0"

scalaVersion := "2.13.12"

// Scala compiler options
scalacOptions ++= Seq(
  "-deprecation",
  "-encoding", "utf-8",
  "-feature",
  "-unchecked"
)

// Dependencies (optional, for testing)
libraryDependencies ++= Seq(
  "org.scalatest" %% "scalatest" % "3.2.17" % Test
)
