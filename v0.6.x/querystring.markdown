## Разбор строки запроса

Этот модуль предоставляет инструменты для работы со строкой запроса.
Используйте `require('querystring')` чтобы получить доступ к функциям модуля.


### querystring.stringify(obj, sep='&', eq='=')

Сериализует объект в строку запроса. Можно менять символы разделителя и присваивания.

Пример:

    querystring.stringify({foo: 'bar'})
    // returns
    'foo=bar'

    querystring.stringify({foo: 'bar', baz: 'bob'}, ';', ':')
    // returns
    'foo:bar;baz:bob'

### querystring.parse(str, sep='&', eq='=')

Десериализует строку запроса в объект. Можно менять символы разделителя и присваивания.

Пример:

    querystring.parse('a=b&b=c')
    // returns
    { a: 'b', b: 'c' }

### querystring.escape

Функция экранирования, используемая в `querystring.stringify`,
предоставляется для того чтобы проще было заменить её собственной.

### querystring.unescape

Функция декодирования, используемая `querystring.parse`,
предоставляется для того чтобы проще было заменить её собственной.

