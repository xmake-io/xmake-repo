package("johnnyengine")

  set_homepage("https://github.com/PucklaMotzer09/JohnnyEngine")
  set_description("A 2D/3D Engine using OpenGL and SDL for input and the window")

  add_urls("https://github.com/PucklaMotzer09/JohnnyEngine/archive/refs/tags/$(version).zip",
           "https://github.com/PucklaMotzer09/JohnnyEngine.git")
  add_versions("1.0.1", "1495d35c84e0141c757d0ea3adf557671c8f4ed4f5680123138d3b77b75de560")

  add_deps("glew", "libsdl", "libsdl_ttf", "libsdl_mixer", "libsdl_gfx", "box2d", "assimp", "stb", "tmxparser")

  on_install("windows", "linux", "macosx", function (package)
    if package:config("shared") then
      io.gsub("xmake.lua", "static", "shared")
    end
    import("package.tools.xmake").install(package)
  end)

  on_test(function (package)
    assert(package:check_cxxsnippets({test = [[
    using namespace Johnny;

    class Game : public MainClass {
    public:
      Game() {}
      ~Game() {}

      bool init() override { return true; }
      bool update() override { return true; }
      bool render() override { return true; }
      void quit() override {}
    };

    void test(int argc, char** argv) {
      Vector2<double> v2(1.0, 2.0);
      auto m4(Matrix4<float>::identity());
      Rectangle<int> r(1, 2, 3, 4);
      Game().run();
    }
  ]]}, {configs = {languages = "cxx11"}, includes = "Johnny.h"}))
  end)
