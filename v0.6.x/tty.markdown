# TTY

    Стабильность: 3 - Стабильно


Используйте `require('tty')` чтобы получить доступ к этому модулю.

Пример:

    var tty = require('tty');
    process.stdin.resume();
    tty.setRawMode(true);
    process.stdin.on('keypress', function(char, key) {
      if (key && key.ctrl && key.name == 'c') {
        console.log('graceful exit');
        process.exit()
      }
    });


## tty.isatty(fd)

Возвращает `true` или `false` в зависимости от того принадлежит ли файловый дескриптор `fd` терминалу.

## tty.setRawMode(mode)

Переменная `mode` должна принимать значение `true` или `false`.
Это задает режим работы потоков ввода-вывода текущего процесса: raw device или default.

## tty.setWindowSize(fd, row, col)

Эта функция была удалена в версии v0.6.0.

## tty.getWindowSize(fd)

Эта функция была удалена в версии v0.6.0.
Используйте `process.stdout.getWindowSize()`.
