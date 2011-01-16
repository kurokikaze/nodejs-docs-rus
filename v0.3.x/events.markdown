## Cобытия

Множество объектов в Node генерируют события: `net.Server` вызывает событие
при каждом поступающем запросе, `fs.readStream` вызывает событие при открытии файла.
Все объекты, генерирующие события, являются экземплярами `events.EventEmitter`.
Используйте `require('events')` чтобы получить доступ к модулю.

Обычно события представлены строками в стиле camelCase. Вот несколько примеров:
`'stream'`, `'data'`, `'messageBegin'`. Однако, это только пожелание и никаких
жёстких ограничений на имена событий не накладывается.

К объектам могут быть присоединены функции, которые будут выполняться
при генерации события. Эти функции называются _обработчиками_ (_listeners_).


### events.EventEmitter

Класс `EventEmitter` находится в модуле `'events'`: `require(events').EventEmitter`.

Когда источник событий сталкивается с ошибкой, типичное поведение — сгенерировать
событие ошибки `'error'`. События ошибки особенные — если им не назначен
обработчик, то они выводят на экран стек вызовов (stack trace) и завершают программу.

Все источники событий генерируют событие `'newListener'`,
когда к ним добавляются новые обработчики.

#### emitter.addListener(event, listener)
#### emitter.on(event, listener)

Добавляет обработчик в конец массива обработчиков указанного события.

    server.on('connection', function (stream) {
      console.log('someone connected!');
    });

#### emitter.once(event, listener)

Добавляет **однократный** обработчик указанного события. Обработчик вызываетя
один раз при первом наступлении события, после чего удаляется.

    server.once('connection', function (stream) {
      console.log('Ah, we have our first user!');
    });

#### emitter.removeListener(event, listener)

Удаляет обработчик из массива обработчиков указанного события.
**Внимание:** изменяет индексы в массиве обработчиков после указанного обработчика.

    var callback = function(stream) {
      console.log('someone connected!');
    };
    server.on('connection', callback);
    // ...
    server.removeListener('connection', callback);


#### emitter.removeAllListeners(event)

Удаляет все обработчики из массива обработчиков для указанного события.


#### emitter.listeners(event)

Возвращает массив обработчиков для указанного события. Этот массив может быть
использован, например, для удаления обработчиков.

    server.on('connection', function (stream) {
      console.log('someone connected!');
    });
    console.log(util.inspect(server.listeners('connection')); // [ [Function] ]

#### emitter.emit(event, [arg1], [arg2], [...])

Выполнит все обработчики события по порядку с указанными аргументами.

#### Событие: 'newListener'

`function (event, listener) { }`

Это событие вызывается каждый раз при добавлении обработчика события.

