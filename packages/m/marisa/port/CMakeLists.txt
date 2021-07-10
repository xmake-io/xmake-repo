cmake_minimum_required(VERSION 3.1)
project(marisa CXX)

include(GNUInstallDirs)

option(BUILD_SHARED_LIBS "Build as shared library" OFF)
option(BUILD_TOOLS "Build tools" ON)
option(ENABLE_TESTS "Build and run tests" ON)

if(BUILD_SHARED_LIBS)
  set(MARISA_LIBRARY_TYPE SHARED)
else()
  set(MARISA_LIBRARY_TYPE STATIC)
endif(BUILD_SHARED_LIBS)

set(CMAKE_CXX_STANDARD 11)

if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Debug)
endif()

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall")
if(NOT MSVC)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Weffc++ -Wextra -Wconversion")
endif()

if(BUILD_SHARED_LIBS AND MSVC)
  set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS TRUE)
endif()

include_directories("${PROJECT_SOURCE_DIR}/include")
include_directories("${PROJECT_SOURCE_DIR}/lib")

add_library(io OBJECT
  "${PROJECT_SOURCE_DIR}/lib/marisa/grimoire/io/mapper.cc"
  "${PROJECT_SOURCE_DIR}/lib/marisa/grimoire/io/reader.cc"
  "${PROJECT_SOURCE_DIR}/lib/marisa/grimoire/io/writer.cc")

add_library(trie OBJECT
  "${PROJECT_SOURCE_DIR}/lib/marisa/grimoire/trie/tail.cc"
  "${PROJECT_SOURCE_DIR}/lib/marisa/grimoire/trie/louds-trie.cc")

add_library(vector OBJECT
  "${PROJECT_SOURCE_DIR}/lib/marisa/grimoire/vector/bit-vector.cc")

add_library(marisa ${MARISA_LIBRARY_TYPE}
  "${PROJECT_SOURCE_DIR}/lib/marisa/keyset.cc"
  "${PROJECT_SOURCE_DIR}/lib/marisa/trie.cc"
  "${PROJECT_SOURCE_DIR}/lib/marisa/agent.cc")
target_link_libraries(marisa PRIVATE io trie vector)
install(TARGETS marisa
  RUNTIME DESTINATION ${CMAKE_INSTALL_FULL_BINDIR}
  LIBRARY DESTINATION ${CMAKE_INSTALL_FULL_LIBDIR}
  ARCHIVE DESTINATION ${CMAKE_INSTALL_FULL_LIBDIR})

if(BUILD_TOOLS)
  add_library(cmdopt OBJECT "${PROJECT_SOURCE_DIR}/tools/cmdopt.cc")
  set(TOOLS
      marisa-benchmark
      marisa-build
      marisa-common-prefix-search
      marisa-dump
      marisa-lookup
      marisa-predictive-search
      marisa-reverse-lookup
  )
  foreach(TOOL ${TOOLS})
    add_executable(${TOOL} "${PROJECT_SOURCE_DIR}/tools/${TOOL}.cc")
    target_link_libraries(${TOOL} PRIVATE marisa cmdopt)
    install(TARGETS ${TOOL}
      RUNTIME DESTINATION ${CMAKE_INSTALL_FULL_BINDIR})
  endforeach(TOOL)
endif()

if(ENABLE_TESTS)
  enable_testing()
  set(TESTS
      base-test
      io-test
      trie-test
      vector-test
      marisa-test
  )
  foreach(TEST ${TESTS})
    add_executable(${TEST} "${PROJECT_SOURCE_DIR}/tests/${TEST}.cc")
    target_link_libraries(${TEST} PRIVATE marisa)
    add_test(${TEST} ${TEST})
  endforeach(TEST)
endif()

configure_file(
    ${PROJECT_SOURCE_DIR}/marisa.pc.in
    ${PROJECT_BINARY_DIR}/marisa.pc
    @ONLY)
install(FILES ${PROJECT_BINARY_DIR}/marisa.pc
  DESTINATION ${CMAKE_INSTALL_FULL_LIBDIR}/pkgconfig)

install(FILES "${PROJECT_SOURCE_DIR}/include/marisa.h"
  DESTINATION ${CMAKE_INSTALL_FULL_INCLUDEDIR})

file(GLOB marisa_other_header_files ${PROJECT_SOURCE_DIR}/include/marisa/*.h)
install(FILES ${marisa_other_header_files}
  DESTINATION ${CMAKE_INSTALL_FULL_INCLUDEDIR}/marisa)
