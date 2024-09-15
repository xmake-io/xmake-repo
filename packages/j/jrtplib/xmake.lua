package("jrtplib")
    set_homepage("https://research.edm.uhasselt.be/jori/page/CS/Jrtplib.html")
    set_description("JRTPLIB is an object-oriented RTP library written in C++")
    set_license("MIT")

    set_urls("https://github.com/j0r1/JRTPLIB/archive/refs/tags/v3.11.2.tar.gz",
             "https://github.com/j0r1/JRTPLIB.git")

    add_versions("v3.11.2", "591bf6cddd0976a4659ed4dd2fada43140e5f5f9c9dbef56b137a3023549673f")

    add_deps("cmake", "jthread", "srtp")

    on_install(function (package)
        io.replace("src/CMakeLists.txt", [[ "Enable -Wall -Wextra -Werror" ON]], [[ "Enable -Wall -Wextra -Werror" OFF]])
        local configs = {"-DJRTPLIB_COMPILE_TESTS=NO", "-DJRTPLIB_COMPILE_EXAMPLES=NO"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
       
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <ada.h>
            void test() {
                auto url = ada::parse<ada::url_aggregator>("https://xmake.io");
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
