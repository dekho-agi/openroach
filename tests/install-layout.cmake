# Installs the build into a scratch prefix and checks where each file lands.
#
#   cmake -DBUILD_DIR=<build dir> -DPREFIX=<scratch prefix> -P install-layout.cmake

file(REMOVE_RECURSE "${PREFIX}")
execute_process(
    COMMAND "${CMAKE_COMMAND}" --install "${BUILD_DIR}" --prefix "${PREFIX}"
    RESULT_VARIABLE result
    OUTPUT_QUIET)
if(NOT result EQUAL 0)
    message(FATAL_ERROR "cmake --install failed: ${result}")
endif()

foreach(path IN ITEMS
        bin/openroach
        share/doc/openroach/LICENSE
        share/doc/openroach/README.md
        share/doc/openroach/CHANGELOG.md)
    if(NOT EXISTS "${PREFIX}/${path}")
        message(FATAL_ERROR "not installed: ${path}")
    endif()
endforeach()
