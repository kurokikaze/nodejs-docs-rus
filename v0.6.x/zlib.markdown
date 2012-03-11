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
удобных методов.

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
для ответов.

**Примечание: эти примеры очень сильно упрощены для того что бы 
показать основную идею.** Zlib операции могут быть дорогими, результаты
должны сохраняться в кеш.  Смотри [настройки использования памяти](#memory_Usage_Tuning)
ниже для получения информации о скорости/памяти/компресии влияющие на использование zlib.

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
	// использование кеширования может быть очень эффективным.
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

## Удобные методы

<!--type=misc-->

Все удобные методы в качестве первого аргумента принимают строки или буферы,
и возвращают результат вызывая функцию обратного вызова 
с параметрами `callback(error, result)`. Движки компрессии/декомпрессии создаются
с настройками по умолчанию. Для использования различных настроек пользуйтесь
Zlib классами напрямую.

## zlib.deflate(buf, callback)

Сжатие строки используя Deflate.

## zlib.deflateRaw(buf, callback)

Сжатие строки используя DeflateRaw.

## zlib.gzip(buf, callback)

Сжатие строки используя Gzip.

## zlib.gunzip(buf, callback)

Распаковка raw Buffer используя Gunzip.

## zlib.inflate(buf, callback)

Распаковка raw Buffer используя Inflate.

## zlib.inflateRaw(buf, callback)

Распаковка raw Buffer используя InflateRaw.

## zlib.unzip(buf, callback)

Распаковка raw Buffer используя Unzip.

## Опции

<!--type=misc-->

Каждый класс может принимать объект с параметрами. Все параметры являются 
опциональными. (Удобные методы использую настройки по умолчанию для всех опций).

Обратите внимание что часть опций доступна только для сжатия, и игнорируются
классами распаковщиками.

* chunkSize (default: 16*1024)
* windowBits
* level (compression only)
* memLevel (compression only)
* strategy (compression only)

Смотри описание о `deflateInit2` и `inflateInit2` на
<http://zlib.net/manual.html#Advanced> для большей информации о них.

## Настройки использования памяти

<!--type=misc-->

Файл `zlib/zconf.h`, изменен для использования nodejs:

Требования к памяти для deflate (в байтах):

    (1 << (windowBits+2)) +  (1 << (memLevel+9))

это: 128K для windowBits=15  +  128K для memLevel = 8
(по умолчанию) плюс несколько килобайт для небольших объектов.

Например, если вы хотите уменьшить требования к памяти по умолчанию
с 256K до 128K, установите параметры:

    { windowBits: 14, memLevel: 7 }

Конечно это как правило ухудшает сжатие (there's no free lunch).

Требования памяти при inflate (в байтах)

    1 << windowBits

это, 32K для windowBits=15 (по умолчанию) плюс несколько килобайт
для небольших объектов.

Это в дополнение к одиночной части исходящего буффера размером `chunkSize`,
который по умолчанию 16К.

На скорость сжатия Zlib существенно влияет настройки `уровня сжатия`. 
Высокий уровень дает лучшее сжатие, но занимает больше времени. Низкий
уровень дает меньше сжатие, но может быть намного быстрее.

В общем, варианты настроек с большим расходом памяти означают, что node 
может делать меньше вызовов zlib, и значит сможет обработать больше данных
за одину операцию `записи`. Так что, это еще один фактор влияющим на
скорость, за счет увеличения использования памяти.