#! /bin/sh

if [ -z "$top_builddir" ] ; then echo $0: error: Bad env. ; exit 1 ; fi

drop=$top_builddir/test/drop.sh
create=$top_builddir/test/create.sh

$drop --no-worries
$create || exit 1

if [ x"$DEBUG" = x ] ; then debug= ; else debug='--debug' ; fi

${GUILE-guile} $debug \
               -l config.scm \
               -s $srcdir/guile-pg-basic-tests.scm
rv=$?

$drop

exit $rv

# basic-tests.sh ends here
