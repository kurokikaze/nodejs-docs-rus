# console

* {Object}

<!--type=global-->

Объект для вывода в стандартный поток вывода `stdout` и стандартный поток ошибок `stderr`.
Похож на `console` в браузерах.

## console.log()

Выводит строку в `stdout`, с переходом на новую строку. Функция может принимать
несколько аргументов и работать как `printf()`. Пример:

    console.log('count: %d', count);

Если первый аргумент `console.log()` не является строкой, то будут выведены преобразованные в строки аргументы,
разделённые пробелом. Преобразование осуществляется функцией `util.inspect()`.
Подробнее об этом смотрите в описании метода [util.format()](util.html#util.format).


## console.info()

Синоним `console.log`.

## console.warn()
## console.error()

Тоже самое, что и `console.log`, но выводит данные в `stderr`

## console.dir(obj)

Выводит результат вызова `util.inspect` для `obj` в `stderr`.

## console.time(label)

Запоминает текущее время.

## console.timeEnd(label)

Завершает отсчёт времени и выводит результат. Пример:

    console.time('100-elements');
    for (var i = 0; i < 100; i++) {
      ;
    }
    console.timeEnd('100-elements');


## console.trace()

Выводит в `stderr` стек вызова для текущей инструкции.

## console.assert()

Синоним `assert.ok()`.

