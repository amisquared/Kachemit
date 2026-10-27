cmake_minimum_required(VERSION 3.16)
project(
    kachemit
    VERSION 0.1.0
    LANGUAGES CXX
)

find_package(ECM 6.0.0 REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH})

include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings NO_POLICY_SCOPE)
include(ECMQmlModule)

find_package(Qt6 6.5 REQUIRED COMPONENTS Core Qml)

add_library(kachemit)
ecm_add_qml_module(
    kachemit 
    URI "io.github.amisquared.kachemit" 
    VERSION 1.0 
    GENERATE_PLUGIN_SOURCE PLUGIN_TARGET kachemit
)
target_sources(kachemit PRIVATE src/kachemit.cpp src/kachemit.h)
target_include_directories(kachemit PRIVATE src)
target_link_libraries(kachemit PRIVATE Qt6::Qml)
ecm_finalize_qml_module(kachemit)

install(DIRECTORY package/
    DESTINATION ${KDE_INSTALL_DATADIR}/plasma/plasmoids/io.github.amisquared.kachemit
)