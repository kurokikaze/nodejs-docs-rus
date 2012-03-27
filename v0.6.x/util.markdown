# Утилиты

    Стабильность: 5 - Заблокировано


Используйте `require('util')` для доступа к этим функциям.


## util.format()

Возвращает составную строку, используя первый параметр в качестве строки формата в стиле `printf`.

Первый аргумент является строкой, которая может содержать нуль
или несколько *заменителей*. Каждый заменитель будет заменён
на отформатированное значение в зависимости от типа аргумента.
Поддерживаемые заменители:

* `%s` - String.
* `%d` - Number (both integer and float).
* `%j` - JSON.
* `%%` - single percent sign (`'%'`). This does not consume an argument.

Если для заменителя не задан соответствующий аргумент, он не будет заменён.

    util.format('%s:%s', 'foo'); // 'foo:%s'

Если аргументов больше, чем заменителей в строке, оставшиеся аргументы
будут преобразованы в строки с помощью `util.inspect()` и склеены
с использованием пробела:

    util.format('%s:%s', 'foo', 'bar', 'baz'); // 'foo:bar baz'

Если первый аргумент не является строкой, то `util.format()` вернёт преобразованные в строки аргументы,
склееные с использованием пробела. Преобразование будет осуществляться функцией `util.inspect()`.

    util.format(1, 2, 3); // '1 2 3'


## util.debug(string)

Синхронный вывод. Заблокирует процесс и выведет строку `string`
в поток `stderr` немедленно.

    require('util').debug('message on stderr');


## util.log(string)

Выводит строку с меткой времени в `stdout`.

    require('util').log('Timestmaped message.');


## util.inspect(object, [showHidden], [depth], [colors])

Возвращает объект `object` в виде строки, очень удобно для отладки.

Если `showHidden` имеет значение true, неперечисляемые свойства тоже будут показаны.
По умолчанию `false`.

Параметр `depth` он сообщает `inspect` на какую глубину просмотреть объект,
прежде чем выдавать результат. Это полезно для больших сложных объектов.

По умолчанию принята глубина просмотра 2. Чтобы просмотреть объект
на неограниченную глубину, передайте `null` в качестве значения `depth`.

Если параметр `colors` равен `true`, то вывод функции будет расцвечен с использованием кодов цветов ANSI.
По умолчанию `false`.

Пример просмотра всех свойств объекта `util`:

    var util = require('util');

    console.log(util.inspect(util, true, null));


## util.isArray(object)

Возвращает `true` если переданный `object` является экземпляром `Array` и `false` в противном случае.

    var util = require('util');

    util.isArray([])
      // true
    util.isArray(new Array)
      // true
    util.isArray({})
      // false


## util.isRegExp(object)

Возвращает `true` если переданный `object` является экземпляром `RegExp` и `false` в противном случае.

    var util = require('util');

    util.isRegExp(/some regexp/)
      // true
    util.isRegExp(new RegExp('another regexp'))
      // true
    util.isRegExp({})
      // false


## util.isDate(object)

Возвращает `true` если переданный `object` является экземпляром `Date` и `false` в противном случае.

    var util = require('util');

    util.isDate(new Date())
      // true
    util.isDate(Date())
      // false (without 'new' returns a String)
    util.isDate({})
      // false


## util.isError(object)

Возвращает `true` если переданный `object` является экземпляром `Error` и `false` в противном случае.

    var util = require('util');

    util.isError(new Error())
      // true
    util.isError(new TypeError())
      // true
    util.isError({ name: 'Error', message: 'an error occurred' })
      // false


## util.pump(readableStream, writableStream, [callback])

Экспериментальный метод.

Читает данные из потока `readableStream` и посылает потоку `writableStream`.
Когда `writableStream.write(data)` возвращает `false` `readableStream`
приостанавливается пока не произойдёт событие `drain` во `writableStream`.
`callback` вызывается после закрытия `writableStream`. `callback` принимает
ошибку в случае если `writableStream` был закрыт или возникла ошибка.


## util.inherits(constructor, superConstructor)

Расширяет [конструктор](https://developer.mozilla.org/en/JavaScript/Reference/Global_Objects/Object/constructor)
прототипа методами из другого прототипа. Прототип `constructor` будет новым объектом, созданным с помощью `superConstructor`.

Также `superConstructor` будет доступен через свойство `constructor.super_`.

    var util = require("util");
    var events = require("events");

    function MyStream() {
        events.EventEmitter.call(this);
    }

    util.inherits(MyStream, events.EventEmitter);

    MyStream.prototype.write = function(data) {
        this.emit("data", data);
    }

    var stream = new MyStream();

    console.log(stream instanceof events.EventEmitter); // true
    console.log(MyStream.super_ === events.EventEmitter); // true

    stream.on("data", function(data) {
        console.log('Received data: "' + data + '"');
    })
    stream.write("It works!"); // Received data: "It works!"

