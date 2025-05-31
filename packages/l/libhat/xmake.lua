package("libhat")
    set_description("A modern, high-performance library for C++20 designed around game hacking")

    set_urls("https://github.com/BasedInc/libhat.git")
    add_versions("0.5.0", "5c4a7b7a15ae0799e928cb0ecf6800799942d0d3")
    add_versions("0.4.0", "7375873e560f46e8569c6a389c6077f4c7133089")
    add_versions("0.3.0", "a3bd74d363a20b58c8e397b078e86621bca0a151")
    add_versions("0.2.0", "2a2c7c37e76104f0593ee4bdd70c77dd9bad47cd")
    add_versions("0.1.1", "c1863ad08ade725de185b6ef32e1eafc09118eaf")
    add_versions("0.1.0", "4874d1a6ee8ef99fec79428a32aadd67850c1b10")
    add_versions("2024.9.22", "5a7970877b297b236818ee2d71730f4f1ca1a06c")
    add_versions("2024.8.10", "f4755aea0987e77c0f6f496c49eb9cd08d5f5a06")
    add_versions("2024.4.16", "5a7970877b297b236818ee2d71730f4f1ca1a06c")


    add_deps("cmake")

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        if package:config("shared") then
            table.insert(configs, "-DLIBHAT_SHARED_C_LIB=ON")
        else
            table.insert(configs, "-DLIBHAT_STATIC_C_LIB=ON")
        end
        import("package.tools.cmake").install(package, configs)
        os.cp("include/*", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            // Parse a pattern's string representation to an array of bytes at compile time
            constexpr auto pattern = hat::compile_signature<"48 8D 05 ? ? ? ? E8">();

            // ...or parse it at runtime
            using parsed_t = hat::result<hat::signature, hat::signature_parse_error>;
            parsed_t runtime_pattern = hat::parse_signature("48 8D 05 ? ? ? ? E8");
        ]]}, {configs = {languages = "c++20"}, includes = "libhat.hpp"}))
    end)