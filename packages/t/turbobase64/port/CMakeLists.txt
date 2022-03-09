cmake_minimum_required(VERSION 3.15)

project(turbobase64 C)

if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release)
endif()

# Run cmake -D<OPTION>=ON|OFF to turn on/off options.
# Usage example:
#     cmake -B build -S . -DNCHECK=ON
#     cmake --build build
option(BUILD_SHARED_LIBS "Build shared libraries" OFF)
option(NCHECK "Dinsable for checking for more fast decoding" OFF)
# default=partial checking, detect allmost all errors
option(FULLCHECK "Enable full base64 checking" OFF)
option(USE_AVX512 "Enable AVX512" OFF)
option(BUILD_APP "Build executables" OFF)

message(STATUS "Configuring with CMAKE_SYSTEM_PROCESSOR ${CMAKE_SYSTEM_PROCESSOR}")
if(${CMAKE_SYSTEM_PROCESSOR} STREQUAL "x86_64")
    set(ARCH_AMD64 ON)
elseif(${CMAKE_SYSTEM_PROCESSOR} STREQUAL "aarch64")
    set(ARCH_AARCH64 ON)
elseif(${CMAKE_SYSTEM_PROCESSOR} STREQUAL "ppc64le")
    set(ARCH_PPC64LE ON)
endif()

set(CMAKE_C_FLAGS_RELEASE "-O3")
set(CMAKE_C_FLAGS_DEBUG "-O0 -ggdb")

# Set compiler options.
if(NCHECK)
    add_compile_definitions(NB64CHECK)
endif()
if(FULLCHECK)
    add_compile_definitions(DB64CHECK)
endif()
if(USE_AVX512)
    add_compile_definitions(USE_AVX512)
endif()

if(ARCH_PPC64LE)
    set(MARCH "-march=power9 -mtune=power9")
    set(MSSE "-D__SSSE3__")
elseif(ARCH_AARCH64)
    set(MARCH "-march=armv8-a")
else()
    set(MARCH "-march=native")
    set(MSSE "-mssse3")
endif()

# Object library is just a bunch of object files.
add_library(_b64_scalar OBJECT turbob64c.c turbob64d.c)
target_compile_options(_b64_scalar PRIVATE ${MARCH} -falign-loops)

# turbob64v128.c contains code for SSE, AVX, NEON, Power9.
# It's compiled twice with different flags.
add_library(_b64_v128 OBJECT turbob64v128.c)
target_compile_options(_b64_v128 PRIVATE ${MSSE} -falign-loops)

# Use a list to collect all object libraries.
set(_b64_objs _b64_scalar _b64_v128)

if(ARCH_AMD64)
    # Compile turbob64v128.c for the second time.
    add_library(_b64_avx OBJECT turbob64v128.c)
    target_compile_options(_b64_avx PRIVATE -march=corei7-avx -mtune=corei7-avx -mno-aes -fstrict-aliasing)
    list(APPEND _b64_objs _b64_avx)

    add_library(_b64_v256 OBJECT turbob64v256.c)
    target_compile_options(_b64_v256 PRIVATE -march=haswell -fstrict-aliasing -falign-loops)
    list(APPEND _b64_objs _b64_v256)
endif()

if(BUILD_SHARED_LIBS)
    add_library(base64 SHARED)
else()
    add_library(base64 STATIC)
endif()

foreach(_obj ${_b64_objs})
    set_target_properties(${_obj} PROPERTIES POSITION_INDEPENDENT_CODE ${BUILD_SHARED_LIBS})
    target_sources(base64 PRIVATE $<TARGET_OBJECTS:${_obj}>)
endforeach()

# The XCODE fix is from https://github.com/ClickHouse/ClickHouse/blob/cf7d354a693f15fc5941edbf39e295d0bf8de21c/contrib%2Fbase64-cmake%2FCMakeLists.txt#L46-L54
if(XCODE OR XCODE_VERSION)
    # https://gitlab.kitware.com/cmake/cmake/issues/17457
    # Some native build systems may not like targets that have only object files, so consider adding at least one real source file
    # This applies to Xcode.
    if(NOT EXISTS "${CMAKE_CURRENT_BINARY_DIR}/dummy.c")
        file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/dummy.c" "")
    endif()
    target_sources(base64 PRIVATE "${CMAKE_CURRENT_BINARY_DIR}/dummy.c")
endif()

if(BUILD_APP)
    add_executable(tb64app tb64app.c)
    target_link_libraries(tb64app base64)
endif()

# Set package information.
set(PACKAGE_NAME ${PROJECT_NAME})
set(PACKAGE_NAMESPACE "turbo::")

# For CMAKE_INSTALL_{INCLUDEDIR,LIBDIR} etc.
include(GNUInstallDirs)
set(CONFIG_INSTALL_DIR "${CMAKE_INSTALL_LIBDIR}/cmake/${PACKAGE_NAME}")

# Please refer "Modern CMake" on how to install a library.
# https://cliutils.gitlab.io/modern-cmake/chapters/install/installing.html
# Also refer to cmake documentation
# https://cmake.org/cmake/help/latest/guide/importing-exporting/index.html

# Set PUBLIC_HEADER property for install(TARGETS) to install header file.
set_target_properties(base64 PROPERTIES PUBLIC_HEADER "${CMAKE_SOURCE_DIR}/turbob64.h")
# Set includes destination for install(TARGETS), which will be added
# to INTERFACE_INCLUDE_DIRECTORIES target property.
# So user only need to call "target_link_libraries(turbo::base64)", without
# needing to set include directories.
target_include_directories(
    base64 SYSTEM PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}> # For being used from add_subdirectory.
    $<INSTALL_INTERFACE:include> # When being used from an installation.
)

# Installs library along with header files.
# Also associates the installed target files with an export.
install(
    TARGETS base64
    EXPORT ${PACKAGE_NAME}-targets
    PUBLIC_HEADER DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/${PACKAGE_NAME}"
)

# Generates and installs cmake config files containing exported targets.
install(
    EXPORT ${PACKAGE_NAME}-targets
    DESTINATION "${CONFIG_INSTALL_DIR}"
    NAMESPACE ${PACKAGE_NAMESPACE}
)

# Generate cmake config-files from template.
include(CMakePackageConfigHelpers)
configure_package_config_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake/${PACKAGE_NAME}-config.cmake.in"
    ${PACKAGE_NAME}-config.cmake
    INSTALL_DESTINATION "${CONFIG_INSTALL_DIR}"
    #NO_CHECK_REQUIRED_COMPONENTS_MACRO
    # PATH_VARS can be referenced in config template file with PACKAGE_<var>.
    PATH_VARS CMAKE_INSTALL_INCLUDEDIR CMAKE_INSTALL_LIBDIR
    )
install(
    FILES
    "${CMAKE_CURRENT_BINARY_DIR}/${PACKAGE_NAME}-config.cmake"
    DESTINATION "${CONFIG_INSTALL_DIR}"
)

