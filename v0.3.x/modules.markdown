## Модули

Node использует систему модулей CommonJS.

Node имеет простую систему загрузки модулей, файлы и модули в которой являются,
в каком-то смысле, синонимами. В примере `foo.js` загружает модуль `circle.js`,
находящийся в той же директории.

Содержимое `foo.js`:

    var circle = require('./circle.js');
    console.log( 'The area of a circle of radius 4 is '
               + circle.area(4));

Содержимое `circle.js`:

    var PI = Math.PI;

    exports.area = function (r) {
      return PI * r * r;
    };

    exports.circumference = function (r) {
      return 2 * PI * r;
    };

Модуль `circle.js` экспортирует функции `area()` и `circumference()`. Для этого
достаточно добавить экспортируемые функции/объекты к специальному объекты `exports`.
(В качетве альтернативы можно использовать `this` вместо `exports`.) Переменные,
локальные для модуля, не будут видны извне. В этом примере переменная `PI` видна
только внутри модуля `circle.js`.

## Стандартные модули

Вместе с Node поставляется несколько стандартных встроенных модулей,
большинство из которых описано ниже.

Стандартные модули можно найти в папке `lib/` исходного кода node.

Стандартные модули всегда имеют приоритет при загрузке с помощью `require()`.
Например, `require('http')` всегда возвратит стандартный модуль HTTP, даже если
существует другой файл с таким именем.

### Поиск модулей

Если файла с именем, переданным в `require()`, не существует, то node сначала
пытается загрузить файлы с этим именем и дополнительным расширением `.js` потом `.node`.

`.js` файлы трактуются как текстовые файлы с JavaScript-кодом, а `.node` файлы
трактуются как скомпилированные дополнения и загружаются с помощью `dlopen`.

Имена, начинающиеся на `'/'`, считаются абсолютными путями. Например,
`require('/home/marco/foo.js')` будет загружать файл `/home/marco/foo.js`.

Модули, имена которых начинаются на `'./'` считаются относительными для
вызывающего `require()` модуля. Это означает, что в примере выше `circle.js`
должен находиться в той же папке, что и `foo.js`, тогда `require('./circle')`
будет работать.

В случае отсутствия '/' или './', которые указывают на необходимость поиска файла,
модуль является илбо стандартным модулем, либо загружается из папки `node_modules`.

### Загрузка из папок `node_modules`

Если идентификатор модуля, переданный в `require()` не представляет стандартный модуль
и не начинается на `'/'`, `'../'` или `'./'`, то node берёт папку текущего модуля,
добалвет к ней `'/node_modules'` и пытается загрузить модуль из этой папки.

Если по этому пути модуль не будет найден, то node переходит к родительской папке
и так далее, пока не будет найден модуль или не будет достигнут корень файловой системы.

Напрмиер, если файл `'/home/ry/projects/foo.js'` вызывает `require('bar.js')`,
то node будет искать в следующей последовательности:

* `/home/ry/projects/node_modules/bar.js`
* `/home/ry/node_modules/bar.js`
* `/home/node_modules/bar.js`
* `/node_modules/bar.js`

Это позволяет программам локализовывать их зависимости, чтобы они не конфликтовали.

#### Оптимизация процесса поиска по папкам `node_modules`

Если есть много уровней вложенных зависимостей, то возможно существование длинных
деревьев файлов, которые нужно проверить. Для ускорения этого процесса применяются
несколько оптимизаций.

Во-первых, `/node_modules` никогда не добьавляется к папке, уже заканчивающейся
на `/node_modules`.

Во-вторых, если файл, вызывающий `require()`, находится в подпапке `node_modules`,
то эта папка трактуется как корень дерева папок.

Например, если файл `'/home/ry/projects/foo/node_modules/bar/node_modules/baz/quux.js'`
вызывает `require('asdf.js')`, то node будет искать в следующей последовательности:

* `/home/ry/projects/foo/node_modules/bar/node_modules/baz/node_modules/asdf.js`
* `/home/ry/projects/foo/node_modules/bar/node_modules/asdf.js`
* `/home/ry/projects/foo/node_modules/asdf.js`

### Папки как модули

Довольно удобно организовывать программы в виде вложеннных папок, предоставляя
единственную точку входа для библиотеки. Есть три способа, которыми папки могут
быть переданы в качестве аргумента `require()`.

Первым является создание в папке файла `package.json`, который определяет
`главный` модуль. Например, package.json может быть таким:

    { "name" : "some-library",
      "main" : "./lib/some-library.js" }

Если он находится в папке `./some-library`, то `require('./some-library')` будет
пытаться загрузить файл `./some-library/lib/some-library.js`.

Этим ограничивается осведомлённость node о файлах package.json.

Если файла package.json в папке нет, то node будет пытаться загрузить `index.js`
или `index.node` в этой папке. При этом `require('./some-library')` попробует
загрузить:

* `./some-library/index.js`
* `./some-library/index.node`

### Кеширование

Модули кешируются при первой загрузке. Это, кроме остального, означает, что
каждый вызов `require('foo')` возвращает точно тотже объект, если модуль
разрешается в тоже самое имя файла.

### Собирая всё вместе...

Для того, чтобы определить, какой модуль был загружен при вызове `require()`,
можно воспользоваться функцией `require.resolve()`.

Учитывая всё вышесказанное, можно составить следующий высокоуровневый псевдокод
для `require()`:

    require(X)
    1. If X is a core module,
       a. return the core module
       b. STOP
    2. If X begins with `./` or `/`,
       a. LOAD_AS_FILE(Y + X)
       b. LOAD_AS_DIRECTORY(Y + X)
    3. LOAD_NODE_MODULES(X, dirname(Y))
    4. THROW "not found"

    LOAD_AS_FILE(X)
    1. If X is a file, load X as JavaScript text.  STOP
    2. If X.js is a file, load X.js as JavaScript text.  STOP
    3. If X.node is a file, load X.node as binary addon.  STOP

    LOAD_AS_DIRECTORY(X)
    1. If X/package.json is a file,
       a. Parse X/package.json, and look for "main" field.
       b. let M = X + (json main field)
       c. LOAD_AS_FILE(M)
    2. LOAD_AS_FILE(X/index)

    LOAD_NODE_MODULES(X, START)
    1. let DIRS=NODE_MODULES_PATHS(START)
    2. for each DIR in DIRS:
       a. LOAD_AS_FILE(DIR/X)
       b. LOAD_AS_DIRECTORY(DIR/X)

    NODE_MODULES_PATHS(START)
    1. let PARTS = path split(START)
    2. let ROOT = index of first instance of "node_modules" in PARTS, or 0
    3. let I = count of PARTS - 1
    4. let DIRS = []
    5. while I > ROOT,
       a. if PARTS[I] = "node_modules" CONTINUE
       c. DIR = path join(PARTS[0 .. I] + "node_modules")
       b. DIRS = DIRS + DIR
    6. return DIRS

+### Loading from the `require.paths` Folders
+
+In node, `require.paths` is an array of strings that represent paths to
+be searched for modules when they are not prefixed with `'/'`, `'./'`, or
+`'../'`.  For example, if require.paths were set to:
+
+    [ '/home/micheil/.node_modules',
+      '/usr/local/lib/node_modules' ]
+
+Then calling `require('bar/baz.js')` would search the following
+locations:
+
+* 1: `'/home/micheil/.node_modules/bar/baz.js'`
+* 2: `'/usr/local/lib/node_modules/bar/baz.js'`
+
+The `require.paths` array can be mutated at run time to alter this
+behavior.
+
+It is set initially from the `NODE_PATH` environment variable, which is
+a colon-delimited list of absolute paths.  In the previous example,
+the `NODE_PATH` environment variable might have been set to:
+
+    /home/micheil/.node_modules:/usr/local/lib/node_modules
+
+#### **Note:** Please Avoid Modifying `require.paths`
+
+For compatibility reasons, `require.paths` is still given first priority
+in the module lookup process.  However, it may disappear in a future
+release.
+
+While it seemed like a good idea at the time, and enabled a lot of
+useful experimentation, in practice a mutable `require.paths` list is
+often a troublesome source of confusion and headaches.
+
+##### Setting `require.paths` to some other value does nothing.
+
+This does not do what one might expect:
+
+    require.paths = [ '/usr/lib/node' ];
+
+All that does is lose the reference to the *actual* node module lookup
+paths, and create a new reference to some other thing that isn't used
+for anything.
+
+##### Putting relative paths in `require.paths` is... weird.
+
+If you do this:
+
+    require.paths.push('./lib');
+
+then it does *not* add the full resolved path to where `./lib`
+is on the filesystem.  Instead, it literally adds `'./lib'`,
+meaning that if you do `require('y.js')` in `/a/b/x.js`, then it'll look
+in `/a/b/lib/y.js`.  If you then did `require('y.js')` in
+`/l/m/n/o/p.js`, then it'd look in `/l/m/n/o/p/lib/y.js`.
+
+In practice, people have used this as an ad hoc way to bundle
+dependencies, but this technique is brittle.
+
+##### Zero Isolation
+
+There is (by regrettable design), only one `require.paths` array used by
+all modules.
+
+As a result, if one node program comes to rely on this behavior, it may
+permanently and subtly alter the behavior of all other node programs in
+the same process.  As the application stack grows, we tend to assemble
+functionality, and it is a problem with those parts interact in ways
+that are difficult to predict.
+
+## Addenda: Package Manager Tips
+
+The semantics of Node's `require()` function were designed to be general
+enough to support a number of sane directory structures. Package manager
+programs such as `dpkg`, `rpm`, and `npm` will hopefully find it possible to
+build native packages from Node modules without modification.
+
+Below we give a suggested directory structure that could work:
+
+Let's say that we wanted to have the folder at
+`/usr/lib/node/<some-package>/<some-version>` hold the contents of a
+specific version of a package.
+
+Packages can depend on one another. In order to install package `foo`, you
+may have to install a specific version of package `bar`.  The `bar` package
+may itself have dependencies, and in some cases, these dependencies may even
+collide or form cycles.
+
+Since Node looks up the `realpath` of any modules it loads (that is,
+resolves symlinks), and then looks for their dependencies in the
+`node_modules` folders as described above, this situation is very simple to
+resolve with the following architecture:
+
+* `/usr/lib/node/foo/1.2.3/` - Contents of the `foo` package, version 1.2.3.
+* `/usr/lib/node/bar/4.3.2/` - Contents of the `bar` package that `foo`
+  depends on.
+* `/usr/lib/node/foo/1.2.3/node_modules/bar` - Symbolic link to
+  `/usr/lib/node/bar/4.3.2/`.
+* `/usr/lib/node/bar/4.3.2/node_modules/*` - Symbolic links to the packages
+  that `bar` depends on.
+
+Thus, even if a cycle is encountered, or if there are dependency
+conflicts, every module will be able to get a version of its dependency
+that it can use.
+
+When the code in the `foo` package does `require('bar')`, it will get the
+version that is symlinked into `/usr/lib/node/foo/1.2.3/node_modules/bar`.
+Then, when the code in the `bar` package calls `require('quux')`, it'll get
+the version that is symlinked into
+`/usr/lib/node/bar/4.3.2/node_modules/quux`.
+
+Furthermore, to make the module lookup process even more optimal, rather
+than putting packages directly in `/usr/lib/node`, we could put them in
+`/usr/lib/node_modules/<name>/<version>`.  Then node will not bother
+looking for missing dependencies in `/usr/node_modules` or `/node_modules`.
+
+In order to make modules available to the node REPL, it might be useful to
+also add the `/usr/lib/node_modules` folder to the `$NODE_PATH` environment
+variable.  Since the module lookups using `node_modules` folders are all
+relative, and based on the real path of the files making the calls to
+`require()`, the packages themselves can be anywhere.

