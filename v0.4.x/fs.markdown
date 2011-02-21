## Файловая система

Файловый ввод/вывод обеспечивается с помощью простой обертки вокруг стандартных
функций POSIX. Используйте `require('fs')` чтобы получить к ним доступ.
Все эти методы имеют асинхронную и синхронную версии.

Асинхронные версии всегда принимают функцию обратного вызова в качестве
последнего аргумента. Аргументы, передаваемые в функцию обратного вызова зависят
от вызываемой функции, но первый из них всегда зарезервирован для исключения.
Если операция завершается без ошибок, то в качется первого аргумента
передаётся `null` или `undefined`.

Пример использования асинхронной версии:

    var fs = require('fs');

    fs.unlink('/tmp/hello', function (err) {
      if (err) throw err;
      console.log('successfully deleted /tmp/hello');
    });

Пример использования асинхронной версии:

    var fs = require('fs');

    fs.unlinkSync('/tmp/hello')
    console.log('successfully deleted /tmp/hello');

Асинхронные методы не гарантируют порядок выполнения операций.
Следующий код может сработать неправильно:

    fs.rename('/tmp/hello', '/tmp/world', function (err) {
      if (err) throw err;
      console.log('renamed complete');
    });
    fs.stat('/tmp/world', function (err, stats) {
      if (err) throw err;
      console.log('stats: ' + JSON.stringify(stats));
    });

Вполне возможно что fs.stat выполнится до fs.rename. Правильный способ сделать
то же самое — выполнение этих методов по цепочке.

    fs.rename('/tmp/hello', '/tmp/world', function (err) {
      if (err) throw err;
      fs.stat('/tmp/world', function (err, stats) {
        if (err) throw err;
        console.log('stats: ' + JSON.stringify(stats));
      });
    });

В нагруженных процессах программисту _строго рекомендуется_ использовать
асинхронные версии вызовов. Синхронные версии будут блокировать весь процесс
до своего завершения — предотвращая любые новые соединения.

### fs.rename(path1, path2, [callback])

Асинхронное переименование (rename(2)).
Обработчику не передаётся аргументов кроме возможного исключения.

### fs.renameSync(path1, path2)

Синхронный rename(2).

### fs.truncate(fd, len, [callback])

Асинхронный ftruncate(2).
Обработчику не передаётся аргументов кроме возможного исключения.

### fs.truncateSync(fd, len)

Синхронный ftruncate(2).

### fs.chmod(path, mode, [callback])

Асинхронное изменение прав доступа (chmod(2)).
Обработчику не передаётся аргументов кроме возможного исключения.

### fs.chmodSync(path, mode)

Синхронный chmod(2).

### fs.stat(path, [callback])

Асинхронный stat(2). Обработчик получает два аргумента `(err, stats)`,
где `stats` это экземпляр `fs.Stats`. Он выглядит примерно так:

    { dev: 2049,
      ino: 305352,
      mode: 16877,
      nlink: 12,
      uid: 1000,
      gid: 1000,
      rdev: 0,
      size: 4096,
      blksize: 4096,
      blocks: 8,
      atime: '2009-06-29T11:11:55Z',
      mtime: '2009-06-29T11:11:40Z',
      ctime: '2009-06-29T11:11:40Z' }

См. `fs.Stats` ниже для дополнительной информации.

### fs.lstat(path, [callback])

Асинхронный lstat(2). Обработчик получает два аргумента `(err, stats)`,
где `stats` это экземпляр `fs.Stats`.

### fs.fstat(fd, [callback])

Асинхронный fstat(2). Обработчик получает два аргумента `(err, stats)`,
где `stats` это экземпляр `fs.Stats`.

### fs.statSync(path)

Синхронный stat(2). Возвращает экземпляр `fs.Stats`.

### fs.lstatSync(path)

Синхронный lstat(2). Возвращает экземпляр `fs.Stats`.

### fs.fstatSync(fd)

Синхронный fstat(2). Возвращает экземпляр `fs.Stats`.

### fs.link(srcpath, dstpath, [callback])

Асинхронное создание ссылки (link(2)).
Передаваемой функции не передаётся ничего кроме возможного исключения.

### fs.linkSync(srcpath, dstpath)

Синхронный link(2).

### fs.symlink(linkdata, path, [callback])

Асинхронное создание символической ссылки (symlink(2)).
Передаваемой функции не передаётся ничего кроме возможного исключения.

### fs.symlinkSync(linkdata, path)

Синхронный symlink(2).

### fs.readlink(path, [callback])

Асинхронное разрешение ссылки (readlink(2)).
Обработчик принимает два аргумента `(err, resolvedPath)`.

### fs.readlinkSync(path)

Синхронный readlink(2). Возвращает полученный путь.

### fs.realpath(path, [callback])

Асинхронный realpath(2).
Обработчик принимает два аргумента `(err, resolvedPath)`.

### fs.realpathSync(path)

Синхронный realpath(2). Возвращает полученный путь.

### fs.unlink(path, [callback])

Асинхронный unlink(2).
Передаваемой функции не передаётся ничего кроме возможного исключения.

### fs.unlinkSync(path)

Синхронный unlink(2).

### fs.rmdir(path, [callback])

Асинхронный rmdir(2).
Передаваемой функции не передаётся ничего кроме возможного исключения.

### fs.rmdirSync(path)

Синхронный rmdir(2).

### fs.mkdir(path, mode, [callback])

Асинхронный mkdir(2).
Передаваемой функции не передаётся ничего кроме возможного исключения.

### fs.mkdirSync(path, mode)

Синхронный mkdir(2).

### fs.readdir(path, [callback])

Асинхронное чтение содержимого директории (readdir(3)).
Обработчик принимает два аргумента `(err, files)`,
где `files` это массив имён файлов в директории исключая `'.'` и `'..'`.


### fs.readdirSync(path)

Синхронный readdir(3). Возвращает массив имён файлов исключая `'.'` и `'..'`.

### fs.close(fd, [callback])

Асинхронный close(2).
Передаваемой функции не передаётся ничего кроме возможного исключения.

### fs.closeSync(fd)

Синхронный close(2).

### ### fs.open(path, flags, [mode], [callback])

Асинхронное открытие файла. См. open(2).
Флаги могут быть `'r'`, `'r+'`, `'w'`, `'w+'`, `'a'` или `'a+'`.
По умолчанию `mode` равняется 0666. Обработчик принимает два аргумента: `(err, fd)`.

### fs.openSync(path, flags, [mode])

Синхронный open(2).

### fs.write(fd, buffer, offset, length, position, [callback])

Записывает буфер `buffer` в файл указанный дескриптором `fd`.

Сдвиг `offset` и длина `length` определяют часть буфера, которая будет записана.

Позиция `position` задаёт смещение от начала файла куда должны быть записаны данные.
Если `position` равна `null`, данные записываются с текущей позиции. См. pwrite(2).

Обработчик принимает два аргумента `(err, written)`,
где `written` указывает сколько _байт_ было записано в файлn.

### fs.writeSync(fd, buffer, offset, length, position)

Синхронная версия `fs.write()`. Возвращает число записанных _байт_.

### fs.writeSync(fd, str, position, encoding='utf8')

Синхронная версия `fs.write()`, записывающая в файл строку, а не буфер.
Возвращает число записанных _байт_.

### fs.read(fd, buffer, offset, length, position, [callback])

Читает данные из файла, указанного дескриптором `fd`.

`buffer` — буфер, в который будут помещены прочитанные данные.

`offset` — смещение внутри буфера с которого начнётся запись.

`length` — число байт для чтения.

`position` — число означающее позицию, с которой начнётся чтение файла.
Если `position` принимает значение `null`, данные будут прочитаны с текущей позиции.

Функция-обработчик принимает два аргумента, `(err, bytesRead)`.

### fs.readSync(fd, buffer, offset, length, position)

Синхронная версия `fs.read`. Возвращает количество прочитанных _байт_.

### fs.readSync(fd, length, position, encoding)

Синхронная версия `fs.read`, читающая из файл строку, а не буфер.
Возвращает количество прочитанных _байт_.

### fs.readFile(filename, [encoding], [callback])

Асинхронно загружает в память содержимое файла. Пример:

    fs.readFile('/etc/passwd', function (err, data) {
      if (err) throw err;
      console.log(data);
    });

Обработчику передаются два аргумента: `(err, data)`, где `data` — содержимое файла.

Если кодировка не указана, возвращается буфер.


### fs.readFileSync(filename, [encoding])

Синхронная версия `fs.readFile`. Возвращает содержимое файла `filename`.

Если указана кодировка `encoding`, то функция возвращает строку. Иначе — возвращает буфер.


### fs.writeFile(filename, data, encoding='utf8', [callback])

Асинхронно записывает данные в файл. `data` может быть строкой или буфером.

Пример:

    fs.writeFile('message.txt', 'Hello Node', function (err) {
      if (err) throw err;
      console.log('It\'s saved!');
    });

### fs.writeFileSync(filename, data, encoding='utf8')

Синхронная версия `fs.writeFile`.

### fs.watchFile(filename, [options], listener)

Наблюдает за файлом `filename`. Обработчик `listener` вызывается каждый раз
при обращении к файлу.

Второй аргумент необязателен. Объект `options`, если он передан, должен содержать
два свойства: булево `persistent` и `interval`, задержку между проверками
файла в миллисекундах. Значение по умолчанию: `{ persistent: true, interval: 0 }`.

Обработчик `listener` принимает два аргумента: текущий объект stat и предыдущий объект stat.

    fs.watchFile(f, function (curr, prev) {
      console.log('the current mtime is: ' + curr.mtime);
      console.log('the previous mtime was: ' + prev.mtime);
    });

Эти объекты — экземпляры `fs.Stat`.

Если вы хотите обрабатывать только события изменения файла, вам следует сравнивать
`curr.mtime` и `prev.mtime.


### fs.unwatchFile(filename)

Прекращает следить за файлом `filename`.

## fs.Stats

Объекты, возвращаемые `fs.stat()`, `fs.lstat()` и `fs.fstat()` являются
экземплярами этого класса.

 - `stats.isFile()`
 - `stats.isDirectory()`
 - `stats.isBlockDevice()`
 - `stats.isCharacterDevice()`
 - `stats.isSymbolicLink()` (доступно только после `fs.lstat()`)
 - `stats.isFIFO()`
 - `stats.isSocket()`


## fs.ReadStream

`ReadStream` является `потоком с возможностью чтения`.

### fs.createReadStream(path, [options])

Возвращает новый объект ReadStream.

`options` это объект со следующими полями по умолчанию:

    { flags: 'r',
      encoding: null,
      mode: 0666,
      bufferSize: 4096 }

Объект `options` может содержать поля `start` и `end` для чтения фрагмента файла
вместо всего файла. И `start`, и `end` являются границами с включением
и начинаюся с 0. При использовании необходимо задавать обе границы

Пример чтения последних 10 байт файла размером 100 байт:

    fs.createReadStream('sample.txt', {start: 90, end: 99});


## fs.WriteStream

`WriteStream` является `потоком с возможностью записи`.

### Событие: 'open'

`function (fd) { }`

`fd` содержит файловый дескриптов, используемый WriteStream.

### fs.createWriteStream(path, [options])

Возвращает новый объект WriteStream.

`options` это объект со следующими свойствами по умолчанию:

    { flags: 'w',
      encoding: null,
      mode: 0666 }

