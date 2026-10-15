cmake_minimum_required(VERSION 3.25)

project(openroach LANGUAGES CXX)

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
