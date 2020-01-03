cmake_minimum_required(VERSION 3.13)
project(project VERSION 0.1 LANGUAGES CXX)

include(CTest)

include(cmake/set_compiler_options.cmake)

add_subdirectory(libproject)
