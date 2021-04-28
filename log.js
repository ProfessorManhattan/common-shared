const consola = require('consola');

const success = (message) => consola.success(message);
const info = (message) => consola.info(message);
const error = (message) => consola.error(message);
const warn = (message) => consola.warn(message);
const log = (message) => consola.log(message);

module.exports = { success, info, error, warn, log };
