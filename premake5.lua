workspace "kri"
  configurations { "debug", "release" }
  architecture "x86_64"
  location "build"

group "vendor"
  include "vendor/lua"
group ""

project "kri"
  kind "ConsoleApp"
  language "C"
  staticruntime "on"

  targetdir "%{wks.location}/bin/%{cfg.buildcfg}"
  objdir "%{wks.location}/obj/%{cfg.buildcfg}"

  files { "src/**.h", "src/**.c" }

  includedirs { "vendor/lua" }

  links { "lua" }

  filter "configurations:debug"
    symbols "on"

  filter "configurations:release"
    optimize "on"
