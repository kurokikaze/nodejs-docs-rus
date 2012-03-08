# Zlib

Что бы получить доступ к этому модулю воспользуйтесь:

    var zlib = require('zlib');

Это привязка к Gzip/Gunzip, Deflate/Inflate, и
DeflateRaw/InflateRaw классам. Каждый класс имеет набор опций,
а также является потоком чтения/записи.

## Примеры

Сжатие или распаковка файлов может быть выполнена путем передачи
потока fs.ReadStream в поток zlib, а затем в fs.WriteStream.

    var gzip = zlib.createGzip();
    var fs = require('fs');
    var inp = fs.createReadStream('input.txt');
    var out = fs.createWriteStream('input.txt.gz');

    inp.pipe(gzip).pipe(out);

Выполнить сжатие или распаковку в один шаг можно с помощью 
методов.

    var input = '.................................';
    zlib.deflate(input, function(err, buffer) {
      if (!err) {
        console.log(buffer.toString('base64'));
      }
    });

    var buffer = new Buffer('eJzT0yMAAGTvBe8=', 'base64');
    zlib.unzip(buffer, function(err, buffer) {
      if (!err) {
        console.log(buffer.toString());
      }
    });

Для испоьзования этого модуля в HTTP клиенте/сервере, воспользуйтесь установкой
заголовков, 
[accept-encoding](http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.3)
для запросов, и
[content-encoding](http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.11)
ответов.

**Примечание: эти примеры очень сильно упрощены для того что бы 
показать основную идею.** Zlib операции могут быть дорогими, результаты
должны сохраняться в кеш.  See [Memory Usage Tuning](#memory_Usage_Tuning)
below for more information on the speed/memory/compression
tradeoffs involved in zlib usage.

    //пример клиентского запроса
    var zlib = require('zlib');
    var http = require('http');
    var fs = require('fs');
    var request = http.get({ host: 'izs.me',
                             path: '/',
                             port: 80,
                             headers: { 'accept-encoding': 'gzip,deflate' } });
    request.on('response', function(response) {
      var output = fs.createWriteStream('izs.me_index.html');

      switch (response.headers['content-encoding']) {
		// или просто используйте zlib.createUnzip(), для 
		// обработки обоих случаев
        case 'gzip':
          response.pipe(zlib.createGunzip()).pipe(output);
          break;
        case 'deflate':
          response.pipe(zlib.createInflate()).pipe(output);
          break;
        default:
          response.pipe(output);
          break;
      }
    });

    // пример сервера
	// Выполнение gzip операций на каждый запрос стоит достаточно дорого.
	// Исспользование кеширования будет очень эффективным.
    var zlib = require('zlib');
    var http = require('http');
    var fs = require('fs');
    http.createServer(function(request, response) {
      var raw = fs.createReadStream('index.html');
      var acceptEncoding = request.headers['accept-encoding'];
      if (!acceptEncoding) {
        acceptEncoding = '';
      }

      // Примечание: это не совместимый accept-encoding парсер.
      // Смотри http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.3
      if (acceptEncoding.match(/\bdeflate\b/)) {
        response.writeHead(200, { 'content-encoding': 'deflate' });
        raw.pipe(zlib.createDeflate()).pipe(response);
      } else if (acceptEncoding.match(/\bgzip\b/)) {
        response.writeHead(200, { 'content-encoding': 'gzip' });
        raw.pipe(zlib.createGzip()).pipe(response);
      } else {
        response.writeHead(200, {});
        raw.pipe(response);
      }
    }).listen(1337);

## Константы

<!--type=misc-->

Все константы определенные в  zlib.h также определены в 
`require('zlib')`. Они подробно описаны в документации Zlib.
Смотри <http://zlib.net/manual.html#Constants> для получения
подробной информации.

## zlib.createGzip([параметры])

Возвращает новый [Gzip](#zlib.Gzip) объект с [параметрами](#options).

## zlib.createGunzip([параметры])

Возвращает новый [Gunzip](#zlib.Gunzip) объект с [параметрами](#options).

## zlib.createDeflate([параметры])

Возвращает новый [Deflate](#zlib.Deflate) объект с [параметрами](#options).

## zlib.createInflate([параметры])

Возвращает новый [Inflate](#zlib.Inflate) объект с [параметрами](#options).

## zlib.createDeflateRaw([параметры])

Возвращает новый [DeflateRaw](#zlib.DeflateRaw) объект с [параметрами](#options).

## zlib.createInflateRaw([параметры])

Возвращает новый [InflateRaw](#zlib.InflateRaw) объект с [параметрами](#options).

## zlib.createUnzip([параметры])

Возвращает новый [Unzip](#zlib.Unzip) объект с [параметрами](#options).


## Класс: zlib.Gzip

Сжатие данных используя gzip.

## Класс: zlib.Gunzip

Расспаковка gzip потока.

## Класс: zlib.Deflate

Сжатие данных используя deflate.

## Класс: zlib.Inflate

Расспаковка deflate потока.

## Класс: zlib.DeflateRaw

Сжатие данных используя deflate, без установки zlib заголовка.

## Класс: zlib.InflateRaw

Расспаковка raw deflate потока.

## Класс: zlib.Unzip

Расспаковка либо Gzip-, либо Deflate-сжатого потока с 
автоматическим определением заголовка.

## Convenience Methods

<!--type=misc-->

All of these take a string or buffer as the first argument, and call the
supplied callback with `callback(error, result)`.  The
compression/decompression engine is created using the default settings
in all convenience methods.  To supply different options, use the
zlib classes directly.

## zlib.deflate(buf, callback)

Compress a string with Deflate.

## zlib.deflateRaw(buf, callback)

Compress a string with DeflateRaw.

## zlib.gzip(buf, callback)

Compress a string with Gzip.

## zlib.gunzip(buf, callback)

Decompress a raw Buffer with Gunzip.

## zlib.inflate(buf, callback)

Decompress a raw Buffer with Inflate.

## zlib.inflateRaw(buf, callback)

Decompress a raw Buffer with InflateRaw.

## zlib.unzip(buf, callback)

Decompress a raw Buffer with Unzip.

## Options

<!--type=misc-->

Each class takes an options object.  All options are optional.  (The
convenience methods use the default settings for all options.)

Note that some options are only
relevant when compressing, and are ignored by the decompression classes.

* chunkSize (default: 16*1024)
* windowBits
* level (compression only)
* memLevel (compression only)
* strategy (compression only)

See the description of `deflateInit2` and `inflateInit2` at
<http://zlib.net/manual.html#Advanced> for more information on these.

## Memory Usage Tuning

<!--type=misc-->

From `zlib/zconf.h`, modified to node's usage:

The memory requirements for deflate are (in bytes):

    (1 << (windowBits+2)) +  (1 << (memLevel+9))

that is: 128K for windowBits=15  +  128K for memLevel = 8
(default values) plus a few kilobytes for small objects.

For example, if you want to reduce
the default memory requirements from 256K to 128K, set the options to:

    { windowBits: 14, memLevel: 7 }

Of course this will generally degrade compression (there's no free lunch).

The memory requirements for inflate are (in bytes)

    1 << windowBits

that is, 32K for windowBits=15 (default value) plus a few kilobytes
for small objects.

This is in addition to a single internal output slab buffer of size
`chunkSize`, which defaults to 16K.

The speed of zlib compression is affected most dramatically by the
`level` setting.  A higher level will result in better compression, but
will take longer to complete.  A lower level will result in less
compression, but will be much faster.

In general, greater memory usage options will mean that node has to make
fewer calls to zlib, since it'll be able to process more data in a
single `write` operation.  So, this is another factor that affects the
speed, at the cost of memory usage.
