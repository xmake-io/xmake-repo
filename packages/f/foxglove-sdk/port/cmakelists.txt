cmake_minimum_required(VERSION 3.20)
project(foxglove-sdk-xmake LANGUAGES CXX)

include(GNUInstallDirs)

option(FOXGLOVE_WRAPPER_SHARED "Build the C++ wrapper as a shared library" OFF)
option(FOXGLOVE_REMOTE_ACCESS "Enable Foxglove Remote Access" OFF)

if(FOXGLOVE_REMOTE_ACCESS AND NOT FOXGLOVE_WRAPPER_SHARED)
    message(FATAL_ERROR "Foxglove Remote Access requires a shared C++ wrapper")
endif()

find_package(foxglove-sdk CONFIG REQUIRED HINTS "${CMAKE_CURRENT_SOURCE_DIR}")

if(FOXGLOVE_WRAPPER_SHARED)
    set(_foxglove_wrapper_type SHARED)
else()
    set(_foxglove_wrapper_type STATIC)
endif()

foxglove_sdk_add_cpp_library(
    foxglove_cpp
    TYPE ${_foxglove_wrapper_type}
    REMOTE_ACCESS ${FOXGLOVE_REMOTE_ACCESS}
)

install(
    TARGETS foxglove_cpp
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
install(DIRECTORY include/ DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})

if(NOT FOXGLOVE_WRAPPER_SHARED)
    install(
        FILES "${CMAKE_CURRENT_SOURCE_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}foxglove${CMAKE_STATIC_LIBRARY_SUFFIX}"
        DESTINATION ${CMAKE_INSTALL_LIBDIR}
    )
elseif(FOXGLOVE_REMOTE_ACCESS)
    if(WIN32)
        install(FILES "${CMAKE_CURRENT_SOURCE_DIR}/lib/foxglove.dll" DESTINATION ${CMAKE_INSTALL_BINDIR})
    else()
        install(
            FILES "${CMAKE_CURRENT_SOURCE_DIR}/lib/${CMAKE_SHARED_LIBRARY_PREFIX}foxglove${CMAKE_SHARED_LIBRARY_SUFFIX}"
            DESTINATION ${CMAKE_INSTALL_LIBDIR}
        )
    endif()
endif()
