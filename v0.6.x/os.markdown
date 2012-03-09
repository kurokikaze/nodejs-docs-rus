# Операционная система

Этот модуль содержит функции для определения параметров операционной системы.

Используйте `require('os')` чтобы получить к нему доступ.

## os.hostname()

Возвращает имя компьютера в сети.

## os.type()

Возвращает имя операционной системы.

## os.platform()

Возвращает платформу операционной системы.

## os.arch()

Возвращает архитектуру CPU, используемую операционной системой.

## os.release()

Возвращает версию операционной системы.

## os.uptime()

Возвращает время работы системы в секундах с последней перезагрузки.

## os.loadavg()

Возвращает массив, содержащия среднюю загрузку системы за последние 1, 5 и 15 минут.

## os.totalmem()

Возвращает полный объём памяти, доступной системе.

## os.freemem()

Возвращает объём свободной памяти.

## os.cpus()

Возвращает массив объектов, содержащих информацию о каждом процессоре/ядре системы:
модель, частоту в мегагерцах и время в тиках,
проводимое в состояниях user, nice, sys, idle и irq.

Example inspection of os.cpus:

    [ { model: 'Intel(R) Core(TM) i7 CPU         860  @ 2.80GHz',
        speed: 2926,
        times:
         { user: 252020,
           nice: 0,
           sys: 30340,
           idle: 1070356870,
           irq: 0 } },
      { model: 'Intel(R) Core(TM) i7 CPU         860  @ 2.80GHz',
        speed: 2926,
        times:
         { user: 306960,
           nice: 0,
           sys: 26980,
           idle: 1071569080,
           irq: 0 } },
      { model: 'Intel(R) Core(TM) i7 CPU         860  @ 2.80GHz',
        speed: 2926,
        times:
         { user: 248450,
           nice: 0,
           sys: 21750,
           idle: 1070919370,
           irq: 0 } },
      { model: 'Intel(R) Core(TM) i7 CPU         860  @ 2.80GHz',
        speed: 2926,
        times:
         { user: 256880,
           nice: 0,
           sys: 19430,
           idle: 1070905480,
           irq: 20 } },
      { model: 'Intel(R) Core(TM) i7 CPU         860  @ 2.80GHz',
        speed: 2926,
        times:
         { user: 511580,
           nice: 20,
           sys: 40900,
           idle: 1070842510,
           irq: 0 } },
      { model: 'Intel(R) Core(TM) i7 CPU         860  @ 2.80GHz',
        speed: 2926,
        times:
         { user: 291660,
           nice: 0,
           sys: 34360,
           idle: 1070888000,
           irq: 10 } },
      { model: 'Intel(R) Core(TM) i7 CPU         860  @ 2.80GHz',
        speed: 2926,
        times:
         { user: 308260,
           nice: 0,
           sys: 55410,
           idle: 1071129970,
           irq: 880 } },
      { model: 'Intel(R) Core(TM) i7 CPU         860  @ 2.80GHz',
        speed: 2926,
        times:
         { user: 266450,
           nice: 1480,
           sys: 34920,
           idle: 1072572010,
           irq: 30 } } ]

## os.networkInterfaces()

Ворвращает список сетевых интерфейсов:

    { lo0: 
       [ { address: '::1', family: 'IPv6', internal: true },
         { address: 'fe80::1', family: 'IPv6', internal: true },
         { address: '127.0.0.1', family: 'IPv4', internal: true } ],
      en1: 
       [ { address: 'fe80::cabc:c8ff:feef:f996', family: 'IPv6',
           internal: false },
         { address: '10.0.1.123', family: 'IPv4', internal: false } ],
      vmnet1: [ { address: '10.99.99.254', family: 'IPv4', internal: false } ],
      vmnet8: [ { address: '10.88.88.1', family: 'IPv4', internal: false } ],
      ppp0: [ { address: '10.2.0.231', family: 'IPv4', internal: false } ] }
