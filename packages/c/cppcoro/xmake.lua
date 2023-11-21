package("cppcoro")

    set_homepage("https://github.com/andreasbuhr/cppcoro")
    set_description("A library of C++ coroutine abstractions for the coroutines TS")

    set_urls("https://github.com/andreasbuhr/cppcoro.git")
    add_versions("2020.10.13", "a87e97fe5b6091ca9f6de4637736b8e0d8b109cf")
    add_versions("2023.11.23", "e86216e4fa6145f0184b5fef79230e9d4dc3aa77")

    add_deps("cmake")

    if is_plat("windows") then
        add_syslinks("synchronization", "ws2_32", "mswsock")
    end

    on_install("windows", "linux", function (package)
        import("package.tools.cmake").install(package)
    end)

    on_test(function (package)
        local cxxflags = package:is_plat("windows") and "/await" or "-fcoroutines-ts"
        assert(package:check_cxxsnippets({test = [[
        #include <cppcoro/read_only_file.hpp>
        #include <cppcoro/task.hpp>
        #include <cppcoro/filesystem.hpp>
        namespace fs = cppcoro::filesystem;

        cppcoro::task<std::uint64_t> count_lines(cppcoro::io_service& ioService, fs::path path)
        {
          auto file = cppcoro::read_only_file::open(ioService, path);
          int lineCount = 0;
          char buffer[1024];
          std::uint64_t offset = 0;
          co_await file.read(offset, buffer, sizeof(buffer));

        }

        ]]}, {configs = {languages = "c++20"}}))
    end)
