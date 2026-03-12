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
include(ExternalProject)

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

set(CVIEWER_OSG_PREFIX_DIR "${CMAKE_BINARY_DIR}/_deps/openscenegraph")
set(CVIEWER_OSG_INSTALL_DIR "${CMAKE_BINARY_DIR}/_deps/openscenegraph-install")
set(CVIEWER_OSG_LIB_DIR "${CVIEWER_OSG_INSTALL_DIR}/lib")

ExternalProject_Add(
    openscenegraph_ep
    PREFIX "${CVIEWER_OSG_PREFIX_DIR}"
    GIT_REPOSITORY https://gitee.com/mirrors/OpenSceneGraph.git
    GIT_TAG master
    UPDATE_DISCONNECTED TRUE
    CMAKE_ARGS
        -DCMAKE_POLICY_VERSION_MINIMUM=3.5
        -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
        -DCMAKE_C_STANDARD:STRING=${CMAKE_C_STANDARD}
        -DCMAKE_CXX_STANDARD:STRING=${CMAKE_CXX_STANDARD}
        -DBUILD_OSG_APPLICATIONS:BOOL=OFF
        -DBUILD_OSG_EXAMPLES:BOOL=OFF
        -DBUILD_DOCUMENTATION:BOOL=OFF
        -DBUILD_OSG_PLUGINS_BY_DEFAULT:BOOL=ON
        -DBUILD_OSG_PLUGIN_CFG:BOOL=OFF
        -DBUILD_OSG_PLUGIN_OBJ:BOOL=OFF
    INSTALL_DIR "${CVIEWER_OSG_INSTALL_DIR}"
)

add_library(cviewer_osg INTERFACE)
target_include_directories(cviewer_osg INTERFACE "${CVIEWER_OSG_INSTALL_DIR}/include")

if(WIN32)
    target_link_libraries(
        cviewer_osg
        INTERFACE
            "$<$<CONFIG:Debug>:${CVIEWER_OSG_LIB_DIR}/OpenThreadsd.lib>"
            "$<$<CONFIG:Debug>:${CVIEWER_OSG_LIB_DIR}/osgd.lib>"
            "$<$<CONFIG:Debug>:${CVIEWER_OSG_LIB_DIR}/osgDBd.lib>"
            "$<$<CONFIG:Release>:${CVIEWER_OSG_LIB_DIR}/OpenThreads.lib>"
            "$<$<CONFIG:Release>:${CVIEWER_OSG_LIB_DIR}/osg.lib>"
            "$<$<CONFIG:Release>:${CVIEWER_OSG_LIB_DIR}/osgDB.lib>"
            "$<$<CONFIG:RelWithDebInfo>:${CVIEWER_OSG_LIB_DIR}/OpenThreadsrd.lib>"
            "$<$<CONFIG:RelWithDebInfo>:${CVIEWER_OSG_LIB_DIR}/osgrd.lib>"
            "$<$<CONFIG:RelWithDebInfo>:${CVIEWER_OSG_LIB_DIR}/osgDBrd.lib>"
            "$<$<CONFIG:MinSizeRel>:${CVIEWER_OSG_LIB_DIR}/OpenThreadss.lib>"
            "$<$<CONFIG:MinSizeRel>:${CVIEWER_OSG_LIB_DIR}/osgs.lib>"
            "$<$<CONFIG:MinSizeRel>:${CVIEWER_OSG_LIB_DIR}/osgDBs.lib>"
    )
else()
    target_link_directories(cviewer_osg INTERFACE "${CVIEWER_OSG_LIB_DIR}")
    target_link_libraries(cviewer_osg INTERFACE OpenThreads osg osgDB)
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
            ${glfw_SOURCE_DIR}/deps
    )
    target_link_libraries(${PROJECT_NAME} PRIVATE glfw OpenGL::GL cviewer_osg)
    add_dependencies(${PROJECT_NAME} openscenegraph_ep)

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
