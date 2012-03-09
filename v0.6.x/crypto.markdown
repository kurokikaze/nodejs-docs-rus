# Модуль криптографии

Используйте `require('crypto')` чтобы получить доступ к функциям модуля.

Криптографический модуль требует для своей работы наличия OpenSSL.
Он предоставляет возможность использовать аутентификацию в HTTPS и HTTP-соединениях.

Модуль также предоставляет набор обёрток для некоторых методов OpenSSL:
hash, hmac, cipher, decipher, sign и verify.

## crypto.createCredentials(details)

Создаёт объект данных аутентификации, может принимать параметром объект со следующими свойствами:

* `key` : строка с PEM-закодированным приватным ключом,
* `cert` : строка с PEM-закодированным сертификатом,
* `ca` : строка или список строк PEM-закодированных доверенных корневых сертификатов.
* `ciphers`: строка, описывающая какие способы шифрования стоит использовать или исключить.
  Описание формата строки вы можете найти по адресу
  <http://www.openssl.org/docs/apps/ciphers.html#CIPHER_LIST_FORMAT>.

Если корневые сертификаты не указаны, node.js будет использовать список доверенных сертификатов,
расположенный по адресу <http://mxr.mozilla.org/mozilla/source/security/nss/lib/ckfw/builtins/certdata.txt>.


## crypto.createHash(algorithm)

Создает и возвращает объект `hash`, который может быть использован
для создания криптографических хэшей по заданному алгоритму.

Возможные значения для `algorithm` зависят от доступных алгоритмах в той версии OpenSSL,
которая у вас установлена. Например, это может быть `'sha1'`, `'md5'` и т.д.
В последней версии OpenSSL список поддерживаемых алгоритмов можно было узнать
с помощью команды `openssl list-message-digest-algorithms`.

Пример: программа, рассчитывающая sha1 хеш-сумму содержимого файла.

    var filename = process.argv[2];
    var crypto = require('crypto');
    var fs = require('fs');

    var shasum = crypto.createHash('sha1');

    var s = fs.ReadStream(filename);
    s.on('data', function(d) {
      shasum.update(d);
    });

    s.on('end', function() {
      var d = shasum.digest('hex');
      console.log(d + '  ' + filename);
    });

## Класс: Hash

Класс для создания криптографических хэшей изс данных.

Инстанцируется с помощью метода `crypto.createHash`.

### hash.update(data, [input_encoding])

Обновляет содержимое на `data`, переданное в кодировке, указанной с помощью параметра
`input_encoding`, который может принимать значения `'utf8'`, `'ascii'` или `'binary'`
(по умолчанию `'binary'`). Этот метод может быть вызван несколько раз.

### hash.digest([encoding])

Вычисляет хеш от всех поступивших данных.
Параметр `encoding` может равняться `'hex'`, `'binary'` или `'base64'` (по умолчанию `'binary'`).

Замечание: объект `hash` нельзя использовать после того, как будет вызван метод `digest()`.


## crypto.createHmac(algorithm, key)

Создает и возвращает объект `hmac`, который может быть использован
для создания хеш-кода идентификации сообщений (HMAC) по заданному алгоритму и ключу.

Возможные значения для `algorithm` зависят от доступных алгоритмах в OpenSSL,
см. описание для `crypto.createHash()` выше. `key` определяет используемый ключ.

## Класс: Hmac

Класс для создания хеш-кода идентификации сообщений (HMAC).

Инстанцируется с помощью метода `crypto.createHmac`.

### hmac.update(data)

Обновляет содержимое на `data`. Этот метод может быть вызван несколько раз.

### hmac.digest([encoding])

Вычисляет хеш от всех поступивших данных.
Параметр encoding может равняться `'hex'`, `'binary'` или `'base64'` (по умолчанию `'binary'`).

Замечание: объект `hmac` нельзя использовать после того, как будет вызван метод `digest()`.


## crypto.createCipher(algorithm, password)

Создает и возвращает объект `cipher`, который может быть использован
для шифрования по заданному алгоритму и паролю.

Возможные значения для `algorithm` зависят от доступных алгоритмах в той версии OpenSSL,
которая у вас установлена. Например, это может быть `'aes192'`, `'blowfish'` и т.д.
В последней версии OpenSSL список поддерживаемых алгоритмов можно было узнать
с помощью команды `openssl list-cipher-algorithms`.

`password` используется для получения информации о ключе и IV, и должен быть строкой,
закодированной с использованием кодировки `'binary'` (см. раздел про [буферы](buffer.html)).


## crypto.createCipheriv(algorithm, key, iv)

Создает и возвращает объект `cipher`, который может быть использован
для шифрования по заданному алгоритму, ключу и IV.

`algorithm` может иметь такие же значения, что и для метода `createCipher()`. `key` является ключём,
используемым в этом алгоритме. `iv` задаёт вектор инициализации. `key` и `iv` должны быть строками,
закодированными с использованием кодировки `'binary'` (см. раздел про [буферы](buffer.html)).


## Класс: Cipher
 
Класс для шифрования данных.
 
Инстанцируется с помощью методов `crypto.createCipher` и `crypto.createCipheriv`.

### cipher.update(data, [input_encoding], [output_encoding])

Обновляет содержимое на `data`, кодировку которых задаёт аргумент `input_encoding`
(может равняться `'utf8'`, `'ascii'` или `'binary'`, по умолчанию `'binary'`). Аргумент `output_encoding`
определяет выходной формат и может равняться `'binary'`, `'base64'` или `'hex'` (по умолчанию `'binary'`).

Возвращает зашифрованного содержимого и может быть названо много раз с новыми данными.

### cipher.final([output_encoding])

Возвращает все оставшиеся зашифрованного содержимого в кодировке `output_encoding`,
которая может равняться `'binary'`, `'ascii'` или `'utf8'` (по умолчанию `'binary'`).

Замечание: объект `cipher` не может быть использован после вызова метода `final()`.


## crypto.createDecipher(algorithm, password)

Создает и возвращает объект `decipher`, который может быть использован
для дешифрования по заданному алгоритму и паролю.
Это метод-близнец для [createCipher()](#crypto.createCipher)`, описанному выше.

## crypto.createDecipheriv(algorithm, key, iv)

Создает и возвращает объект `decipher`, который может быть использован
для дешифрования по заданному алгоритму, ключу и IV.
Это метод-близнец для [createCipheriv()](#crypto.createCipheriv), описанному выше.


## Класс: Decipher

Класс для дешифрования данных.
 
Инстанцируется с помощью методов `crypto.createDecipher` и `crypto.createDecipheriv`.

### decipher.update(data, [input_encoding], [output_encoding])

Обновляет содержимое на `data`, формат которых задаёт аргумент `input_encoding`
(может равняться `'binary'`, `'base64'` или `'hex'`, по умолчанию `'binary'`). Аргумент `output_encoding`
определяет выходную кодировку и может равняться `'utf8'`, `'ascii'` или `'binary'` (по умолчанию `'binary'`).

### decipher.final([output_encoding])

Возвращает все оставшиеся разшифрованного содержимого в виде простого текста.
Значение аргументо output_encoding объяснено выше.

Замечание: объект `decipher` не может быть использован после вызова метода `final()`.


## crypto.createSign(algorithm)

Создает и возвращает объект `signer`, который может быть использован
для создания электронной подписи по заданному алгоритму.


## Класс: Signer

Класс для создания цифровых подписей.

Инстанцируется с помощью метода `crypto.createSign`.

### signer.update(data)

Обновляет содержимое на `data`. Этот метод может быть вызван несколько раз.

### signer.sign(private_key, [output_format])

Вычисляет подпись для всех данных. `private_key` задаёт закрытый ключ в формате PEM.

Возвращает подпись в формате `output_format`, который может равняться `'binary'`, `'hex'` или `'base64'`
(по умолчанию `'binary'`).

Замечание: объект `signer` не может быть использован после вызова метода `sign()`.


## crypto.createVerify(algorithm)

Создает и возвращает объект `verifier`, который может быть использован
для проверки электронной подписи. Это объект-близнец для объекта `signer`.


## Класс: Verify

Класс для проверки цифровых подписей.

Инстанцируется с помощью метод `crypto.createVerify`.

### verifier.update(data)

Обновляет содержимое на `data`. Этот метод может быть вызван несколько раз.

### verifier.verify(cert, signature, [signature_format])

Проверяет данные с помощью сертификата `cert` в формате PEM и подписи
`signature` формата `signature_format`, который может равняться `'binary'`, `'hex'` или `'base64'`
(по умолчанию `'binary'`).

Возвращает `true` или `false` в зависимости от действительности подписи и публичного ключа.

Замечание: объект `verifier` не может быть использован после вызова метода `verify()`.


## crypto.createDiffieHellman(prime_length)

Creates a Diffie-Hellman key exchange object and generates a prime of the
given bit length. The generator used is `2`.

## crypto.createDiffieHellman(prime, [encoding])

Creates a Diffie-Hellman key exchange object using the supplied prime. The
generator used is `2`. Encoding can be `'binary'`, `'hex'`, or `'base64'`.
Defaults to `'binary'`.

## Class: DiffieHellman

The class for creating Diffie-Hellman key exchanges.

Returned by `crypto.createDiffieHellman`.

### diffieHellman.generateKeys([encoding])

Generates private and public Diffie-Hellman key values, and returns the
public key in the specified encoding. This key should be transferred to the
other party. Encoding can be `'binary'`, `'hex'`, or `'base64'`.
Defaults to `'binary'`.

### diffieHellman.computeSecret(other_public_key, [input_encoding], [output_encoding])

Computes the shared secret using `other_public_key` as the other party's
public key and returns the computed shared secret. Supplied key is
interpreted using specified `input_encoding`, and secret is encoded using
specified `output_encoding`. Encodings can be `'binary'`, `'hex'`, or
`'base64'`. The input encoding defaults to `'binary'`.
If no output encoding is given, the input encoding is used as output encoding.

### diffieHellman.getPrime([encoding])

Returns the Diffie-Hellman prime in the specified encoding, which can be
`'binary'`, `'hex'`, or `'base64'`. Defaults to `'binary'`.

### diffieHellman.getGenerator([encoding])

Returns the Diffie-Hellman prime in the specified encoding, which can be
`'binary'`, `'hex'`, or `'base64'`. Defaults to `'binary'`.

### diffieHellman.getPublicKey([encoding])

Returns the Diffie-Hellman public key in the specified encoding, which can
be `'binary'`, `'hex'`, or `'base64'`. Defaults to `'binary'`.

### diffieHellman.getPrivateKey([encoding])

Returns the Diffie-Hellman private key in the specified encoding, which can
be `'binary'`, `'hex'`, or `'base64'`. Defaults to `'binary'`.

### diffieHellman.setPublicKey(public_key, [encoding])

Sets the Diffie-Hellman public key. Key encoding can be `'binary'`, `'hex'`,
or `'base64'`. Defaults to `'binary'`.

### diffieHellman.setPrivateKey(public_key, [encoding])

Sets the Diffie-Hellman private key. Key encoding can be `'binary'`, `'hex'`,
or `'base64'`. Defaults to `'binary'`.

## crypto.pbkdf2(password, salt, iterations, keylen, callback)

Asynchronous PBKDF2 applies pseudorandom function HMAC-SHA1 to derive
a key of given length from the given password, salt and iterations.
The callback gets two arguments `(err, derivedKey)`.

## crypto.randomBytes(size, [callback])

Generates cryptographically strong pseudo-random data. Usage:

    // async
    crypto.randomBytes(256, function(ex, buf) {
      if (ex) throw ex;
      console.log('Have %d bytes of random data: %s', buf.length, buf);
    });

    // sync
    try {
      var buf = crypto.randomBytes(256);
      console.log('Have %d bytes of random data: %s', buf.length, buf);
    } catch (ex) {
      // handle error
    }

