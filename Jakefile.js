var sys = require('sys'),
  fs = require('fs');

desc('Create online version.');
task('default', [], function(params) {
  console.log('Creating online version...');
  fs.readFile('api.htm', 'utf-8', function(err, data) {
    if (err) throw err;
    data = data.replace('api-files/logo.png', 'http://nodejs.org/logo.png');
    data = data.replace('api-files/jquery.js',
      'http://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js');
    data = data.replace('api-files/sh_main.js',
      'http://nodejs.org/sh_main.js');
    data = data.replace('api-files/sh_javascript.min.js',
      'http://nodejs.org/sh_javascript.min.js');
    data = data.replace('api-files/doc.js',
      'http://nodejs.org/doc.js');
    data = data.replace('<!-- Yandex.Metrika -->',
      '<!-- Yandex.Metrika -->\n' +
      '<script src="//mc.yandex.ru/metrika/watch.js" type="text/javascript"></script>\n' +
      '<script type="text/javascript">\n' +
      'try { var yaCounter612423 = new Ya.Metrika(612423); } catch(e){}\n' +
      '</script>\n' +
      '<noscript><div style="position: absolute;"><img src="//mc.yandex.ru/watch/612423" ' +
      'alt="" /></div></noscript>\n' +
      '<!-- /Yandex.Metrika -->\n');
    fs.writeFile('api.html', data, function (err) {
      if (err) throw err;
      console.log('Online version successfully created!');
    });
  });
});
