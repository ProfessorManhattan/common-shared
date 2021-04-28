const consola = require('consola');

const success = (message) => consola.success(message);
const info = (message) => consola.info(message);
const error = (message) => consola.error(message);
const warn = (message) => consola.warn(message);
const log = (message) => consola.log(message);
const fatal = (message) => consola.fatal(message);
const debug = (message) => consola.debug(message);
const trace = (message) => consola.trace(message);
const verbose = (message) => consola.verbose(message);

module.exports = { success, info, error, warn, log, fatal, debug, trace, verbose };
