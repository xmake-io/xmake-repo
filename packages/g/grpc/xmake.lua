package("grpc")
    set_homepage("https://grpc.io")
    set_description("The C based gRPC (C++, Python, Ruby, Objective-C, PHP, C#)")
    set_license("Apache-2.0")

    add_urls("https://github.com/grpc/grpc.git")
    add_versions("v1.46.3", "53d69cc581c5b7305708587f4f1939278477c28a")

    add_deps("cmake")
    if is_plat("linux") then
        add_deps("autoconf", "libtool", "pkg-config")
        add_extsources("apt::build-essential")
    elseif is_plat("macosx") then
        add_deps("autoconf", "automake", "libtool")
        add_extsources("brew::shtool")
    elseif is_plat("windows") then
        add_deps("nasm")
        add_configs("shared", {description = "Build shared libraries.", default = false, type = "boolean", readonly = true})
    end

    on_load("linux", "macosx", function (package)
        if package:config("shared") then
            package:add("links", "absl_city", "absl_raw_logging_internal", "absl_flags_config", "absl_scoped_set_env", "absl_flags_usage", "absl_strings_internal", "absl_failure_signal_handler", "absl_flags_parse", "absl_statusor", "absl_flags_marshalling", "absl_cord", "absl_exponential_biased", "grpc++", "protobuf-lite", "absl_examine_stack", "grpc++_unsecure", "absl_random_internal_distribution_test_util", "absl_bad_any_cast_impl", "gpr", "absl_leak_check", "absl_cordz_sample_token", "absl_cordz_functions", "absl_str_format_internal", "absl_random_internal_randen_slow", "grpc++_reflection", "absl_int128", "absl_cordz_info", "absl_flags_commandlineflag", "grpc++_alts", "absl_leak_check_disable", "absl_cord_internal", "absl_stacktrace", "absl_spinlock_wait", "absl_status", "absl_symbolize", "z", "grpc_unsecure", "absl_random_internal_platform", "absl_cordz_handle", "absl_flags_commandlineflag_internal", "absl_flags_program_name", "absl_random_seed_gen_exception", "absl_raw_hash_set", "absl_malloc_internal", "absl_bad_optional_access", "absl_flags_usage_internal", "re2", "absl_graphcycles_internal", "crypto", "absl_debugging_internal", "absl_base", "upb", "address_sorting", "absl_random_internal_randen", "absl_throw_delegate", "absl_strerror", "grpc", "absl_strings", "absl_flags_reflection", "absl_random_internal_randen_hwaes", "grpc_plugin_support", "absl_flags", "absl_flags_private_handle_accessor", "absl_random_internal_randen_hwaes_impl", "absl_random_internal_pool_urbg", "absl_flags_internal", "absl_random_distributions", "absl_time_zone", "absl_hashtablez_sampler", "absl_random_seed_sequences", "grpc++_error_details", "absl_low_level_hash", "absl_random_internal_seed_material", "protobuf", "protoc", "ssl", "cares", "absl_bad_variant_access", "absl_civil_time", "absl_synchronization", "absl_demangle_internal", "absl_periodic_sampler", "grpcpp_channelz", "absl_hash", "absl_log_severity", "absl_time")
        else
            package:add("links", "pthread", "dl", "m", "c")
        end
    end)
    
    on_install("linux", "macosx", "windows", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        io.replace("third_party/boringssl-with-bazel/CMakeLists.txt", "target_link_libraries(bssl ssl crypto)", "target_link_libraries(ssl crypto)\ntarget_link_libraries(bssl ssl crypto)", {plain = true})
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                grpc::CompletionQueue q;
            }
        ]]}, {configs = {languages = "c++11"}, includes = "grpcpp/grpcpp.h"}))
    end)
