package("jrtplib")
    set_homepage("https://research.edm.uhasselt.be/jori/page/CS/Jrtplib.html")
    set_description("JRTPLIB is an object-oriented RTP library written in C++")
    set_license("MIT")

    set_urls("https://github.com/j0r1/JRTPLIB.git")

    add_versions("2023.11.23", "d43c112f693bf663825ff00fbbad4bfe98f8dd5f")

    add_deps("cmake", "jthread")

    add_includedirs("include", "include/jrtplib3")

    if is_plat ("linux") then 
        add_syslinks("pthread")
    elseif is_plat("windows") then 
        add_syslinks("ws2_32", "advapi32")
    end

    on_install("windows", "linux", "macosx", function (package)
        io.replace("src/CMakeLists.txt", [[option(JRTPLIB_WARNINGSASERRORS "Enable -Wall -Wextra -Werror" ON)]], [[option(JRTPLIB_WARNINGSASERRORS "Enable -Wall -Wextra -Werror" OFF)]], {plain=true})
        io.replace("src/CMakeLists.txt", [[NOT MSVC OR JRTPLIB_COMPILE_STATIC]], [[JRTPLIB_COMPILE_STATIC]], {plain=true})
        io.replace("src/CMakeLists.txt", [[NOT MSVC OR NOT JRTPLIB_COMPILE_STATIC]], [[NOT JRTPLIB_COMPILE_STATIC]], {plain=true})
        local configs = {"-DJRTPLIB_COMPILE_TESTS=NO", "-DJRTPLIB_COMPILE_EXAMPLES=NO"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DJRTPLIB_COMPILE_STATIC=" .. (package:config("shared") and "OFF" or "ON"))

        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
        #include "rtpsession.h"
        #include "rtpsessionparams.h"
        #include "rtpudpv4transmitter.h"
        #include "rtpipv4address.h"
        #include "rtptimeutilities.h"
        #include "rtppacket.h"

        using namespace jrtplib;

        void test() {
            RTPSession session;
	        
            RTPSessionParams sessionparams;
	        sessionparams.SetOwnTimestampUnit(1.0/8000.0);
	        
            RTPUDPv4TransmissionParams transparams;
	        transparams.SetPortbase(8000);
	        int status = session.Create(sessionparams,&transparams);
        }
        ]]}, {configs = {languages = "c++11"}}))
    end)