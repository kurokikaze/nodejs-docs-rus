# Краткий обзор

<!--type=misc-->

Пример [web сервера](http.html), написанного с помощью Node
и отвечающего строкой 'Hello World':

    var http = require('http');

    http.createServer(function (request, response) {
      response.writeHead(200, {'Content-Type': 'text/plain'});
      response.end('Hello World\n');
    }).listen(8124);

    console.log('Server running at http://127.0.0.1:8124/');

Чтобы запустить сервер, поместите код в файл с названием `example.js`
и выполните его программой `node`:

    > node example.js
    Server running at http://127.0.0.1:8124/

Все примеры в этом руководстве можно запустить таким же образом.

