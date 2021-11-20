'use strict'

import chalk from 'chalk'

export function decorateSystem(name) {
  const lower = name.toLowerCase();
  if (lower.includes('archlinux')) {
    return chalk.cyan('●') + ' ' + name;
  } else if (lower.includes('centos')) {
    return chalk.purple('●') + ' ' + name;
  } else if (lower.includes('debian')) {
    return chalk.red('●') + ' ' + name;
  } else if (lower.includes('fedora')) {
    return chalk.blue('●') + ' ' + name;
  } else if (lower.includes('ubuntu')) {
    return chalk.orange('●') + ' ' + name;
  } else if (lower.includes('mac')) {
    return chalk.white('●') + ' ' + name;
  } else if (lower.includes('windows')) {
    return chalk.green('●') + ' ' + name;
  } else {
    return chalk.black('●') + ' ' + name;
  }
}
