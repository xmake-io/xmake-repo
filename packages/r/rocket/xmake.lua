package("rocket")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/tripleslash/rocket")
    set_description("Fast single header signal/slots library for C++")

    add_urls("https://github.com/tripleslash/rocket.git")

    add_versions("2020.06.03", "348869fcda83f8b8b521c7654f83fea07ebe7a0a")
    -- add_versions("2024.08.21", "ce3a936f21bc8868aec36f221706ca73228297ab")

    on_install(function (package)
        io.replace("rocket.hpp", "return thread_id != std::thread::id{}", "return !(thread_id == std::thread::id{})", {plain = true})
        io.replace("rocket.hpp", "&& thread_id != std::this_thread::get_id();", "&& !(thread_id == std::this_thread::get_id());", {plain = true})
        os.cp("rocket.hpp", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                rocket::signal<void()> thread_unsafe_signal;
                rocket::thread_safe_signal<void()> thread_safe_signal;
                thread_unsafe_signal.connect([]() {});
            }
        ]]}, {configs = {languages = "c++17"}, includes = "rocket.hpp"}))
    end)
