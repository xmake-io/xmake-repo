package("cimg")
    set_kind("library", {headeronly = true})
    set_homepage("https://cimg.eu/")
    set_description("Small and open-source C++ toolkit for image processing")
    set_license("CeCILL-C")

    add_urls("https://github.com/greyclab/cimg/archive/refs/tags/$(version).tar.gz", {version = function(version)
        return version:gsub("%v", "v.")
    end})
    add_urls("https://github.com/greyclab/cimg.git", {alias="git"})

    add_versions("v3.7.0", "795966120c828eceba48a0742866bf371c50b3ed51ba323d1752c74db944d4dc")
    add_versions("v3.6.6", "18606cfa9a03d0c9e58463f6f5f90db18d91ea7d17abf263d7fc16c1532ad3ac")
    add_versions("v3.6.5", "ea5dbc4f7f7dc7138d964d75e75f7bf88869ff6cfd1f544367b6fdd7355d9739")
    add_versions("v3.6.4", "50845fa3533d2a4e011b2f333a882b1ceaad3038a50b86308418e1b7320bb897")
    add_versions("v3.6.3", "6dd5aabbf1edf56f39d09cdb9d361dd526db0b9c0991f7bf8b1b2b489fa043ae")
    add_versions("v3.6.2", "e4ec8c103015903d5e66bc4d1cd39fb19e9d2f535c45917587668abc74226147")
    add_versions("v3.6.1", "63bf760fd98bde151f8cbb78be595aaf2b1d370eafa36fbd41b4cac2aa6ddc47")
    add_versions("v3.6.0", "95d623b36073519a1b4511601ede1abaa95127556ff83102e84db8bbde828569")
    add_versions("v3.5.5", "ffc8f0cf77e39cdae79d44de9aec7cf7edb83d787233388b5ad4b5c2475f4241")
    add_versions("v3.5.4", "f3102efc0803cb52693b43adf759579feb3dbc018506a8004af5e29b40649ffb")
    add_versions("v3.5.3", "4b45e413a76ede23cb164fea74b4adc92500a873cfd87dd66cf8c93ce57ab627")
    add_versions("v3.5.2", "6ece3344b65cfcc30b286df9c621a66634c3a79da0b5041b4e01e3b33f2d22f1")
    add_versions("v3.5.1", "41930b9ab4627a87140bacee8f98e97332df3f60993bd568b89f6ac5b7186e1f")
    add_versions("v3.5.0", "e23205a75b640423fdac394bd77b5e36a56070743892656fe6705597f38bfc3a")
    add_versions("v3.4.3", "87dc0a945a350222253d61dc680fdca3878b92827d63a47a6cb1e1b3772050e0")
    add_versions("v3.4.2", "d427168370301f6d288d9e1c69fcc48d9d4919e977ac5c2ec013ae6ac5613efb")
    add_versions("v3.4.1", "ea8bc2186142eb59fbb391b0debfc4150f839a0b39552bc8093225cf02eda335")
    add_versions("v3.4.0", "987bddc3a98ec684c2ffc7968881adb2626f5b09c90e6102947b3c4acd0de931")
    add_versions("v3.3.6", "7bb6621c38458152f3d1cae3f020e4ca6a314076cb7b4b5d6bbf324ad3d0ab88")
    add_versions("v3.2.6", "1fcca9a7a453aa278660c10d54c6db9b4c614b6a29250adeb231e95a0be209e7")

    add_versions("git:v3.7.0", "v.3.7.0")
    add_versions("git:v3.6.6", "v.3.6.6")
    add_versions("git:v3.6.5", "v.3.6.5")
    add_versions("git:v3.6.4", "v.3.6.4")
    add_versions("git:v3.6.3", "v.3.6.3")
    add_versions("git:v3.6.2", "v.3.6.2")
    add_versions("git:v3.6.1", "v.3.6.1")
    add_versions("git:v3.6.0", "v.3.6.0")
    add_versions("git:v3.5.5", "v.3.5.5")

    if is_plat("windows") then
        add_syslinks("gdi32", "shell32", "user32")
    elseif is_plat("linux") then
        add_syslinks("pthread")
    elseif is_plat("macosx") then
        add_syslinks("m", "pthread")
    end

    on_load("macosx", "mingw@macosx", function (package)
        if macos.version():lt("15") then
            package:add("cxxflags", "-msse2") -- macOS 14 needs this flag to support fp16
        end
    end)

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
