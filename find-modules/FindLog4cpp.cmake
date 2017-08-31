# Copyright (c) 2014, 2015 InternetWide.org and the ARPA2.net project
# All rights reserved. See file LICENSE for exact terms (2-clause BSD license).
#
# Adriaan de Groot <groot@kde.org>

# Try to find log4cpp libraries. Sets standard variables
# LOG4CPP_LIBRARIES and LOG4CPP_INCLUDE_DIRS. If there is no
# installed package, you can use LOG4CPP_PREFIX to tell
# this module where log4cpp is installed; it will look in
# lib/ and include/ subdirectories of that prefix.
#
if(LOG4CPP_FOUND)
  return()
endif()

include(FindPackageHandleStandardArgs)

find_library(_L4CPP log4cpp
  PATHS ${LOG4CPP_PREFIX}/lib64 ${LOG4CPP_PREFIX}/lib32 ${LOG4CPP_PREFIX}/lib)
if (_L4CPP)
  set(LOG4CPP_LIBRARIES ${_L4CPP})
endif()

find_path(LOG4CPP_INCLUDE_DIRS log4cpp/Category.hh
  PATHS ${LOG4CPP_PREFIX}/include)

if (_L4CPP)
  set(LOG4CPP_DEFINITIONS -DDEBUG)
else (_L4CPP)
  set(LOG4CPP_DEFINITIONS -DNDEBUG)
endif (_L4CPP)

find_package_handle_standard_args(LOG4CPP 
  REQUIRED_VARS LOG4CPP_LIBRARIES LOG4CPP_INCLUDE_DIRS LOG4CPP_DEFINITIONS)

if (_L4CPP)
  try_compile(_L4CPP_NEEDS_NO_PTHREAD ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_CURRENT_LIST_DIR}/check_log4cpp.cpp
    COMPILE_DEFINITIONS ${LOG4CPP_DEFINITIONS}
    LINK_LIBRARIES ${LOG4CPP_LIBRARIES})
  if (NOT _L4CPP_NEEDS_NO_PTHREAD)
    message(STATUS "Log4cpp doesn't link, try with -pthread")
    set(LOG4CPP_LIBRARIES ${LOG4CPP_LIBRARIES} -pthread)
    # Now the variable is misnamed
    try_compile(_L4CPP_NEEDS_NO_PTHREAD ${CMAKE_CURRENT_BINARY_DIR}
      ${CMAKE_CURRENT_LIST_DIR}/check_log4cpp.cpp
      COMPILE_DEFINITIONS ${LOG4CPP_DEFINITIONS}
      LINK_LIBRARIES ${LOG4CPP_LIBRARIES}
      OUTPUT_VARIABLE _L4CPP_LINK)
    if (NOT _L4CPP_NEEDS_NO_PTHREAD)
      message(WARNING " .. Cannot find linker arguments for log4cpp")
      message(WARNING ${_L4CPP_LINK})
    else (NOT _L4CPP_NEEDS_NO_PTHREAD)
      message(STATUS " .. Log4cpp needs -pthread")
    endif (NOT _L4CPP_NEEDS_NO_PTHREAD)
  endif (NOT _L4CPP_NEEDS_NO_PTHREAD)
endif (_L4CPP)
