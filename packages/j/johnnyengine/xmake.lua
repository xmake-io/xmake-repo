package("johnnyengine")

  set_homepage("https://github.com/PucklaMotzer09/JohnnyEngine")
  set_description("A 2D/3D Engine using OpenGL and SDL for input and the window")

  add_urls("https://github.com/PucklaMotzer09/JohnnyEngine/archive/refs/tags/$(version).zip",
           "https://github.com/PucklaMotzer09/JohnnyEngine.git")
  add_versions("1.0.1", "7841a3b9865db2b323395926a83384ad96285a3ab083e439afe2a3c6583b5510")

  add_deps("glew", "libsdl", "libsdl_ttf", "libsdl_mixer", "libsdl_gfx", "box2d", "assimp", "stb", "tmxparser")

  on_install("windows", "linux", "macosx", function (package)
    if package:config("shared") then
      io.gsub("xmake.lua", "static", "shared")
    end
    import("package.tools.xmake").install(package)
  end)
