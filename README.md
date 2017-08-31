# ARPA2CM

> CMake Module library for the ARPA2 project, like KDE Extra CMake Modules (ECM)

The CMake module library for the ARPA2 project, including the LillyDAP,
TLSPool and IdentityHub software stacks. Like the KDE Extra CMake Modules (ECM)
which is a large-ish collection of curated CMake modules of particular
interest to Qt-based and KDE Frameworks-based applications, the ARPA2
CMake Modules (ARPA2CM) is a collection of modules for the software
stack from the ARPA2 project. This is largely oriented towards
TLS, SSL, X509, DER and LDAP technologies. The ARPA2 CMake Modules
also include modules used for product release and deployment of
the ARPA2 software stack.

Some modules in the ARPA2 CM are copied from KDE ECM; this is so
that ARPA2 software only need rely on the ARPA2 CM, instead of
on KDE ECM as well. These duplicates are documented later.

## Using ARPA2CM

When ARPA2 CMake Modules are installed, use `find_package()` to find the
modules. This sets one variable, `ARPA2CM_MODULE_PATH`, which should be
added to your `CMAKE_MODULE_PATH`. Typical use looks like so:

```
    find_package(ARPA2CM REQUIRED NO_MODULE)
    set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${ARPA2CM_MODULE_PATH})
```

Once this is done, the ARPA2 CM provides the following modules:

### Find Modules

Each of these modules defines `_LIBRARIES` and `_INCLUDE_DIRECTORIES`
variables prefixed by the (case-sensitive) name of the module, and also
defines a `_FOUND` variable which may be false if the requested software
cannot be found.

 - *BDB* finds the Berkeley database, version 5.
 - *GnuTLSDane* checks if the installed GnuTLS module has the DANE extensions
   proposed by the ARPA2 project, which are being upstreamed. This module
   defines only a `GnuTLSDane_FOUND` variable, indicating the presence of the
   extensions.
 - *GPerf* looks for GNU Perf, the perfect-hash generating tool. This module
   is copied from KDE ECM.
 - *LibTASN1* looks for the corresponding library.
 - *Libldns* looks for the corresponding library.
 - *Log4cpp* looks for one of the many logging libraries for C++.
 - *OpenLDAP* looks for the corresponding library. It also looks for the BER
   library from OpenLDAP, and includes that in the `_LIBRARIES` variable.
 - *P11-Kit* looks for the corresponding library.
 - *SQLite3* **deprecated** finds SQLite, version 3, but a similar module is
   now available in CMake itself.
 - *Unbound* looks for the libraries for the caching resolving DNS server
   from NLNet labs.

One more file, *ECMFindModuleHelpers*, is included as support for *FindGperf*,
which comes from KDE ECM.

### ARPA2 Modules

ARPA2 projects have certain standards for building the ARPA2 software stack
itself. These are supported by the modules in the `modules/` directory.
They may be useful for other projects as well; they duplicate functionality
found in KDE ECM and elsewhere.

 - *MacroEnsureOutOfSourceBuild* complains when building in-source; most
   ARPA2 software has a top-level `Makefile` that creates a separate build-
   directory and runs CMake there. This macro helps ensure that we don't
   accidentally build in the source tree and pollute it with build artifacts.
 - *MacroGitVersionInfo* uses `git describe` to assign a version number
   if there is a git checkout available; ARPA2 projects should still contain
   version information for non-git source distribution.

### ARPA2 Toolchain

This directory is empty in ARPA2CM. Other parts of the ARPA2 stack can install
CMake modules here, to support tools from those parts of the stack. E.g.,
Quick-DER installs CMake modules here to help build bindings for ASN.1
syntax definitions.
