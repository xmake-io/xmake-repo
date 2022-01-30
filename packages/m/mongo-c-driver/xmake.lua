package("mongo-c-driver")

    set_homepage("http://mongoc.org/")
    set_description("The MongoDB C Driver.")
    set_license("Apache-2.0")

    add_urls("https://github.com/mongodb/mongo-c-driver/archive/$(version).zip",
             "https://github.com/mongodb/mongo-c-driver.git")
    add_versions("1.20.1", "3a856e1c40b02fc5160cb7b39594d654f3076eeb671829b867971e7d35ed497c")
    add_versions("1.19.0", "3e545964ee82ee60afe4213852208e6174297b19d6b837eca3c711af34a4b107")

    add_deps("cmake")
    if is_plat("macosx", "linux") then
        add_deps("openssl")
    end

    add_includedirs("include/libbson-1.0")
    add_includedirs("include/libmongoc-1.0")

    on_install("windows", "linux", "macosx", function (package)
        local configs = {"-DENABLE_AUTOMATIC_INIT_AND_CLEANUP=OFF",
                        "-DENABLE_ICU=OFF",
                        "-DENABLE_TESTS=OFF",
                        "-DENABLE_EXAMPLES=OFF"}
        if package:is_plat("windows") then 
            table.insert(configs, "-DENABLE_EXTRA_ALIGNMENT=0")    
        end
        table.insert(configs, "-DBUILD_VERSION=" .. package:version())
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "RelWithDebInfo"))
        table.insert(configs, "-DENABLE_STATIC=" .. (package:config("shared") and "OFF" or "BUILD_ONLY"))
        table.insert(configs, "-DENABLE_STATIC_BUILD=" .. (package:config("shared") and "OFF" or "BUILD_ONLY"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("mongoc_init", {includes = "mongoc/mongoc.h"}))
    end)
