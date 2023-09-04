package("fdk-aac")
    set_homepage("https://sourceforge.net/projects/opencore-amr/")
    set_description("A standalone library of the Fraunhofer FDK AAC code from Android.")
    set_license("Apache-2.0")

    add_urls("https://github.com/mstorsjo/fdk-aac/archive/refs/tags/v$(version).tar.gz",
             "https://github.com/mstorsjo/fdk-aac.git")
    add_versions("2.0.0", "6e6c7921713788e31df655911e1d42620b057180b00bf16874f5d630e1d5b9a2")
    add_versions("2.0.1", "a4142815d8d52d0e798212a5adea54ecf42bcd4eec8092b37a8cb615ace91dc6")
    add_versions("2.0.2", "7812b4f0cf66acda0d0fe4302545339517e702af7674dd04e5fe22a5ade16a90")

    add_deps("cmake")

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:is_plat("android") then
            io.replace("libSBRdec/src/lpp_tran.cpp", "#ifdef __ANDROID__", "#if 0")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("aacEncOpen", {includes = "fdk-aac/aacenc_lib.h"}))
    end)
