package("johnnyengine")

  set_homepage("https://github.com/PucklaMotzer09/JohnnyEngine")
  set_description("A 2D/3D Engine using OpenGL and SDL for input and the window")

  add_urls("https://github.com/PucklaMotzer09/JohnnyEngine/archive/refs/tags/$(version).zip",
           "https://github.com/PucklaMotzer09/JohnnyEngine.git")
  add_versions("1.0.1", "f4c02eb49f3c27095939f2655d2cf6adf2b6a36081dd7e16dfad79b737d1f964")

  add_deps("glew", "libsdl", "libsdl_ttf", "libsdl_mixer", "libsdl_gfx", "box2d", "assimp", "stb", "tmxparser")

  on_install("windows", "linux", "macosx", function (package)
    if package:config("shared") then
      io.gsub("xmake.lua", "static", "shared")
    end
    import("package.tools.xmake").install(package)
    os.mkdir(package:installdir("src"))
    os.cp("src/Geometry.cpp", package:installdir("src"))
    os.cp("src/Matrix*.cpp", package:installdir("src"))
    os.cp("src/Vector*.cpp", package:installdir("src"))
  end)

  on_test(function (package)
    assert(package:check_cxxsnippets({test = [[
    #include <Vector2.h>
    #include <Matrix4.h>
    #include <Geometry.h>
    void test(int argc, char** argv) {
      Johnny::Vector2<double> v2(1.0, 2.0);
      auto m4(Johnny::Matrix4<float>::identity());
      Johnny::Rectangle<int> r(1, 2, 3, 4);
    }
  ]]}, {configs = {languages = "cxx11"}, includes = "Johnny.h"}))
  end)
