include(ExternalProject)

function(cviewer_configure_glfw out_interface_target out_dependency_target)
    set(_glfw_prefix_dir "${CMAKE_BINARY_DIR}/_deps/glfw")

    ExternalProject_Add(
        glfw_ep
        PREFIX "${_glfw_prefix_dir}"
        GIT_REPOSITORY https://gitee.com/mirrors/glfw.git
        GIT_TAG master
        UPDATE_DISCONNECTED TRUE
        CMAKE_ARGS
            -DCMAKE_C_STANDARD:STRING=${CMAKE_C_STANDARD}
            -DCMAKE_CXX_STANDARD:STRING=${CMAKE_CXX_STANDARD}
            -DBUILD_SHARED_LIBS:BOOL=OFF
            -DGLFW_BUILD_DOCS:BOOL=OFF
            -DGLFW_BUILD_TESTS:BOOL=OFF
            -DGLFW_BUILD_EXAMPLES:BOOL=OFF
            -DGLFW_INSTALL:BOOL=OFF
        INSTALL_COMMAND ""
    )

    ExternalProject_Get_Property(glfw_ep SOURCE_DIR BINARY_DIR)

    if(WIN32)
        if(CMAKE_CONFIGURATION_TYPES)
            set(_glfw_library "${BINARY_DIR}/src/$<CONFIG>/glfw3.lib")
        else()
            set(_glfw_library "${BINARY_DIR}/src/glfw3.lib")
        endif()
    else()
        if(CMAKE_CONFIGURATION_TYPES)
            set(_glfw_library "${BINARY_DIR}/src/$<CONFIG>/libglfw3.a")
        else()
            set(_glfw_library "${BINARY_DIR}/src/libglfw3.a")
        endif()
    endif()

    add_library(cviewer_glfw INTERFACE)
    target_include_directories(
        cviewer_glfw
        INTERFACE
            "${SOURCE_DIR}/include"
            "${SOURCE_DIR}/deps"
    )
    target_link_libraries(cviewer_glfw INTERFACE "${_glfw_library}")

    set(${out_interface_target} cviewer_glfw PARENT_SCOPE)
    set(${out_dependency_target} glfw_ep PARENT_SCOPE)
endfunction()
