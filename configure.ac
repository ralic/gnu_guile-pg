dnl configure.ac
dnl
dnl Copyright (C) 2002-2015 Thien-Thi Nguyen
dnl Portions Copyright (C) 1998 Ian Grant
dnl
dnl This file is part of Guile-PG.
dnl
dnl Guile-PG is free software; you can redistribute it and/or modify it
dnl under the terms of the GNU General Public License as published by
dnl the Free Software Foundation; either version 3, or (at your
dnl option) any later version.
dnl
dnl Guile-PG is distributed in the hope that it will be useful, but
dnl WITHOUT ANY WARRANTY; without even the implied warranty of
dnl MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
dnl General Public License for more details.
dnl
dnl You should have received a copy of the GNU General Public License
dnl along with Guile-PG.  If not, see <http://www.gnu.org/licenses/>.

AC_INIT([Guile-PG],[0.47],[guile-user@gnu.org])
AC_CONFIG_MACRO_DIR([build-aux])
AC_CONFIG_AUX_DIR([build-aux])
AM_INIT_AUTOMAKE([1.12.2 -Wall no-dist-gzip dist-xz serial-tests])

AC_CONFIG_HEADERS([src/config.h])

SNUGGLE_MAINT_MODE

AC_ARG_ENABLE([cmod],[AS_HELP_STRING([--disable-cmod],
 [do not install (database postgres) as a shared object library;
  use a Scheme wrapper that does the dynamic-link "manually"
  (default: install the module as a shared object library,
  but only if Guile seems capable of loading it directly)])],[],[
enable_cmod=yes
])

AC_ARG_ENABLE([pq-rpath],[AS_HELP_STRING([--enable-pq-rpath],
 [arrange to use "-R" when linking libpq])])

AC_DEFUN([NOTE_ENVVAR],[
  AS_IF([test "[$]$1"],[val="= [$]$1"],[val='(empty)'])
  AC_MSG_NOTICE([ $1 $val])
  AS_UNSET([val])
])

dnl This needs to go before ‘LT_INIT’ else autoreconf complains.  :-/
AM_PROG_AR

LT_PREREQ([2.2.6])
LT_INIT([dlopen disable-static]) dnl module only

AC_PROG_CC

AC_HEADER_STDC

AC_FUNC_ALLOCA

##----------------------------------------------------------------------------
## Guile

AC_MSG_NOTICE([checking Guile particulars])

SNUGGLE_PROGS
SNUGGLE_FLAGS

SNUGGLE_GUILE_LIBSITE_DIR([pg])

AS_IF([test xyes = x$enable_cmod],
[SNUGGLE_GUILE_TOOLS_EXISTSP([pg_cv_mkmodcat],[make-module-catalog])])
AM_CONDITIONAL([USE_CMOD],
[test yes = $enable_cmod && test xyes = x"$pg_cv_mkmodcat"])

AM_COND_IF([USE_CMOD],[
  AC_DEFINE([USE_CMOD], 1,
     [Define to 1 if Guile can load C modules.])
  AC_MSG_NOTICE([will install C module directly])
],[
  AC_MSG_NOTICE([will install Scheme wrapper for shared object library])
])

saved_CPPFLAGS="$CPPFLAGS"	# restoration below
saved_LDFLAGS="$LDFLAGS"
CPPFLAGS="$GUILE_CFLAGS $CPPFLAGS"
LDFLAGS="$GUILE_LDFLAGS $LDFLAGS"

dnl Ancient guiles know ‘scm_terminating’ as simply ‘terminating’
dnl and don't even declare it.  So, we check for both.

AC_CHECK_DECLS([scm_terminating],,,[[#include <libguile.h>]])
AS_IF([test no = $ac_cv_have_decl_scm_terminating],[
 AC_CHECK_LIB([guile], [terminating],
 [AC_DEFINE([HAVE_LIBGUILE_TERMINATING], 1,
            [Define if libguile defines terminating.])])
])

SNUGGLE_CHECK_CLASSIC_HEADERS

CPPFLAGS="$saved_CPPFLAGS"
LDFLAGS="$saved_LDFLAGS"

##----------------------------------------------------------------------------
## PostgreSQL

AC_ARG_VAR([PQ_CPPFLAGS],[preprocessor flags to indicate where
to find <libpq-fe.h> and <libpq/libpq-fs.h>,
e.g. "-I/my/include/postgresql"])

AC_ARG_VAR([PQ_LDFLAGS],[linker flags to indicate where to find the libpq
shared-object library, without "-lpq", e.g. "-L/my/lib"])

AC_MSG_NOTICE([checking PostgreSQL particulars])
NOTE_ENVVAR([PQ_CPPFLAGS])
NOTE_ENVVAR([PQ_LDFLAGS])

saved_CPPFLAGS="$CPPFLAGS"                  # restoration below
saved_LDFLAGS="$LDFLAGS"
CPPFLAGS="$PQ_CPPFLAGS $CPPFLAGS"
LDFLAGS="$PQ_LDFLAGS -lpq $LDFLAGS"

AC_CHECK_HEADERS([libpq-fe.h libpq/libpq-fs.h])
AS_IF([! test yes = $ac_cv_header_libpq_fe_h ||
       ! test yes = $ac_cv_header_libpq_libpq_fs_h],
[AC_MSG_ERROR([could not find PostgreSQL headers -- see README])])

AC_CHECK_DECLS([pg_encoding_to_char, pg_char_to_encoding],,,[
#include <libpq-fe.h>
])

AC_CHECK_FUNCS(m4_normalize(
dnl 7.4 (earliest supported PostgreSQL)
    PQfreemem
dnl 8.0
    PQserverVersion
))

AS_IF([! test xyes = x"$ac_cv_func_PQfreemem"],
[AC_MSG_ERROR([could not find sane libpq -- see README])])

CPPFLAGS="$saved_CPPFLAGS"
LDFLAGS="$saved_LDFLAGS"

# Add rpath to link flags if requested by ‘--enable-pq-rpath’.
AS_IF([test yes = "$enable_pq_rpath"],[
more=`echo $PQ_LDFLAGS | sed s/^-L/-R/`
PQ_LDFLAGS="$more $PQ_LDFLAGS"
AS_UNSET([more])
])

##----------------------------------------------------------------------------
## Compose ‘SUBCPPFLAGS’ and ‘SUBLDFLAGS’, whose names are deliberately
## without underscore (info "(automake) Flag Variables Ordering").

AS_IF([test "$PQ_CPPFLAGS" = "$GUILE_CFLAGS"],
      [SUBCPPFLAGS="$GUILE_CFLAGS"],
      [SUBCPPFLAGS="$PQ_CPPFLAGS $GUILE_CFLAGS"])
SUBLDFLAGS="$PQ_LDFLAGS -lpq $GUILE_LDFLAGS"
AC_SUBST([SUBCPPFLAGS])
AC_SUBST([SUBLDFLAGS])

AC_MSG_NOTICE([NOTE: combined cpp and linker flags (see README if wrong):
 SUBCPPFLAGS: $SUBCPPFLAGS
  SUBLDFLAGS: $SUBLDFLAGS])

##----------------------------------------------------------------------------
## Etc

SNUGGLE_SET_SOFIXFLAGS
AC_PROG_INSTALL
AC_PROG_LN_S

AC_CONFIG_FILES([
  Makefile
  src/Makefile
  doc/Makefile
  test/Makefile
  test/runtest
  test/show-platform
])

AC_OUTPUT

dnl configure.ac ends here
