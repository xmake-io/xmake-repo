package("witty")
    set_homepage("http://www.webtoolkit.eu/wt")
    set_description("Wt, C++ Web Toolkit")

    add_urls("https://github.com/emweb/wt/archive/refs/tags/$(version).tar.gz",
             "https://github.com/emweb/wt.git")

    add_versions("4.11.4", "b42b9818e4c8ab8af835b0c88bda5c4f71ccfb38fd8baf90648064b0544eb564")

    add_deps("cmake")
    add_deps("boost", {
        configs = {
            algorithm = true, array = true, asio = true,
            bind = true, config = true, container_hash = true,
            filesystem = true, foreach = true, fusion = true,
            interprocess = true, lexical_cast = true, logic = true,
            math = true, multi_index = true, optional = true,
            phoenix = true, pool = true, program_options = true,
            range = true, serialization = true, smart_ptr = true,
            spirit = true, system = true, thread = true,
            tokenizer = true, tuple = true, ublas = true, variant = true
        }
    })
    add_deps("glew", "libharu", "libpng", "zlib")
    if not is_plat(windows) then
        add_deps("harfbuzz", "pango")
    end

    on_install(function (package)
        local configs = {
            "-DBUILD_EXAMPLES=OFF", "-DBUILD_TESTS=OFF", "-DCONNECTOR_HTTP=ON", "-DENABLE_HARU=ON",
            "-DENABLE_MYSQL=OFF", "-DENABLE_FIREBIRD=OFF", "-DENABLE_QT4=OFF", "-DENABLE_QT5=OFF",
            "-DENABLE_LIBWTTEST=ON", "-DENABLE_OPENGL=ON"
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DSHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DBOOST_DYNAMIC=" .. (package:dep("boost"):config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DHARU_DYNAMIC=" .. (package:dep("libharu"):config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("foo", {includes = "foo.h"}))
    end)
