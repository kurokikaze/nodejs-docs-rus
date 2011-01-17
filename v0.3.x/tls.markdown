## TLS (SSL)

Используйте `require('tls')` чтобы получить доступ к функциям этого модуля.

Модуль `tls` использует OpenSSL чтобы предоставить Transport Layer Security и/или
Secure Socket Layer (SSL): зашифрованные соединения.

TLS/SSL это инфраструктура с публичными ключами. Каждый клиент и каждый сервер должны иметь собственный приватный ключ. Приватный ключ создаётся таким образом:

    openssl genrsa -out ryans-key.pem 1024

Все серверы и некоторые клиенты должны иметь сертификат. Сертификаты это публичные ключи подписанные Центром Сертификации или самим создателем сертификата. Первый шаг в получени сертификата: создание файла запроса на подпись сертификата (CSR, Certificate Signing Request). Это делается следующим образом:

    openssl req -new -key ryans-key.pem -out ryans-csr.pem

Чтобы создать самостоятельно подписанный сертификат CSR, сделайте:

    openssl x509 -req -in ryans-csr.pem -signkey ryans-key.pem -out ryans-cert.pem

Либо Вы можете отправить CSR в Центр Сертификации для подписи.

(TODO: docs on creating a CA, for now interested users should just look at
`test/fixtures/keys/Makefile` in the Node source code)


### s = tls.connect(port, [host], [options], callback)

Создаёт новое соединение на выбранный порт и хост (хост по умолчанию - `localhost`). Опции `options` должны быть объектом, содержащим

  - `key`: Строка или буфер содержащие приватный ключ сервера в формате PEM (обязательно)

  - `cert`: Строка или буфер содержащие ключ сертификата сервера в формате PEM.

  - `ca`: Массив строк или буферов с Центрами Сертификации. Если этот массив пропущен, будут использованы "корневые" Центры Сертификации, например VeriSign. Они будут использованы для авторизации соединения.

`tls.connect()` возвращает текстовый объект `CryptoStream`.

После рукопожатия TLS/SSL вызывается переданная функция. Вызов произойдёт независимо от того был ли авторизрван сертификат. Пользователь сам должен проверить значение `s.authorized` чтобы увидеть был ли сертификат подписан одним из указанных центров. Если `s.authorized === false` то в переменной `s.authorizationError` будет содержаться объект соответствующей ошибки.


### tls.Server

This class is a subclass of `net.Server` and has the same methods on it.
Instead of accepting just raw TCP connections, this accepts encrypted
connections using TLS or SSL.

Here is a simple example echo server:

    var tls = require('tls');
    var fs = require('fs');

    var options = {
      key: fs.readFileSync('server-key.pem'),
      cert: fs.readFileSync('server-cert.pem')
    };

    tls.createServer(options, function (s) {
      s.write("welcome!\n");
      s.pipe(s);
    }).listen(8000);


You can test this server by connecting to it with `openssl s_client`:


    openssl s_client -connect 127.0.0.1:8000


#### tls.createServer(options, secureConnectionListener)

This is a constructor for the `tls.Server` class. The options object
has these possibilities:

  - `key`: A string or `Buffer` containing the private key of the server in
    PEM format. (Required)

  - `cert`: A string or `Buffer` containing the certificate key of the server in
    PEM format. (Required)

  - `ca`: An array of strings or `Buffer`s of trusted certificates. If this is
    omitted several well known "root" CAs will be used, like VeriSign.
    These are used to authorize connections.

  - `requestCert`: If `true` the server will request a certificate from
    clients that connect and attempt to verify that certificate. Default:
    `false`.

  - `rejectUnauthorized`: If `true` the server will reject any connection
    which is not authorized with the list of supplied CAs. This option only
    has an effect if `requestCert` is `true`. Default: `false`.


#### Event: 'secureConnection'

`function (cleartextStream) {}`

This event is emitted after a new connection has been successfully
handshaked. The argument is a duplex instance of `stream.Stream`. It has all
the common stream methods and events.

`cleartextStream.authorized` is a boolean value which indicates if the
client has verified by one of the supplied cerificate authorities for the
server. If `cleartextStream.authorized` is false, then
`cleartextStream.authorizationError` is set to describe how authorization
failed. Implied but worth mentioning: depending on the settings of the TLS
server, you unauthorized connections may be accepted.


#### server.listen(port, [host], [callback])

Begin accepting connections on the specified `port` and `host`.  If the
`host` is omitted, the server will accept connections directed to any
IPv4 address (`INADDR_ANY`).

This function is asynchronous. The last parameter `callback` will be called
when the server has been bound.

See `net.Server` for more information.


#### server.close()

Stops the server from accepting new connections. This function is
asynchronous, the server is finally closed when the server emits a `'close'`
event.


#### server.maxConnections

Set this property to reject connections when the server's connection count gets high.

#### server.connections

The number of concurrent connections on the server.
