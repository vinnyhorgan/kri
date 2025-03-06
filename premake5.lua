workspace "kri"
  configurations { "debug", "release" }
  architecture "x86_64"
  location "build"

group "vendor"
  include "vendor/libuv"
  include "vendor/lua"
  include "vendor/miniz"
group ""

project "kri"
  kind "ConsoleApp"
  language "C"
  staticruntime "on"

  targetdir "%{wks.location}/bin/%{cfg.buildcfg}"
  objdir "%{wks.location}/obj/%{cfg.buildcfg}"

  files {
    "src/**.h",
    "src/**.c"
  }

  includedirs {
    "vendor/libuv/include",
    "vendor/lua",
    "vendor/miniz"
  }

  links {
    "libuv",
    "lua",
    "miniz"
  }

  filter "system:windows"
    links {
      "psapi",
      "user32",
      "advapi32",
      "iphlpapi",
      "userenv",
      "ws2_32",
      "dbghelp",
      "ole32",
      "shell32"
    }

  filter "system:linux"
    links { "m" }

  filter "configurations:debug"
    symbols "on"

  filter "configurations:release"
    optimize "on"
