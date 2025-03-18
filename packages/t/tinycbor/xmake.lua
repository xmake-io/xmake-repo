package("tinycbor")
    set_homepage("https://github.com/intel/tinycbor")
    set_description("Concise Binary Object Representation (CBOR) Library")
    set_license("MIT")

    add_urls("https://github.com/intel/tinycbor/archive/refs/tags/$(version).tar.gz",
             "https://github.com/intel/tinycbor.git")

    add_versions("v0.6.1", "0f9944496d1143935e9c996bc6233ca0dd5451299def33ef400a409942f8f34b")
    add_versions("v0.6.0", "512e2c9fce74f60ef9ed3af59161e905f9e19f30a52e433fc55f39f4c70d27e4")

    add_configs("float", {description = "Enable floating point data type.", default = true, type = "boolean"})
    add_configs("cmake", {description = "Use cmake build system", default = false, type = "boolean"})

    on_load(function (package)
        if (package:gitref() or package:version():gt("0.6.1")) and package:config("cmake") then
            package:add("deps", "cmake")
            if not package:config("shared") then
                package:add("defines", "CBOR_STATIC_DEFINE")
            end
        end
        if package:is_plat("mingw") and package:is_arch("i386") then
            -- Only work with gcc >= 14
            package:config_set("float", false)
            wprint("package(tinycbor) disable config(float) on mingw/i386")
        end
    end)

    on_install(function (package)
        local configs = {}
        if package:config("cmake") then
            io.replace("CMakeLists.txt", "add_subdirectory(tests)", "", {plain = true})
            io.replace("CMakeLists.txt", "include(PackageConfig)", "", {plain = true})

            table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
            table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
            import("package.tools.cmake").install(package, configs)
        else
            os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
            import("package.tools.xmake").install(package, {enable_float = package:config("float")})

            if package:is_plat("windows") and package:config("shared") then
                io.replace(path.join(package:installdir("include"), "cbor.h"), "define CBOR_API", "define CBOR_API __declspec(dllimport)", {plain = true})
            end
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("cbor_encoder_init", {includes = "cbor.h"}))
    end)
