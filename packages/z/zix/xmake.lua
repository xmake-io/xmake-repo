package("zix")
    set_description("A lightweight C99 portability and data structure library")
    set_license("0BSD", "ISC")

    add_urls("https://gitlab.com/drobilla/zix/-/archive/v$(version)/zix-v$(version).tar.gz",
             "https://gitlab.com/drobilla/zix.git")

    add_versions("0.8.0", "51d70d63e970214db84e32d55377d84090c02145f5768265ab140d117f2b8e24")

    add_deps("meson", "ninja")

    on_install(function (package)
        local configs = {
            "-Dbenchmarks=disabled",
            "-Ddocs=disabled",
            "-Dtests=disabled",
			"-Dtests_cpp=disabled",
        }
		import("package.tools.meson").install(package, configs)
		package:add("includedirs", path.join("include", "zix-0"))
        if not package:config("shared") then
            package:add("defines", "ZIX_STATIC")
        end

    end)

    on_test(function (package)		
        assert(package:has_cfuncs("zix_strerror", {includes = "zix/status.h"}))
    end)