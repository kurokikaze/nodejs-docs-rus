## DNS

Используйте `require('dns')` чтобы получить доступ к модулю.

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

### dns.lookup(domain, family=null, callback)

Resolves a domain (e.g. `'google.com'`) into the first found A (IPv4) or
AAAA (IPv6) record.

The callback has arguments `(err, address, family)`.  The `address` argument
is a string representation of a IP v4 or v6 address. The `family` argument
is either the integer 4 or 6 and denotes the family of `address` (not
neccessarily the value initially passed to `lookup`).


### dns.resolve(domain, rrtype='A', callback)

Разрешает домен (например `'google.com'`) в массив записей типа, указанного в `rrtype`.
Допустимые значения rrtypes: `'A'` (адреса IPV4), `'AAAA'` (адреса IPV6),
`'MX'` (записи mail exchange), `'TXT'` (текстовые записи), `'SRV'` (записи SRV)
и `'PTR'` (используются для запросов домена по IP).

Обработчик принимает аргументы `(err, addresses)`. Тип каждого элемента `addresses`
определяется типом записи и описан в документации по соответствующим методам запроса ниже.

При ошибке `err` будет экземпляром объекта `Error`, где `err.errno` — один из кодов ошибки,
перечисленных ниже, а `err.message` — строка, содержащая описание ошибки на английском.

### dns.resolve4(domain, callback)

То же что `dns.resolve()`, но только для IPv4 адресов (записи типа A).
`addresses` это массив IPv4 адресов (например  
`['74.125.79.104', '74.125.79.105', '74.125.79.106']`).

### dns.resolve6(domain, callback)

То же что `dns.resolve4()` но только для IPv6 адресов (записи типа AAAA).

### dns.resolveMx(domain, callback)

То же что `dns.resolve()`, но только для MX-записей.

`addresses` это массив MX записей, каждая с атрибутами `priority` и `exchange`
(например `[{'priority': 10, 'exchange': 'mx.example.com'},...]`).

### dns.resolveTxt(domain, callback)

То же что `dns.resolve()`, но только для текстовых записей (тип записи TXT).
`addresses` это массив текстовых записей, доступных для домена `domain`
(например `['v=spf1 ip4:0.0.0.0 ~all']`).

### dns.resolveSrv(domain, callback)

То же, что `dns.resolve()`, но только для service records (записей SRV).
`addresses` это массив SRV записей, доступных для домена `domain`.
Свойства SRV записей: `priority`, `weight`, `port`, и `name`
(например, `[{'priority': 10, {'weight': 5, 'port': 21223, 'name': 'service.example.com'}, ...]`).

### dns.reverse(ip, callback)

Обратно разрешает IP-адрес в массив доменных имён.

Аргументы обработчика: `(err, domains)`.

Если произошла ошибка, err будет ненулевым экземпляром объекта `Error`.

Каждый запрос к DNS может вернуть код ошибки.

- `dns.TEMPFAIL`: таймаут, SERVFAIL или что-то подобное.
- `dns.PROTOCOL`: получен повреждённый ответ.
- `dns.NXDOMAIN`: домен не существует.
- `dns.NODATA`: домен существует, но нет данных требуемого типа.
- `dns.NOMEM`: при обработке закончилась память.
- `dns.BADQUERY`: запрос неверно сформирован.

