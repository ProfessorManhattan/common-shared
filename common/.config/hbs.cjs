const glob = require("glob")

module.exports.register = function (Handlebars) {
  /**
   * Import [handlebars-helpers](https://github.com/helpers/handlebars-helpers)
   */
  require('handlebars-helpers')({
    handlebars: Handlebars
  });

  /**
   * Returns files/directories matching glob pattern
   */
  Handlebars.registerHelper('glob', function(pattern, options) {
    const files = glob.sync(pattern)

    return files
  })
}
