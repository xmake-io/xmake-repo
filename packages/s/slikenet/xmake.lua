package("slikenet")
    set_homepage("https://www.slikenet.com/")
    set_description("SLikeNet™ is an Open Source/Free Software cross-platform network engine written in C++ and specifially designed for games (and applications which have comparable requirements on a network engine like games) building upon the discontinued RakNet network engine which had more than 13 years of active development.")
    set_license("MIT")

    add_urls("https://github.com/SLikeSoft/SLikeNet.git")
    add_versions("2021.07.01", "d5f775d789563a2d505e2afbf99a550d990bb49e")

    add_patches("2021.07.01", "patches/2021.07.01/fix-emscripten.patch", "ee6720cd12d81bb89355b63e40fbdcca739b051af9f4fa2c5ad7846bd8cd13e7")
    add_patches("2021.07.01", "patches/2021.07.01/fix-install.patch", "7f1307651bbf7fdff4cedf1b0301521275d83a060361ffc896065254c9908953")

    add_deps("cmake")
    add_deps("openssl")

    on_install(function (package)
        os.rmdir("Source/src/crypto")
        os.rmdir("Source/include/slikenet/crypto")
        local configs = {"-DSLIKENET_ENABLE_SAMPLES=OFF"}
        table.insert(configs, "-DSLIKENET_ENABLE_DLL=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DSLIKENET_ENABLE_STATIC=" .. (package:config("shared") and "OFF" or "ON"))
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <slikenet/TCPInterface.h>
            using namespace SLNet;
            void test() {
                TCPInterface *g = TCPInterface::GetInstance();
                g->Stop();
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
