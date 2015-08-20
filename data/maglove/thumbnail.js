var system = require("system");
var fs = require('fs');
var TypeShot = (function() {
  TypeShot.prototype.page = null;
  TypeShot.prototype.html = null;
  TypeShot.prototype.logger = null;

  TypeShot.prototype.options = {
    logFile: 'phantom.log',
    format: 'JPG',
    width: 960,
    height: 1280,
    zoomFactor: 1,
    timeout: 60000
  };

  function TypeShot(html, options) {
    this.html = html;
    this.options = this.extend(this.options, options);
    this.setupLogger();
    this.setupPhantom();
    this.setupPage();
  }

  TypeShot.prototype.setupLogger = function() {
    var logPath = this.options.logPath;
    this.logger = {
      clear: function() {
        fs.write(logPath, "", 'w');
      },
      info: function(msg) {
        fs.write(logPath, msg + "\n", 'a');
      },
      error: function(msg, trace) {
        fs.write(logPath, msg + "\n", 'a');
        if(trace) {
          for(var i=0; i<trace.length; i++) {
            fs.write(logPath, "-- " + trace[i].file + ":" + trace[i].line + "\n", 'a');
          }
        }
      }
    };
    this.logger.clear();
  },

  TypeShot.prototype.setupPhantom = function() {
    return phantom.onError = (function(_this) {
      return function(msg, trace) {
        _this.logger.error(msg, trace);
        return _this.exit(false);
      };
    })(this);
  };

  TypeShot.prototype.setupPage = function() {
    this.page = require("webpage").create();
    this.page.settings.userAgent = this.options.userAgent;
    this.page.viewportSize = {
      width: this.options.width,
      height: this.options.height
    };
    this.page.clipRect = {
      top: 0,
      left: 0,
      width: this.options.width,
      height: this.options.height
    };
    this.page.zoomFactor = this.options.zoomFactor
    this.page.customHeaders.url = this.options.customHeaderUrl;
    this.page.onLoadFinished = (function(_this) {
      return function(status) {
        var loaded;
        var logger = _this.logger;
        _this.logger.info('page loaded');
        loaded = _this.page.evaluate(function() {
          if(document.body) {
            document.body.style["background-color"] = "#FFFFFF";
            document.body.style["min-height"] = "100%";
            return true;
          }else{
            return false;
          }
        });
        if (status === "success" || loaded === true) {
          return setTimeout(function() {
            return _this.render();
          }, 1000);
        }
      };
    })(this);
    this.page.onError = (function(_this) {
      return function(msg, trace) {
        _this.logger.error(msg, trace);
      };
    })(this);
    return this.page.onInitialized = (function(_this) {
      return function() {
        return _this.page.customHeaders.Referer = "http://localhost:3001";
      };
    })(this);
  };

  TypeShot.prototype.run = function() {
    setTimeout((function(_this) {
      return function() {
        _this.logger.error("Timeout of " + (_this.options.timeout / 1000) + " seconds reached")
        return _this.exit(false);
      };
    })(this), this.options.timeout);
    return this.page.setContent(this.html, this.options.referrer);
  };

  TypeShot.prototype.render = function() {
    var result;
    result = this.page.evaluate(function() {
      result = {};
      if ((typeof document !== "undefined" && document !== null ? document.title : void 0) != null) {
        result.title = document.title;
      }
      return result;
    });
    this.logger.info('page evaluated');
    if (!result.width) {
      delete result.width;
    }
    this.page.render('/dev/stdout', { format: this.options.format, quality: 100 })
    this.logger.info('page saved');
    return phantom.exit(true);
  };

  TypeShot.prototype.exit = function(success) {
    if (success) {
      phantom.exit(0);
    }else{
      fs.write('/dev/stdout', "ERROR", 'a');
      phantom.exit(1);
    }
  };

  TypeShot.prototype.extend = function(object, properties) {
    var key, val;
    for (key in properties) {
      val = properties[key];
      object[key] = val;
    }
    return object;
  };

  return TypeShot;

})();

var ts = new TypeShot(atob(system.args[2]), {
  logPath: system.args[1],
  format: system.args[3],
  width: system.args[4],
  height: system.args[5],
  zoomFactor: system.args[6]
});
ts.run();
