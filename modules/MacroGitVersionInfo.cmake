# GET_VERSION_FROM_GIT(<appname> <default>)
#    Uses git tags to determine a version name and sets <appname>_VERSION
#    (along with split-out _MAJOR, _MINOR and _PATCHLEVEL variables). If
#    git isn't available, use <default> for version information (which should
#    be a string in the format M.m.p).
#
# Version Information
#
# This assumes you are working from a git checkout that uses tags
# in an orderly fashion (e.g. according to the ARPA2 project best
# practices guide, with version-* tags). It also checks for local
# modifications and uses that to munge the <patchlevel> part of
# the version number.
#
# Produces version numbers <major>.<minor>.<patchlevel>.
#
# To use the macro, provide an app- or package name; this is
# used to fill variables called <app>_VERSION_MAJOR, .. and
# overall <app>_VERSION. If git can't be found or does not Produce
# meaningful output, use the provided default, e.g.:
#
#   get_version_from_git(Quick-DER 0.1-5)
#
# After the macro invocation, Quick-DER_VERSION is set according
# to the git tag or 0.1.5. Note that the provided default version
# **MUST** have the format x.y-z (with a dash) or x.y (in which
# case -0 is assumed). Format x.y is preferred.
#
# Git tags **MUST** have names like "version-x.y" (including
# the "version-" prefix).

# Copyright 2017, Rick van Rein <rick@openfortress.nl>
# Copyright 2017, Adriaan de Groot <groot@kde.org>
#
# Redistribution and use is allowed according to the terms of the two-clause BSD license.
#    SPDX-License-Identifier: BSD-2-Clause.degroot
#    License-Filename: LICENSES/BSD-2-Clause.degroot

macro(get_version_from_git _appname _default)
	find_package (Git QUIET)

	if (${_default} MATCHES "^([1-9][0-9]*|0)[.]([1-9][0-9]*|0)-(.*)$")
		# x.y-z flavor; that's weird but acceptable
		set (_default_ver ${_default})
	elseif (${_default} MATCHES "^([1-9][0-9]*|0)[.]([1-9][0-9]*|0)$")
		# x.y (no trailing -z), fix it up because later code
		# expects version-x.y-z output from git.
		set (_default_ver ${_default}-0)
	else()
		message(WARNING "Default version ${_default} for ${_appname} is poorly formatted.")
		# Keep it anyway
		set (_default_ver ${_default})
	endif()

	if (Git_FOUND)
		message(STATUS "Looking for git-versioning information.")
		exec_program (
			${GIT_EXECUTABLE}
			${CMAKE_CURRENT_SOURCE_DIR}
			ARGS diff --quiet
			RETURN_VALUE GIT_HAVE_CHANGES
		)

		# Same exit codes as diff: 0 for no changes, 1 for changes,
		# but git can also error out (e.g. not-a-git-repo).
		if (GIT_HAVE_CHANGES EQUAL 129)
			message(WARNING "Git repository not found: git-versioning uses default ${_default_ver}.")
			set (GIT_HAVE_CHANGES 0)
			set (GIT_VERSION_INFO "version-${_default_ver}")
		else()
			exec_program (
				${GIT_EXECUTABLE}
				${CMAKE_CURRENT_SOURCE_DIR}
				ARGS describe --tags --match 'version-*.*-*'
				OUTPUT_VARIABLE GIT_VERSION_INFO
				RETURN_VALUE GIT_HAVE_VERSION
			)
			if (GIT_HAVE_VERSION)
				# Non-zero exit, so describe failed; usually missing tags
				message(WARNING "Git repository missing tags: git-versioning uses default ${_default_ver}.")
				set(GIT_VERSION_INFO "version-${_default_ver}")
			endif()
		endif()
	else(NOT Git_FOUND)
		message(WARNING "Git not found; git-versioning uses default ${_default_ver}.")
		set(GIT_VERSION_INFO "version-${_default_ver}")
		set(GIT_HAVE_CHANGES 0)
	endif()

	string (
		REGEX REPLACE "^version-([1-9][0-9]*|0)[.]([1-9][0-9]*|0)-(.*)$"
		"\\1"
		GIT_VERSION_MAJOR
		${GIT_VERSION_INFO}
	)

	string (
		REGEX REPLACE "^version-([1-9][0-9]*|0)[.]([1-9][0-9]*|0)-(.*)$"
		"\\2"
		GIT_VERSION_MINOR
		${GIT_VERSION_INFO}
	)

	if (GIT_HAVE_CHANGES EQUAL 0)
		string (
			REGEX REPLACE "^version-([1-9][0-9]*|0)[.]([1-9][0-9]*|0)-(.*)$"
			"\\3"
			GIT_VERSION_PATCHLEVEL
			${GIT_VERSION_INFO}
		)

		set (
			USER_SUPPLIED_PATCHLEVEL
			"${GIT_VERSION_PATCHLEVEL}"
			CACHE STRING "User-override for patch level under ${GIT_VERSION_MAJOR}.${GIT_VERSION_MINOR}"
		)

	else()

		exec_program (
			date
			ARGS '+%Y%m%d-%H%M%S'
			OUTPUT_VARIABLE GIT_CHANGES_TIMESTAMP
		)
		set (GIT_VERSION_PATCHLEVEL "local-${GIT_CHANGES_TIMESTAMP}")
		message (STATUS "Git reports local changes, fixing patch level to local-${GIT_CHANGES_TIMESTAMP}")

		unset (USER_SUPPLIED_PATCHLEVEL CACHE)

	endif()

	set(${_appname}_VERSION_MAJOR ${GIT_VERSION_MAJOR})
	set(${_appname}_VERSION_MINOR ${GIT_VERSION_MINOR})
	set(${_appname}_VERSION_PATCHLEVEL ${GIT_VERSION_PATCHLEVEL})
	set(${_appname}_VERSION ${GIT_VERSION_MAJOR}.${GIT_VERSION_MINOR}.${GIT_VERSION_PATCHLEVEL})

	if(Git_FOUND)
		message(STATUS "Got version ${${_appname}_VERSION}")
	endif()
endmacro()
