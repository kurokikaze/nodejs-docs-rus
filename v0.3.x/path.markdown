## Path

Этот модуль содержит средства для работы с путями.
Используйте `require('path')` чтобы получить к нему доступ.

### path.join([path1], [path2], [...])

Соединяет все аргументы и обрабатывает получившийся путь.

Пример:

    node> require('path').join(
    ...   '/foo', 'bar', 'baz/asdf', 'quux', '..')
    '/foo/bar/baz/asdf'

### path.normalizeArray(arr)

Нормализует массив частей пути, обрабатывая `'..'` и `'.'`.

Пример:

    path.normalizeArray(['', 
      'foo', 'bar', 'baz', 'asdf', 'quux', '..'])
    // returns
    [ '', 'foo', 'bar', 'baz', 'asdf' ]

### path.normalize(p)

Нормализует строку пути, обрабатывая `'..'` и `'.'`.

Пример:

    path.normalize('/foo/bar/baz/asdf/quux/..')
    // returns
    '/foo/bar/baz/asdf'

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

