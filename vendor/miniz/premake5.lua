project "miniz"
  kind "StaticLib"
  language "C"
  staticruntime "on"

  targetdir "%{wks.location}/vendor/%{prj.name}/bin/%{cfg.buildcfg}"
  objdir "%{wks.location}/vendor/%{prj.name}/obj/%{cfg.buildcfg}"

  defines { "MINIZ_NO_STDIO" }

  files { "*.h", "*.c" }

  filter "configurations:debug"
    symbols "on"

  filter "configurations:release"
    optimize "on"
