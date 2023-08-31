package("openvr")

    set_homepage("https://www.steamvr.com/")
    set_description("OpenVR SDK")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/ValveSoftware/openvr/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ValveSoftware/openvr.git")
    add_versions("v1.26.7", "e7391f1129db777b2754f5b017cfa356d7811a7bcaf57f09805b47c2e630a725")

    add_deps("cmake")
    if is_plat("windows") then
        add_syslinks("shell32")
    end
    on_load("windows", function (package)
        if not package:config("shared") then
            package:add("defines", "OPENVR_BUILD_STATIC")
        end
    end)

    on_install("windows", "macosx", "linux", function (package)
        local configs = {"-DUSE_LIBCXX=OFF", "-DBUILD_UNIVERSAL=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                vr::EVRInitError eError = vr::VRInitError_None;
	            vr::IVRSystem *m_pHMD = vr::VR_Init(&eError, vr::VRApplication_Scene);
            }
        ]]}, {configs = {languages = "c++11"}, includes = "openvr/openvr.h"}))
    end)
