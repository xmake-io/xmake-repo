function cmake(package)
    local version = package:version()

    if version:eq("8.0.39") then
        io.replace("cmake/ssl.cmake", "IF(NOT OPENSSL_APPLINK_C)", "IF(FALSE)", {plain = true})
        io.replace("cmake/boost.cmake", "IF(NOT BOOST_MINOR_VERSION EQUAL 77)", "IF(FALSE)", {plain = true})
        if package:is_cross() then
            local libevent_version = package:dep("libevent"):version()
            if not libevent_version then
                version = "2.1.12"
            end
            -- skip try_run
            io.replace("cmake/libevent.cmake",
                [[SET(LIBEVENT_VERSION_STRING "${RUN_OUTPUT}")]],
                format([[SET(LIBEVENT_VERSION_STRING "%s")]], libevent_version), {plain = true})
        end
    elseif version:eq("9.0.1") then
        io.replace("cmake/ssl.cmake", "FIND_CUSTOM_OPENSSL()", "FIND_SYSTEM_OPENSSL()", {plain = true})
    end

    if package:is_plat("windows") then
        -- fix pdb install
        io.replace("cmake/install_macros.cmake",
            [[NOT type MATCHES "STATIC_LIBRARY"]],
            [[NOT type MATCHES "STATIC_LIBRARY" AND CMAKE_BUILD_TYPE STREQUAL "DEBUG"]], {plain = true})

        if package:is_cross() then
            -- skip try_run
            io.replace("cmake/rapidjson.cmake", "IF (NOT HAVE_RAPIDJSON_WITH_STD_REGEX)", "if(FALSE)", {plain = true})
        end
    end
end
