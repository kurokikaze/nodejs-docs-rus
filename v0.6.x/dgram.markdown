# UDP / Датаграммы

    Стабильность: 3 - Стабильно


<!-- name=dgram -->

Сокеты для датаграмм доступны при включении `require('dgram')`.

## dgram.createSocket(type, [callback])

* `type` String. Может принимать значения 'udp4' или 'udp6'
* `callback` Function. Функция назвачается обработчиков события `message` сокета. Необязательный параметр
* Возвращает: Объект сокета

Создаёт сокет для датаграмм заданного типа. Доступные типы: `udp4`, `udp6`.

Если вы хотите иметь возможнорсть получать датаграммы, необходимо вызвать `socket.bind`.
Вызов `socket.bind()` без параметров назначит прослушивание всех интерфейсов на случайном порту
(что будет верно работать для `udp4` и `udp6` сокетов). Вы можете узнать назначенный адрес и порт с помощью
`socket.address().address` и `socket.address().port`.

Принимает необязательную функцию, которая добавляется обработчиком событий `message`.

## Класс: Socket

Класс сокета датаграмм инкапсулирует всю функциональность, которая для них доступна.
Должен быть инстанцирован с помощью метода `dgram.createSocket(type, [callback])`.

### Событие: 'message'

* `msg` Объект буффера. Передаваемое сообщение
* `rinfo` Объект. Информация об адресе отправителя

Генерируется когда новая датаграмма доступна на сокете. `msg` это `Buffer`,
а `rinfo` это объект с информацией об адресе отправителя и количестве байт в датаграмме.

### Событие: 'listening'

Генеритуется когда сокет начинает приём датаграмм. Для UDP-сокета это происходит
при создании.

### Событие: 'close'

Генерируется когда сокет закрывается с помощью `close()`.
События `message` на этом сокете больше не будут генерироваться.

### Событие: 'error'

* `exception` Объект ошибки

Генерируется в случае возникновения ошибки.

### dgram.send(buf, offset, length, port, address, [callback])

Для UDP сокета, адрес назначения представляет port and IP-адрес. В качетве
аргумента `address` может быть передана строка, которая может быть разрешена
с помощью DNS. Принимает необязательную функцию, которая будет вызвана после
завершения разрешения DNS имени и когда буфер можно будет использовать заново.
Следует иметь в виду, что DNS запросы требуют времени, по крайне мере
до следующего витка цикла событий. Единственный способ узнать, что отправка
состоялась — использовать callback.

Пример отправки UDP-пакета на произвольный порт `localhost`:

    var dgram = require('dgram');
    var message = new Buffer("Some bytes");
    var client = dgram.createSocket("udp4");
    client.send(message, 0, message.length, 41234, "localhost", function(err, bytes) {
      client.close();
    });

**Примечания насчёт размера UDP сообщения**

Максимальный размер `IPv4/v6` датаграм зависит от занчения полей `MTU` (_Maximum Transmission Unit_)
и `Payload Length`.

- The `Payload Length` field is `16 bits` wide, which means that a normal payload
  cannot be larger than 64K octets including internet header and data
  (65,507 bytes = 65,535 − 8 bytes UDP header − 20 bytes IP header);
  this is generally true for loopback interfaces, but such long datagrams
  are impractical for most hosts and networks.

- The `MTU` is the largest size a given link layer technology can support for datagrams.
  For any link, `IPv4` mandates a minimum `MTU` of `68` octets, while the recommended `MTU`
  for IPv4 is `576` (typically recommended as the `MTU` for dial-up type applications),
  whether they arrive whole or in fragments.

  For `IPv6`, the minimum `MTU` is `1280` octets, however, the mandatory minimum
  fragment reassembly buffer size is `1500` octets.
  The value of `68` octets is very small, since most current link layer technologies have
  a minimum `MTU` of `1500` (like Ethernet).

Note that it's impossible to know in advance the MTU of each link through which
a packet might travel, and that generally sending a datagram greater than
the (receiver) `MTU` won't work (the packet gets silently dropped, without
informing the source that the data did not reach its intended recipient).

### dgram.bind(port, [address])

* `port` Integer
* `address` String, необязательный параметр

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
сокетов этот объект содержит свойства `address` и `port`.

### dgram.setBroadcast(flag)

* `flag` Boolean

Устанавливает или сбрасывает опцию `SO_BROADCAST` сокета. если эта опция установлена,
то UDP пакеты могут оправляться по широковещательному адресу локального интерфейса.

### dgram.setTTL(ttl)

* `ttl` Integer

Устанавливает опуцию `IP_TTL` сокета.  TTL означает "время жизни", и его значение
определяет количество IP, сквозь которые может быть передан пакет. Каждый роутер
или шлюз на пути пакета уменьшают TTL. Как только он станет равным нуля, пакет уничтожится.
Изменение TTL может быть полезно для тестирования сети или широковещательной рассылки.

Аргументом `setTTL()` является число от 1 до 255. По умолчанию на большинстве
систем ипользуется 64.

### dgram.setMulticastTTL(ttl)

* `ttl` Integer

Устанавливает опцию `IP_MULTICAST_TTL` сокета.  TTL означает "время жизни",
и его значение определяет количество IP, сквозь которые может быть передан пакет,
в данном случае при широковещательной рассылке. Каждый роутер или шлюз на пути пакета
уменьшают TTL. Как только он станет равным нуля, пакет уничтожится.

Аргументом `setMulticastTTL()` является число от 0 до 255. По умолчанию на большинстве
систем ипользуется 64.

### dgram.setMulticastLoopback(flag)

* `flag` Boolean

Устанавливает или очищает опцию `IP_MULTICAST_LOOP` сокета. Если эта опция установлена,
то широковещательные пакеты также будут получены на локальных сетевых интерфейсах.

### dgram.addMembership(multicastAddress, [multicastInterface])

* `multicastAddress` String
* `multicastInterface` String, необязательный параметр

Указывает ядру вступить в широковещательную группу используя опцию `IP_ADD_MEMBERSHIP` сокета.

Если `multicastInterface` не указан, то ОС будет пытаться вступить в группу,
используя каждый доступный сетевой интерфейс.

### dgram.dropMembership(multicastAddress, [multicastInterface])

* `multicastAddress` String
* `multicastInterface` String, необязательный параметр

Противоположность `addMembership` &mdash; указывает ядру покинуть широковещательную
группу используя опцию `IP_DROP_MEMBERSHIP` сокета. В большинстве приложений
не обязательно вызывать эту функцию, так как ОС сделает это автоматически
при закрытии сокета.

Если `multicastInterface` не указан, то ОС будет пытаться покинуть группу,
используя каждый доступный сетевой интерфейс.
