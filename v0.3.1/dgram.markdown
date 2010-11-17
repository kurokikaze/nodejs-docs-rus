## dgram

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

For UDP sockets, the destination port and IP address must be specified.  A string
may be supplied for the `address` parameter, and it will be resolved with DNS.  An 
optional callback may be specified to detect any DNS errors and when `buf` may be
re-used.  Note that DNS lookups will delay the time that a send takes place, at
least until the next tick.  The only way to know for sure that a send has taken place
is to use the callback.

Example of sending a UDP packet to a random port on `localhost`;

    var dgram = require('dgram');
    var message = new Buffer("Some bytes");
    var client = dgram.createSocket("udp4");
    client.send(message, 0, message.length, 41234, "localhost");
    client.close();


### dgram.bind(path)

For Unix domain datagram sockets, start listening for incoming datagrams on a
socket specified by `path`. Note that clients may `send()` without `bind()`,
but no datagrams will be received without a `bind()`.

Example of a Unix domain datagram server that echoes back all messages it receives:

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

Example of a Unix domain datagram client that talks to this server:

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

For UDP sockets, listen for datagrams on a named `port` and optional `address`.  If
`address` is not specified, the OS will try to listen on all addresses.

Example of a UDP server listening on port 41234:

    var dgram = require("dgram");

    var server = dgram.createSocket("udp4");
    var messageToSend = new Buffer("A message to send");

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

Close the underlying socket and stop listening for data on it.  UDP sockets 
automatically listen for messages, even if they did not call `bind()`.

### dgram.address()

Returns an object containing the address information for a socket.  For UDP sockets, 
this object will contain `address` and `port`.  For Unix domain sockets, it will contain
only `address`.

### dgram.setBroadcast(flag)

Sets or clears the `SO_BROADCAST` socket option.  When this option is set, UDP packets
may be sent to a local interface's broadcast address.

### dgram.setTTL(ttl)

Sets the `IP_TTL` socket option.  TTL stands for "Time to Live," but in this context it
specifies the number of IP hops that a packet is allowed to go through.  Each router or 
gateway that forwards a packet decrements the TTL.  If the TTL is decremented to 0 by a
router, it will not be forwarded.  Changing TTL values is typically done for network 
probes or when multicasting.

The argument to `setTTL()` is a number of hops between 1 and 255.  The default on most
systems is 64.

