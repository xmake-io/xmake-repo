package("json-c")
    set_homepage("https://github.com/json-c/json-c/wiki")
    set_description("JSON parser for C")
    set_license("MIT")

    add_urls("https://github.com/json-c/json-c.git")
    add_urls("https://github.com/json-c/json-c/archive/refs/tags/json-c-$(version).tar.gz", {
        version = function (version)
        local list =  {
            ["0.17"] = "20230812",
	        ["0.18"] = "20240915",
        }
        return version .. "-" .. list[tostring(version)]
    end})

    add_versions("0.17", "024d302a3aadcbf9f78735320a6d5aedf8b77876c8ac8bbb95081ca55054c7eb")
    add_versions("0.18", "3112c1f25d39eca661fe3fc663431e130cc6e2f900c081738317fba49d29e298")

    add_deps("cmake")

    on_install(function (package)
        if package:config("shared") and package:is_plat("windows") then
            package:add("defines", "JSON_EXPORT=__declspec(dllimport)")
        end

        local configs = {"-DBUILD_TESTING=OFF", "-DBUILD_APPS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_STATIC_LIBS=" .. (package:config("shared") and "OFF" or "ON"))
        if package:config("pic") ~= false then
            table.insert(configs, "-DCMAKE_POSITION_INDEPENDENT_CODE=ON")
            table.insert(configs, "-DDISABLE_STATIC_FPIC=OFF")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("json_object_new_object", {includes = "json-c/json.h"}))
    end)
