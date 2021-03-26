find_package(HDF5 COMPONENTS Fortran)

if (HDF5_FOUND)

  # Older versions of FindHDF5 (before CMake 3.19) don't export any targets.
  # We now check for HDF5 targets, and if they aren't found we create
  # imported targets using the result variables populated by FindHDF5

  if (NOT TARGET HDF5::HDF5)
    add_library(HDF5::HDF5 INTERFACE IMPORTED)
    string(REPLACE "-D" "" _hdf5_definitions "${HDF5_DEFINITIONS}")
    set_target_properties(HDF5::HDF5 PROPERTIES
      INTERFACE_LINK_LIBRARIES "${HDF5_LIBRARIES}"
      INTERFACE_INCLUDE_DIRECTORIES "${HDF5_INCLUDE_DIRS}"
      INTERFACE_COMPILE_DEFINITIONS "${_hdf5_definitions}")
    unset(_hdf5_definitions)
  endif ()

  foreach (hdf5_lang IN LISTS HDF5_LANGUAGE_BINDINGS)
    if (hdf5_lang STREQUAL "C")
      set(hdf5_target_name "hdf5")
    elseif (hdf5_lang STREQUAL "CXX")
      set(hdf5_target_name "hdf5_cpp")
    elseif (hdf5_lang STREQUAL "Fortran")
      set(hdf5_target_name "hdf5_fortran")
    else ()
      continue ()
    endif ()

    if (NOT TARGET "hdf5::${hdf5_target_name}")
      add_library("hdf5::${hdf5_target_name}" INTERFACE IMPORTED)
      string(REPLACE "-D" "" _hdf5_definitions "${HDF5_${hdf5_lang}_DEFINITIONS}")
      set_target_properties("hdf5::${hdf5_target_name}" PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${HDF5_${hdf5_lang}_INCLUDE_DIRS}"
        INTERFACE_COMPILE_DEFINITIONS "${HDF5_${hdf5_lang}_DEFINITIONS}"
        INTERFACE_LINK_LIBRARIES "${HDF5_${hdf5_lang}_LIBRARIES}")
    endif ()

    if (NOT HDF5_FIND_HL)
      continue ()
    endif ()

    if (hdf5_lang STREQUAL "C")
      set(hdf5_target_name "hdf5_hl")
    elseif (hdf5_lang STREQUAL "CXX")
      set(hdf5_target_name "hdf5_hl_cpp")
    elseif (hdf5_lang STREQUAL "Fortran")
      set(hdf5_target_name "hdf5_hl_fortran")
    else ()
      continue ()
    endif ()

    if (NOT TARGET "hdf5::${hdf5_target_name}")
      if (HDF5_COMPILER_NO_INTERROGATE)
        add_library("hdf5::${hdf5_target_name}" INTERFACE IMPORTED)
        string(REPLACE "-D" "" _hdf5_definitions "${HDF5_${hdf5_lang}_HL_DEFINITIONS}")
        set_target_properties("hdf5::${hdf5_target_name}" PROPERTIES
          INTERFACE_INCLUDE_DIRECTORIES "${HDF5_${hdf5_lang}_HL_INCLUDE_DIRS}"
          INTERFACE_COMPILE_DEFINITIONS "${_hdf5_definitions}")
      else()
        if (DEFINED "HDF5_${hdf5_target_name}_LIBRARY")
          set(_hdf5_location "${HDF5_${hdf5_target_name}_LIBRARY}")
        elseif (DEFINED "HDF5_${hdf5_lang}_HL_LIBRARY")
          set(_hdf5_location "${HDF5_${hdf5_lang}_HL_LIBRARY}")
        elseif (DEFINED "HDF5_${hdf5_lang}_LIBRARY_${hdf5_target_name}")
          set(_hdf5_location "${HDF5_${hdf5_lang}_LIBRARY_${hdf5_target_name}}")
        else ()
          # Error if we still don't have the location.
          message(SEND_ERROR
            "HDF5 was found, but a different variable was set which contains "
            "its location.")
        endif ()
        add_library("hdf5::${hdf5_target_name}" UNKNOWN IMPORTED)
        string(REPLACE "-D" "" _hdf5_definitions "${HDF5_${hdf5_lang}_HL_DEFINITIONS}")
        set_target_properties("hdf5::${hdf5_target_name}" PROPERTIES
          IMPORTED_LOCATION "${_hdf5_location}"
          IMPORTED_IMPLIB "${_hdf5_location}"
          INTERFACE_INCLUDE_DIRECTORIES "${HDF5_${hdf5_lang}_HL_INCLUDE_DIRS}"
          INTERFACE_COMPILE_DEFINITIONS "${_hdf5_definitions}")
        if (_hdf5_libtype STREQUAL "SHARED")
          set_property(TARGET "hdf5::${hdf5_target_name}" APPEND
            PROPERTY
              INTERFACE_COMPILE_DEFINITIONS H5_BUILT_AS_DYNAMIC_LIB)
        elseif (_hdf5_libtype STREQUAL "STATIC")
          set_property(TARGET "hdf5::${hdf5_target_name}" APPEND
            PROPERTY
              INTERFACE_COMPILE_DEFINITIONS H5_BUILT_AS_STATIC_LIB)
        endif ()
        unset(_hdf5_definitions)
        unset(_hdf5_libtype)
        unset(_hdf5_location)
      endif ()
    endif ()
  endforeach ()
  unset(hdf5_lang)

  if (HDF5_DIFF_EXECUTABLE AND NOT TARGET hdf5::h5diff)
    add_executable(hdf5::h5diff IMPORTED)
    set_target_properties(hdf5::h5diff PROPERTIES
      IMPORTED_LOCATION "${HDF5_DIFF_EXECUTABLE}")
  endif ()
endif ()
