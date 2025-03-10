workspace "kri"
  configurations { "release", "debug" }
  architecture "x86_64"
  location "build"

group "vendor"
  include "vendor/libuv"
  include "vendor/lpeg"
  include "vendor/lua"
  include "vendor/miniz"
group ""

group "tools"
  include "tools/embed"
group ""

project "kri"
  kind "ConsoleApp"
  language "C"
  staticruntime "on"

  dependson { "embed" }

  targetdir "%{wks.location}/bin/%{cfg.buildcfg}"
  objdir "%{wks.location}/obj/%{cfg.buildcfg}"

  files {
    "src/**.h",
    "src/**.c"
  }

  includedirs {
    "%{wks.location}",
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
    prebuildcommands {
      "%{wks.location}/tools/embed/bin/%{cfg.buildcfg}/embed.exe ../data %{wks.location}/data.h"
    }

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
    prebuildcommands {
      "%{wks.location}/tools/embed/bin/%{cfg.buildcfg}/embed ../data %{wks.location}/data.h"
    }

    links { "m" }

  filter "configurations:debug"
    symbols "on"

  filter "configurations:release"
    optimize "on"
