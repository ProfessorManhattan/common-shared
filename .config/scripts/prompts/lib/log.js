/* eslint-disable no-console, sonarjs/no-nested-template-literals */
import chalk from 'chalk'

/**
 * @param title
 * @param message
 */
export function logInstructions(title, message) {
  console.log(`\n${chalk.white.bgBlueBright.bold(`   ${title}   `)}`)
  console.log(`\n${message}\n`)
}
