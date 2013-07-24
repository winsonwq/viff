'use strict'

module.exports = (function initLinks() {

  return [
    '/404.html',
    ['/', function (driver, webdriver) {
      driver.findElement(webdriver.By.partialLinkText('Drupal初体验')).click();
    }]
  ];

})();
