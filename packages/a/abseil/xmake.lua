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
    add_versions("20230802.1", "987ce98f02eefbaf930d6e38ab16aa05737234d7afbab2d5c4ea7adbe50c28ed")

    add_deps("cmake")

    add_linkorders('absl_raw_logging_internal', 'absl_bad_any_cast_impl')
    add_linkorders('absl_raw_logging_internal', 'absl_bad_optional_access')
    add_linkorders('absl_raw_logging_internal', 'absl_bad_variant_access')
    add_linkorders('absl_log_severity', 'absl_base')
    add_linkorders('absl_raw_logging_internal', 'absl_base')
    add_linkorders('absl_spinlock_wait', 'absl_base')
    add_linkorders('absl_base', 'absl_cord')
    add_linkorders('absl_cord_internal', 'absl_cord')
    add_linkorders('absl_cordz_functions', 'absl_cord')
    add_linkorders('absl_cordz_info', 'absl_cord')
    add_linkorders('absl_crc_cord_state', 'absl_cord')
    add_linkorders('absl_raw_logging_internal', 'absl_cord')
    add_linkorders('absl_strings', 'absl_cord')
    add_linkorders('absl_exponential_biased', 'absl_cordz_functions')
    add_linkorders('absl_raw_logging_internal', 'absl_cordz_functions')
    add_linkorders('absl_base', 'absl_cordz_handle')
    add_linkorders('absl_raw_logging_internal', 'absl_cordz_handle')
    add_linkorders('absl_synchronization', 'absl_cordz_handle')
    add_linkorders('absl_base', 'absl_cordz_info')
    add_linkorders('absl_cord_internal', 'absl_cordz_info')
    add_linkorders('absl_cordz_functions', 'absl_cordz_info')
    add_linkorders('absl_cordz_handle', 'absl_cordz_info')
    add_linkorders('absl_raw_logging_internal', 'absl_cordz_info')
    add_linkorders('absl_stacktrace', 'absl_cordz_info')
    add_linkorders('absl_synchronization', 'absl_cordz_info')
    add_linkorders('absl_cordz_handle', 'absl_cordz_sample_token')
    add_linkorders('absl_cordz_info', 'absl_cordz_sample_token')
    add_linkorders('absl_crc_cord_state', 'absl_cord_internal')
    add_linkorders('absl_raw_logging_internal', 'absl_cord_internal')
    add_linkorders('absl_strings', 'absl_cord_internal')
    add_linkorders('absl_throw_delegate', 'absl_cord_internal')
    add_linkorders('absl_crc_cpu_detect', 'absl_crc32c')
    add_linkorders('absl_crc_internal', 'absl_crc32c')
    add_linkorders('absl_strings', 'absl_crc32c')
    add_linkorders('absl_crc32c', 'absl_crc_cord_state')
    add_linkorders('absl_strings', 'absl_crc_cord_state')
    add_linkorders('absl_base', 'absl_crc_cpu_detect')
    add_linkorders('absl_crc_cpu_detect', 'absl_crc_internal')
    add_linkorders('absl_base', 'absl_crc_internal')
    add_linkorders('absl_raw_logging_internal', 'absl_crc_internal')
    add_linkorders('absl_raw_logging_internal', 'absl_debugging_internal')
    add_linkorders('absl_base', 'absl_demangle_internal')
    add_linkorders('absl_stacktrace', 'absl_examine_stack')
    add_linkorders('absl_symbolize', 'absl_examine_stack')
    add_linkorders('absl_raw_logging_internal', 'absl_examine_stack')
    add_linkorders('absl_examine_stack', 'absl_failure_signal_handler')
    add_linkorders('absl_stacktrace', 'absl_failure_signal_handler')
    add_linkorders('absl_base', 'absl_failure_signal_handler')
    add_linkorders('absl_raw_logging_internal', 'absl_failure_signal_handler')
    add_linkorders('absl_flags_commandlineflag', 'absl_flags')
    add_linkorders('absl_flags_config', 'absl_flags')
    add_linkorders('absl_flags_internal', 'absl_flags')
    add_linkorders('absl_flags_reflection', 'absl_flags')
    add_linkorders('absl_base', 'absl_flags')
    add_linkorders('absl_strings', 'absl_flags')
    add_linkorders('absl_flags_commandlineflag_internal', 'absl_flags_commandlineflag')
    add_linkorders('absl_strings', 'absl_flags_commandlineflag')
    add_linkorders('absl_flags_program_name', 'absl_flags_config')
    add_linkorders('absl_strings', 'absl_flags_config')
    add_linkorders('absl_synchronization', 'absl_flags_config')
    add_linkorders('absl_base', 'absl_flags_internal')
    add_linkorders('absl_flags_commandlineflag', 'absl_flags_internal')
    add_linkorders('absl_flags_commandlineflag_internal', 'absl_flags_internal')
    add_linkorders('absl_flags_config', 'absl_flags_internal')
    add_linkorders('absl_flags_marshalling', 'absl_flags_internal')
    add_linkorders('absl_synchronization', 'absl_flags_internal')
    add_linkorders('absl_log_severity', 'absl_flags_marshalling')
    add_linkorders('absl_strings', 'absl_flags_marshalling')
    add_linkorders('absl_flags_config', 'absl_flags_parse')
    add_linkorders('absl_flags', 'absl_flags_parse')
    add_linkorders('absl_flags_commandlineflag', 'absl_flags_parse')
    add_linkorders('absl_flags_commandlineflag_internal', 'absl_flags_parse')
    add_linkorders('absl_flags_internal', 'absl_flags_parse')
    add_linkorders('absl_flags_private_handle_accessor', 'absl_flags_parse')
    add_linkorders('absl_flags_program_name', 'absl_flags_parse')
    add_linkorders('absl_flags_reflection', 'absl_flags_parse')
    add_linkorders('absl_flags_usage', 'absl_flags_parse')
    add_linkorders('absl_strings', 'absl_flags_parse')
    add_linkorders('absl_synchronization', 'absl_flags_parse')
    add_linkorders('absl_flags_commandlineflag', 'absl_flags_private_handle_accessor')
    add_linkorders('absl_flags_commandlineflag_internal', 'absl_flags_private_handle_accessor')
    add_linkorders('absl_strings', 'absl_flags_private_handle_accessor')
    add_linkorders('absl_strings', 'absl_flags_program_name')
    add_linkorders('absl_synchronization', 'absl_flags_program_name')
    add_linkorders('absl_flags_commandlineflag', 'absl_flags_reflection')
    add_linkorders('absl_flags_private_handle_accessor', 'absl_flags_reflection')
    add_linkorders('absl_flags_config', 'absl_flags_reflection')
    add_linkorders('absl_strings', 'absl_flags_reflection')
    add_linkorders('absl_synchronization', 'absl_flags_reflection')
    add_linkorders('absl_flags_usage_internal', 'absl_flags_usage')
    add_linkorders('absl_strings', 'absl_flags_usage')
    add_linkorders('absl_synchronization', 'absl_flags_usage')
    add_linkorders('absl_flags_config', 'absl_flags_usage_internal')
    add_linkorders('absl_flags', 'absl_flags_usage_internal')
    add_linkorders('absl_flags_commandlineflag', 'absl_flags_usage_internal')
    add_linkorders('absl_flags_internal', 'absl_flags_usage_internal')
    add_linkorders('absl_flags_private_handle_accessor', 'absl_flags_usage_internal')
    add_linkorders('absl_flags_program_name', 'absl_flags_usage_internal')
    add_linkorders('absl_flags_reflection', 'absl_flags_usage_internal')
    add_linkorders('absl_strings', 'absl_flags_usage_internal')
    add_linkorders('absl_synchronization', 'absl_flags_usage_internal')
    add_linkorders('absl_base', 'absl_graphcycles_internal')
    add_linkorders('absl_malloc_internal', 'absl_graphcycles_internal')
    add_linkorders('absl_raw_logging_internal', 'absl_graphcycles_internal')
    add_linkorders('absl_city', 'absl_hash')
    add_linkorders('absl_int128', 'absl_hash')
    add_linkorders('absl_strings', 'absl_hash')
    add_linkorders('absl_low_level_hash', 'absl_hash')
    add_linkorders('absl_base', 'absl_hashtablez_sampler')
    add_linkorders('absl_exponential_biased', 'absl_hashtablez_sampler')
    add_linkorders('absl_synchronization', 'absl_hashtablez_sampler')
    add_linkorders('absl_int128', 'absl_low_level_hash')
    add_linkorders('absl_base', 'absl_malloc_internal')
    add_linkorders('absl_raw_logging_internal', 'absl_malloc_internal')
    add_linkorders('absl_exponential_biased', 'absl_periodic_sampler')
    add_linkorders('absl_strings', 'absl_random_distributions')
    add_linkorders('absl_raw_logging_internal', 'absl_random_internal_distribution_test_util')
    add_linkorders('absl_strings', 'absl_random_internal_distribution_test_util')
    add_linkorders('absl_base', 'absl_random_internal_pool_urbg')
    add_linkorders('absl_random_internal_randen', 'absl_random_internal_pool_urbg')
    add_linkorders('absl_random_internal_seed_material', 'absl_random_internal_pool_urbg')
    add_linkorders('absl_random_seed_gen_exception', 'absl_random_internal_pool_urbg')
    add_linkorders('absl_raw_logging_internal', 'absl_random_internal_pool_urbg')
    add_linkorders('absl_random_internal_platform', 'absl_random_internal_randen')
    add_linkorders('absl_random_internal_randen_hwaes', 'absl_random_internal_randen')
    add_linkorders('absl_random_internal_randen_slow', 'absl_random_internal_randen')
    add_linkorders('absl_random_internal_platform', 'absl_random_internal_randen_hwaes')
    add_linkorders('absl_random_internal_randen_hwaes_impl', 'absl_random_internal_randen_hwaes')
    add_linkorders('absl_random_internal_platform', 'absl_random_internal_randen_hwaes_impl')
    add_linkorders('absl_random_internal_platform', 'absl_random_internal_randen_slow')
    add_linkorders('absl_raw_logging_internal', 'absl_random_internal_seed_material')
    add_linkorders('absl_strings', 'absl_random_internal_seed_material')
    add_linkorders('absl_random_internal_pool_urbg', 'absl_random_seed_sequences')
    add_linkorders('absl_random_internal_seed_material', 'absl_random_seed_sequences')
    add_linkorders('absl_random_seed_gen_exception', 'absl_random_seed_sequences')
    add_linkorders('absl_hashtablez_sampler', 'absl_raw_hash_set')
    add_linkorders('absl_raw_logging_internal', 'absl_raw_hash_set')
    add_linkorders('absl_log_severity', 'absl_raw_logging_internal')
    add_linkorders('absl_raw_logging_internal', 'absl_scoped_set_env')
    add_linkorders('absl_debugging_internal', 'absl_stacktrace')
    add_linkorders('absl_raw_logging_internal', 'absl_stacktrace')
    add_linkorders('absl_cord', 'absl_status')
    add_linkorders('absl_raw_logging_internal', 'absl_status')
    add_linkorders('absl_stacktrace', 'absl_status')
    add_linkorders('absl_strerror', 'absl_status')
    add_linkorders('absl_strings', 'absl_status')
    add_linkorders('absl_symbolize', 'absl_status')
    add_linkorders('absl_base', 'absl_statusor')
    add_linkorders('absl_status', 'absl_statusor')
    add_linkorders('absl_raw_logging_internal', 'absl_statusor')
    add_linkorders('absl_strings', 'absl_statusor')
    add_linkorders('absl_strings_internal', 'absl_strings')
    add_linkorders('absl_base', 'absl_strings')
    add_linkorders('absl_int128', 'absl_strings')
    add_linkorders('absl_raw_logging_internal', 'absl_strings')
    add_linkorders('absl_throw_delegate', 'absl_strings')
    add_linkorders('absl_raw_logging_internal', 'absl_strings_internal')
    add_linkorders('absl_strings', 'absl_str_format_internal')
    add_linkorders('absl_int128', 'absl_str_format_internal')
    add_linkorders('absl_debugging_internal', 'absl_symbolize')
    add_linkorders('absl_demangle_internal', 'absl_symbolize')
    add_linkorders('absl_base', 'absl_symbolize')
    add_linkorders('absl_malloc_internal', 'absl_symbolize')
    add_linkorders('absl_raw_logging_internal', 'absl_symbolize')
    add_linkorders('absl_strings', 'absl_symbolize')
    add_linkorders('absl_raw_logging_internal', 'absl_throw_delegate')
    add_linkorders('absl_base', 'absl_time')
    add_linkorders('absl_civil_time', 'absl_time')
    add_linkorders('absl_int128', 'absl_time')
    add_linkorders('absl_raw_logging_internal', 'absl_time')
    add_linkorders('absl_strings', 'absl_time')
    add_linkorders('absl_time_zone', 'absl_time')

    if is_plat("macosx") then
        add_frameworks("CoreFoundation")
    end

    on_load(function (package)
        if package:is_plat("windows") and package:config("shared") then
            package:add("defines", "ABSL_CONSUME_DLL")
            package:add("links", "abseil_dll")
        end
        if package:version():eq("20230802.1") then
            package:add('linkorders', "absl_strings", "absl_die_if_null")
            package:add('linkorders', "absl_raw_logging_internal", "absl_kernel_timeout_internal")
            package:add('linkorders', "absl_time", "absl_kernel_timeout_internal")
            package:add('linkorders', "absl_log_severity", "absl_log_entry")
            package:add('linkorders', "absl_strings", "absl_log_entry")
            package:add('linkorders', "absl_time", "absl_log_entry")
            package:add('linkorders', "absl_log_globals", "absl_log_flags")
            package:add('linkorders', "absl_log_severity", "absl_log_flags")
            package:add('linkorders', "absl_flags", "absl_log_flags")
            package:add('linkorders', "absl_flags_marshalling", "absl_log_flags")
            package:add('linkorders', "absl_strings", "absl_log_flags")
            package:add('linkorders', "absl_hash", "absl_log_globals")
            package:add('linkorders', "absl_log_severity", "absl_log_globals")
            package:add('linkorders', "absl_strings", "absl_log_globals")
            package:add('linkorders', "absl_log_globals", "absl_log_initialize")
            package:add('linkorders', "absl_log_internal_globals", "absl_log_initialize")
            package:add('linkorders', "absl_time", "absl_log_initialize")
            package:add('linkorders', "absl_log_internal_nullguard", "absl_log_internal_check_op")
            package:add('linkorders', "absl_strings", "absl_log_internal_check_op")
            package:add('linkorders', "absl_base", "absl_log_internal_conditions")
            package:add('linkorders', "absl_log_internal_globals", "absl_log_internal_format")
            package:add('linkorders', "absl_log_severity", "absl_log_internal_format")
            package:add('linkorders', "absl_strings", "absl_log_internal_format")
            package:add('linkorders', "absl_time", "absl_log_internal_format")
            package:add('linkorders', "absl_log_severity", "absl_log_internal_globals")
            package:add('linkorders', "absl_raw_logging_internal", "absl_log_internal_globals")
            package:add('linkorders', "absl_strings", "absl_log_internal_globals")
            package:add('linkorders', "absl_time", "absl_log_internal_globals")
            package:add('linkorders', "absl_base", "absl_log_internal_log_sink_set")
            package:add('linkorders', "absl_log_internal_globals", "absl_log_internal_log_sink_set")
            package:add('linkorders', "absl_log_globals", "absl_log_internal_log_sink_set")
            package:add('linkorders', "absl_log_entry", "absl_log_internal_log_sink_set")
            package:add('linkorders', "absl_log_severity", "absl_log_internal_log_sink_set")
            package:add('linkorders', "absl_log_sink", "absl_log_internal_log_sink_set")
            package:add('linkorders', "absl_raw_logging_internal", "absl_log_internal_log_sink_set")
            package:add('linkorders', "absl_synchronization", "absl_log_internal_log_sink_set")
            package:add('linkorders', "absl_strings", "absl_log_internal_log_sink_set")
            package:add('linkorders', "absl_base", "absl_log_internal_message")
            package:add('linkorders', "absl_examine_stack", "absl_log_internal_message")
            package:add('linkorders', "absl_log_internal_format", "absl_log_internal_message")
            package:add('linkorders', "absl_log_internal_globals", "absl_log_internal_message")
            package:add('linkorders', "absl_log_internal_proto", "absl_log_internal_message")
            package:add('linkorders', "absl_log_internal_log_sink_set", "absl_log_internal_message")
            package:add('linkorders', "absl_log_internal_nullguard", "absl_log_internal_message")
            package:add('linkorders', "absl_log_globals", "absl_log_internal_message")
            package:add('linkorders', "absl_log_entry", "absl_log_internal_message")
            package:add('linkorders', "absl_log_severity", "absl_log_internal_message")
            package:add('linkorders', "absl_log_sink", "absl_log_internal_message")
            package:add('linkorders', "absl_raw_logging_internal", "absl_log_internal_message")
            package:add('linkorders', "absl_strings", "absl_log_internal_message")
            package:add('linkorders', "absl_strerror", "absl_log_internal_message")
            package:add('linkorders', "absl_time", "absl_log_internal_message")
            package:add('linkorders', "absl_base", "absl_log_internal_proto")
            package:add('linkorders', "absl_strings", "absl_log_internal_proto")
            package:add('linkorders', "absl_log_entry", "absl_log_sink")
            package:add('linkorders', "absl_graphcycles_internal", "absl_synchronization")
            package:add('linkorders', "absl_kernel_timeout_internal", "absl_synchronization")
            package:add('linkorders', "absl_base", "absl_synchronization")
            package:add('linkorders', "absl_malloc_internal", "absl_synchronization")
            package:add('linkorders', "absl_raw_logging_internal", "absl_synchronization")
            package:add('linkorders', "absl_stacktrace", "absl_synchronization")
            package:add('linkorders', "absl_symbolize", "absl_synchronization")
            package:add('linkorders', "absl_time", "absl_synchronization")
        end
    end)

    on_install("macosx", "linux", "windows", "mingw", "cross", function (package)
        if package:version():eq("20230802.1") and package:is_plat("mingw") then
            io.replace(path.join("absl", "synchronization", "internal", "pthread_waiter.h"), "#ifndef _WIN32", "#if !defined(_WIN32) && !defined(__MINGW32__)", {plain = true})
            io.replace(path.join("absl", "synchronization", "internal", "win32_waiter.h"), "#if defined(_WIN32) && _WIN32_WINNT >= _WIN32_WINNT_VISTA", "#if defined(_WIN32) && !defined(__MINGW32__) && _WIN32_WINNT >= _WIN32_WINNT_VISTA", {plain = true})
        end
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
        ]]}, {configs = {languages = "cxx17"}}))
    end)
