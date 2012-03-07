## Path

Этот модуль содержит средства для работы с путями.
Используйте `require('path')` чтобы получить к нему доступ.

### path.normalize(p)

Нормализует строку пути, обрабатывая `'..'` и `'.'`.

Пример:

    path.normalize('/foo/bar/baz/asdf/quux/..')
    // returns
    '/foo/bar/baz/asdf'

### path.join([path1], [path2], [...])

Соединяет все аргументы и нормализует получившийся путь.

Пример:

    node> require('path').join(
    ...   '/foo', 'bar', 'baz/asdf', 'quux', '..')
    '/foo/bar/baz/asdf'

### path.resolve([from ...], to)

Разрешает путь `to` в абсолютный.

Если `to` не является абсолютным, то к нему добавляют пути, справа налево,
из аргументов `from` до тех пор, пока полученный путь не будет абсолютным.
Если в итоге путь останется относительным, он будет разрешён относительно
рабочей директории. полученный путь нормализуется и у него удаляется
завершающий слеш, если конечно это не корневая директория.

Возможно, вам будет проще понять механизм работы этого метода,
если считать что он последовательно выполняет команду `cd` и возвращает конечный путь, т.е.

    path.resolve('foo/bar', '/tmp/file/', '..', 'a/../subfile')

возвращает тоже самое, что и:

    cd foo/bar
    cd /tmp/file/
    cd ..
    cd a/../subfile
    pwd

Разница в том, что промежуточные пути могут не существовать или быть файлами.

Примеры:

    path.resolve('/foo/bar', './baz')
    // returns
    '/foo/bar/baz'

    path.resolve('/foo/bar', '/tmp/file/')
    // returns
    '/tmp/file'

    path.resolve('wwwroot', 'static_files/png/', '../gif/image.gif')
    // if currently in /home/myself/node, it returns
    '/home/myself/node/wwwroot/static_files/gif/image.gif'

### path.dirname(p)

Возвращает имя директории для пути. Действует как Unix-команда `dirname`.

Пример:

    path.dirname('/foo/bar/baz/asdf/quux')
    // returns
    '/foo/bar/baz/asdf'

### path.basename(p, [ext])

Возвращает последнюю часть пути. Действует как Unix-команда `basename`.

Пример:

    path.basename('/foo/bar/baz/asdf/quux.html')
    // returns
    'quux.html'

    path.basename('/foo/bar/baz/asdf/quux.html', '.html')
    // returns
    'quux'

### path.extname(p)

Возвращает расширение пути. Учитывается всё после последней '.' в последней части пути.
Если в последней части нет '.' или '.' единственный символ, возвращает пустую строку.

Пример:

    path.extname('index.html')
    // returns 
    '.html'

    path.extname('index')
    // returns
    ''

### path.exists(p, [callback])

Проверяет, существует ли данный путь. Вызывает переданный обработчик
с аргументом `true` или `false`.

Пример:

    path.exists('/etc/passwd', function (exists) {
      util.debug(exists ? "it's there" : "no passwd!");
    });

### path.existsSync(p)

Синхронная версия `path.exists`.

