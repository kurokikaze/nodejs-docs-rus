# DNS

Используйте `require('dns')` чтобы получить доступ к модулю.
Все методы этого модуля используют библиотеку C-Ares, кроме метода `dns.lookup`,
который использует вызов `getaddrinfo(3)` в пуле потоков. C-Ares работает быстрее, чем `getaddrinfo`,
но системный вызов более предсказуем и он используется в большинстве других программ.
Когда вы вызываете `net.connect(80, 'google.com')` или `http.get({ host: 'google.com' })`,
то используется метод `dns.lookup`. Если же вам необходимо быстро выполнить множество DNS-запросов,
то лучше вызывать другие методы модуля, которые используют библиотеку C-Ares.

Пример, преобразующий в IP-адрес хост `'www.google.com'`
и преобразовывающий обратно полученные адреса.

    var dns = require('dns');

    dns.resolve4('www.google.com', function (err, addresses) {
      if (err) throw err;

      console.log('addresses: ' + JSON.stringify(addresses));

      addresses.forEach(function (a) {
        dns.reverse(a, function (err, domains) {
          if (err) {
            console.log('reverse for ' + a + ' failed: ' +
              err.message);
          } else {
            console.log('reverse for ' + a + ': ' +
              JSON.stringify(domains));
          }
        });
      });
    });

## dns.lookup(domain, [family], callback)

Разрешает домен (например `'google.com'`) в первую найденную A (для IPv4) или
AAAA (для IPv6) запись.
Параметр `family` может равняться `4` или `6`. По умолчанию он равен `null`,
в этом случае будет предпринята попытка найти адрес любого семейства.

Обработчик принимает аргументы `(err, address, family)`.
Аргумент `address` это строка, содержащая представление адреса в формате IPv4 или IPv6.
Аргумент `family` это число 4 или 6 и обозначает семейство `address` (необязательно совпадает со значением, изначально переданным в `lookup`).


## dns.resolve(domain, [rrtype], callback)

Разрешает домен (например `'google.com'`) в массив записей типа, указанного в `rrtype`.
Допустимые значения rrtypes: `'A'` (адреса IPV4, используется по умолчанию), `'AAAA'` (адреса IPV6),
`'MX'` (записи mail exchange), `'TXT'` (текстовые записи), `'SRV'` (записи SRV),
`'PTR'` (используются для запросов домена по IP), `NS` (записи серверов имён) и `CNAME` (канонические записи).

Обработчик принимает аргументы `(err, addresses)`. Тип каждого элемента `addresses`
определяется типом записи и описан в документации по соответствующим методам запроса ниже.

При ошибке `err` будет экземпляром объекта `Error`,
где `err.errno` — один из кодов ошибки, перечисленных ниже,
а `err.message` — строка, содержащая описание ошибки на английском.

## dns.resolve4(domain, callback)

То же что `dns.resolve()`, но только для IPv4 адресов (записи типа A).
`addresses` это массив IPv4 адресов (например  
`['74.125.79.104', '74.125.79.105', '74.125.79.106']`).

## dns.resolve6(domain, callback)

То же что `dns.resolve4()` но только для IPv6 адресов (записи типа AAAA).

## dns.resolveMx(domain, callback)

То же что `dns.resolve()`, но только для MX-записей.

`addresses` это массив MX записей, каждая с атрибутами `priority` и `exchange`
(например `[{'priority': 10, 'exchange': 'mx.example.com'},...]`).

## dns.resolveTxt(domain, callback)

То же что `dns.resolve()`, но только для текстовых записей (тип записи `TXT`).
`addresses` это массив текстовых записей, доступных для домена `domain`
(например `['v=spf1 ip4:0.0.0.0 ~all']`).

## dns.resolveSrv(domain, callback)

То же, что `dns.resolve()`, но только для сервисных записей (записей типа `SRV`).
`addresses` это массив SRV записей, доступных для домена `domain`.
Свойства SRV записей: `priority`, `weight`, `port`, и `name`
(например, `[{'priority': 10, {'weight': 5, 'port': 21223, 'name': 'service.example.com'}, ...]`).

## dns.reverse(ip, callback)

Обратно разрешает IP-адрес в массив доменных имён.

Аргументы обработчика: `(err, domains)`.

## dns.resolveNs(domain, callback)

То же, что `dns.resolve()`, но для записей серверов имён (`NS` записей).
`addresses` это массив NS записей, доступных для домена `domain`.
(например, `['ns1.example.com', 'ns2.example.com']`).

## dns.resolveCname(domain, callback)

То же, что `dns.resolve()`, но для канонических записей (`CNAME`
записей). `addresses` это массив канонических записей, доступных для домена
`domain` (например, `['bar.example.com']`).


Если произошла ошибка, err будет ненулевым экземпляром объекта `Error`.

Каждый запрос к DNS может вернуть код ошибки.

- `dns.TEMPFAIL`: таймаут, SERVFAIL или что-то подобное.
- `dns.PROTOCOL`: получен повреждённый ответ.
- `dns.NXDOMAIN`: домен не существует.
- `dns.NODATA`: домен существует, но нет данных требуемого типа.
- `dns.NOMEM`: при обработке закончилась память.
- `dns.BADQUERY`: запрос неверно сформирован.
