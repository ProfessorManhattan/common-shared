'use strict'

/* eslint-disable import/no-extraneous-dependencies, import/no-unresolved, node/no-missing-import */

import inquirer from 'inquirer'
import signale from 'signale'
import { decorateSystem } from './lib/decorate-system'

/**
 * Prompts the user for the operating system they wish to launch and test the
 * Ansible play against.
 */
async function promptForDesktop() {
  const choices = ['Archlinux', 'CentOS', 'Debian', 'Fedora', 'macOS', 'Ubuntu', 'Windows']
  const choicesDecorated = choices.map(choice => decorateSystem(choice))
  const response = await inquirer.prompt([
    {
      type: 'list',
      name: 'operatingSystem',
      message: 'Which desktop operating system would you like to test the Ansible play against?',
      choices: choicesDecorated
    }
  ])
  const env = response.operatingSystem.replace('● ', '').toLowerCase()

  return env
}

/**
 * Main script logic
 */
async function run() {
  signale.info(
    'Choose a desktop environment below to run the Ansible play on.' +
    ' After choosing, a VirtualBox VM will be created. Then, the Ansible play will run on the VM.' +
    ' After it is done, the VM will be left open for inspection. Please do get carried away' +
    ' ensuring everything is working as expected and looking for configuration optimizations that' +
    ' can be made. The operating systems should all be the latest stable release but might not always' +
    ' be the latest version.'
  )
  const env = await promptForDesktop()
  console.log(env)
}

run()
