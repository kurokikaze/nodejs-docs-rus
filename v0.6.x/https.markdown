## HTTPS

    Стабильность: 3 - Стабильно


HTTPS представляет из себя HTTP протокол с использованием TLS/SSL канала
для передачи данных. Node включает отдельный модуль для HTTP.

## https.Server

Этот класс является потомком `tls.Server` и генерирует те же события, что и `http.Server`.
См. описание `http.Server` для более подробной информации.

## https.createServer(options, [requestListener])

Возвращает новый объект HTTPS веб сервера. Параметры `options` такие же,
как у `tls.createServer()`. Функция `requestListener` будет автоматически
добавлена в качестве обработчика события `'request'`.

Пример:

    // curl -k https://localhost:8000/
    var https = require('https');
    var fs = require('fs');

    var options = {
      key: fs.readFileSync('test/fixtures/keys/agent2-key.pem'),
      cert: fs.readFileSync('test/fixtures/keys/agent2-cert.pem')
    };

    https.createServer(options, function (req, res) {
      res.writeHead(200);
      res.end("hello world\n");
    }).listen(8000);


## https.request(options, callback)

Создаёт запрос к защищённому серверу.
Параметры аналогичны параметрам `http.request()`.

Пример:

    var https = require('https');

    var options = {
      host: 'encrypted.google.com',
      port: 443,
      path: '/',
      method: 'GET'
    };

    var req = https.request(options, function(res) {
      console.log("statusCode: ", res.statusCode);
      console.log("headers: ", res.headers);

      res.on('data', function(d) {
        process.stdout.write(d);
      });
    });
    req.end();

    req.on('error', function(e) {
      console.error(e);
    });

Параметры `options`:

- `host`: Доменное имя или IP адрес для запроса. По умолчанию `'localhost'`.
- `port`: Порт на удалённом сервере. По умолчанию 443.
- `method`: Строка, определяющая HTTP метод. возможные значения:
  `'GET'` (по умолчанию), `'POST'`, `'PUT'` и `'DELETE'`.
- `path`: HTTP-путь, может включать строку запроса при необходимости.
  По умолчанию `'/'`.
- key: Приватный ключ для SSL. По умолчанию `null`.
- cert: Публичный x509 сертификат. По умолчанию `null`.
- ca: Сертификат или список доверенных сертификатов
  для проверки подлинности удалённого хоста.


## https.get(options, callback)

Аналог `http.get()` для HTTPS.

Пример:

    var https = require('https');

    https.get({ host: 'encrypted.google.com', path: '/' }, function(res) {
      console.log("statusCode: ", res.statusCode);
      console.log("headers: ", res.headers);

      res.on('data', function(d) {
        process.stdout.write(d);
      });

    }).on('error', function(e) {
      console.error(e);
    });




