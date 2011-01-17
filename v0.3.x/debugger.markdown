## Встроенный отладчик

Вместе с V8 идет мощный отладчик, доступный прямо в процессе выполнения через простой [TCP протокол](http://code.google.com/p/v8/wiki/DebuggerProtocol).
В Node есть встроенный клиент для этого отладчика. Чтобы его использовать, запустите Node с ключом `debug`; появится следующее приглашение:

    % node debug myscript.js
    debug>

Пока `myscript.js` ещё не запущен. Чтобы запустить скрипт, введите команду `run`. Если всё в порядке, вывод будет выглядеть примерно так:

    % node debug myscript.js
    debug> run
    debugger listening on port 5858
    connecting...ok

Отладчик Node не поддерживает полный набор команд но выполнение и просмотр окружения вполне возможны. Добавив строку `debugger;` в исходный код, вы добавляете точку остановки.

Например, предположим что `myscript.js` выглядит так:

    // myscript.js
    x = 5;
    setTimeout(function () {
      debugger;
      console.log("world");
    }, 1000);
    console.log("hello");

При запуске в режиме отладки остановка произойдёт на четвёртой строке.

    % ./node debug myscript.js
    debug> run
    debugger listening on port 5858
    connecting...ok
    hello
    break in #<an Object>._onTimeout(), myscript.js:4
      debugger;
      ^
    debug> next
    break in #<an Object>._onTimeout(), myscript.js:5
      console.log("world");
      ^
    debug> print x
    5
    debug> print 2+2
    4
    debug> next
    world
    break in #<an Object>._onTimeout() returning undefined, myscript.js:6
    }, 1000);
    ^
    debug> quit
    A debugging session is active. Quit anyway? (y or n) y
    %


Команда `print` позволяет просматривать переменные. Команда `next` выполняет следующую строку скрипта. Кроме этого доступно ещё несколько команд, и ещё больше будут добавлены. Введите `help` чтобы увидеть остальные.


### Продвинутое использование

Отладчик V8 может быть включен и использован либо при запуске Node с ключом `--debug` или при передаче существующему процессу Node сигнала `SIGUSR1`.


