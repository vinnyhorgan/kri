workspace "kri"
  configurations { "Debug", "Release" }
  architecture "x86_64"
  location "build"

project "kri"
  kind "ConsoleApp"
  language "C"
  targetdir "build/bin/%{cfg.buildcfg}"

  files { "src/**.h", "src/**.c" }

  filter "configurations:Debug"
    defines { "DEBUG" }
    symbols "On"

  filter "configurations:Release"
    defines { "NDEBUG" }
    optimize "On"
