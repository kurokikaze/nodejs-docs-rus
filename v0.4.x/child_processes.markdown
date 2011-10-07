## Дочерние процессы

Node предоставляет tri-directional popen(3) в классе `ChildProcess`.

С дочерним потоком можно обмениваться данными через `stdin`, `stdout` и `stderr`
в полностью неблокирующем стиле.

Для создания дочернего процесса используйте `require('child_process').spawn()`.

С дочерним процессом всегда ассоциированы три потока:
`child.stdin`, `child.stdout` и `child.stderr`.

`ChildProcess` — экземпляр `EventEmitter`.

### Событие: 'exit'

`function (code, signal) {}`

Это событие генерируется при завершении дочернего процесса. Если процесс
завершён нормально, в `code` передаётся код завершения процесса, иначе
передаётся `null`. Если процесс завершился от принятия сигнала, то `signal` —
это строка, содержащая имя сигнала, либо `null`.

См. также: `waitpid(2)`.

### child.stdin

`Поток с возможностью записи`, связанный со `stdin` процесса дочернего.
Закрытие потока с помощью `end()` часто приводит к завершению процесса.

### child.stdout

`Поток с возможностью чтения`, связанный со `stdout` дочернего процесса.

### child.stderr

`Поток с возможностью чтения`, связанный со `stderr` дочернего процесса.

### child.pid

Идентификатор дочернего процесса.

Пример:

    var spawn = require('child_process').spawn,
        grep  = spawn('grep', ['ssh']);

    console.log('Spawned child pid: ' + grep.pid);
    grep.stdin.end();


### child_process.spawn(command, args=[], [options])

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

См. также: `child_process.exec()`.


### child_process.exec(command, [options], callback)

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


### child.kill(signal='SIGTERM')

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

