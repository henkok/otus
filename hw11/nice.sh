#!/bin/bash
STIME=$(date +%s)
DATADIR=/var/* #это архивируем
ARHDIR=/tmp #здесь сохраняем
rm -rf $ARHDIR/{low,high}.tar.gz
echo "" > $ARHDIR/archive_log.log

hinice() {
    nice -20 tar czvf $ARHDIR/hinice.tar.gz $DATADIR > /dev/null 2>&1
    echo -e " ============== [Total time HIGH NICE \e[1;33;4;44m$(($(date +%s)-$STIME))\e[0m sec] =================]"  >> $ARHDIR/archive_log.log
	cat $ARHDIR/archive_log.log
}

lonice() {
    nice --19 tar czvf $ARHDIR/lonice.tar.gz $DATADIR > /dev/null 2>&1 
    echo -e " ============== [Total time LOW NICE  \e[1;33;4;44m$(($(date +%s)-$STIME))\e[0m sec] =================]"  >> $ARHDIR/archive_log.log
}
hinice &
lonice &