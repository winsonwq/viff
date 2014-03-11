# Viff

Find virsual differences between web pages in different environments(developing, staging, production) and browsers.

## Installation

Viff is running on selenium sever. Don't worry, you can easily set up selenium server by using `wdm`.

```
$ npm install wdm -g
$ wdm update --standalone // install selenium and webdrivers
```
Then install `viff` command line.

```
npm install -g coffee-script && npm install -g viff
```
No need to install coffee-script if you have.

If you meet issue about `node-canvas`. Have a check [node-canvas wiki](https://github.com/LearnBoost/node-canvas/wiki/Installation---OSX)

## Examples

Checkout [`viff-examples`](https://github.com/winsonwq/viff-examples) reporsitory for more examples including

1. Tiny CSS difference
2. Chart difference
3. Content difference
4. Partial difference
5. Event Handling
6. Responsive
7. Multiple browsers
8. Multiple Environments
9. Browserstack
10. Programmable

### Quick example

Start server

```
$ wdm start // open selenium webdriver server
```

You could run `xx.config.js` file.

```javascript
// build_prod.config.js
'use strict'

module.exports = {
  seleniumHost: 'http://localhost:4444/wd/hub',
  browsers: ['firefox'/*, 'chrome', 'safari', 'opera'*/],
  envHosts: {
    build: 'http://localhost:4000',
    prod: 'http://www.ishouldbeageek.me'
  },
  paths: [
    '/404.html',
    '/',
    '/page2',
    '/page3',
    '/page4',
    '/page5',
    '/strict-mode',
    ['/', function clickLink(browser) {
      browser.elementByPartialLinkText('viff').click();
    }],
    ['/', '#main-content'/*, function (browser) { } */],
    { 'this is a testcase description' : ['/', '#main-content', function(browser) {
      browser.maximize();
    }]}
  ],
  reportFormat: 'file'
};
```

Then, you could run

```
viff ./build_prod.config.js
```

## Programmable

Use `viff` in your own project.

```javascript
var Viff = require('viff');
var viff = new Viff('http://localhost:4444/wd/hub');

viff.takeScreenshot('firefox', 'http://localhost:3000', '/path1', function (bufferImg) {
  /* buffer of images */  
});

// partial of web pages
viff.takeScreenshot('firefox', 'http://localhost:3000', ['path1', '#css-selecor'], function (bufferPartialImg) {});

// responsive of web pages
function size(width) {
  return function (driver) {
    driver.setWindowSize(width, 600 /* any height*/);
  };
}

viff.takeScreenshot('firefox', 'http://localhost:3000', ['path', size(1024)], function (bufferImg) {});

// Q promise
viff.takeScreenshot('firefox', 'http://localhost:3000', ['path', size(1024)])
  .done(function (bufferImg) {
    /* generate image here */
  })
  .catch(function (err) {
    /* handle err here */
  })

// using browserstack
viff = new Viff('http://hub.browserstack.com/wd/hub');
viff.takeScreenshot({
  'browserName' : 'iPhone',
  'platform' : 'MAC',
  'device' : 'iPhone 5',
  'browserstack.user': /* your name */,
  'browserstack.key': /* your key */
}, 'http://www.google.com', 'path1', function (bufferImg) {});
```

## file report embeded in viff reporter
![file report example](http://ww2.sinaimg.cn/mw1024/64eae748jw1e7fmlo9otwj21kw0vrqe5.jpg)

repo for viff reporter is [ViffReport](https://github.com/xjsi/ViffReport)

# History
2014-03-11 **viff@0.8.0** use [`wd`](https://github.com/admc/wd) to replace `selenium-webdriver`, so that you could use beautiful [Q Promised API](https://github.com/admc/wd/blob/master/doc/api.md) in your code.

---

2014-02-26 **viff@0.7.6** simplify console output [DEMO](https://asciinema.org/a/7903).

2014-02-17 **viff@0.7.2** make viff programmable.

2013-12-25 **viff@0.7.0** refactor testcases and compare differences cross browsers !!! Merry Christmas !!!

2013-11-13 **viff@0.6.1** optimise memory usage and only support `file` report format

2013-10-30 **viff@0.5.0** add testcase running status in console.

2013-10-27 **viff@0.4.2** won't stop testing if one of them fail.

2013-09-22 **viff@0.4.1** could write testcase description.

2013-08-08 **viff@0.4.0**  add partial screenshot support. working perfectly in firefox, phantomjs.

2013-08-01 **viff@0.3.0**  add new report format `file`, which will generate images.

2013-07-24 **viff@0.2.0**  use [resemble.js](https://github.com/Huddle/Resemble.js) to replace imagemagick

2013-07-16 **viff@0.1.2**  support resizing images before finding diff

# License

Copyright (c) 2013 - 2016 Wang Qiu (winsonwq@gmail.com)

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
