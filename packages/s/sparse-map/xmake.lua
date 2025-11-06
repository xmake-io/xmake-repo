package("sparse-map")

    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/Tessil/sparse-map")
    set_description("C++ implementation of a memory efficient hash map and hash set")
    set_license("MIT")

    add_urls("https://github.com/Tessil/sparse-map/archive/refs/tags/$(version).tar.gz",
             "https://github.com/Tessil/sparse-map.git")

    add_versions("v0.7.0", "b603a24f596f95a06ec1d437f4cb928c2647cf9bc73b751ac6fb82deb7863d98")
    add_versions("v0.6.2", "7020c21e8752e59d72e37456cd80000e18671c803890a3e55ae36b295eba99f6")

    on_install("windows|x86", "windows|x64", "linux", "macosx", "bsd", "mingw", "msys", "android", "iphoneos", "cross", function (package)
        os.cp("include/*", package:installdir("include"))
    end)

    on_test(function (package)
      assert(package:check_cxxsnippets({test = [[
          #include "tsl/sparse_map.h"

          void test() {
              tsl::sparse_map<int, int> map = {{1, 1}, {2, 1}, {3, 1}};
              for(auto it = map.begin(); it != map.end(); ++it) {
                  it.value() = 2;
              }
          }
      ]]}, {configs = {languages = "cxx11"}}))
  end)
