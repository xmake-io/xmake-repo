package("llhttp")
    set_homepage("https://github.com/nodejs/llhttp")
    set_description("Port of http_parser to llparse")
    set_license("MIT")

    add_urls("https://github.com/nodejs/llhttp/archive/refs/tags/release/$(version).tar.gz")

    add_versions("v9.3.0", "1a2b45cb8dda7082b307d336607023aa65549d6f060da1d246b1313da22b685a")
    add_versions("v9.2.1", "3c163891446e529604b590f9ad097b2e98b5ef7e4d3ddcf1cf98b62ca668f23e")
    add_versions("v8.1.0", "9da0d23453e8e242cf3b2bc5d6fb70b1517b8a70520065fcbad6be787e86638e")
    add_versions("v3.0.0", "02931556e69f8d075edb5896127099e70a093c104a994a57b4d72c85b48d25b0")


    on_load(function (package)
        if package:version():ge("9.2.1") then
            package:add("deps", "cmake")
        end
    end)

    on_install(function (package)
        io.replace("include/llhttp.h", "__wasm__", "__GNUC__", {plain = true})
        io.replace("include/llhttp.h", "_WIN32", "_MSC_VER", {plain = true})
        if not package:config("shared") then
            io.replace("include/llhttp.h", "__declspec(dllexport)", "", {plain = true})
        end

        local xmake_configs = {}
        if package:version():ge("9.2.1") then
            -- Get cmake config file
            local configs = {}
            local opt = {}
            if package:is_plat("cross") then
                opt.cflags = {"-flax-vector-conversions"}
            end
            table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
            table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
            table.insert(configs, "-DBUILD_STATIC_LIBS=" .. (package:config("shared") and "OFF" or "ON"))
            import("package.tools.cmake").install(package, configs, opt)
        else
            xmake_configs.export_symbol = true
        end
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package, xmake_configs)

        if package:config("shared") then
            io.replace(package:installdir("include/llhttp.h"), "__declspec(dllexport)", "__declspec(dllimport)", {plain = true})
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("llhttp_init", {includes = "llhttp.h"}))
    end)
