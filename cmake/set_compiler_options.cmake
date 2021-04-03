include_guard(GLOBAL)


include(CheckIPOSupported)
include(GenerateExportHeader)


function(_sco_set_strict target_name)
    check_cxx_compiler_flag(-Werror CXX_HAS_-Werror)

    if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU"
            OR CMAKE_CXX_COMPILER_ID STREQUAL "Clang"
            OR CMAKE_CXX_COMPILER_ID STREQUAL "AppleClang")
        set(CXX_HAS_-Werror 1 CACHE INTERNAL "CXX has -Werror")
    endif()

    string(TOUPPER "${CMAKE_PROJECT_NAME}" upper_project_name)
    option("${upper_project_name}_ENABLE_STRICT" "Make warnings errors" TRUE)

    if(${upper_project_name}_ENABLE_STRICT AND CXX_HAS_-Werror)
        target_compile_options("${target_name}" PRIVATE -Werror)
    endif()
endfunction()


function(_sco_set_ipo target_name)
    string(TOUPPER "${CMAKE_PROJECT_NAME}" upper_project_name)
    option("${upper_project_name}_ENABLE_IPO" "Enable IPO" TRUE)
    check_ipo_supported(RESULT ipo_supported LANGUAGES CXX)

    if(ipo_supported AND ${upper_project_name}_ENABLE_IPO)
        set_property(TARGET "${target_name}" PROPERTY
            INTERPROCEDURAL_OPTIMIZATION TRUE)
    endif()
endfunction()


function(_sco_set_compiler_options target_name)
    foreach(option IN LISTS ARGN)
        string(REPLACE " " "_" test_name "${option}")
        check_cxx_compiler_flag("${option}" "CXX_HAS_${test_name}")

        if(CXX_HAS_${test_name})
            target_compile_options("${target_name}" PRIVATE "${option}")
        endif()
    endforeach()
endfunction()


function(_sco_check_linker_flag flag out_var)
    set(CMAKE_REQUIRED_LINK_OPTIONS "${flag}")
    check_cxx_compiler_flag("" "${out_var}")
endfunction()


function(_sco_set_linker_options target_name scope)
    foreach(option IN LISTS ARGN)
        string(REPLACE " " "_" test_name "${option}")
        _sco_check_linker_flag("${option}" "CXX_LINKER_HAS_${test_name}")

        if(CXX_LINKER_HAS_${test_name})
            target_link_options("${target_name}" "${scope}" "${option}")
        endif()
    endforeach()
endfunction()


function(_sco_check_compiler_and_linker_flag flag out_var)
    set(CMAKE_REQUIRED_LINK_OPTIONS "${flag}")
    check_cxx_compiler_flag("${flag}" "${out_var}")
endfunction()


function(_sco_set_compiler_and_linker_options target_name scope)
    foreach(option IN LISTS ARGN)
        string(REPLACE " " "_" test_name "${option}")
        _sco_check_compiler_and_linker_flag(
            "${option}"
            "CXX_AND_CXX_LINKER_HAVE_${test_name}")

        if(CXX_AND_CXX_LINKER_HAVE_${test_name})
            target_compile_options("${target_name}" "${scope}" "${option}")
            target_link_options("${target_name}" "${scope}" "${option}")
        endif()
    endforeach()
endfunction()


function(_sco_set_sanitize target_name)
    string(TOUPPER "${CMAKE_PROJECT_NAME}" upper_project_name)
    option("${upper_project_name}_ENABLE_SANITIZE" "Enable sanitize" FALSE)

    if(${upper_project_name}_ENABLE_SANITIZE)
        _sco_set_compiler_and_linker_options("${target_name}" PUBLIC
            -fno-sanitize-recover=all
            -fsanitize=address
            -fsanitize=float-cast-overflow
            -fsanitize=float-divide-by-zero
            -fsanitize=undefined)

        get_target_property(target_type "${target_name}" TYPE)

        if (target_type STREQUAL "SHARED_LIBRARY")
            _sco_set_linker_options("${target_name}" PUBLIC -shared-libsan)
        endif()
    endif()
endfunction()


function(set_compiler_options target_name)
    set_target_properties("${target_name}" PROPERTIES
        BUILD_RPATH_USE_ORIGIN TRUE
        CXX_EXTENSIONS FALSE
        CXX_STANDARD 20
        CXX_STANDARD_REQUIRED TRUE
        CXX_VISIBILITY_PRESET hidden
        POSITION_INDEPENDENT_CODE TRUE
        PREFIX "")

    if(NOT CMAKE_SYSTEM_NAME STREQUAL "Darwin")
        set_property(TARGET "${target_name}" PROPERTY LINK_WHAT_YOU_USE TRUE)
    endif()

    _sco_set_compiler_options("${target_name}" -Wfatal-errors)

    _sco_set_compiler_options("${target_name}"
        -Wall
        -Weffc++
        -Weverything
        -Wextra
        -Wpedantic
        /permissive-)

    _sco_set_compiler_options("${target_name}"
        -Wabi-tag
        -Waggregate-return
        -Waligned-new=all
        -Walloca
        -Warray-bounds=2
        -Wattribute-alias=2
        -Wcast-align=strict
        -Wcast-qual
        -Wcatch-value=3
        -Wcomma-subscript
        -Wconditionally-supported
        -Wconversion
        -Wctor-dtor-privacy
        -Wdate-time
        -Wdeprecated-copy-dtor
        -Wdisabled-optimization
        -Wdouble-promotion
        -Wduplicated-branches
        -Wduplicated-cond
        -Wextra-semi
        -Wfloat-equal
        -Wformat=2
        -Wformat-overflow=2
        -Wformat-signedness
        -Wformat-truncation=2
        -Wframe-larger-than=1024
        -Wimplicit-fallthrough=5
        -Winline
        -Winvalid-pch
        -Wlarger-than=1024
        -Wlogical-op
        -Wmismatched-tags
        -Wmissing-braces
        -Wmissing-declarations
        -Wmissing-include-dirs
        -Wmultiple-inheritance
        -Wnoexcept
        -Wnull-dereference
        -Wold-style-cast
        -Woverloaded-virtual
        -Wpacked
        -Wpadded
        -Wplacement-new=2
        -Wredundant-decls
        -Wredundant-tags
        -Wregister
        -Wshadow
        -Wshift-overflow=2
        -Wsign-conversion
        -Wsign-promo
        -Wstack-protector
        -Wstack-usage=1024
        -Wstrict-null-sentinel
        -Wstrict-overflow=5
        -Wstringop-overflow=4
        -Wsuggest-attribute=format
        -Wsuggest-attribute=noreturn
        -Wsuggest-final-methods
        -Wsuggest-final-types
        -Wsuggest-override
        -Wswitch-default
        -Wswitch-enum
        -Wtrampolines
        -Wundef
        -Wuninitialized
        -Wunused-macros
        -Wuseless-cast
        -Wvector-operation-performance
        -Wvirtual-inheritance
        -Wvolatile
        -Wzero-as-null-pointer-constant)

    _sco_set_compiler_options("${target_name}" -Wno-c++98-compat)

    _sco_set_compiler_options("${target_name}"
        --param=ssp-buffer-size=4
        -fasynchronous-unwind-tables
        -fcf-protection=full
        -fdevirtualize-at-ltrans
        -fno-plt
        -fno-semantic-interposition
        -fstack-clash-protection
        -fstack-protector-all
        -ftrapv
        -mshstk
        -pipe)

    _sco_set_linker_options("${target_name}" PRIVATE
        -Wl,--sort-common
        -Wl,-z,defs
        -Wl,-z,noexecstack
        -Wl,-z,now
        -Wl,-z,relro)

    _sco_set_ipo("${target_name}")
    _sco_set_sanitize("${target_name}")
    _sco_set_strict("${target_name}")

    target_compile_definitions("${target_name}" PRIVATE
        _GLIBCXX_ASSERTIONS
        $<$<NOT:$<CONFIG:Debug>>:_FORTIFY_SOURCE=2>
        $<$<CONFIG:Debug>:_GLIBCXX_DEBUG_PEDANTIC>)

    target_compile_definitions("${target_name}" PUBLIC
        $<$<CONFIG:Debug>:_GLIBCXX_DEBUG>)

    if(NOT CMAKE_CXX_COMPILER_ID STREQUAL "AppleClang")
        target_compile_definitions("${target_name}" PUBLIC
            $<$<CONFIG:Debug>:_LIBCPP_DEBUG=1>)
    endif()

    get_target_property(target_type "${target_name}" TYPE)

    if(NOT target_type STREQUAL "EXECUTABLE")
        generate_export_header("${target_name}")
        target_include_directories("${target_name}" PUBLIC
            "${CMAKE_CURRENT_BINARY_DIR}")
    endif()
endfunction()
