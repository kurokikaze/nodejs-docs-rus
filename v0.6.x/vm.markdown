# Выполнение JavaScript

<!--name=vm-->

    Стабильность: 3 - Стабильно


Для доступа к модулю используйте:

    var vm = require('vm');

JavaScript-код может быть скомпилирован и исполнен немедленно,
либо сохранён для последующего запуска.

## vm.runInThisContext(code, [filename])

`vm.runInThisContext()` компилирует `code`, выполняет его и возвращает результат выполнения.
Запускаемый код не имеет доступа к локальной области видимости.
`filename` не является обязательным аргументом, и используется только при выводе стека выполнения.

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

## vm.runInNewContext(code, [sandbox], [filename])

`vm.runInNewContext` компилирует `code` для запуска в области видимости
`sandbox`, выполняет его и возвращает результат выполнения.
Запускаемый код не имеет доступа к локальной области видимости,
и использует объект `sandbox` в качестве глобального объекта.
`sandbox` и `filename` не являются обязательными аргументами,
а `filename` используется только при выводе стека выполнения.

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

## vm.runInContext(code, context, [filename])

`vm.runInContext` compiles `code`, then runs it in `context` and returns the
result. A (V8) context comprises a global object, together with a set of
built-in objects and functions. Running code does not have access to local scope
and the global object held within `context` will be used as the global object
for `code`.
`filename` is optional, it's used only in stack traces.

Example: compile and execute code in a existing context.

    var util = require('util'),
        vm = require('vm'),
        initSandbox = {
          animal: 'cat',
          count: 2
        },
        context = vm.createContext(initSandbox);

    vm.runInContext('count += 1; name = "CATT"', context, 'myfile.vm');
    console.log(util.inspect(context));

    // { animal: 'cat', count: 3, name: 'CATT' }

Note that `createContext` will perform a shallow clone of the supplied sandbox object in order to
initialise the global object of the freshly constructed context.

Note that running untrusted code is a tricky business requiring great care.  To prevent accidental
global variable leakage, `vm.runInContext` is quite useful, but safely running untrusted code
requires a separate process.

In case of syntax error in `code`, `vm.runInContext` emits the syntax error to stderr
and throws an exception.

## vm.createContext([initSandbox])

`vm.createContext` создаёт новый контекст, который может быть использован
в качестве второго аргумента в вызове `vm.runInContext`.
A (V8) context comprises a global object together with a set of
build-in objects and functions. The optional argument `initSandbox` will be shallow-copied
to seed the initial contents of the global object used by the context.

## vm.createScript(code, [filename])

`createScript` компилирует `code` как будто он загружен из файла `filename`,
но нен выполняет его. Эта функция возвращает объект `vm.Script`, представляющий
гдаоткомпилированный кода. Этот код может быть запущель позже с помощью описанных
ниже методов. Возвращаемый скрипт не связан с каким-лтбо глобальным объектом,
это связаванеи происходит при каждом выполнение. `filename` не является
обязательным аргументом, и используется только при выводе стека выполнения..

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
