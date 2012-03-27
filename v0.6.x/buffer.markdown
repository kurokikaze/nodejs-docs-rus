# Буфер

    Стабильность: 3 - Стабильно

Чистый JavaScript поддерживает Unicode, но в нём нет средств для работы
с двоичными данными. При работе с TCP или файловой системой часто необходимо
работать именно с потоками двоичных данных. В Node предусмотрено несколько
средств управления, создания и приёма двоичных потоков.

Бинарные данные хранятся в экземплярах класса Buffer. Buffer похож на массив
целых чисел, но ему соответствует область памяти, выделенная вне стандартной
кучи V8. Размер Buffer невозможно изменить после создания. 

Объект `Buffer` существует в глобальном пространстве имён,
но при необходимости его можно получить с помощью `require('buffer')`.

При преобразовании между буферами и строками JavaScript требуется явно
указывать метод кодирования символов. Node поддерживает 3 кодировки для строк:

* `'ascii'` — только для 7-битных ASCII-строк. Этот метод кодирования очень
  быстрый, и будет сбрасывать старший бит символа, если тот установлен.
  Нужно помнить, что при использовании этой кодировки нулевые символы (`'\0'` или `'\u0000'`)
  преобразуются в `0x20` (символ пробела). Если вам нужно сохранить нулевые символы как `0x00`,
  то вам нужно использовать кодировку `'utf8'`.

* `'utf8'` — Многобайтовые Unicode-символы. Многие веб-страницы и документы используют UTF-8.

+ `'ucs2'` — Двухбайтовые little endian Unicode-символы.
  Могут кодировать только символы в диапазоне U+0000 - U+FFFF (Basic Multilingual Plane).

* `'binary'` — устаревший способ. Хранит двоичные данные в строке используя
  младшие 8 бит каждого символа. Не используйте эту кодировку.


## Класс: Buffer

Класс Buffer является клобальным классом для работы с бинарными данными напрямую.
Его можно инстанцировать несколькими способами.

### new Buffer(size)

* `size` Number

Создаёт новый буфер размера `size` байт.

### new Buffer(array)

* `array` Array

Создаёт новый буфер из массива `array` 8-битных символов.

### new Buffer(str, [encoding])

* `str` String - строка для записи в буфер.
* `encoding` String, необязательный параметр, по умолчанию: 'utf8'

Создаёт новый буфер, содержащий строку `str` в кодировке `encoding`.

### buf.write(string, [offset], [length], [encoding])

* `string` String - данные для записи в буфер
* `offset` Number, необязательный параметр, по умолчанию: 0
* `length` Number, необязательный параметр
* `encoding` String, необязательный параметр, по умолчанию: 'utf8'

Записывает строку `string` в буфер по смещению `offset` от его начала
с использованием указанной кодировки. Возвращает количество записанных байт.
Если `buffer` не имеет достаточно места для сохранения всей строки,
то метод запишет только её часть. Этот метод не будет записывать частичные символы.

Пример: записать UTF-8 строку в буфер, потом напечатать его.

    buf = new Buffer(256);
    len = buf.write('\u00bd + \u00bc = \u00be', 0);
    console.log(len + " bytes: " + buf.toString('utf8', 0, len));

Количество записанных символов (которое может отличаться от количества записанных байт)
устанавливается в `Buffer._charsWritten`
и может быть изменено при следующем вызове `buf.write()`.

### buf.toString([encoding], [start], [end])

* `encoding` String, необязательный параметр, по умолчанию: 'utf8'
* `start` Number, необязательный параметр, по умолчанию: 0
* `end` Number, необязательный параметр

Декодирует и возвращает строку из данных буфера, закодированных в кодировке
`encoding` начиная с позиции `start` и заканчивая позицией `end`.

См. пример `buffer.write()` выше.


### buf[index]

<!--type=property-->
<!--name=[index]-->

Получает или устанавливает байт на позиции `index`. Значения соответствуют индивидуальным
байтам и могут лежать в пределах от `0x00` до `0xFF` в шестнадцатиричной записи
и от `0` до `255` в десятичной. 

Пример: скопировать ASCII строку в буфер, байт за байтом.

    str = "node.js";
    buf = new Buffer(str.length);

    for (var i = 0; i < str.length ; i++) {
      buf[i] = str.charCodeAt(i);
    }

    console.log(buf);

    // node.js


### Метод класса: Buffer.isBuffer(obj)

* `obj` Object
* Возвращает: Boolean

Проверяет, является ли `obj` буфером.


### Class Method: Buffer.byteLength(string, [encoding])

* `string` String
* `encoding` String, необязательный параметр, по умолчанию: 'utf8'
* Возвращает: Number

Возвращает количество байт в строке. Это не то же самое что `String.prototype.length`,
так как этот метод возвращает число *символов* в строке.

Пример:

    str = '\u00bd + \u00bc = \u00be';

    console.log(str + ": " + str.length + " characters, " +
      Buffer.byteLength(str, 'utf8') + " bytes");

    // ½ + ¼ = ¾: 9 characters, 12 bytes


### buf.length

* Number

Размер буфера в байтах. Заметьте, что это значение не всегда соответствует размеру
содержимого. `length` возвращает объем памяти, зарезервированный для объекта буфера.
Это значение не изменяется при изменении содержимого буфера.

    buf = new Buffer(1234);

    console.log(buf.length);
    buf.write("some string", "ascii", 0);
    console.log(buf.length);

    // 1234
    // 1234


### buf.copy(targetBuffer, [targetStart], [sourceStart], [sourceEnd])

* `targetBuffer` объект класса Buffer - целевой буффер для копирования
* `targetStart` Number, необязательный параметр, по умолчанию: 0
* `sourceStart` Number, необязательный параметр, по умолчанию: 0
* `sourceEnd` Number, необязательный параметр, по умолчанию: 0

Копирует данные между буферами. Области `target` и `source` могут пересекаться.

Пример: создадим два буфера, потом скопировать `buf1`
с байта 16 по байт 19 в `buf2`, начиная с 8-го байта в `buf2`.

    buf1 = new Buffer(26);
    buf2 = new Buffer(26);

    for (var i = 0 ; i < 26 ; i++) {
      buf1[i] = i + 97; // 97 is ASCII a
      buf2[i] = 33; // ASCII !
    }

    buf1.copy(buf2, 8, 16, 20);
    console.log(buf2.toString('ascii', 0, 25));

    // !!!!!!!!qrst!!!!!!!!!!!!!

### buffer.slice([start], [end])

* `start` Number, необязательный параметр, по умолчанию: 0
* `end` Number, необязательный параметр, по умолчанию: 0

Возвращает новый буфер, указывающий на ту же область памяти что предыдущий,
но начиная со `start` и заканчивая `end` байтами.

**Изменение содержимого нового буфера затронет содержимое старого!**

Пример: построить буфер с ASCII-алфавитом, вырезать часть в новый буфер, затем
изменить 1 часть в оригинальном буфере.

    var buf1 = new Buffer(26);

    for (var i = 0 ; i < 26 ; i++) {
      buf1[i] = i + 97; // 97 is ASCII a
    }

    var buf2 = buf1.slice(0, 3);
    console.log(buf2.toString('ascii', 0, buf2.length));
    buf1[0] = 33;
    console.log(buf2.toString('ascii', 0, buf2.length));

    // abc
    // !bc

### buf.readUInt8(offset, [noAssert])

* `offset` Number
* `noAssert` Boolean, Optional, Default: false
* Return: Number

Reads an unsigned 8 bit integer from the buffer at the specified offset.

Set `noAssert` to true to skip validation of `offset`. This means that `offset`
may be beyond the end of the buffer. Defaults to `false`.

Example:

    var buf = new Buffer(4);

    buf[0] = 0x3;
    buf[1] = 0x4;
    buf[2] = 0x23;
    buf[3] = 0x42;

    for (ii = 0; ii < buf.length; ii++) {
      console.log(buf.readUInt8(ii));
    }

    // 0x3
    // 0x4
    // 0x23
    // 0x42

### buf.readUInt16LE(offset, [noAssert])
### buf.readUInt16BE(offset, [noAssert])

* `offset` Number
* `noAssert` Boolean, Optional, Default: false
* Return: Number

Reads an unsigned 16 bit integer from the buffer at the specified offset with
specified endian format.

Set `noAssert` to true to skip validation of `offset`. This means that `offset`
may be beyond the end of the buffer. Defaults to `false`.

Example:

    var buf = new Buffer(4);

    buf[0] = 0x3;
    buf[1] = 0x4;
    buf[2] = 0x23;
    buf[3] = 0x42;

    console.log(buf.readUInt16BE(0));
    console.log(buf.readUInt16LE(0));
    console.log(buf.readUInt16BE(1));
    console.log(buf.readUInt16LE(1));
    console.log(buf.readUInt16BE(2));
    console.log(buf.readUInt16LE(2));

    // 0x0304
    // 0x0403
    // 0x0423
    // 0x2304
    // 0x2342
    // 0x4223

### buf.readUInt32LE(offset, [noAssert])
### buf.readUInt32BE(offset, [noAssert])

* `offset` Number
* `noAssert` Boolean, Optional, Default: false
* Return: Number

Reads an unsigned 32 bit integer from the buffer at the specified offset with
specified endian format.

Set `noAssert` to true to skip validation of `offset`. This means that `offset`
may be beyond the end of the buffer. Defaults to `false`.

Example:

    var buf = new Buffer(4);

    buf[0] = 0x3;
    buf[1] = 0x4;
    buf[2] = 0x23;
    buf[3] = 0x42;

    console.log(buf.readUInt32BE(0));
    console.log(buf.readUInt32LE(0));

    // 0x03042342
    // 0x42230403

### buf.readInt8(offset, [noAssert])

* `offset` Number
* `noAssert` Boolean, Optional, Default: false
* Return: Number

Reads a signed 8 bit integer from the buffer at the specified offset.

Set `noAssert` to true to skip validation of `offset`. This means that `offset`
may be beyond the end of the buffer. Defaults to `false`.

Works as `buffer.readUInt8`, except buffer contents are treated as two's
complement signed values.

### buf.readInt16LE(offset, [noAssert])
### buf.readInt16BE(offset, [noAssert])

* `offset` Number
* `noAssert` Boolean, Optional, Default: false
* Return: Number

Reads a signed 16 bit integer from the buffer at the specified offset with
specified endian format.

Set `noAssert` to true to skip validation of `offset`. This means that `offset`
may be beyond the end of the buffer. Defaults to `false`.

Works as `buffer.readUInt16*`, except buffer contents are treated as two's
complement signed values.

### buf.readInt32LE(offset, [noAssert])
### buf.readInt32BE(offset, [noAssert])

* `offset` Number
* `noAssert` Boolean, Optional, Default: false
* Return: Number

Reads a signed 32 bit integer from the buffer at the specified offset with
specified endian format.

Set `noAssert` to true to skip validation of `offset`. This means that `offset`
may be beyond the end of the buffer. Defaults to `false`.

Works as `buffer.readUInt32*`, except buffer contents are treated as two's
complement signed values.

### buf.readFloatLE(offset, [noAssert])
### buf.readFloatBE(offset, [noAssert])

* `offset` Number
* `noAssert` Boolean, Optional, Default: false
* Return: Number

Reads a 32 bit float from the buffer at the specified offset with specified
endian format.

Set `noAssert` to true to skip validation of `offset`. This means that `offset`
may be beyond the end of the buffer. Defaults to `false`.

Example:

    var buf = new Buffer(4);

    buf[0] = 0x00;
    buf[1] = 0x00;
    buf[2] = 0x80;
    buf[3] = 0x3f;

    console.log(buf.readFloatLE(0));

    // 0x01

### buf.readDoubleLE(offset, [noAssert])
### buf.readDoubleBE(offset, [noAssert])

* `offset` Number
* `noAssert` Boolean, Optional, Default: false
* Return: Number

Reads a 64 bit double from the buffer at the specified offset with specified
endian format.

Set `noAssert` to true to skip validation of `offset`. This means that `offset`
may be beyond the end of the buffer. Defaults to `false`.

Example:

    var buf = new Buffer(8);

    buf[0] = 0x55;
    buf[1] = 0x55;
    buf[2] = 0x55;
    buf[3] = 0x55;
    buf[4] = 0x55;
    buf[5] = 0x55;
    buf[6] = 0xd5;
    buf[7] = 0x3f;

    console.log(buf.readDoubleLE(0));

    // 0.3333333333333333

### buf.writeUInt8(value, offset, [noAssert])

* `value` Number
* `offset` Number
* `noAssert` Boolean, Optional, Default: false

Writes `value` to the buffer at the specified offset. Note, `value` must be a
valid unsigned 8 bit integer.

Set `noAssert` to true to skip validation of `value` and `offset`. This means
that `value` may be too large for the specific function and `offset` may be
beyond the end of the buffer leading to the values being silently dropped. This
should not be used unless you are certain of correctness. Defaults to `false`.

Example:

    var buf = new Buffer(4);
    buf.writeUInt8(0x3, 0);
    buf.writeUInt8(0x4, 1);
    buf.writeUInt8(0x23, 2);
    buf.writeUInt8(0x42, 3);

    console.log(buf);

    // <Buffer 03 04 23 42>

### buf.writeUInt16LE(value, offset, [noAssert])
### buf.writeUInt16BE(value, offset, [noAssert])

* `value` Number
* `offset` Number
* `noAssert` Boolean, Optional, Default: false

Writes `value` to the buffer at the specified offset with specified endian
format. Note, `value` must be a valid unsigned 16 bit integer.

Set `noAssert` to true to skip validation of `value` and `offset`. This means
that `value` may be too large for the specific function and `offset` may be
beyond the end of the buffer leading to the values being silently dropped. This
should not be used unless you are certain of correctness. Defaults to `false`.

Example:

    var buf = new Buffer(4);
    buf.writeUInt16BE(0xdead, 0);
    buf.writeUInt16BE(0xbeef, 2);

    console.log(buf);

    buf.writeUInt16LE(0xdead, 0);
    buf.writeUInt16LE(0xbeef, 2);

    console.log(buf);

    // <Buffer de ad be ef>
    // <Buffer ad de ef be>

### buf.writeUInt32LE(value, offset, [noAssert])
### buf.writeUInt32BE(value, offset, [noAssert])

* `value` Number
* `offset` Number
* `noAssert` Boolean, Optional, Default: false

Writes `value` to the buffer at the specified offset with specified endian
format. Note, `value` must be a valid unsigned 32 bit integer.

Set `noAssert` to true to skip validation of `value` and `offset`. This means
that `value` may be too large for the specific function and `offset` may be
beyond the end of the buffer leading to the values being silently dropped. This
should not be used unless you are certain of correctness. Defaults to `false`.

Example:

    var buf = new Buffer(4);
    buf.writeUInt32BE(0xfeedface, 0);

    console.log(buf);

    buf.writeUInt32LE(0xfeedface, 0);

    console.log(buf);

    // <Buffer fe ed fa ce>
    // <Buffer ce fa ed fe>

### buf.writeInt8(value, offset, [noAssert])

* `value` Number
* `offset` Number
* `noAssert` Boolean, Optional, Default: false

Writes `value` to the buffer at the specified offset. Note, `value` must be a
valid signed 8 bit integer.

Set `noAssert` to true to skip validation of `value` and `offset`. This means
that `value` may be too large for the specific function and `offset` may be
beyond the end of the buffer leading to the values being silently dropped. This
should not be used unless you are certain of correctness. Defaults to `false`.

Works as `buffer.writeUInt8`, except value is written out as a two's complement
signed integer into `buffer`.

### buf.writeInt16LE(value, offset, [noAssert])
### buf.writeInt16BE(value, offset, [noAssert])

* `value` Number
* `offset` Number
* `noAssert` Boolean, Optional, Default: false

Writes `value` to the buffer at the specified offset with specified endian
format. Note, `value` must be a valid signed 16 bit integer.

Set `noAssert` to true to skip validation of `value` and `offset`. This means
that `value` may be too large for the specific function and `offset` may be
beyond the end of the buffer leading to the values being silently dropped. This
should not be used unless you are certain of correctness. Defaults to `false`.

Works as `buffer.writeUInt16*`, except value is written out as a two's
complement signed integer into `buffer`.

### buf.writeInt32LE(value, offset, [noAssert])
### buf.writeInt32BE(value, offset, [noAssert])

* `value` Number
* `offset` Number
* `noAssert` Boolean, Optional, Default: false

Writes `value` to the buffer at the specified offset with specified endian
format. Note, `value` must be a valid signed 32 bit integer.

Set `noAssert` to true to skip validation of `value` and `offset`. This means
that `value` may be too large for the specific function and `offset` may be
beyond the end of the buffer leading to the values being silently dropped. This
should not be used unless you are certain of correctness. Defaults to `false`.

Works as `buffer.writeUInt32*`, except value is written out as a two's
complement signed integer into `buffer`.

### buf.writeFloatLE(value, offset, [noAssert])
### buf.writeFloatBE(value, offset, [noAssert])

* `value` Number
* `offset` Number
* `noAssert` Boolean, Optional, Default: false

Writes `value` to the buffer at the specified offset with specified endian
format. Note, `value` must be a valid 32 bit float.

Set `noAssert` to true to skip validation of `value` and `offset`. This means
that `value` may be too large for the specific function and `offset` may be
beyond the end of the buffer leading to the values being silently dropped. This
should not be used unless you are certain of correctness. Defaults to `false`.

Example:

    var buf = new Buffer(4);
    buf.writeFloatBE(0xcafebabe, 0);

    console.log(buf);

    buf.writeFloatLE(0xcafebabe, 0);

    console.log(buf);

    // <Buffer 4f 4a fe bb>
    // <Buffer bb fe 4a 4f>

### buf.writeDoubleLE(value, offset, [noAssert])
### buf.writeDoubleBE(value, offset, [noAssert])

* `value` Number
* `offset` Number
* `noAssert` Boolean, Optional, Default: false

Writes `value` to the buffer at the specified offset with specified endian
format. Note, `value` must be a valid 64 bit double.

Set `noAssert` to true to skip validation of `value` and `offset`. This means
that `value` may be too large for the specific function and `offset` may be
beyond the end of the buffer leading to the values being silently dropped. This
should not be used unless you are certain of correctness. Defaults to `false`.

Example:

    var buf = new Buffer(8);
    buf.writeDoubleBE(0xdeadbeefcafebabe, 0);

    console.log(buf);

    buf.writeDoubleLE(0xdeadbeefcafebabe, 0);

    console.log(buf);

    // <Buffer 43 eb d5 b7 dd f9 5f d7>
    // <Buffer d7 5f f9 dd b7 d5 eb 43>

### buf.fill(value, [offset], [end])

* `value`
* `offset` Number, Optional
* `end` Number, Optional

Fills the buffer with the specified value. If the `offset` (defaults to `0`)
and `end` (defaults to `buffer.length`) are not given it will fill the entire
buffer.

    var b = new Buffer(50);
    b.fill("h");

## buffer.INSPECT_MAX_BYTES

* Number, Default: 50

How many bytes will be returned when `buffer.inspect()` is called. This can
be overridden by user modules.

Note that this is a property on the buffer module returned by
`require('buffer')`, not on the Buffer global, or a buffer instance.

## Class: SlowBuffer

This class is primarily for internal use.  JavaScript programs should
use Buffer instead of using SlowBuffer.

In order to avoid the overhead of allocating many C++ Buffer objects for
small blocks of memory in the lifetime of a server, Node allocates memory
in 8Kb (8192 byte) chunks.  If a buffer is smaller than this size, then it
will be backed by a parent SlowBuffer object.  If it is larger than this,
then Node will allocate a SlowBuffer slab for it directly.
