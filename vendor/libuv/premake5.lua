project "libuv"
  kind "StaticLib"
  language "C"
  staticruntime "on"

  targetdir "%{wks.location}/vendor/%{prj.name}/bin/%{cfg.buildcfg}"
  objdir "%{wks.location}/vendor/%{prj.name}/obj/%{cfg.buildcfg}"

  files {
    "include/**.h",
    "src/*.h",
    "src/*.c"
  }

  includedirs { "include", "src" }

  filter "system:windows"
    defines { "_CRT_SECURE_NO_WARNINGS" }

    disablewarnings { "4244", "4267", "4334" }

    files {
      "src/win/*.h",
      "src/win/*.c"
    }

  filter "configurations:debug"
    symbols "on"

  filter "configurations:release"
    optimize "on"
