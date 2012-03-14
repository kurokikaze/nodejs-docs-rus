# Встроенный отладчик

<!-- type=misc -->

Вместе с V8 идет мощный отладчик, доступный прямо в процессе выполнения
через простой [TCP протокол](http://code.google.com/p/v8/wiki/DebuggerProtocol).
В Node есть встроенный клиент для этого отладчика. Чтобы его использовать,
запустите Node с ключом `debug`; появится следующее приглашение:

    % node debug myscript.js
    < debugger listening on port 5858
    connecting... ok
    break in /home/indutny/Code/git/indutny/myscript.js:1
      1 x = 5;
      2 setTimeout(function () {
      3   debugger;
    debug>

Отладчик Node не поддерживает полный набор команд но выполнение и просмотр окружения
вполне возможны. Добавив строку `debugger;` в исходный код, вы добавляете точку остановки.

Например, предположим что `myscript.js` выглядит так:

    // myscript.js
    x = 5;
    setTimeout(function () {
      debugger;
      console.log("world");
    }, 1000);
    console.log("hello");

При запуске в режиме отладки остановка произойдёт на четвёртой строке.

    % node debug myscript.js
    < debugger listening on port 5858
    connecting... ok
    break in /home/indutny/Code/git/indutny/myscript.js:1
      1 x = 5;
      2 setTimeout(function () {
      3   debugger;
    debug> cont
    < hello
    break in /home/indutny/Code/git/indutny/myscript.js:3
      1 x = 5;
      2 setTimeout(function () {
      3   debugger;
      4   console.log("world");
      5 }, 1000);
    debug> next
    break in /home/indutny/Code/git/indutny/myscript.js:4
      2 setTimeout(function () {
      3   debugger;
      4   console.log("world");
      5 }, 1000);
      6 console.log("hello");
    debug> repl
    Press Ctrl + C to leave debug repl
    > x
    5
    > 2+2
    4
    debug> next
    < world
    break in /home/indutny/Code/git/indutny/myscript.js:5
      3   debugger;
      4   console.log("world");
      5 }, 1000);
      6 console.log("hello");
      7
    debug> quit
    %


Команда `repl` позволяет удалённое выполнение кода. Команда `next` выполняет
следующую строку скрипта. Кроме этого доступно ещё несколько команд, и ещё больше
будут добавлены. Введите `help` чтобы увидеть остальные.

## Наблюдение за значениями выражений

Вы можете следить за значениями выражений и переменных при отладке кода.
На каждой точке отсновки вычисляется каждое выражение из списка наблюдения
и выводится перед выводом листинга кода точки остановки.

Для того, чтобы начать следить за выражением, нужно набрать в консоли `watch("my_expression")`.
Команда `watchers` выведет текущее значение выражений.
Для удаления выражения из списка используйте команду `unwatch("my_expression")`.

## Доступные команды

### Пошаговое выполнение

* `cont`, `c` - Продолжить выполнение
* `next`, `n` - Выполнить следующую инструкцию
* `step`, `s` - Перейти на уровень ниже при выполнении функций
* `out`, `o` - Перейти на уровень выше

### Точки остановки

* `setBreakpoint()`, `sb()` - Установичку точку остановки на текущей строке
* `setBreakpoint('fn()')`, `sb(...)` - Установичку точку остановки
на первой строке тела функции
* `setBreakpoint('script.js', 1)`, `sb(...)` - Установичку точку остановки
на первой строке файла script.js
* `clearBreakpoint`, `cb(...)` - Удалить точку остановки

### Получение информации

* `backtrace`, `bt` - Вывести стек вызова для текущей строки
* `list(5)` - Вывести исходный код скрипта, по 5 строк до и после текущей строки
* `watch(expr)` - Добавить выражение к списку наблюдения
* `unwatch(expr)` - Удалить выражение из списка наблюдения
* `watchers` - Вывести список  наблюдения со значениями выражений (автоматически вызывается на каждой точке остановки)
* `repl` - Открыть REPL для выполения команд в контексте отлаживаемого скрипта

### Контроль выполнения

* `run` - Выполнить скрипт (автоматически вызывается при старта отладчика)
* `restart` - Перезапустить скрипт
* `kill` - Завершить скрипт

### Разное

* `scripts` - Вывести список всех загруженных скриптов
* `version` - Вывести версию v8

## Продвинутое использование

Отладчик V8 может быть включен и использован либо при запуске Node с ключом `--debug`
или при передаче существующему процессу Node сигнала `SIGUSR1`.
