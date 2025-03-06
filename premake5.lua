workspace "kri"
  configurations { "debug", "release" }
  architecture "x86_64"
  location "build"

group "vendor"
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
    "vendor/lua",
    "vendor/miniz"
  }

  links {
    "lua",
    "miniz"
  }

  filter "system:linux"
    links { "m" }

  filter "configurations:debug"
    symbols "on"

  filter "configurations:release"
    optimize "on"
