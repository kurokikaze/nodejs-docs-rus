## Процесс

Объект `process` — глобальный и может быть использован в любом месте кода.
Является экземпляром `EventEmitter`.


### Событие: 'exit'

`function () {}`

Генерируется перед тем как процесс завершится. Это хорошее место для проверок
состояния модуля (например, юнит-тестов). Event loop не будет действовать
после завершения обработчика `'exit'`, так что таймеры использовать нельзя.

Пример обработки события `'exit'`:

    process.on('exit', function () {
      process.nextTick(function () {
       console.log('This will not run');
      });
      console.log('About to exit.');
    });

### Событие: 'uncaughtException'

`function (err) { }`

Генерируется, когда неперехваченное исключение достигает цикла обработки событий.
Если этому событию назначен обработчик,
стандартное действие (печать стека и выход) производиться не будет.

Пример обработки события `'uncaughtException'`:

    process.on('uncaughtException', function (err) {
      console.log('Caught exception: ' + err);
    });

    setTimeout(function () {
      console.log('This will still run.');
    }, 500);

    // Intentionally cause an exception, but don't catch it.
    nonexistentFunc();
    console.log('This will not run.');

Заметьте, что событие `'uncaughtException'` — это очень грубый механизм для управления исключениями.
Использование try/catch даст вам больший контроль над выполнением вашего кода.
Но для программ, предназначенных для постоянной работы,
`'uncaughtException'` может быть очень полезным механизмом безопасности.


### Сигнальные события

`function () {}`

Генерируются когда процесс получает сигнал.
См. sigaction(2) для списка стандартных имён сигналов в POSIX,
таких как `SIGINT`, `SIGUSR1` и т.д.

Пример обработки сигнала `SIGINT`:

    // Start reading from stdin so we don't exit.
    process.stdin.resume();

    process.on('SIGINT', function () {
      console.log('Got SIGINT.  Press Control-D to exit.');
    });

Простой способ отправки сигнала `SIGINT`: `Control-C` в большинстве терминальных программ.


### process.stdout

Поток с возможностью записи, представляющий стандартный поток вывода `stdout`.

Пример (определение `console.log`):

    console.log = function (d) {
      process.stdout.write(d + '\n');
    };


### process.stdin

Стандартный поток ввода stdin. Этот поток по умолчанию не реагирует на события,
для чтения из него нужно предварительно вызвать `process.stdin.resume()`.

Пример открытия стандартного потока ввода и обработки обоих событий:

    process.stdin.resume();
    process.stdin.setEncoding('utf8');

    process.stdin.on('data', function (chunk) {
      process.stdout.write('data: ' + chunk);
    });

    process.stdin.on('end', function () {
      process.stdout.write('end');
    });


### process.argv

Массив, содержащий аргументы командной строки.
Первым элементом будет 'node', вторым — имя JavaScript файла.
Следующие элементы будут дополнительными аргументами скрипта.

    // print process.argv
    process.argv.forEach(function (val, index, array) {
      console.log(index + ': ' + val);
    });

В результате получим:

    $ node process-2.js one two=three four
    0: node
    1: /Users/mjr/work/node/process-2.js
    2: one
    3: two=three
    4: four


### process.execPath

Абсолютный путь к приложению, запустившему процесс.

Пример:

    /usr/local/bin/node


### process.chdir(directory)

Изменяет текущий рабочий каталог приложения либо генерирует исключение,
если изменить каталог не удаётся.

    console.log('Starting directory: ' + process.cwd());
    try {
      process.chdir('/tmp');
      console.log('New directory: ' + process.cwd());
    }
    catch (err) {
      console.log('chdir: ' + err);
    }



### process.cwd()

Возвращает текущую рабочую директорию процесса.

    console.log('Current directory: ' + process.cwd());


### process.env

Объект, хранящий окружение пользователя. См. environ(7).


### process.exit(code=0)

Завершает процесс с указанным кодом `code`.
Если код пропущен, завершает процесс со стандартным успешным кодом `0`.

Чтобы выйти с ощибочным кодом, нужно вызвать:

    process.exit(1);

Оболочка, с помощью которой был запущен скрипт в node, должна получить код `1`.


### process.getgid()

Возвращает групповой индикатор процесса (см. setgid(2)). Это числовое значение id группы, а не её имя.

    console.log('Current gid: ' + process.getgid());


### process.setgid(id)

Устанавливает групповой индикатор процесса (см. setgid(2)).
Функция принимает как числовое значение, так и его текстовый эквивалент.
Если функции передано имя группы, то функция блокирует выполнение кода
пока не разрешит имя в числовой идентификатор.

    console.log('Current gid: ' + process.getgid());
    try {
      process.setgid(501);
      console.log('New gid: ' + process.getgid());
    }
    catch (err) {
      console.log('Failed to set gid: ' + err);
    }


### process.getuid()

Возвращает индикатор пользователя-владельца процесса (см. setuid(2)). Это числовой идентификатор, а не имя пользователя.

    console.log('Current uid: ' + process.getuid());


### process.setuid(id)

Устанавливает индикатор пользователя-владельца процесса (см. setuid(2)).
Функция принимает как числовое значение, так и его текстовый эквивалент.
Если функции передано имя пользователя, то функция блокирует выполнение кода
пока не разрешит имя в числовой идентификатор.

    console.log('Current uid: ' + process.getuid());
    try {
      process.setuid(501);
      console.log('New uid: ' + process.getuid());
    }
    catch (err) {
      console.log('Failed to set uid: ' + err);
    }


### process.version

Заданное при компиляции свойство, возвращающее версию Node (`NODE_VERSION`).

    console.log('Version: ' + process.version);

### process.installPrefix

Заданное при компиляции свойство, хранящее директорию,
в которую устанавливали Node (`NODE_PREFIX`).

    console.log('Prefix: ' + process.installPrefix);


### process.kill(pid, signal='SIGTERM')

Отправляет сигнал процессу. `pid` это идентификатор процесса, `signal` — строка,
обозначающая отправляемый сигнал. Имена сигналов это строки вроде `'SIGINT'` или `'SIGUSR1'`.
Если имя сигнала пропущено, отправлен будет сигнал `'SIGTERM'`.
См. kill(2) для более подробной информации.

Заметьте, что хотя функция и называется `process.kill`,
на самом деле она просто отправляет сигнал, как и системная команда `kill`.
Отправляемый сигнал может не только завершать целевой процесс.

Пример процесса, отправляющего сигнал самому себе:

    process.on('SIGHUP', function () {
      console.log('Got SIGHUP signal.');
    });

    setTimeout(function () {
      console.log('Exiting.');
      process.exit(0);
    }, 100);

    process.kill(process.pid, 'SIGHUP');


### process.pid

Идентификатор процесса (PID).

    console.log('This process is pid ' + process.pid);

### process.title

свойство для определение/задания заголовка, отобращаемого в списке процессов.


### process.platform

Платформа, на которой выполняется node. `'linux2'`, `'darwin'` и т.д.

    console.log('This platform is ' + process.platform);


### process.memoryUsage()

Возвращает объект, описывающий потребление памяти процессом Node.

    var util = require('util');

    console.log(util.inspect(process.memoryUsage()));

В результате получим:

    { rss: 4935680,
      vsize: 41893888,
      heapTotal: 1826816,
      heapUsed: 650472 }

`heapTotal` и `heapUsed`     относятся к потреблению памяти движком V8.


### process.nextTick(callback)

На следующей итерации цикла обработки событий запустить указанный обработчик.
Это *не* простой alias для `setTimeout(fn, 0)`, это намного более эффективный метод.

    process.nextTick(function () {
      console.log('nextTick callback');
    });


### process.umask([mask])

Задаёт и возвращает маску создания файлов процессом.
Дочерние процессы наследуют эту маску от процесса-родителя.
Если задан аргумент mask возвращает старую маску, иначе — возвращает текущую.

    var oldmask, newmask = 0644;

    oldmask = process.umask(newmask);
    console.log('Changed umask from: ' + oldmask.toString(8) +
                ' to ' + newmask.toString(8));

