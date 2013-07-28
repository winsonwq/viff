
template = """
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf8"/>
    <title>Viff Report</title>
    <style type="text/css">
      @import url(http://fonts.googleapis.com/css?family=Open+Sans:300italic,400italic,600italic,300,400,600);
      body{font: normal normal 14px/1.5 'Open Sans', sans-serif; }
      body,ul,h1,h2,h3,h4{margin:0;padding:0;font-weight:300;font-style:normal;}
      body{margin: 20px;}
      h2{font-size: 3em;}
      ul{overflow: hidden;}
      li{list-style-type: none; margin-bottom: 20px; overflow: hidden;}
      a {float: left;height: 100px;width: 100px; overflow: hidden; margin-right:1%; position: relative;}
      a:before {
        content: attr(data-env);
        position: absolute;
        top: 0;
        left: 0;
        width: 100px;
        font-size: 30px;
        line-height: 100px;
        text-align: center;
        text-decoration: none;
        text-transform:lowercase;
        color: #000;
        background: #eee;
        opacity: .8;
      }
      a:nth-of-type(3):before {
        background: #C0392B;
        color: #fff;
      }
      img{max-width: 600px;}
    </style>
  </head>
  <body>
    {{#each compares}}
    <h2>{{@key}}</h2>
    <ul>
      {{#each this}}
      <li>
        <h3>{{@key}} {{this.analysisTime}}ms</h3>
        {{#each this.images}}
        <a href="data:image/png;base64,{{this}}" data-env="{{@key}}">
          <img src="data:image/png;base64,{{this}}"/>
        </a>
        {{/each}}
      </li>
      {{/each}}
    </ul>
    {{/each}}
  </body>
</html>
"""

module.exports = template