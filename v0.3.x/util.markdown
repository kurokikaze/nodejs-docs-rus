## Утилиты

Используйте `require('util')` для доступа к этим функциям.


### util.debug(string)

Синхронный вывод. Заблокирует процесс и выведет строку `string`
в поток `stderr` немедленно.

    require('util').debug('message on stderr');


### util.log(string)

Выводит строку с меткой времени в `stdout`.

    require('util').log('Timestmaped message.');


### util.inspect(object, showHidden=false, depth=2)

Возвращает объект `object` в виде строки, очень удобно для отладки.

Если `showHidden` имеет значение true, неперечисляемые свойства тоже будут показаны.

Параметр `depth` он сообщает `inspect` на какую глубину просмотреть объект,
прежде чем выдавать результат. Это полезно для больших сложных объектов.

По умолчанию принята глубина просмотра 2. Чтобы просмотреть объект
на неограниченную глубину, передайте `null` в качестве значения `depth`.

Пример просмотра всех свойств объекта `util`:

    var util = require('util');

    console.log(util.inspect(util, true, null));


### util.pump(readableStream, writeableStream, [callback])

Экспериментальный метод.

Читает данные из потока `readableStream` и посылает потоку `writableStream`.
Когда `writeableStream.write(data)` возвращает `false` `readableStream`
приостанавливается пока не произойдёт событие `drain` во `writableStream`.
`callback` вызывается после закрытия `writableStream`. `callback` принимает
ошибку в случае если `writableStream` был закрыт или возникла ошибка.


### util.inherits(constructor, superConstructor)

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

