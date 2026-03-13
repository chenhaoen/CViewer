include(ExternalProject)

function(cviewer_configure_openscenegraph out_interface_target out_dependency_target)
    set(_osg_prefix_dir "${CMAKE_BINARY_DIR}/_deps/openscenegraph")
    set(_osg_install_dir "${CMAKE_BINARY_DIR}/_deps/openscenegraph-install")
    set(_osg_lib_dir "${_osg_install_dir}/lib")

    ExternalProject_Add(
        openscenegraph_ep
        PREFIX "${_osg_prefix_dir}"
        GIT_REPOSITORY https://gitee.com/mirrors/OpenSceneGraph.git
        GIT_TAG master
        UPDATE_DISCONNECTED TRUE
        CMAKE_ARGS
            -DCMAKE_POLICY_VERSION_MINIMUM=3.5
            -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
            -DCMAKE_C_STANDARD:STRING=${CMAKE_C_STANDARD}
            -DCMAKE_CXX_STANDARD:STRING=11
            -DBUILD_OSG_APPLICATIONS:BOOL=OFF
            -DBUILD_OSG_EXAMPLES:BOOL=OFF
            -DBUILD_DOCUMENTATION:BOOL=OFF
            -DBUILD_OSG_PLUGINS_BY_DEFAULT:BOOL=ON
            -DBUILD_OSG_PLUGIN_CFG:BOOL=OFF
            -DBUILD_OSG_PLUGIN_OBJ:BOOL=OFF
        INSTALL_DIR "${_osg_install_dir}"
    )

    add_library(cviewer_osg INTERFACE)
    target_include_directories(cviewer_osg INTERFACE "${_osg_install_dir}/include")

    if(WIN32)
        target_link_libraries(
            cviewer_osg
            INTERFACE
                "$<$<CONFIG:Debug>:${_osg_lib_dir}/OpenThreadsd.lib>"
                "$<$<CONFIG:Debug>:${_osg_lib_dir}/osgd.lib>"
                "$<$<CONFIG:Debug>:${_osg_lib_dir}/osgDBd.lib>"
                "$<$<CONFIG:Release>:${_osg_lib_dir}/OpenThreads.lib>"
                "$<$<CONFIG:Release>:${_osg_lib_dir}/osg.lib>"
                "$<$<CONFIG:Release>:${_osg_lib_dir}/osgDB.lib>"
                "$<$<CONFIG:RelWithDebInfo>:${_osg_lib_dir}/OpenThreadsrd.lib>"
                "$<$<CONFIG:RelWithDebInfo>:${_osg_lib_dir}/osgrd.lib>"
                "$<$<CONFIG:RelWithDebInfo>:${_osg_lib_dir}/osgDBrd.lib>"
                "$<$<CONFIG:MinSizeRel>:${_osg_lib_dir}/OpenThreadss.lib>"
                "$<$<CONFIG:MinSizeRel>:${_osg_lib_dir}/osgs.lib>"
                "$<$<CONFIG:MinSizeRel>:${_osg_lib_dir}/osgDBs.lib>"
        )
    else()
        target_link_directories(cviewer_osg INTERFACE "${_osg_lib_dir}")
        target_link_libraries(cviewer_osg INTERFACE OpenThreads osg osgDB)
    endif()

    set(${out_interface_target} cviewer_osg PARENT_SCOPE)
    set(${out_dependency_target} openscenegraph_ep PARENT_SCOPE)
endfunction()
