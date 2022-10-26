package("openjpeg")

    set_homepage("http://www.openjpeg.org/")
    set_description("OpenJPEG is an open-source JPEG 2000 codec written in C language.")
    set_license("BSD-2-Clause")

    add_urls("https://github.com/uclouvain/openjpeg/archive/refs/tags/$(version).tar.gz",
             "https://github.com/uclouvain/openjpeg.git")
    add_versions("v2.3.1", "63f5a4713ecafc86de51bfad89cc07bb788e9bba24ebbf0c4ca637621aadb6a9")
    add_versions("v2.4.0", "8702ba68b442657f11aaeb2b338443ca8d5fb95b0d845757968a7be31ef7f16d")
    add_versions("v2.5.0", "0333806d6adecc6f7a91243b2b839ff4d2053823634d4f6ed7a59bc87409122a")
    add_patches("v2.5.0", path.join(os.scriptdir(), "patches", "2.5.0", "build.patch"), "0842372f2f8c941865edeb5ac98b9a05cfa59e66fd6f16e3e014866a6965a7d6")

    add_deps("cmake")
    add_deps("lcms", "libtiff", "libpng")
    if is_plat("linux") then
        add_syslinks("pthread")
    end

    on_load("windows", "linux", "macosx", function (package)
        local ver = package:version():major() .. "." .. package:version():minor()
        package:add("includedirs", "include/openjpeg-" .. ver)
        if package:is_plat("windows") and not package:config("shared") then
            package:add("defines", "OPJ_STATIC")
        end
    end)

    on_install("windows", "linux", "macosx", function (package)
        local configs = {"-DBUILD_TESTING=OFF", "-DBUILD_DOC=OFF", "-DBUILD_CODEC=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_STATIC_LIBS=" .. (package:config("shared") and "OFF" or "ON"))
        import("package.tools.cmake").install(package, configs)
        package:addenv("PATH", "bin")

        -- fix cmake import files
        local ver = package:version():major() .. "." .. package:version():minor()
        io.gsub(package:installdir("lib", "openjpeg-" .. ver, "OpenJPEGConfig.cmake"), "set%(INC_DIR .-%)", format("set(INC_DIR ${SELF_DIR}/../../include/openjpeg-%s)", ver))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("opj_version", {includes = "openjpeg.h"}))
    end)
