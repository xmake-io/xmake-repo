package("google-cloud-cpp")
    set_homepage("https://github.com/googleapis/google-cloud-cpp")
    set_description("C++ Client Libraries for Google Cloud Services")
    set_license("Apache-2.0")

    add_urls("https://github.com/googleapis/google-cloud-cpp/archive/refs/tags/$(version).tar.gz",
             "https://github.com/googleapis/google-cloud-cpp.git")

    add_versions("v2.46.0", "492734e092e5150d8395797f0d269f3d1e49ba3a959db4a332d15a1f382ff7ee")
    add_versions("v2.45.0", "3d1b5eb696832f9071bf7ef0b3f0c9fd27c1a39d5edcb8a9976c65193319fd01")
    add_versions("v2.43.0", "2aea914128db8a550bd926e1e08c155fae1caff8a451e1b644602952dd6d8b5c")
    add_versions("v2.42.0", "699955112a4c57ae9111fbadeff1698674a1762acd77daf36360e6dfc227dc93")
    add_versions("v2.39.0", "629cbfcc5bd581d38277ba8fa94a5b6591af1e0f6af0dab6d1d9ed796bf48b61")
    add_versions("v2.38.0", "f1493b2dce9b379714342f2be7ccb483d70d13aac09d4a90ae3b4756693b72fc")
    add_versions("v2.37.0", "10867580483cb338e7d50920c2383698f3572cc6b4c7d072e38d5f43755cbd80")
    add_versions("v2.36.0", "9a6e182fd658ba114512cf21bd9f274a315830638f62f0b831113df9e674bea0")
    add_versions("v2.34.0", "22deeb6c2abf0838f4d4c6100e83489bb581fa8015180370500ad31712f601ac")
    add_versions("v2.33.0", "e53ba3799c052d97acac9a6a6b27af24ce822dbde7bfde973bac9e5da714e6b2")

    add_configs("libraries", {description = "Enable subset of the libraries (default: google_cloud_cpp_common)", default = {}, type = "table"})
    add_configs("exceptions", {description = "Enable exceptions", default = true, type = "boolean"})

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    add_deps("cmake")

    on_check("mingw", function (package)
        -- https://github.com/googleapis/google-cloud-cpp/issues/14436
        if is_subhost("msys") then
            raise("Unsupported msys2 mingw64, see https://github.com/rui314/mold/issues/613#issuecomment-1214294138")
        end
    end)

    on_load(function (package)
        package:add("deps", "abseil")
        if not package:is_plat("windows", "mingw", "msys") then
            if package:is_plat("macosx") then
                package:add("deps", "openssl3", {system = false})
            else
                package:add("deps", "openssl3")
            end
        end

        -- https://github.com/googleapis/google-cloud-cpp/blob/main/cmake/GoogleCloudCppFeatures.cmake
        local libraries = package:config("libraries")
        if libraries and #libraries ~= 0 then
            import("core.base.hashset")

            local has_grpc = false
            local no_grpc_require = hashset.of("experimental-bigquery_rest", "mocks", "oauth2", "storage")

            local has_rest = false
            local rest_requires = hashset.of(
                "storage",
                "bigquerycontrol",
                "compute",
                "experimental",
                "gkeconnect",
                "oauth2",
                "opentelemetry",
                "sql",
                "universe_domain",
                "generator"
            )

            for _, lib in ipairs(libraries) do
                if not no_grpc_require:has(lib) then
                    has_grpc = true
                end
                if rest_requires:has(lib) then
                    has_rest = true
                end
            end

            if has_grpc then
                if package:config("shared") then
                    package:add("deps", "grpc", {configs = {shared = true}})
                    wprint([[Build google-cloud-cpp shared library require protobuf shared too, Please use `add_requireconfs("**.protobuf-cpp", {configs = {shared = true}})`]])
                else
                    package:add("deps", "grpc")
                end

                if package:is_cross() then
                    package:add("deps", "grpc~binary", {private = true, kind = "binary"})
                end
                -- commit hash from https://github.com/googleapis/google-cloud-cpp/blob/main/cmake/GoogleapisConfig.cmake
                package:add("resources", ">=2.33.0", "googleapis", "https://github.com/googleapis/googleapis.git", "c3556b45dc35a145e04b5692bc72e01a4f58a6b2")
            end

            if has_rest then
                package:add("deps", "nlohmann_json", {configs = {cmake = true}})
                package:add("deps", "libcurl", "crc32c")
            end

            local hash_libraries = hashset.from(libraries)
            package:data_set("hash_libraries", hash_libraries)
            if hash_libraries:has("opentelemetry") then
                package:add("deps", "opentelemetry-cpp")
            end
        end
    end)

    on_install(function (package)
        -- https://github.com/googleapis/google-cloud-cpp/blob/main/doc/packaging.md
        if package:dep("grpc") then
            local googleapis_dir = path.unix(package:resourcedir("googleapis"))
            io.replace("external/googleapis/CMakeLists.txt", 
                [[set(EXTERNAL_GOOGLEAPIS_PREFIX "${PROJECT_BINARY_DIR}/external/googleapis")]],
                format([[set(EXTERNAL_GOOGLEAPIS_PREFIX "%s")]], googleapis_dir), {plain = true})
        end

        local configs = {
            "-DBUILD_TESTING=OFF",
            "-DGOOGLE_CLOUD_CPP_ENABLE_EXAMPLES=OFF",
            "-DGOOGLE_CLOUD_CPP_ENABLE_WERROR=OFF",
            "-DGOOGLE_CLOUD_CPP_WITH_MOCKS=OFF",
            "-DGOOGLE_CLOUD_CPP_ENABLE_MACOS_OPENSSL_CHECK=OFF",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DGOOGLE_CLOUD_CPP_ENABLE_CXX_EXCEPTIONS=" .. (package:config("exceptions") and "ON" or "OFF"))
        if package:is_plat("windows") and package:config("shared") then
            table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
        end

        local openssl = package:dep("openssl")
        if openssl then
            if not openssl:is_system() then
                table.insert(configs, "-DOPENSSL_ROOT_DIR=" .. openssl:installdir())
            end
        end

        local libraries = package:config("libraries")
        if libraries then
            table.insert(configs, "-DGOOGLE_CLOUD_CPP_ENABLE=" .. table.concat(libraries, ";"))
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        local languages = "c++" .. package:dep("abseil"):config("cxx_standard")
        assert(package:check_cxxsnippets({test = [[
            #include <google/cloud/version.h>
            void test() {
                auto version = google::cloud::version_string();
            }
        ]]}, {configs = {languages = languages}}))

        local hash_libraries = package:data("hash_libraries")
        if not hash_libraries then
            return
        end

        if hash_libraries:has("storage") then
            assert(package:check_cxxsnippets({test = [[
                #include <google/cloud/storage/client.h>
                void test() {
                    auto client = google::cloud::storage::Client();
                }
            ]]}, {configs = {languages = languages}}))
        end
    end)
