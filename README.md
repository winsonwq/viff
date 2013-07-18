# Viff

version **_Alpha_**

Find virtual differences between web pages in different environments(developing, staging, production) and browsers.

# Installation

Viff is running on selenium sever. Don't worry, you can easily set up selenium server by using [selenium-server-standalone.jar](https://code.google.com/p/selenium/downloads/detail?name=selenium-server-standalone-2.33.0.jar&can=2&q=). 

```
npm install -g coffee-script && npm install -g viff
```
No need to install coffee-script if you have.

# Example

Start server

```
java -jar ./selenium-server-standalone.jar -port 4444
```

Run your task using inline command-line way. Viff web pages in different environments (build, prod) and browsers (firefox, chrome).

```
viff --selenium-host http://localhost:4444/wd/hub -browsers "firefox,chrome" -envs build=http://localhost:4000,prod=http://ishouldbeageek.me -paths "/404.html,/page2" --report-format html > report.html
```

If the paths that you want to test are so many. You could choose `xx.config.js` file.

```javascript
// links.js
'use strict'

module.exports = [
  '/404.html',
  '/',
  '/page2',
  '/page3',
  '/page4',
  '/page5',
  '/strict-mode'
];

// build_prod.config.js
'use strict'

module.exports = {
  seleniumHost: 'http://localhost:4444/wd/hub',
  browsers: ['firefox', 'chrome', 'safari', 'opera'],
  envHosts: {
    build: 'http://localhost:4000',
    prod: 'http://www.ishouldbeageek.me'
  },
  paths: require('./links.js'),
  reportFormat: 'html'
};
```
Then, you could run

```
viff ./build_prod.config.js --selenium-host http://localhost:4000/wd/hub
```
Actually, these arguments like `--selenium-host` are optional. But if set, the inline configurations will override configurations in `.config.js` file. So `http://localhost:4000/wd/hub` will be in use.

## html report example
![html report example](http://ww2.sinaimg.cn/mw1024/64eae748tw1e6leimsy64j20rm0go0u6.jpg)

# History

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
