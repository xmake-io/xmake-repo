package("cimg")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/greyclab/cimg")
    set_description("Small and open-source C++ toolkit for image processing")
    set_license("CeCILL-C")

    add_urls("https://github.com/greyclab/cimg/archive/refs/tags/$(version).tar.gz", {version = function(version)
        return version:gsub("%v", "v.")
    end})
    add_urls("https://github.com/greyclab/cimg.git")

    add_versions("v3.4.1", "ea8bc2186142eb59fbb391b0debfc4150f839a0b39552bc8093225cf02eda335")
    add_versions("v3.4.0", "987bddc3a98ec684c2ffc7968881adb2626f5b09c90e6102947b3c4acd0de931")
    add_versions("v3.3.6", "7bb6621c38458152f3d1cae3f020e4ca6a314076cb7b4b5d6bbf324ad3d0ab88")
    add_versions("v3.2.6", "1fcca9a7a453aa278660c10d54c6db9b4c614b6a29250adeb231e95a0be209e7")

    if is_plat("windows") then
        add_syslinks("gdi32", "shell32", "user32")
    elseif is_plat("linux") then
        add_syslinks("pthread")
    elseif is_plat("macosx") then
        add_syslinks("m", "pthread")
    end

    on_install("windows", "linux", "macosx", "android", "mingw", "cygwin", "bsd", "cross", function (package)
        os.cp("CImg.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            int main() {
                cimg_library::CImg<unsigned char> img{ 128, 128, 1, 3 };
                img.fill(32);
                img.noise(128);
            }
        ]]}, {configs = {languages = "c++11", defines = "cimg_display=0"}, includes = "CImg.h"}))
    end)
