package("xquic")
    set_homepage("https://github.com/alibaba/xquic")
    set_description("A client and server implementation of QUIC and HTTP/3 as specified by the IETF")
    set_license("Apache-2.0")

    add_urls("https://github.com/alibaba/xquic.git")
    add_versions("2022.01.08", "837c493d51952cd842b815f7d60c88efbad3b9eb")

    add_deps("cmake", "boringssl")

    on_install("linux", "macosx", function (package)
        local configs = {"-DSSL_TYPE=boringssl"}
        if package:is_plat("macosx") then
            table.insert(configs, "-DPLATFORM=mac")
        end
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        io.replace("CMakeLists.txt", "${SSL_LIB_PATH}", "", {plain = true})
        io.replace("CMakeLists.txt", "-Werror", "", {plain = true})
        io.replace("CMakeLists.txt", "include_directories(${SSL_INC_PATH})", "", {plain = true})
        import("package.tools.cmake").install(package, configs, {buildir = "build", packagedeps = "boringssl"})
        os.cp("include", package:installdir())
        if package:config("shared") then
            if package:is_plat("macosx") then
                os.cp("build/*.dylib", package:installdir("lib"))
            else
                os.cp("build/*.so", package:installdir("lib"))
            end
        else
            os.cp("build/*.a", package:installdir("lib"))
        end

    end)

    on_test(function (package)
        assert(package:has_cfuncs("xqc_engine_main_logic", {includes = "xquic/xquic.h"}))
    end)
