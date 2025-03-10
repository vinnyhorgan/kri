project "lua"
  kind "StaticLib"
  language "C"
  staticruntime "on"

  targetdir "%{wks.location}/vendor/%{prj.name}/bin/%{cfg.buildcfg}"
  objdir "%{wks.location}/vendor/%{prj.name}/obj/%{cfg.buildcfg}"

  files { "*.h", "*.c" }

  filter "system:linux"
    defines { "LUA_USE_LINUX" }

  filter "configurations:debug"
    symbols "on"

  filter "configurations:release"
    optimize "on"
