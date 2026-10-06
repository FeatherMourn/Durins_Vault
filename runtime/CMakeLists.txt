cmake_minimum_required(VERSION 3.22)

project(DurinsVaultNative)

if(NOT DEFINED UE4SS_SOURCE)
    message(FATAL_ERROR "UE4SS_SOURCE must point to an external UE4SS source checkout")
endif()

if(NOT EXISTS "${UE4SS_SOURCE}/CMakeLists.txt")
    message(FATAL_ERROR "UE4SS_SOURCE is not a CMake source tree: ${UE4SS_SOURCE}")
endif()

# UE4SS and its dependencies remain external and are never copied into this
# repository. The external project exports the UE4SS target consumed below.
add_subdirectory("${UE4SS_SOURCE}" "${CMAKE_BINARY_DIR}/ue4ss")
add_subdirectory(DurinsVaultInspector)

if(DEFINED MORIA_CPP_MOD_SOURCE)
    if(NOT EXISTS "${MORIA_CPP_MOD_SOURCE}/CMakeLists.txt")
        message(FATAL_ERROR "MORIA_CPP_MOD_SOURCE is not a CMake source tree: ${MORIA_CPP_MOD_SOURCE}")
    endif()
    add_subdirectory("${MORIA_CPP_MOD_SOURCE}" "${CMAKE_BINARY_DIR}/MoriaCppMod")
endif()
