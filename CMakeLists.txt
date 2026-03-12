cmake_minimum_required(VERSION 3.20)

project(CViewer VERSION 0.1.0 LANGUAGES C CXX)

set(
    CMAKE_POLICY_VERSION_MINIMUM
    3.5
    CACHE STRING
    "Policy baseline for legacy third-party CMake projects on CMake 4+."
    FORCE
)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS OFF)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

find_package(OpenGL REQUIRED)

include(FetchContent)

set(GLFW_BUILD_DOCS OFF CACHE BOOL "" FORCE)
set(GLFW_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(GLFW_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
set(GLFW_INSTALL OFF CACHE BOOL "" FORCE)

FetchContent_Declare(
    glfw
    GIT_REPOSITORY https://gitee.com/mirrors/glfw.git
    GIT_TAG master
)
FetchContent_MakeAvailable(glfw)

set(BUILD_OSG_APPLICATIONS OFF CACHE BOOL "" FORCE)
set(BUILD_OSG_EXAMPLES OFF CACHE BOOL "" FORCE)
set(BUILD_OSG_PLUGINS_BY_DEFAULT ON CACHE BOOL "" FORCE)
set(BUILD_DOCUMENTATION OFF CACHE BOOL "" FORCE)
set(BUILD_OSG_PLUGIN_CFG OFF CACHE BOOL "" FORCE)
set(BUILD_OSG_PLUGIN_OBJ OFF CACHE BOOL "" FORCE)

FetchContent_Declare(
    openscenegraph
    GIT_REPOSITORY https://gitee.com/mirrors/OpenSceneGraph.git
    GIT_TAG master
)
FetchContent_MakeAvailable(openscenegraph)

set(CVIEWER_OSG_TARGET "")
if(TARGET osg)
    set(CVIEWER_OSG_TARGET osg osgDB)
endif()

if(NOT CVIEWER_OSG_TARGET)
    message(FATAL_ERROR "OpenSceneGraph target 'osg' was not created.")
endif()

file(
    GLOB_RECURSE CVIEWER_SOURCES
    CONFIGURE_DEPENDS
    src/*.c
    src/*.cc
    src/*.cpp
    src/*.cxx
)

if(CVIEWER_SOURCES)
    add_executable(${PROJECT_NAME} ${CVIEWER_SOURCES})
    # OSG provides headers in source/include and generates osg/Config, osg/Version in binary/include.
    target_include_directories(
        ${PROJECT_NAME}
        PRIVATE
            include
            ${openscenegraph_BINARY_DIR}/include
            ${GLFW_SOURCE_DIR}/deps
    )
    target_link_libraries(${PROJECT_NAME} PRIVATE glfw OpenGL::GL ${CVIEWER_OSG_TARGET})

    set(CVIEWER_SHADER_SOURCE_DIR "${CMAKE_SOURCE_DIR}/shader")
    if(EXISTS "${CVIEWER_SHADER_SOURCE_DIR}")
        add_custom_command(
            TARGET ${PROJECT_NAME}
            POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E make_directory "$<TARGET_FILE_DIR:${PROJECT_NAME}>/shader"
            COMMAND ${CMAKE_COMMAND} -E copy_directory
                "${CVIEWER_SHADER_SOURCE_DIR}"
                "$<TARGET_FILE_DIR:${PROJECT_NAME}>/shader"
            COMMENT "Copying shader directory to output bin folder"
        )
    endif()
else()
    message(STATUS "No source files found in src/. Add code under src/ to build ${PROJECT_NAME}.")
endif()
