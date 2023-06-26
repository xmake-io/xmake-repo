package("abseil")

    set_homepage("https://abseil.io")
    set_description("C++ Common Libraries")
    set_license("Apache-2.0")

    add_urls("https://github.com/abseil/abseil-cpp/archive/$(version).tar.gz",
             "https://github.com/abseil/abseil-cpp.git")
    add_versions("20200225.1", "0db0d26f43ba6806a8a3338da3e646bb581f0ca5359b3a201d8fb8e4752fd5f8")
    add_versions("20210324.1", "441db7c09a0565376ecacf0085b2d4c2bbedde6115d7773551bc116212c2a8d6")
    add_versions("20210324.2", "59b862f50e710277f8ede96f083a5bb8d7c9595376146838b9580be90374ee1f")
    add_versions("20211102.0", "dcf71b9cba8dc0ca9940c4b316a0c796be8fab42b070bb6b7cab62b48f0e66c4")
    add_versions("20220623.0", "4208129b49006089ba1d6710845a45e31c59b0ab6bff9e5788a87f55c5abd602")
    add_versions("20230125.2", "9a2b5752d7bfade0bdeee2701de17c9480620f8b237e1964c1b9967c75374906")

    add_deps("cmake")

    add_links(
        "absl_status", "absl_cord",
        "absl_flags", "absl_flags_parse", "absl_flags_internal", "absl_flags_reflection", "absl_flags_marshalling",
        "absl_flags_commandlineflag_internal", "absl_synchronization", "absl_time", "absl_hash", "absl_city", "absl_time_zone",
        "absl_spinlock_wait", "absl_failure_signal_handler", "absl_bad_optional_access", "absl_flags_commandlineflag",
        "absl_random_internal_pool_urbg",
        "absl_cordz_info", "absl_cord_internal", "absl_cordz_functions", "absl_cordz_handle", "absl_cordz_sample_token",
        "absl_base", "absl_bad_any_cast_impl", "absl_periodic_sampler", "absl_random_distributions",
        "absl_flags_usage_internal", "absl_random_seed_sequences",
        "absl_throw_delegate", "absl_stacktrace", "absl_symbolize", "absl_debugging_internal",
        "absl_flags_private_handle_accessor",
        "absl_strings", "absl_flags_config", "absl_malloc_internal", "absl_str_format_internal",
        "absl_flags_usage", "absl_strings_internal", "absl_flags_program_name", "absl_int128",
        "absl_scoped_set_env", "absl_raw_hash_set", "absl_random_internal_seed_material",
        "absl_random_internal_randen", "absl_random_internal_randen_slow", "absl_random_internal_randen_hwaes_impl",
        "absl_random_internal_randen_hwaes",
        "absl_graphcycles_internal", "absl_exponential_biased", "absl_bad_variant_access", "absl_statusor",
        "absl_random_internal_distribution_test_util", "absl_random_internal_platform",
        "absl_hashtablez_sampler", "absl_demangle_internal", "absl_leak_check", "absl_log_severity", "absl_raw_logging_internal",
        "absl_strerror", "absl_examine_stack", "absl_low_level_hash", "absl_random_seed_gen_exception", "absl_civil_time",
        "absl_crc_cord_state", "absl_crc32c", "absl_crc_cpu_detect", "absl_crc_internal")

    if is_plat("macosx") then
        add_frameworks("CoreFoundation")
    end

    on_load(function (package)
        if package:is_plat("windows") and package:config("shared") then
            package:add("defines", "ABSL_CONSUME_DLL")
            package:add("links", "abseil_dll")
        end
    end)

    on_install("macosx", "linux", "windows", function (package)
        local configs = {"-DCMAKE_CXX_STANDARD=17"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs, {buildir = os.tmpfile() .. ".dir"})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <iostream>
            #include <string>
            #include <vector>
            #include "absl/strings/numbers.h"
            #include "absl/strings/str_join.h"
            void test () {
                std::vector<std::string> v = {"foo","bar","baz"};
                std::string s = absl::StrJoin(v, "-");
                int result = 0;
                auto a = absl::SimpleAtoi("123", &result);
                std::cout << "Joined string: " << s << "\\n";
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
