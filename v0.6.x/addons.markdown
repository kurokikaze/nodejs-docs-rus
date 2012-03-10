# C/C++ дополнения

Дополнения — это динамически подключаемые объекты. Они могут предоставлять
связь с библиотеками на языках C/C++. На данный момент API для дополнений
довольно сложное и использует следующие библиотеки:

 - Движок V8 JavaScript, написан на C++. Используется для обращения к JavaScript
   из дополнения: создания объектов, вызова функций и т.д. Документация по нему
   крайне скудна, в основном стоит полагаться на заголовочный файл `v8.h`
   (`deps/v8/include/v8.h` в дистрибутиве Node), документация по которому
   также доступна [онлайн](http://izs.me/v8-docs/main.html).

 - [libuv](https://github.com/joyent/libuv), библиотека цикла событий, написанная на C.
   Каждый раз, когда вам потребуется подождать пока файловый дескриптор станет
   доступен для чтения, подождать вызова таймера или поступления сигнала,
   вы будете испльзовать вызовы из libuv.

 - Внутренние библиотеки Node. Наиболее важная из них — класс `node::ObjectWrap`,
   от которого будут наследоваться большинство ваших классов.

 - Остальные доступные библиотеки вы можете найти впапке `deps` дистрибутива Node.

При сборке Node все её зависимости статически компилируются в исполняемый файл.
При сборке своего модуля вы не должны задумываться об описанных выше библиотеках.

## Hello world

В качестве простого примера сделаем дополнение для Node на C++, которое будет
делать тоже самое, что и JavaScript код:

    exports.hello = 'world';

Для начала создадим файл `hello.cc`:

    #include <node.h>
    #include <v8.h>

    using namespace v8;

    Handle<Value> Method(const Arguments& args) {
      HandleScope scope;
      return scope.Close(String::New("world"));
    }

    void init(Handle<Object> target) {
      target->Set(String::NewSymbol("hello"),
          FunctionTemplate::New(Method)->GetFunction());
    }
    NODE_MODULE(hello, init)

Каждое дополнение должно экспортировать функцию инициализации следующим образом:

    void Initialize (Handle<Object> target);
    NODE_MODULE(module_name, Initialize)

После `NODE_MODULE` нет точки с запятой, так как это не функция, а макрос (см. `node.h`).

Текст `module_name` должен совпадать с именем файла скопилированного бинарного дополнения
(баз суффикса .node).

Этот код нужно собрать в файл `hello.node`, файл бинарного дополнения.
Для этого создадим файл `wscript`, содержащий код на Python (аналог Makefile):

    srcdir = '.'
    blddir = 'build'
    VERSION = '0.0.1'

    def set_options(opt):
      opt.tool_options('compiler_cxx')

    def configure(conf):
      conf.check_tool('compiler_cxx')
      conf.check_tool('node_addon')

    def build(bld):
      obj = bld.new_task_gen('cxx', 'shlib', 'node_addon')
      obj.target = 'hello'
      obj.source = 'hello.cc'

Теперь можно запустить команду `node-waf configure build`, которая создаст файл
`build/default/hello.node`, содержащий бинарную версию дополнения.

`node-waf` — расширение [WAF](http://code.google.com/p/waf/), системы сборки
на языке Python. `node-waf` включён в состав Node для упрощения процесса
сборки дополнений.

You can now use the binary addon in a Node project `hello.js` by pointing `require` to
the recently built module:

    var addon = require('./build/Release/hello');

    console.log(addon.hello()); // 'world'

Некоторые шаблоны кода, необходимые для написания расширений, приведены ниже.
В качестве примера вы можете просмотреть код <https://github.com/pietern/hiredis-node>.


## Фрагменты кода дополнений

Ниже приведены некоторые фрагменты кода дополнений, которые часто используются
и помогут вам начать писать свои бинарные дополнения для Node.js. Для более подробной информации по бибилиотеке v8
вы можете воспользоваться [справкой](http://izs.me/v8-docs/main.html),
а также [v8 Embedder's Guide](http://code.google.com/apis/v8/embed.html), в котором описаны некоторые концепции библиотеки,
такие handle, замыкание, шаблон функции и т.д.

Чтобы скомпилировать приведённые примеры, создаёте простой `wscript` и выполните в консоли команду
`node-waf configure build`:

    srcdir = '.'
    blddir = 'build'
    VERSION = '0.0.1'

    def set_options(opt):
      opt.tool_options('compiler_cxx')

    def configure(conf):
      conf.check_tool('compiler_cxx')
      conf.check_tool('node_addon')

    def build(bld):
      obj = bld.new_task_gen('cxx', 'shlib', 'node_addon')
      obj.target = 'addon'
      obj.source = ['addon.cc']

Если дополнение требует более одного файла `.cc`, просто добавьте его в массив `obj.source`:

    obj.source = ['addon.cc', 'myexample.cc']


### Передача аргументов в функции

Этот пример показывает, как прочитать переданные из JavaScript аргументы функции и вернуть результат выполнения.
Для этого потребует только один исходный файл `addon.cc`:

    #define BUILDING_NODE_EXTENSION
    #include <node.h>

    using namespace v8;

    Handle<Value> Add(const Arguments& args) {
      HandleScope scope;

      if (args.Length() < 2) {
        ThrowException(Exception::TypeError(String::New("Wrong number of arguments")));
        return scope.Close(Undefined());
      }

      if (!args[0]->IsNumber() || !args[1]->IsNumber()) {
        ThrowException(Exception::TypeError(String::New("Wrong arguments")));
        return scope.Close(Undefined());
      }

      Local<Number> num = Number::New(args[0]->NumberValue() +
          args[1]->NumberValue());
      return scope.Close(num);
    }

    void Init(Handle<Object> target) {
      target->Set(String::NewSymbol("add"),
          FunctionTemplate::New(Add)->GetFunction());
    }

    NODE_MODULE(addon, Init)

Вы можете проверить работоспособность дополнения с помощью следующего JavaScript кода:

    var addon = require('./build/Release/addon');

    console.log( 'This should be eight:', addon.add(3,5) );


### Функции обратного вызова

Вы можете передать JavaScript функции в дополнение для вызова её оттуда.
Пример `addon.cc`:

    #define BUILDING_NODE_EXTENSION
    #include <node.h>

    using namespace v8;

    Handle<Value> RunCallback(const Arguments& args) {
      HandleScope scope;

      Local<Function> cb = Local<Function>::Cast(args[0]);
      const unsigned argc = 1;
      Local<Value> argv[argc] = { Local<Value>::New(String::New("hello world")) };
      cb->Call(Context::GetCurrent()->Global(), argc, argv);

      return scope.Close(Undefined());
    }

    void Init(Handle<Object> target) {
      target->Set(String::NewSymbol("runCallback"),
          FunctionTemplate::New(RunCallback)->GetFunction());
    }

    NODE_MODULE(addon, Init)

Проверяем работоспособность дополнения:

    var addon = require('./build/Release/addon');

    addon.runCallback(function(msg){
      console.log(msg); // 'hello world'
    });


### Фабрика объектов

В этом примере мы создадим функцию `createObject()`, которая будект возвращать объект со свойством `msg`,
содержащим переданный в функцию текст:

    #define BUILDING_NODE_EXTENSION
    #include <node.h>

    using namespace v8;

    Handle<Value> CreateObject(const Arguments& args) {
      HandleScope scope;

      Local<Object> obj = Object::New();
      obj->Set(String::NewSymbol("msg"), args[0]->ToString());

      return scope.Close(obj);
    }

    void Init(Handle<Object> target) {
      target->Set(String::NewSymbol("createObject"),
          FunctionTemplate::New(CreateObject)->GetFunction());
    }

    NODE_MODULE(addon, Init)

Проверяем работоспособность дополнения:

    var addon = require('./build/Release/addon');

    var obj1 = addon.createObject('hello');
    var obj2 = addon.createObject('world');
    console.log(obj1.msg+' '+obj2.msg); // 'hello world'


### Фабрика функций

Этот пример показывает, как создать и вернуть из C++ кода Javascript функцию, связанную с другой C++ функцией:

    #define BUILDING_NODE_EXTENSION
    #include <node.h>

    using namespace v8;

    Handle<Value> MyFunction(const Arguments& args) {
      HandleScope scope;
      return scope.Close(String::New("hello world"));
    }

    Handle<Value> CreateFunction(const Arguments& args) {
      HandleScope scope;

      Local<FunctionTemplate> tpl = FunctionTemplate::New(MyFunction);
      Local<Function> fn = tpl->GetFunction();
      fn->SetName(String::NewSymbol("theFunction")); // omit this to make it anonymous

      return scope.Close(fn);
    }

    void Init(Handle<Object> target) {
      target->Set(String::NewSymbol("createFunction"),
          FunctionTemplate::New(CreateFunction)->GetFunction());
    }

    NODE_MODULE(addon, Init)


Для проверки выполняем:

    var addon = require('./build/Release/addon');

    var fn = addon.createFunction();
    console.log(fn()); // 'hello world'


### Обертка C++ объектов

Вы также можете создавать Javascript обёртки для C++ объектов/классов. В данном случае `MyObject` может быть
инстанцирован в JavaScript с помощью оператора `new`. Для начала напишем основной файл дополнения, `addon.cc`:

    #define BUILDING_NODE_EXTENSION
    #include <node.h>
    #include "myobject.h"

    using namespace v8;

    void InitAll(Handle<Object> target) {
      MyObject::Init(target);
    }

    NODE_MODULE(addon, InitAll)

В файле `myobject.h` унаследуем нашу обёртку от `node::ObjectWrap`:

    #ifndef MYOBJECT_H
    #define MYOBJECT_H

    #include <node.h>

    class MyObject : public node::ObjectWrap {
     public:
      static void Init(v8::Handle<v8::Object> target);

     private:
      MyObject();
      ~MyObject();

      static v8::Handle<v8::Value> New(const v8::Arguments& args);
      static v8::Handle<v8::Value> PlusOne(const v8::Arguments& args);
      double counter_;
    };

    #endif

А в файл `myobject.cc` поместим реализацию некоторых методов класса, которые мы хотим сделать видимыми в Javascrip.
Для этого мы должны добавить метод `plusOne` в прототип конструктора объекта:

    #define BUILDING_NODE_EXTENSION
    #include <node.h>
    #include "myobject.h"

    using namespace v8;

    MyObject::MyObject() {};
    MyObject::~MyObject() {};

    void MyObject::Init(Handle<Object> target) {
      // Prepare constructor template
      Local<FunctionTemplate> tpl = FunctionTemplate::New(New);
      tpl->SetClassName(String::NewSymbol("MyObject"));
      tpl->InstanceTemplate()->SetInternalFieldCount(1);
      // Prototype
      tpl->PrototypeTemplate()->Set(String::NewSymbol("plusOne"),
          FunctionTemplate::New(PlusOne)->GetFunction());

      Persistent<Function> constructor = Persistent<Function>::New(tpl->GetFunction());
      target->Set(String::NewSymbol("MyObject"), constructor);
    }

    Handle<Value> MyObject::New(const Arguments& args) {
      HandleScope scope;

      MyObject* obj = new MyObject();
      obj->counter_ = args[0]->IsUndefined() ? 0 : args[0]->NumberValue();
      obj->Wrap(args.This());

      return args.This();
    }

    Handle<Value> MyObject::PlusOne(const Arguments& args) {
      HandleScope scope;

      MyObject* obj = ObjectWrap::Unwrap<MyObject>(args.This());
      obj->counter_ += 1;

      return scope.Close(Number::New(obj->counter_));
    }

Для проверки выполняем:

    var addon = require('./build/Release/addon');

    var obj = new addon.MyObject(10);
    console.log( obj.plusOne() ); // 11
    console.log( obj.plusOne() ); // 12
    console.log( obj.plusOne() ); // 13


### Фабрика обёрток объектов

Бывает полезным создание объектов без использования оператора `new` в JavaScript, например.

    var obj = addon.createObject();
    // instead of:
    // var obj = new addon.Object();

Для этого создадим метод `createObject` в `addon.cc`:

    #define BUILDING_NODE_EXTENSION
    #include <node.h>
    #include "myobject.h"

    using namespace v8;

    Handle<Value> CreateObject(const Arguments& args) {
      HandleScope scope;
      return scope.Close(MyObject::NewInstance(args));
    }

    void InitAll(Handle<Object> target) {
      MyObject::Init();

      target->Set(String::NewSymbol("createObject"),
          FunctionTemplate::New(CreateObject)->GetFunction());
    }

    NODE_MODULE(addon, InitAll)

Теперь нам необходимо объявить в `myobject.h` статический метод `NewInstance`, который будет инстанцировать объект
(т.е. выполнять функцию `new` в JavaScript):

    #define BUILDING_NODE_EXTENSION
    #ifndef MYOBJECT_H
    #define MYOBJECT_H

    #include <node.h>

    class MyObject : public node::ObjectWrap {
     public:
      static void Init();
      static v8::Handle<v8::Value> NewInstance(const v8::Arguments& args);

     private:
      MyObject();
      ~MyObject();

      static v8::Persistent<v8::Function> constructor;
      static v8::Handle<v8::Value> New(const v8::Arguments& args);
      static v8::Handle<v8::Value> PlusOne(const v8::Arguments& args);
      double counter_;
    };

    #endif

Реализация `myobject.cc` похожа на описанную выше:

    #define BUILDING_NODE_EXTENSION
    #include <node.h>
    #include "myobject.h"

    using namespace v8;

    MyObject::MyObject() {};
    MyObject::~MyObject() {};

    Persistent<Function> MyObject::constructor;

    void MyObject::Init() {
      // Prepare constructor template
      Local<FunctionTemplate> tpl = FunctionTemplate::New(New);
      tpl->SetClassName(String::NewSymbol("MyObject"));
      tpl->InstanceTemplate()->SetInternalFieldCount(1);
      // Prototype
      tpl->PrototypeTemplate()->Set(String::NewSymbol("plusOne"),
          FunctionTemplate::New(PlusOne)->GetFunction());

      constructor = Persistent<Function>::New(tpl->GetFunction());
    }

    Handle<Value> MyObject::New(const Arguments& args) {
      HandleScope scope;

      MyObject* obj = new MyObject();
      obj->counter_ = args[0]->IsUndefined() ? 0 : args[0]->NumberValue();
      obj->Wrap(args.This());

      return args.This();
    }

    Handle<Value> MyObject::NewInstance(const Arguments& args) {
      HandleScope scope;

      const unsigned argc = 1;
      Handle<Value> argv[argc] = { args[0] };
      Local<Object> instance = constructor->NewInstance(argc, argv);

      return scope.Close(instance);
    }

    Handle<Value> MyObject::PlusOne(const Arguments& args) {
      HandleScope scope;

      MyObject* obj = ObjectWrap::Unwrap<MyObject>(args.This());
      obj->counter_ += 1;

      return scope.Close(Number::New(obj->counter_));
    }

Для проверки выполняем:

    var addon = require('./build/Release/addon');

    var obj = addon.createObject(10);
    console.log( obj.plusOne() ); // 11
    console.log( obj.plusOne() ); // 12
    console.log( obj.plusOne() ); // 13

    var obj2 = addon.createObject(20);
    console.log( obj2.plusOne() ); // 21
    console.log( obj2.plusOne() ); // 22
    console.log( obj2.plusOne() ); // 23


### Использование обёрнутых объектов в C++ коде

Кроме того, что C++ объекты можно обёртывать и возвращать в Javascript код, их также можно передавать обратно,
разворачивать и использовать в C++ коде как обычные C++ объекты. Для этого используется функция `node::ObjectWrap::Unwrap`.
Добавим в `addon.cc` функцию `add()`, которая принимает два объекта класса `MyObject`:

    #define BUILDING_NODE_EXTENSION
    #include <node.h>
    #include "myobject.h"

    using namespace v8;

    Handle<Value> CreateObject(const Arguments& args) {
      HandleScope scope;
      return scope.Close(MyObject::NewInstance(args));
    }

    Handle<Value> Add(const Arguments& args) {
      HandleScope scope;

      MyObject* obj1 = node::ObjectWrap::Unwrap<MyObject>(
          args[0]->ToObject());
      MyObject* obj2 = node::ObjectWrap::Unwrap<MyObject>(
          args[1]->ToObject());

      double sum = obj1->Val() + obj2->Val();
      return scope.Close(Number::New(sum));
    }

    void InitAll(Handle<Object> target) {
      MyObject::Init();

      target->Set(String::NewSymbol("createObject"),
          FunctionTemplate::New(CreateObject)->GetFunction());

      target->Set(String::NewSymbol("add"),
          FunctionTemplate::New(Add)->GetFunction());
    }

    NODE_MODULE(addon, InitAll)

Для получения значения приватной переменной `val_` напишем дополнительную функцию прямо в `myobject.h`:

    #define BUILDING_NODE_EXTENSION
    #ifndef MYOBJECT_H
    #define MYOBJECT_H

    #include <node.h>

    class MyObject : public node::ObjectWrap {
     public:
      static void Init();
      static v8::Handle<v8::Value> NewInstance(const v8::Arguments& args);
      double Val() const { return val_; }

     private:
      MyObject();
      ~MyObject();

      static v8::Persistent<v8::Function> constructor;
      static v8::Handle<v8::Value> New(const v8::Arguments& args);
      double val_;
    };

    #endif

Реализация `myobject.cc` не изменилась:

    #define BUILDING_NODE_EXTENSION
    #include <node.h>
    #include "myobject.h"

    using namespace v8;

    MyObject::MyObject() {};
    MyObject::~MyObject() {};

    Persistent<Function> MyObject::constructor;

    void MyObject::Init() {
      // Prepare constructor template
      Local<FunctionTemplate> tpl = FunctionTemplate::New(New);
      tpl->SetClassName(String::NewSymbol("MyObject"));
      tpl->InstanceTemplate()->SetInternalFieldCount(1);

      constructor = Persistent<Function>::New(tpl->GetFunction());
    }

    Handle<Value> MyObject::New(const Arguments& args) {
      HandleScope scope;

      MyObject* obj = new MyObject();
      obj->val_ = args[0]->IsUndefined() ? 0 : args[0]->NumberValue();
      obj->Wrap(args.This());

      return args.This();
    }

    Handle<Value> MyObject::NewInstance(const Arguments& args) {
      HandleScope scope;

      const unsigned argc = 1;
      Handle<Value> argv[argc] = { args[0] };
      Local<Object> instance = constructor->NewInstance(argc, argv);

      return scope.Close(instance);
    }

Для проверки выполняем:

    var addon = require('./build/Release/addon');

    var obj1 = addon.createObject(10);
    var obj2 = addon.createObject(20);
    var result = addon.add(obj1, obj2);

    console.log(result); // 30
