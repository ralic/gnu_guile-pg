# Makefile.am
#
# Copyright (C) 2003-2009, 2011, 2014, 2015 Thien-Thi Nguyen
# Portions Copyright (C) 1998 Ian Grant
#
# This file is part of Guile-PG.
#
# Guile-PG is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3, or
# (at your option) any later version.
#
# Guile-PG is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Guile-PG.  If not, see <http://www.gnu.org/licenses/>.

include $(top_srcdir)/build-aux/common.mk

info_TEXINFOS = guile-pg.texi
guile_pg_TEXINFOS = guile-pg.texi relinfo.texi ref.texi qcons-tables.texi
guile_pg_TEXINFOS += coltypes.texi

relinfo.texi: $(top_srcdir)/configure
	@echo Creating $@
	@nice=`echo $(PACKAGE_BUGREPORT) | sed 's/@/@@/g'` ;	\
	echo '@set BUGREPORT' "$$nice" > $@
	@echo '@set VERSION $(PACKAGE_VERSION)' >> $@
	@echo '@set RELDATE' `date +%Y-%m-%d -r $<` >> $@

qcons-tables.texi: $(top_srcdir)/src/postgres-qcons.scm
	$(srcdir)/mkinc $< > $@

EXTRA_DIST = ref.texh mkinc guile-pg.html
EXTRA_DIST += coltypes.texi
EXTRA_DIST += fdl.texi

if MAINT_MODE

SUFFIXES = .texh

snippets = ../src/all.tsar

.texh.texi:
	$(gx) tsin -f $(snippets) -c utf-8 $<

ref.texi: $(snippets)

coltypes.texi: $(top_srcdir)/src/postgres-types.scm
	{ < $<						\
	  sed -e "/^.define-db-col-type '/!d"		\
	      -e 's///'					\
	  | while read name rest ; do			\
	      printf '%-11s  %s\n' "$$name" "$$rest" ;	\
	    done ;					\
	} > $@T
	{ sed 's/ .*//;s/^/@converter /' $@T ;	\
	  echo '@example' ;			\
	  pr -2Tt -s' ' -W 72 $@T | expand ;	\
	  echo '@end example' ;			\
	  printf '\n%s\n%s\n\n'			\
	    '@noindent'				\
	    'Here are the array variants:' ;	\
	  echo '@example' ;			\
	  < $< sed				\
	    -e '/^.def.*-array-variant "/!d'	\
	    -e 's///' -e 's/".*//' 		\
	    -e 's/\[\]/*/g'			\
	    -e 's/\([^*]*\)\(.*\)/\2\1/' ;	\
	  echo '@end example' ;			\
	} > $@
	rm -f $@T

endif # MAINT_MODE

# Makefile.am ends here
