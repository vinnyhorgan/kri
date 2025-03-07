project "lpeg"
  kind "StaticLib"
  language "C"
  staticruntime "on"

  targetdir "%{wks.location}/vendor/%{prj.name}/bin/%{cfg.buildcfg}"
  objdir "%{wks.location}/vendor/%{prj.name}/obj/%{cfg.buildcfg}"

  files { "*.h", "*.c" }

  includedirs { "../lua" }

  filter "system:windows"
    disablewarnings { "4244", "4267" }

  filter "configurations:debug"
    defines { "LPEG_DEBUG" }
    symbols "on"

  filter "configurations:release"
    optimize "on"
