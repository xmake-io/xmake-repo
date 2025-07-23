package("reckless")
    set_homepage("https://github.com/mattiasflodin/reckless")
    set_description("Reckless logging. Low-latency, high-throughput, asynchronous logging library for C++.")

    add_urls("https://github.com/mattiasflodin/reckless/archive/refs/tags/$(version).tar.gz",
             "https://github.com/mattiasflodin/reckless.git")

    add_versions("v3.0.3", "522656ded4aa72d2c465e48d43b9378c66108339fe3be4324ea0e601bf0537f9")

    add_deps("cmake")

    if is_plat("windows") then
        add_syslinks("synchronization")
    elseif is_plat("linux") then
        add_syslinks("pthread")
    end

    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})

    on_install("linux|!arm*", "windows|!arm*", function (package)
        io.replace("CMakeLists.txt", "add_library(reckless STATIC ${SRC_LIST})", "add_library(reckless STATIC ${SRC_LIST}) \n install(TARGETS reckless DESTINATION lib) \n install(DIRECTORY reckless/include/   DESTINATION include)", {plain = true})
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <reckless/severity_log.hpp>
            #include <reckless/file_writer.hpp>
            using log_t = reckless::severity_log<
                reckless::indent<4>,       
                ' ',                       
                reckless::severity_field,  
                reckless::timestamp_field  
                >;
            reckless::file_writer writer("log.txt");
            log_t g_log(&writer);
            void test()
            {
                std::string s("Hello World!");
                g_log.debug("Pointer: %p", s.c_str());
                g_log.info("Info line: %s", s);
                for(int i=0; i!=4; ++i) {
                    reckless::scoped_indent indent;  
                    g_log.warn("Warning: %d", i);    
                }
                g_log.error("Error: %f", 3.14);
            }
        ]]}, {configs = {languages = "cxx11"}}))
    end)
