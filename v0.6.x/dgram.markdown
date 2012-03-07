## UDP / Датаграммы

Сокеты для датаграмм доступны при включении `require('dgram')`. Датаграммы
чаще всего обрабатываются как сообщения IP/UDP, но они могут быть использованы
и с доменными сокетами Unix.

### Событие: 'message'

`function (msg, rinfo) { }`

Генерируется когда новая датаграмма доступна на сокете. `msg` это `Buffer`,
а `rinfo` это объект с информацией об адресе отправителя и количестве байт в датаграмме.

### Событие: 'listening'

`function () { }`

Генеритуется когда сокет начинает приём датаграмм. Для UDP-сокета это происходит
при создании. Сокеты Unix не начинают приём до вызова для них `bind()`.

### Событие: 'close'

`function () { }`

Генерируется когда сокет закрывается с помощью `close()`.
События `message` на этом сокете больше не будут генерироваться.

### dgram.createSocket(type, [callback])

Создаёт сокет для датаграмм заданного типа. Доступные типы: `udp4`, `udp6` и `unix_dgram`.

Принимает необязательную функцию, которая добавляется обработчиком событий `message`.

### dgram.send(buf, offset, length, path, [callback])

Для датаграмм на Unix-сокетах адрес назначения это путь в файловой системе.
Принимает необязательную функцию, которая будет вызвана после завершения
вызова `sendto` операционной системой. Пока идёт вызов, повторное использование
буфера `buf` небезопасно. Заметьте, что если сокет не привязан к пути в файловой
системе с помощью `bind()`, на нём невозможно получать сообщения.

Пример отправки сообщения демону syslogd в OSX через Unix-сокет `/var/run/syslog`:

    var dgram = require('dgram');
    var message = new Buffer("A message to log.");
    var client = dgram.createSocket("unix_dgram");
    client.send(message, 0, message.length, "/var/run/syslog",
      function (err, bytes) {
        if (err) {
          throw err;
        }
        console.log("Wrote " + bytes + " bytes to socket.");
    });

### dgram.send(buf, offset, length, port, address, [callback])

Для UDP сокета, адрес назначения представляет port and IP-адрес. В качетве
аргумента `address` может быть передана строка, которая может быть разрешена
с помощью DNS. Принимает необязательную функцию, которая будет вызвана после
завершения разрешения DNS имени и когда буфер можно будет использовать заново.
Следует иметь в виду, что DNS запросы требуют времени, по крайне мере
до следующего витка цикола событий. Единственный способ узнать, что отправка
состоялась — использовать callback.

Пример отправки UDP-пакета на произвольный порт `localhost`:

    var dgram = require('dgram');
    var message = new Buffer("Some bytes");
    var client = dgram.createSocket("udp4");
    client.send(message, 0, message.length, 41234, "localhost");
    client.close();


### dgram.bind(path)

Для Unix-сокета задаёт путь `path`. Имейте в виду, что клиент может вызывать
`send()` перед `bind()`, но данные не будут отправлены до вызова `bind()`.

Пример сервера на Unix-сокете, который отправляет обратно поступающие сообщения:

    var dgram = require("dgram");
    var serverPath = "/tmp/dgram_server_sock";
    var server = dgram.createSocket("unix_dgram");

    server.on("message", function (msg, rinfo) {
      console.log("got: " + msg + " from " + rinfo.address);
      server.send(msg, 0, msg.length, rinfo.address);
    });

    server.on("listening", function () {
      console.log("server listening " + server.address().address);
    })

    server.bind(serverPath);

Пример клиента на Unix-сокете, обращающегося к серверу:

    var dgram = require("dgram");
    var serverPath = "/tmp/dgram_server_sock";
    var clientPath = "/tmp/dgram_client_sock";

    var message = new Buffer("A message at " + (new Date()));

    var client = dgram.createSocket("unix_dgram");

    client.on("message", function (msg, rinfo) {
      console.log("got: " + msg + " from " + rinfo.address);
    });

    client.on("listening", function () {
      console.log("client listening " + client.address().address);
      client.send(message, 0, message.length, serverPath);
    });

    client.bind(clientPath);

### dgram.bind(port, [address])

Для UDP сокетов задаёт порт `port` и необязательный адрес `address`
для прослушивания. Если `address` не задан, то будет предпринята попытка
прослушивания всех адресов.

Пример UDP-сервера, слушающего на 41234 порту:

    var dgram = require("dgram");

    var server = dgram.createSocket("udp4");

    server.on("message", function (msg, rinfo) {
      console.log("server got: " + msg + " from " +
        rinfo.address + ":" + rinfo.port);
    });

    server.on("listening", function () {
      var address = server.address();
      console.log("server listening " +
          address.address + ":" + address.port);
    });

    server.bind(41234);
    // server listening 0.0.0.0:41234


### dgram.close()

Закрывает сокет и прекращает приём данных.

### dgram.address()

Возвращает объект с информацией об адресе, на который настроен сокет. Для UDP
сокетов этот объект содержит свойства `address` и `port`, а для Unix-сокетов
только свойство `address`.

### dgram.setBroadcast(flag)

Устанавливает или сбрасывает опцию `SO_BROADCAST` сокета. если эта опция установлена,
то UDP пакеты могут оправляться по широковещательному адресу локального интерфейса.

### dgram.setTTL(ttl)

Устанавливает опуцию `IP_TTL` сокета.  TTL означает "время жизни", и его значение
определяет количество IP, сквозь которые может быть передан пакет. Каждый роутер
или шлюз на пути пакета уменьшают TTL. Как только он станет равным нуля, пакет уничтожится.
Изменение TTL может быть полезно для тестирования сети или широковещательной рассылки.

Аргументом `setTTL()` является число от 1 до 255. По умолчанию на большинстве
систем ипользуется 64.

### dgram.setMulticastTTL(ttl)

Устанавливает опцию `IP_MULTICAST_TTL` сокета.  TTL означает "время жизни",
и его значение определяет количество IP, сквозь которые может быть передан пакет,
в данном случае при широковещательной рассылке. Каждый роутер или шлюз на пути пакета
уменьшают TTL. Как только он станет равным нуля, пакет уничтожится.

Аргументом `setMulticastTTL()` является число от 0 до 255. По умолчанию на большинстве
систем ипользуется 64.

### dgram.setMulticastLoopback(flag)

Устанавливает или очищает опцию `IP_MULTICAST_LOOP` сокета. Если эта опция установлена,
то широковещательные пакеты также будут получены на локальных сетевых интерфейсах.

### dgram.addMembership(multicastAddress, [multicastInterface])

Указывает ядру вступить в широковещательную группу используя опцию `IP_ADD_MEMBERSHIP` сокета.

Если `multicastInterface` не указан, то ОС будет пытаться вступить в группу,
используя каждый доступный сетевой интерфейс.

### dgram.dropMembership(multicastAddress, [multicastInterface])

Противоположность `addMembership` &mdash; указывает ядру покинуть широковещательную
группу используя опцию `IP_DROP_MEMBERSHIP` сокета. В большинстве приложений
не обязательно вызывать эту функцию, так как ОС сделает это автоматически
при закрытии сокета.

Если `multicastInterface` не указан, то ОС будет пытаться покинуть группу,
используя каждый доступный сетевой интерфейс.

