package("cppcoro")

    set_homepage("https://github.com/lewissbaker/cppcoro")
    set_description("A library of C++ coroutine abstractions for the coroutines TS")

    set_urls("https://github.com/lewissbaker/cppcoro.git")
    add_versions("2020.10.13", "a87e97fe5b6091ca9f6de4637736b8e0d8b109cf")

    if is_plat("windows") then
        add_syslinks("synchronization", "ws2_32", "mswsock")
    end

    on_install("windows", function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("cppcoro")
                set_kind("$(kind)")
                add_files("lib/*.cpp|win32.cpp")
                add_includedirs("include")
                add_headerfiles("include/(**.hpp)")
                set_languages("c++17")
                if is_plat("windows") then
                    add_files("lib/win32.cpp")
                    add_defines("_SILENCE_EXPERIMENTAL_FILESYSTEM_DEPRECATION_WARNING")
                    add_cxxflags("/await")
                    if is_kind("shared") then
                        add_rules("utils.symbols.export_all", {export_classes = true})
                        add_syslinks("synchronization", "ws2_32", "mswsock")
                    end
                else
                    add_cxxflags("-fcoroutines-ts")
                end
        ]])
        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        elseif not package:is_plat("windows", "mingw") and package:config("pic") ~= false then
            configs.cxflags = "-fPIC"
        end
        for _, filepath in ipairs(os.files("lib/*.cpp")) do
            io.replace(filepath, "cppcoro\\", "cppcoro/", {plain = true})
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        local cxxflags = package:is_plat("windows") and "/await" or "-fcoroutines-ts"
        assert(package:check_cxxsnippets({test = [[
        #include <cppcoro/task.hpp>
        #include <cppcoro/task.hpp>
        #include <cppcoro/sync_wait.hpp>
        #include <cppcoro/io_service.hpp>
        #include <cppcoro/when_all_ready.hpp>
        #include <cppcoro/read_only_file.hpp>

        #include <experimental/filesystem>
        #include <memory>
        #include <algorithm>
        #include <iostream>

        namespace fs = std::experimental::filesystem;

        cppcoro::task<std::uint64_t> count_lines(cppcoro::io_service& ioService, fs::path path) {
          auto file = cppcoro::read_only_file::open(ioService, path);

          constexpr size_t bufferSize = 4096;
          auto buffer = std::make_unique<std::uint8_t[]>(bufferSize);

          std::uint64_t newlineCount = 0;

          for (std::uint64_t offset = 0, fileSize = file.size(); offset < fileSize;) {
            const auto bytesToRead = static_cast<size_t>(
              std::min<std::uint64_t>(bufferSize, fileSize - offset));
            const auto bytesRead = co_await file.read(offset, buffer.get(), bytesToRead);
            newlineCount += std::count(buffer.get(), buffer.get() + bytesRead, '\n');
            offset += bytesRead;
          }
          co_return newlineCount;
        }

        cppcoro::task<> run(cppcoro::io_service& ioService) {
          cppcoro::io_work_scope ioScope(ioService);
          auto lineCount = co_await count_lines(ioService, fs::path{"foo.txt"});
          std::cout << "foo.txt has " << lineCount << " lines." << std::endl;;
        }

        cppcoro::task<> process_events(cppcoro::io_service& ioService) {
          co_return;
        }

        int test() {
          cppcoro::io_service ioService;
          cppcoro::sync_wait(cppcoro::when_all_ready(
            run(ioService),
            process_events(ioService)));
          return 0;
        }
        ]]}, {configs = {cxxflags = cxxflags, languages = "c++17", defines = "_SILENCE_EXPERIMENTAL_FILESYSTEM_DEPRECATION_WARNING"}}))
    end)
