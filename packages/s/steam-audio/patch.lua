function main(package)
    if package:is_plat("mingw", "msys") then
        io.replace("CMakeLists.txt", "# Windows flags\nif (IPL_OS_WINDOWS)", "if(0)", {plain = true})
    else
        -- remove ucrt hardcode
        io.replace("CMakeLists.txt", "$<$<AND:$<CONFIG:Debug>,$<BOOL:${STEAMAUDIO_STATIC_RUNTIME}>>:/MTd>", "", {plain = true})
        io.replace("CMakeLists.txt", "$<$<AND:$<CONFIG:Debug>,$<NOT:$<BOOL:${STEAMAUDIO_STATIC_RUNTIME}>>>:/MDd>", "", {plain = true})
        io.replace("CMakeLists.txt", "$<$<AND:$<NOT:$<CONFIG:Debug>>,$<BOOL:${STEAMAUDIO_STATIC_RUNTIME}>>:/MT>", "", {plain = true})
        io.replace("CMakeLists.txt", "$<$<AND:$<NOT:$<CONFIG:Debug>>,$<NOT:$<BOOL:${STEAMAUDIO_STATIC_RUNTIME}>>>:/MD>", "", {plain = true})
        io.replace("CMakeLists.txt", "$<IF:$<CONFIG:Debug>,_DEBUG,NDEBUG>", "", {plain = true})
    
        -- remove lto hardcode
        io.replace("CMakeLists.txt", "$<$<CONFIG:Release>:/GL>", "", {plain = true})
    end

    -- remove zlib hardcode
    io.replace("build/FindMySOFA.cmake", "set(ZLIB_ROOT ${CMAKE_HOME_DIRECTORY}/deps/zlib/lib/${IPL_BIN_SUBDIR}/release)", "", {plain = true})
    io.replace("build/FindMySOFA.cmake", "set(ZLIB_INCLUDE_DIR ${CMAKE_HOME_DIRECTORY}/deps/zlib/include)", "", {plain = true})
    -- https://github.com/ValveSoftware/steam-audio/pull/399
    io.replace("src/core/profiler.h", [[#include "memory_allocator.h"]], [[
        #include "memory_allocator.h"
        #include <chrono>
    ]], {plain = true})

    io.replace("src/core/CMakeLists.txt", "get_bin_subdir(IPL_BIN_SUBDIR)", "set(IPL_BIN_SUBDIR )", {plain = true})
    -- remove symbol install command
    io.replace("src/core/CMakeLists.txt", 
[[    install(
        FILES       ${CMAKE_CURRENT_BINARY_DIR}/$<CONFIG>/phonon.pdb
        DESTINATION symbols/${IPL_BIN_SUBDIR}
    )]], "", {plain = true})
    io.replace("src/core/CMakeLists.txt", 
[[    install(
        FILES       ${CMAKE_CURRENT_BINARY_DIR}/libphonon.so.dbg
        DESTINATION symbols/${IPL_BIN_SUBDIR}
    )]], "", {plain = true})

    -- remove deps dll install command
    io.replace("src/core/CMakeLists.txt", 
[[    install(
        FILES       ${CMAKE_HOME_DIRECTORY}/deps/trueaudionext/bin/windows-x64/$<LOWER_CASE:$<CONFIG>>/TrueAudioNext.dll
                    ${CMAKE_HOME_DIRECTORY}/deps/trueaudionext/bin/windows-x64/$<LOWER_CASE:$<CONFIG>>/GPUUtilities.dll
        DESTINATION lib/${IPL_BIN_SUBDIR}
    )]], "", {plain = true})
end
