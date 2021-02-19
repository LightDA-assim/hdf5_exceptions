find_package(fortran_exceptions REQUIRED)
find_package(HDF5 COMPONENTS Fortran REQUIRED)

set(HDF5_EXCEPTIONS_SOURCES hdf5_exceptions.F90)
add_library(hdf5_exceptions SHARED ${HDF5_EXCEPTIONS_SOURCES})
target_include_directories(hdf5_exceptions INTERFACE
  $<INSTALL_INTERFACE:${Fortran_MODULE_DIRECTORY}>)
target_link_libraries(hdf5_exceptions PUBLIC hdf5::hdf5_fortran)
target_link_libraries(hdf5_exceptions PUBLIC fortran_exceptions)
install(TARGETS hdf5_exceptions EXPORT hdf5_exceptions)

set(ALL_SOURCES ${HDF5_EXCEPTIONS_SOURCES})

# Prepend path to sources and propagate to parent scope
list(TRANSFORM ALL_SOURCES PREPEND "src/")
set(ALL_SOURCES ${ALL_SOURCES} PARENT_SCOPE)
