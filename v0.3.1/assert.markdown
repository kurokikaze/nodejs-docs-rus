## Тестирование (asserts)

Этот модуль используется для написания юнит-тестов для ваших приложений,
вы можете использовать его вызвав `require('assert')`.

### assert.fail(actual, expected, message, operator)

Проверяет что `actual` соответствует `expected` используя указанный оператор.

### assert.ok(value, [message])

Проверяет что значение `value` равно `true`, то же самое что
`assert.equal(true, value, message);`.

### assert.equal(actual, expected, [message])

Неглубокая проверка на равенство с использованием соответствующего оператора ( `==` ).

### assert.notEqual(actual, expected, [message])

Неглубокая проверка на неравенство с использованием соответствующего оператора ( `!=` ).

### assert.deepEqual(actual, expected, [message])

Глубокая проверка на равенство.

### assert.notDeepEqual(actual, expected, [message])

Глубокая проверка на неравенство.

### assert.strictEqual(actual, expected, [message])

Проверка на строгое равенство, с использованием соответствующего оператора ( `===` ).

### assert.notStrictEqual(actual, expected, [message])

Проверка на строгое неравенство, с использованием соответствующего оператора ( `!==` ).

### assert.throws(block, [error], [message])

Ожидает что блок кода `block` вызовет ошибку.

### assert.doesNotThrow(block, [error], [message])

Ожидает что блок кода `block` не вызовет ошибки.

### assert.ifError(value)

Проверяет что `value` имеет значение `false`, бросает исключение встретив `true`.
Удобно для проверки первого аргумента функций-обработчиков, `error`.

