cmake_minimum_required(VERSION 3.10)

include(ExternalProject)

project(hdf5_exceptions)

enable_language(Fortran)

set(
  fortran_exceptions_GIT_URL
  "git@gitlab.hpc.mil:john.haiducek.ctr/fortran_exceptions.git" CACHE STRING
  "URL of fortran_exceptions git repository")

set(
  HDF5_GIT_URL
  "https://github.com/HDFGroup/hdf5.git" CACHE STRING
  "URL of HDF5 git repository")

find_package(HDF5 COMPONENTS Fortran)

if(NOT ${HDF5_FOUND})
  ExternalProject_Add(
    HDF5
    GIT_REPOSITORY ${HDF5_GIT_URL}
    GIT_TAG hdf5-1_10_7
    UPDATE_COMMAND ""
    UPDATE_DISCONNECTED OFF
    CMAKE_CACHE_ARGS
      -DHDF5_BUILD_FORTRAN:BOOL=ON
      -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}/HDF5)
  set(HDF5_DIR ${CMAKE_CURRENT_BINARY_DIR}/HDF5/share/cmake/hdf5)
else()
  add_custom_target(HDF5)
endif()

ExternalProject_Add(
  fortran_exceptions
  GIT_REPOSITORY ${fortran_exceptions_GIT_URL}
  GIT_TAG main
  CMAKE_CACHE_ARGS
        -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}/fortran_exceptions)

ExternalProject_Add(hdf5_exceptions
  SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/.."
  CMAKE_CACHE_ARGS
    -Dfortran_exceptions_DIR:STRING=${CMAKE_CURRENT_BINARY_DIR}/fortran_exceptions/lib/cmake/fortran_exceptions
    -Dhdf5_DIR:PATH=${HDF5_DIR}
    -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}/hdf5_exceptions
  DEPENDS fortran_exceptions HDF5)
