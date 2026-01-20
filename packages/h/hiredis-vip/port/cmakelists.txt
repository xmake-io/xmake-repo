cmake_minimum_required(VERSION 3.16)
project(hiredis-vip LANGUAGES C)

file(READ "${CMAKE_CURRENT_SOURCE_DIR}/hircluster.h" HIRCLUSTER_H)
string(REGEX MATCH "HIREDIS_VIP_MAJOR[ \t]+([0-9]+)" _ ${HIRCLUSTER_H})
set(HIREDIS_VIP_MAJOR "${CMAKE_MATCH_1}")
string(REGEX MATCH "HIREDIS_VIP_MINOR[ \t]+([0-9]+)" _ ${HIRCLUSTER_H})
set(HIREDIS_VIP_MINOR "${CMAKE_MATCH_1}")
string(REGEX MATCH "HIREDIS_VIP_PATCH[ \t]+([0-9]+)" _ ${HIRCLUSTER_H})
set(HIREDIS_VIP_PATCH "${CMAKE_MATCH_1}")

option(BUILD_SHARED_LIBS "Build shared library" ON)

set(SOURCES
    net.c
    hiredis.c
    sds.c
    async.c
    read.c
    hiarray.c
    hiutil.c
    command.c
    crc16.c
    adlist.c
    hircluster.c
    dict.c
)

add_library(hiredis_vip ${SOURCES})
target_include_directories(hiredis_vip
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
        $<INSTALL_INTERFACE:include/hiredis-vip>
)
target_compile_features(hiredis_vip PRIVATE c_std_99)
target_compile_options(hiredis_vip PRIVATE -Wall -Wstrict-prototypes -Wwrite-strings)

if(APPLE AND BUILD_SHARED_LIBS)
    set_target_properties(hiredis_vip PROPERTIES
        MACOSX_RPATH ON
        INSTALL_NAME_DIR "@rpath"
        OUTPUT_NAME "hiredis_vip"
        VERSION "${HIREDIS_VIP_MAJOR}.${HIREDIS_VIP_MINOR}.${HIREDIS_VIP_PATCH}"
        SOVERSION "${HIREDIS_VIP_MAJOR}"
    )
else()
    set_target_properties(hiredis_vip PROPERTIES
        OUTPUT_NAME "hiredis_vip"
        VERSION "${HIREDIS_VIP_MAJOR}.${HIREDIS_VIP_MINOR}.${HIREDIS_VIP_PATCH}"
        SOVERSION "${HIREDIS_VIP_MAJOR}"
    )
endif()

install(DIRECTORY
    adapters
    DESTINATION include/hiredis-vip
)
install(FILES
    hiredis.h async.h read.h sds.h hiutil.h hiarray.h dict.h adlist.h fmacros.h hircluster.h
    DESTINATION include/hiredis-vip
)

install(TARGETS hiredis_vip
    EXPORT hiredis_vipTargets
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
    RUNTIME DESTINATION bin
)

configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/hiredis_vip.pc.in
    ${CMAKE_CURRENT_BINARY_DIR}/hiredis_vip.pc
    @ONLY
)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/hiredis_vip.pc DESTINATION lib/pkgconfig)

install(EXPORT hiredis_vipTargets
    FILE hiredis_vipTargets.cmake
    NAMESPACE hiredis_vip::
    DESTINATION lib/cmake/hiredis_vip
)
