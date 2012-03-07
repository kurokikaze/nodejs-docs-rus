## Выполнение JavaScript

Для доступа к модулю используйте:

    var vm = require('vm');

JavaScript-код может быть скомпилирован и исполнен немедленно,
либо сохранён для последующего запуска.


### vm.runInThisContext(code, [filename])

`vm.runInThisContext()` компилирует `code` как будто он загружен из файла `filename`,
выполняет его и возвращает результат выполнения. Запускаемый код не имеет доступа
к локальной области видимости. `filename` не является обязательным аргументом.

Пример использования `vm.runInThisContext` и `eval` для выполнения одинакового кода:

    var localVar = 123,
        usingscript, evaled,
        vm = require('vm');

    usingscript = vm.runInThisContext('localVar = 1;',
      'myfile.vm');
    console.log('localVar: ' + localVar + ', usingscript: ' +
      usingscript);
    evaled = eval('localVar = 1;');
    console.log('localVar: ' + localVar + ', evaled: ' +
      evaled);

    // localVar: 123, usingscript: 1
    // localVar: 1, evaled: 1

`vm.runInThisContext` не имеет доступа к локальной области видимости, поэтому
`localVar` остаётся неизменной. `eval` имеет доступ к локальной области видимости,
поэтому `localVar` изменяется.

В случае синтаксической ошибке в `code`, `vm.runInThisContext` выводит ошибку
на stderr и бросает исключение.


### vm.runInNewContext(code, [sandbox], [filename])

`vm.runInNewContext` компилирует `code` для запуска в области видимости
`sandbox` как будто он загружен из файла `filename`, выполняет его и возвращает
результат выполнения. Запускаемый код не имеет доступа к локальной области
видимости, и использует объект `sandbox` в качестве глобального объекта.
`sandbox` и `filename` не являются обязательными аргументами.

Пример: компиляция и выполнение кода, который увеличивает глобальную переменную
юи создаёт новую. Эти глобальные переменные становятся доступными в `sandbox`.

    var util = require('util'),
        vm = require('vm'),
        sandbox = {
          animal: 'cat',
          count: 2
        };

    vm.runInNewContext('count += 1; name = "kitty"', sandbox, 'myfile.vm');
    console.log(util.inspect(sandbox));

    // { animal: 'cat', count: 3, name: 'kitty' }

Имейте в виду, что исполнение непроверенного кода довольно опасно. Для предотвращения
изменения таким кодом глобальных переменных можно использовать `vm.runInNewContext`,
но лучше всего выполнять такой код в отдельном процессе.

В случае синтаксической ошибке в `code`, `vm.runInNewContext` выводит ошибку
на stderr и бросает исключение.


### vm.createScript(code, [filename])

`createScript` компилирует `code` как будто он загружен из файла `filename`,
но нен выполняет его. Эта функция возвращает объект `vm.Script`, представляющий
гдаоткомпилированный кода. Этот код может быть запущель позже с помощью описанных
ниже методов. Возвращаемый скрипт не связан с каким-лтбо глобальным объектом,
это связаванеи происходит при каждом выполнение. `filename` не является
обязательным аргументом.

В случае синтаксической ошибке в `code`, `vm.createScript` выводит ошибку
на stderr и бросает исключение.


## Класс: Script

Класс, используемый для запуска скриптов. Экземпляры этого класса создаются с помощью vm.createScript.

### script.runInThisContext()

Тоже самое, что и `vm.runInThisContext`, но для предварительно скомпилированного
объекта `vm.Script. Запускаемый код не имет доступа к локальным переменным,
но имеет дост к глобальным (v8: in actual context).

Пример использования `script.runInThisContext` для компиляции кода
и множественного его исполнения:

    var vm = require('vm');

    globalVar = 0;

    var script = vm.createScript('globalVar += 1', 'myfile.vm');

    for (var i = 0; i < 1000 ; i += 1) {
      script.runInThisContext();
    }

    console.log(globalVar);

    // 1000


### script.runInNewContext([sandbox])

Тоже самое, что и `vm.runInNewContext`, но для предварительно скомпилированного
объекта `vm.Script.

Пример: компиляция кода, который увеличивает глобальную переменную
юи создаёт новую, и множественное его выполнение. Эти глобальные переменные
становятся доступными в `sandbox`.

    var util = require('util'),
        vm = require('vm'),
        sandbox = {
          animal: 'cat',
          count: 2
        };

    var script = vm.createScript('count += 1; name = "kitty"', 'myfile.vm');

    for (var i = 0; i < 10 ; i += 1) {
      script.runInNewContext(sandbox);
    }

    console.log(util.inspect(sandbox));

    // { animal: 'cat', count: 12, name: 'kitty' }

Имейте в виду, что исполнение непроверенного кода довольно опасно. Для предотвращения
изменения таким кодом глобальных переменных можно использовать `script.runInNewContext`,
но лучше всего выполнять такой код в отдельном процессе.

