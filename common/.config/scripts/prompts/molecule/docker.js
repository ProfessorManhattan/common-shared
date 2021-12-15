import inquirer from 'inquirer'
import { execSync } from 'node:child_process'
import { decorateSystem } from '../lib/decorate-system.js'
import { logInstructions, LOG_DECORATOR_REGEX } from '../lib/log.js'

/**
 * Prompts the user for environment group they wish to target
 *
 * @returns {string} The operating system string, lowercased
 */
async function promptForGroup() {
  const groups = JSON.parse(execSync("yq eval -o=j '.groups' molecule/docker/molecule.yml"))
  const choices = Object.keys(groups).map(key => key.padEnd(24) + chalk.gray(groups[key]))
  const choicesDecorated = choices.map((choice) => decorateSystem(choice))
  const response = await inquirer.prompt([
    {
      choices: choicesDecorated,
      message: 'Which environment(s) would you like to run the test on?',
      name: 'group',
      type: 'list'
    }
  ])

  const DECORATION_LENGTH = 2

  return response.group.replace(LOG_DECORATOR_REGEX, '')
    .toLowerCase().slice(DECORATION_LENGTH).split(" ")[0]
}

/**
 * Main script logic
 */
async function run() {
  logInstructions(
    'Ansible Molecule Test via Docker',
    'Choose a container group from the options below to begin the Molecule test.' +
      ' The choices should be mostly self-explanatory. The `Snap` group is a special group' +
      ' that should be used to test roles that contain `snap` logic. Only recent versions of Debian' +
      ' and Ubuntu support snap installations inside a Docker container. Docker tests are a quick way' +
      ' to test Ansible plays without consuming a large amount of system resources. Granted, to fully' +
      ' test an Ansible play, a VirtualBox method should be used instead.'
  )
  const group = await promptForGroup()
  execSync(`task ansible:test:molecule:virtualbox:converge:cli -- ${group}`, { stdio: 'inherit' })
}

run()
