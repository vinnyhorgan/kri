project "embed"
  kind "ConsoleApp"
  language "C"
  staticruntime "on"

  targetdir "%{wks.location}/tools/%{prj.name}/bin/%{cfg.buildcfg}"
  objdir "%{wks.location}/tools/%{prj.name}/obj/%{cfg.buildcfg}"

  files { "*.c" }

  includedirs {
    "../../vendor/libuv/include",
    "../../vendor/miniz"
  }

  links {
    "libuv",
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

  filter "configurations:debug"
    symbols "on"

  filter "configurations:release"
    optimize "on"
