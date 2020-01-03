add_library(libproject src/project.cpp)
target_include_directories(libproject PUBLIC
    "${CMAKE_CURRENT_SOURCE_DIR}/include")
set_compiler_options(libproject)

add_subdirectory(test)
