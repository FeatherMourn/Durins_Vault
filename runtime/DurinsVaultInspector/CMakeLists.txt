cmake_minimum_required(VERSION 3.22)

set(TARGET DurinsVaultInspector)
project(${TARGET})

add_library(${TARGET} SHARED
    src/dllmain.cpp
)

target_link_libraries(${TARGET} PRIVATE UE4SS)
target_compile_options(${TARGET} PRIVATE $<$<CXX_COMPILER_ID:MSVC>:/utf-8>)
