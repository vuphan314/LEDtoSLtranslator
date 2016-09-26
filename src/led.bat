goto starting

:body
    set fold=examples\
    set fil=counting
    set fils=aggregation, boolean, counting, comparison, definition, game, nonstrict, quantification, set, test, tictactoe
    for %%i in (%fil%) do (
        set base=%fold%%%~ni
        set led=!base!.led
        set p=!base!.p
        set sl=!base!.sl
        set parse=py ledparser.py !led!
        set transl=py translator.py !led!

        REM py -i translator.py
        REM py -i unparser.py

        echo !base! & echo:
        REM type !led!

        REM !parse!
        REM !parse! >> !led!
        REM !led!
        REM !parse! > !p!
        REM !p!

        REM !transl!
        !transl! > !sl!
        REM !sl!
        REM sli -l !sl!
    )
    goto ending

:starting
    @echo off
    cls
    setlocal enabledelayedexpansion
    echo starting...
    echo:
    goto body

:ending
    echo:
    echo done