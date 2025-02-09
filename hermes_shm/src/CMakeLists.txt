cmake_minimum_required(VERSION 3.10)
project(hermes_shm)

set(CMAKE_CXX_STANDARD 17)

##################Build HermesShm main packages
add_library(hermes_shm_data_structures
        ${CMAKE_CURRENT_SOURCE_DIR}/thread/mutex.cc
        ${CMAKE_CURRENT_SOURCE_DIR}/thread/rwlock.cc
        ${CMAKE_CURRENT_SOURCE_DIR}/memory/malloc_allocator.cc
        ${CMAKE_CURRENT_SOURCE_DIR}/memory/stack_allocator.cc
        ${CMAKE_CURRENT_SOURCE_DIR}/memory/memory_manager.cc
        ${CMAKE_CURRENT_SOURCE_DIR}/data_structure_singleton.cc)
target_link_libraries(hermes_shm_data_structures
        yaml-cpp pthread -lrt -ldl)

##################Install HermesShm
install(TARGETS
        hermes_shm_data_structures
        EXPORT
        ${HERMES_EXPORTED_TARGETS}
        LIBRARY DESTINATION ${HERMES_INSTALL_LIB_DIR}
        ARCHIVE DESTINATION ${HERMES_INSTALL_LIB_DIR}
        RUNTIME DESTINATION ${HERMES_INSTALL_BIN_DIR})

##################COVERAGE
if(HERMES_ENABLE_COVERAGE)
    set_coverage_flags(hermes_shm_data_structures)
endif()

#-----------------------------------------------------------------------------
# Export all exported targets to the build tree for use by parent project
#-----------------------------------------------------------------------------
set(HERMES_EXPORTED_LIBS
        hermes_shm_data_structures
        ${HERMES_EXPORTED_LIBS})
if(NOT HERMES_EXTERNALLY_CONFIGURED)
    EXPORT (
        TARGETS
        ${HERMES_EXPORTED_LIBS}
        FILE
        ${HERMES_EXPORTED_TARGETS}.cmake
    )
endif()