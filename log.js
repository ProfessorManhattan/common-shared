const consola = require('consola')

const logger = consola.create({
  level: 5
})

const success = (message) => logger.success(message)
const info = (message) => logger.info(message)
const error = (message) => logger.error(message)
const warn = (message) => logger.warn(message)
const log = (message) => logger.log(message)
const fatal = (message) => logger.fatal(message)
const debug = (message) => logger.debug(message)
const trace = (message) => logger.trace(message)
const verbose = (message) => logger.verbose(message)

module.exports = { success, info, error, warn, log, fatal, debug, trace, verbose }
