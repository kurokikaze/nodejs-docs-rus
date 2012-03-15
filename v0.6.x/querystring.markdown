# Разбор строки запроса

<!--name=querystring-->

Этот модуль предоставляет инструменты для работы со строкой запроса.
Используйте `require('querystring')` чтобы получить доступ к функциям модуля.


## querystring.stringify(obj, [sep], [eq])

Сериализует объект в строку запроса.
Позволяет опционально задать символ разделителя (`'&'`) и присваивания (`'='`).

Пример:

    querystring.stringify({ foo: 'bar', baz: ['qux', 'quux'], corge: '' })
    // returns
    foo=bar&baz=qux&baz=quux&corge=

    querystring.stringify({foo: 'bar', baz: 'qux'}, ';', ':')
    // returns
    'foo:bar;baz:qux'

## querystring.parse(str, [sep], [eq])

Десериализует строку запроса в объект.
Позволяет опционально задать символ разделителя (`'&'`) и присваивания (`'='`).

Пример:

    querystring.parse('foo=bar&baz=qux&baz=quux&corge')
    // returns
    { foo: 'bar', baz: ['qux', 'quux'], corge: '' }

## querystring.escape

Функция экранирования, используемая в `querystring.stringify`,
предоставляется для того чтобы проще было заменить её собственной.

## querystring.unescape

Функция декодирования, используемая `querystring.parse`,
предоставляется для того чтобы проще было заменить её собственной.
