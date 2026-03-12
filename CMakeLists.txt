cmake_minimum_required(VERSION 3.20)

project(CViewer VERSION 0.1.0 LANGUAGES C CXX)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS OFF)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

find_package(OpenGL REQUIRED)

include(cmake/GlfwExternal.cmake)
include(cmake/OpenSceneGraphExternal.cmake)

cviewer_configure_glfw(
    CVIEWER_GLFW_TARGET
    CVIEWER_GLFW_DEPENDENCY_TARGET
)

cviewer_configure_openscenegraph(
    CVIEWER_OSG_TARGET
    CVIEWER_OSG_DEPENDENCY_TARGET
)

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
    target_include_directories(
        ${PROJECT_NAME}
        PRIVATE
            include
    )
    target_link_libraries(${PROJECT_NAME} PRIVATE ${CVIEWER_GLFW_TARGET} OpenGL::GL ${CVIEWER_OSG_TARGET})
    add_dependencies(${PROJECT_NAME} ${CVIEWER_GLFW_DEPENDENCY_TARGET} ${CVIEWER_OSG_DEPENDENCY_TARGET})

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
