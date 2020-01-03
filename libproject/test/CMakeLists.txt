add_executable(libproject_test main.cpp)
target_link_libraries(libproject_test PRIVATE libproject)
set_compiler_options(libproject_test)

add_test(NAME libproject_test COMMAND $<TARGET_FILE:libproject_test>)
