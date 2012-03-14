# Дочерний процесс

    Стабильность: 3 - Стабильно

Node предоставляет tri-directional popen(3) с помощью модуля `child_process`.

С дочерним потоком можно обмениваться данными через `stdin`, `stdout` и `stderr`
в полностью неблокирующем стиле.

Для создания дочернего процесса используйте `require('child_process').spawn()` или
`require('child_process').fork()`. Различие между этими вызовами опасаны ниже.

## Class: ChildProcess

`ChildProcess` — экземпляр `EventEmitter`.

С дочерним процессом всегда ассоциированы три потока: `child.stdin`, `child.stdout` и `child.stderr`.
Они могут быть общими с соответствующими потоками родителя, или различаться.

Класс ChildProcess не должен быть использован напрямую, используйте метод `spawn()` или `fork()`
модуля `child_process` для создания дочернего процесса.

### Событие: 'exit'

* `code` {Number} Код выхода, в случае успешного совершения работы.
* `signal` {String} Сигнал, завершивший процесс, если он был завершён родителем.

`function (code, signal) {}`

Это событие генерируется при завершении дочернего процесса. Если процесс
завершён нормально, в `code` передаётся код завершения процесса, иначе
передаётся `null`. Если процесс завершился от принятия сигнала, то `signal` —
это строка, содержащая имя сигнала, либо `null`.

См. также: `waitpid(2)`.

### child.stdin

* {Stream object}

`Поток с возможностью записи`, связанный со `stdin` процесса дочернего.
Закрытие потока с помощью `end()` часто приводит к завершению процесса.

Если поток `stdin` дочернего потока совпадает с соответствующим поток родителя, то это свойство не задано.

### child.stdout

* {Stream object}

`Поток с возможностью чтения`, связанный со `stdout` дочернего процесса.

Если поток `stdout` дочернего потока совпадает с соответствующим поток родителя, то это свойство не задано.

### child.stderr

* {Stream object}

`Поток с возможностью чтения`, связанный со `stderr` дочернего процесса.

Если поток `stderr` дочернего потока совпадает с соответствующим поток родителя, то это свойство не задано.

### child.pid

* {Integer}

Идентификатор дочернего процесса.

Пример:

    var spawn = require('child_process').spawn,
        grep  = spawn('grep', ['ssh']);

    console.log('Spawned child pid: ' + grep.pid);
    grep.stdin.end();

### child.kill(signal='SIGTERM')

* `signal` {String}

Отправляет сигнал дочернему процессу. Если аргументы не переданы, то процессу
будет отправлен сигнал `'SIGTERM'`. См. `signal(7)` для списка возможных имён сигналов.

    var spawn = require('child_process').spawn,
        grep  = spawn('grep', ['ssh']);

    grep.on('exit', function (code, signal) {
      console.log('child process terminated due to receipt of signal '+signal);
    });

    // send SIGHUP to process
    grep.kill('SIGHUP');

Заметьте, что хотя функция называется `kill`, сигнал, отправляемый дочернему процессу,
не обязательно его завершит. Метод `kill` просто отправляет сигналы.

См. также: `kill(2)`.

### child.send(message, [sendHandle])

* `message` {Object}
* `sendHandle` {Handle object}

Send a message (and, optionally, a handle object) to a child process.

See `child_process.fork()` for details.

## child_process.spawn(command, [args], [options])

* `command` {String} Команда для исполнения
* `args` {Array} Список строк-аргументов
* `options` {Object}
  * `cwd` {String} Рабочая директория дочернего процесса
  * `customFds` {Array} **Устарело** Файловые дескрипторы для использования дочерним процессом, см. ниже
  * `env` {Object} Переменные окружение дочернего процесса, пары имя-значение
  * `setsid` {Boolean}
* Возвращает: {ChildProcess object}

Запускает новый процесс с указанной командой `command` и аргументами командной
строки `args`. Если аргументы пропущены, args будет пустым массивом.

Третий аргумент функции используется для задания дополнительных опций
со следующими значениями по умолчанию:

    { cwd: undefined,
      env: process.env,
      customFds: [-1, -1, -1],
      setsid: false
    }

`cwd` позволяет вам задать рабочую папку для дочернего процесса.
Используйте `env` для определия переменных окружения, видимых дочернему процессу.
С помощью `customFds` возможно связать `stdin`, `stdout` и `stderr` дочернего процесса
с существующими потоками; -1 означает, что нужно создать новый поток.
Если `setsid` истинно, то процесс будет создан в новой пользовательской сессии.

Пример запуска `ls -lh /usr`, чтения `stdout`, `stderr` и получения кода завершения:

    var util   = require('util'),
        spawn  = require('child_process').spawn,
        ls     = spawn('ls', ['-lh', '/usr']);

    ls.stdout.on('data', function (data) {
      console.log('stdout: ' + data);
    });

    ls.stderr.on('data', function (data) {
      console.log('stderr: ' + data);
    });

    ls.on('exit', function (code) {
      console.log('child process exited with code ' + code);
    });

Пример: достаточно сложный способ выполнить 'ps ax | grep ssh'.

    var util  = require('util'),
        spawn = require('child_process').spawn,
        ps    = spawn('ps', ['ax']),
        grep  = spawn('grep', ['ssh']);

    ps.stdout.on('data', function (data) {
      grep.stdin.write(data);
    });

    ps.stderr.on('data', function (data) {
      console.log('ps stderr: ' + data);
    });

    ps.on('exit', function (code) {
      if (code !== 0) {
        console.log('ps process exited with code ' + code);
      }
      grep.stdin.end();
    });

    grep.stdout.on('data', function (data) {
      console.log(data);
    });

    grep.stderr.on('data', function (data) {
      console.log('grep stderr: ' + data);
    });

    grep.on('exit', function (code) {
      if (code !== 0) {
        console.log('grep process exited with code ' + code);
      }
    });

Пример проверки ошибки запуска приложения:

    var spawn = require('child_process').spawn,
        child = spawn('bad_command');

    child.stderr.setEncoding('utf8');
    child.stderr.on('data', function (data) {
      if (/^execvp\(\)/.test(data)) {
        console.log('Failed to start child process.');
      }
    });

См. также: `child_process.exec()` и `child_process.fork()`.


## child_process.exec(command, [options], callback)

* `command` {String} Команда для исполнения, с аргументами, разделёнными пробелами
* `options` {Object}
  * `cwd` {String} Рабочая директория дочернего процесса
  * `customFds` {Array} **Устарело** Файловые дескрипторы для использования дочерним процессом, см. ниже
  * `env` {Object} Переменные окружение дочернего процесса, пары имя-значение
  * `setsid` {Boolean}
  * `encoding` {String} (По умолчанию: 'utf8')
  * `timeout` {Number} (По умолчанию: 0)
  * `maxBuffer` {Number} (По умолчанию: 200*1024)
  * `killSignal` {String} (По умолчанию: 'SIGTERM')
* `callback` {Function} Функция обратного вызова, принимающая вывод процесса после его завершения
  * `code` {Integer} Код выхода
  * `stdout` {Buffer}
  * `stderr` {Buffer}
* Возвращает: {ChildProcess object}

Высокоуровневый способ выполнить команду в качестве дочернего процесса,
сохранить весь её вывод, и передать его в callback.

    var util = require('util'),
        exec = require('child_process').exec,
        child;

    child = exec('cat *.js bad_file | wc -l',
      function (error, stdout, stderr) {
        console.log('stdout: ' + stdout);
        console.log('stderr: ' + stderr);
        if (error !== null) {
          console.log('exec error: ' + error);
        }
    });

Функция-callback получает аргументы `(error, stdout, stderr)`. При удачном
выполнении в `error` будет `null`. При ошибке `error` будет экземпляром `Error`,
`err.code` будет кодом завершения дочернего процесса, а в `err.signal` будет
содержаться имя сигнала, завершившего процесс.

Вторым аргументом могут быть переданы дополнительные опции
со следующими значениями по умолчанию:

    { encoding: 'utf8',
      timeout: 0,
      maxBuffer: 200*1024,
      killSignal: 'SIGTERM',
      cwd: null,
      env: null }

Если `timeout` больше 0, процесс будет завершён, если он выполняется дольше,
чем `timeout` миллисекунд. Дочерний процесс завершается с помощью сигнала
`killSignal`. В `maxBuffer` указывается максимальный объём данных, разрешённый
на `stdout` или `stderr` — если этот объём будет превышен,
то дочерний процесс будет завершён.

## child_process.execFile(file, args, options, callback)

* `file` {String} Файл для исполнения
* `args` {Array} Список строк-аргументов
* `options` {Object}
  * `cwd` {String} Рабочая директория дочернего процесса
  * `customFds` {Array} **Устарело** Файловые дескрипторы для использования дочерним процессом, см. ниже
  * `env` {Object} Переменные окружение дочернего процесса, пары имя-значение
  * `setsid` {Boolean}
  * `encoding` {String} (По умолчанию: 'utf8')
  * `timeout` {Number} (По умолчанию: 0)
  * `maxBuffer` {Number} (По умолчанию: 200*1024)
  * `killSignal` {String} (По умолчанию: 'SIGTERM')
* `callback` {Function} Функция обратного вызова, принимающая вывод процесса после его завершения
  * `code` {Integer} Код выхода
  * `stdout` {Buffer}
  * `stderr` {Buffer}
* Возвращает: {ChildProcess object}


Идентично `child_process.exec()`, но не создаёт subshell, а выполняет файл напрямую.
Это делает его компактнее `child_process.exec`. Имеет аналогичные опции.

## child_process.fork(modulePath, [args], [options])

* `modulePath` {String} Модуль который будет запущен как потомок
* `args` {Array} Список строк-аргументов
* `options` {Object}
  * `cwd` {String} Рабочая директория дочернего процесса
  * `customFds` {Array} **Устарело** Файловые дескрипторы для использования дочерним процессом, см. ниже
  * `env` {Object} Переменные окружение дочернего процесса, пары имя-значение
  * `setsid` {Boolean}
  * `encoding` {String} (По умолчанию: 'utf8')
  * `timeout` {Number} (По умолчанию: 0)
* `callback` {Function} Функция обратного вызова, принимающая вывод процесса после его завершения
  * `code` {Integer} Код выхода
  * `stdout` {Buffer}
  * `stderr` {Buffer}
* Возвращает: ChildProcess object

Это частный случай `spawn()` для запуска Node процессов. В возвращаемый объект, который
имеет все методы стандартного дочернего объекта, добавляется канал для обмена сообщениями.
Запись в канал осуществляется методом `child.send(message, [sendHandle])`, а получение
сообщения с помощью события `'message'` дочернего процесса.

Для примера:

    var cp = require('child_process');

    var n = cp.fork(__dirname + '/sub.js');

    n.on('message', function(m) {
      console.log('РОДИТЕЛЬ получил сообщение:', m);
    });

    n.send({ hello: 'world' });

Скрипт дочеренго процесса, `'sub.js'` может выглядеть так:

    process.on('message', function(m) {
      console.log('РЕБЕНОК получил сообщение:', m);
    });

    process.send({ foo: 'bar' });

В дочеренем процессе объект `process` будет иметь метод `send()`, и `process`
будет сообщать о полученых объектах при получении сообщения на канал.

По умолчанию дочерний процесс Node имеет потоки stdin, stdout, stderr
связанные с родительским процессом.

Дочернии процессы все еще являются новыми экземплярами V8. Каждый процесс Node
стартует минимум за 30ms и потребляет минимум 10mb памяти. Это значит что вы 
не можете создавать много дочерних процессов.

Параметр `sendHandle` в `child.send()` служит для передачи обработчика в дочерний
процесс. Дочерний процесс получит обработчик как второй аргумент в событии `message`.

Пример передачи обработчика.

    var server = require('net').createServer();
    var child = require('child_process').fork(__dirname + '/child.js');
    // Запустить сервер и передать отбработчик в дочерний процесс.
    server.listen(1337, function() {
      child.send({ server: true }, server._handle);
    });

Пример получения обработчика и совместного использования его между процессами.

    process.on('message', function(m, serverHandle) {
      if (serverHandle) {
        var server = require('net').createServer();
        server.listen(serverHandle);
      }
    });
