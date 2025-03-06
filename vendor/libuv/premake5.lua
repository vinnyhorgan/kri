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

  filter "system:not windows"
    files {
      "src/unix/async.c",
      "src/unix/core.c",
      "src/unix/dl.c",
      "src/unix/fs.c",
      "src/unix/getaddrinfo.c",
      "src/unix/getnameinfo.c",
      "src/unix/loop-watcher.c",
      "src/unix/loop.c",
      "src/unix/pipe.c",
      "src/unix/poll.c",
      "src/unix/process.c",
      "src/unix/random-devurandom.c",
      "src/unix/signal.c",
      "src/unix/stream.c",
      "src/unix/tcp.c",
      "src/unix/thread.c",
      "src/unix/tty.c",
      "src/unix/udp.c"
    }

  filter "system:linux"
    defines { "_GNU_SOURCE" }

    files {
      "src/unix/proctitle.c",
      "src/unix/linux.c",
      "src/unix/procfs-exepath.c",
      "src/unix/random-getrandom.c",
      "src/unix/random-sysctl-linux.c"
    }

  filter "configurations:debug"
    symbols "on"

  filter "configurations:release"
    optimize "on"
