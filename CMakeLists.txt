cmake_minimum_required(VERSION 3.25)

project(openroach LANGUAGES CXX)

include(GNUInstallDirs)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

add_executable(openroach src/main.cpp)

install(TARGETS openroach)
install(FILES LICENSE README.md CHANGELOG.md TYPE DOC)

enable_testing()

add_test(NAME prints-hello-world COMMAND openroach)
set_tests_properties(prints-hello-world PROPERTIES
    PASS_REGULAR_EXPRESSION "^hello world\n$")

add_test(NAME installs-into-its-own-doc-directory
    COMMAND ${CMAKE_COMMAND}
        -DBUILD_DIR=${CMAKE_BINARY_DIR}
        -DPREFIX=${CMAKE_BINARY_DIR}/install-layout
        -P ${CMAKE_SOURCE_DIR}/tests/install-layout.cmake)
