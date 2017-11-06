# CREATE_CONFIG_FILES(<packagename>)
#    Call this macro to generate CMake and pkg-config configuration
#    files from templates found in the top-level source directory.
#
# Most ARPA2-related components write configuration-information
# files and install them. There are two flavors:
#
#   - CMake config-info files (<foo>Config.cmake and <foo>ConfigVersion.cmake)
#   - pkg-config files (<foo>.pc)
#
# The macro create_config_files() simplifies this process
# by using named template files for all three output files.
# Pass a package name (e.g. "Quick-DER") to the macro, and
# the source files (e.g. <file>.in for the files named above
# will be taken from the top-level contrib/{cmake,pkgconfig}
# source directories.
#
# As an (un)special case, the ConfigVersion file may be taken from
# the cmake/ directory, since there is nothing particularly special
# for that file (as opposed to the other files, which need to
# specify paths, dependencies, and other things).

# Copyright 2017, Adriaan de Groot <groot@kde.org>
#
# Redistribution and use is allowed according to the terms of the two-clause BSD license.
#    SPDX-License-Identifier: BSD-2-Clause.degroot
#    License-Filename: LICENSES/BSD-2-Clause.degroot

include(CMakePackageConfigHelpers)

set(SHARE_INSTALL_DIR share
    CACHE
    PATH
    "read-only architecture-independent data"
)

macro (create_config_file_internal _packagename _bstype _filename)
	# Find the .in files
	set(_configfile_in "")
	foreach(_configfile_in_candidate
		"${ARPA2CM_MODULE_DIR}/${_filename}.in"
		"${CMAKE_CURRENT_LIST_DIR}/${_filename}.in"
		"${CMAKE_CURRENT_LIST_DIR}/${_packagename}${_filename}.in"
		"${CMAKE_SOURCE_DIR}/${_bstype}/${_filename}.in"
		"${CMAKE_SOURCE_DIR}/${_bstype}/${_packagename}${_filename}.in"
		"${PROJECT_SOURCE_DIR}/contrib/${_bstype}/${_filename}.in"
		"${PROJECT_SOURCE_DIR}/contrib/${_bstype}/${_packagename}${_filename}.in"
		)
		if(EXISTS ${_configfile_in_candidate})
			set(_configfile_in ${_configfile_in_candidate})
		endif()
	endforeach()
	if(NOT _configfile_in)
		message(FATAL_ERROR "No ${_filename}.in was found.")
	endif()

	# Substitute in real values for the placeholders in the .in files,
	# create the files in the build tree, and install them.
	configure_file (${_configfile_in}
		"${PROJECT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/${_packagename}${_filename}" @ONLY)
endmacro()

macro (create_config_files _packagename)
	export (PACKAGE ${_packagename})
	
	cmake_parse_arguments(ARPA2CM_CCF "NO_PKGCONFIG" "" "" ${ARGN})
	
	# The CMake configuration files are written to different locations
	# depending on the host platform, since different conventions apply.
	if (WIN32 AND NOT CYGWIN)
		set (DEF_INSTALL_CMAKE_DIR CMake)
	else ()
		set (DEF_INSTALL_CMAKE_DIR ${SHARE_INSTALL_DIR}/${_packagename}/cmake/)
	endif ()
	set (INSTALL_CMAKE_DIR ${DEF_INSTALL_CMAKE_DIR} CACHE PATH
		"Installation directory for CMake files")

	# Calculate include/ relative to the installed place of the config file.
	file (RELATIVE_PATH REL_INCLUDE_DIR "${CMAKE_INSTALL_PREFIX}/${INSTALL_CMAKE_DIR}"
		"${CMAKE_INSTALL_PREFIX}/include")
	file (RELATIVE_PATH REL_LIB_DIR "${CMAKE_INSTALL_PREFIX}/${INSTALL_CMAKE_DIR}"
		"${CMAKE_INSTALL_PREFIX}/lib")
	set (CONF_INCLUDE_DIRS "\${${_packagename}_CMAKE_DIR}/${REL_INCLUDE_DIR}")
	set (CONF_LIB_DIRS "\${${_packagename}_CMAKE_DIR}/${REL_LIB_DIR}")
	set (_conf_version ${${_packagename}_VERSION})

	create_config_file_internal(${_packagename} cmake Config.cmake)
	if (NOT ARPA2CM_CCF_NO_PKGCONFIG)
		create_config_file_internal(${_packagename} pkgconfig .pc)
		install (FILES
			"${PROJECT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/${_packagename}.pc"
			DESTINATION "lib/pkgconfig/"
			COMPONENT dev)
	endif()

	write_basic_package_version_file(
		${PROJECT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/${_packagename}ConfigVersion.cmake
		VERSION ${${_packagename}_VERSION}
		COMPATIBILITY SameMajorVersion )

	install (FILES
		"${PROJECT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/${_packagename}Config.cmake"
		"${PROJECT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/${_packagename}ConfigVersion.cmake"
		DESTINATION "${INSTALL_CMAKE_DIR}" COMPONENT dev)
endmacro ()
