# ADD_UNINSTALL_TARGET()
#    Add custom target 'uninstall' that removes all the files
#    installed by this build (not recommended by CMake devs though).
#
# Add an uninstall target, as described on the CMake wiki.
# Include this file, then call add_uninstall_target().
# Requires a top-level cmake/ directory containing this
# macro file and a cmake_uninstall.cmake.in.

macro(add_uninstall_target)
	# uninstall target, source of uninstall template from
	# least to most specific.
	set(_uninstall_in "")
	foreach(_uninstall_in_candidate
		"${ARPA2CM_MODULE_DIR}/cmake_uninstall.cmake.in"
		"${CMAKE_CURRENT_LIST_DIR}/cmake_uninstall.cmake.in"
		"${CMAKE_SOURCE_DIR}/cmake/cmake_uninstall.cmake.in")
		if(EXISTS ${_uninstall_in_candidate})
			set(_uninstall_in ${_uninstall_in_candidate})
		endif()
	endforeach()
	if(NOT _uninstall_in)
		message(FATAL_ERROR "No cmake_uninstall.cmake.in was found.")
	endif()

	configure_file(
		"${_uninstall_in}"
		"${CMAKE_BINARY_DIR}/cmake_uninstall.cmake"
		IMMEDIATE @ONLY)

	add_custom_target(uninstall
		COMMAND ${CMAKE_COMMAND} -P ${CMAKE_BINARY_DIR}/cmake_uninstall.cmake)
endmacro()
