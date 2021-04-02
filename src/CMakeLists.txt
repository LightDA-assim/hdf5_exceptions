find_package(fortran_exceptions REQUIRED)
find_package(HDF5 COMPONENTS Fortran QUIET)
find_package(hdf5 COMPONENTS Fortran QUIET)

# Prevent older CMake versions from setting include directories with -isystem,
# which prevents gfortran from finding Fortran module files
set(CMAKE_NO_SYSTEM_FROM_IMPORTED ON)

set(HDF5_EXCEPTIONS_SOURCES hdf5_exceptions.F90)
add_library(hdf5_exceptions SHARED ${HDF5_EXCEPTIONS_SOURCES})
target_include_directories(hdf5_exceptions INTERFACE
  $<INSTALL_INTERFACE:${Fortran_MODULE_DIRECTORY}>)

if(TARGET "hdf5_fortran-static" )
  target_link_libraries(hdf5_exceptions PUBLIC hdf5_fortran-static)
elseif(TARGET "hdf5_fortran-shared")
  target_link_libraries(hdf5_exceptions PUBLIC hdf5_fortran-shared)
else()
  include(HDF5Targets)
  target_link_libraries(hdf5_exceptions PUBLIC hdf5::hdf5_fortran)
endif()

target_link_libraries(hdf5_exceptions PUBLIC fortran_exceptions)
install(TARGETS hdf5_exceptions
  EXPORT hdf5_exceptions
  LIBRARY DESTINATION lib ${CMAKE_INSTALL_LIBDIR})

set(ALL_SOURCES ${HDF5_EXCEPTIONS_SOURCES})

# Prepend path to sources and propagate to parent scope
list_transform_prepend(ALL_SOURCES "src/")
set(ALL_SOURCES ${ALL_SOURCES} PARENT_SCOPE)
