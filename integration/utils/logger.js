const chalk = require('chalk');
const moment = require('moment');

module.exports = class Logger {
  static log(content, type = 'info') {
    const date = moment().format('YYYY-MM-DD HH:mm:ss');
    const timestamp = `[${date}]`;
    const message = String(content);

    // Define color scheme
    const colors = {
      info: {
        label: chalk.hex("#3498db"), // Bright blue
        time: chalk.hex("#3498db"),
        text: chalk.hex("#87CEEB")   // Sky blue
      },
      warn: {
        label: chalk.hex("#ffd966"), // Golden yellow
        time: chalk.hex("#ffd966"),
        text: chalk.hex("#ECC211")   // Darker yellow
      },
      error: {
        label: chalk.hex("#A61717"), // Deep red
        time: chalk.hex("#A61717"),
        text: chalk.hex("#620E0E")   // Darker red
      },
      success: {
        label: chalk.hex("#1FAC64"), // Green
        time: chalk.hex("#1FAC64"),
        text: chalk.hex("#1FAC64")   // Same green
      },
      debug: {
        label: chalk.hex("#d1006b"), // Pink/magenta
        time: chalk.hex("#d1006b"),
        text: chalk.hex("#d1006b")   // Same pink/magenta
      }
    };

    // Define emojis and paddings
    const logConfig = {
      info: {
        emoji: 'ℹ️',
        label: 'INFO',
        padding: '        '
      },
      warn: {
        emoji: '⚠️',
        label: 'WARNING',
        padding: '    '
      },
      error: {
        emoji: '❌',
        label: 'ERROR',
        padding: '      '
      },
      success: {
        emoji: '✅',
        label: 'SUCCESS',
        padding: '    '
      },
      debug: {
        emoji: '🔍',
        label: 'DEBUG',
        padding: '      '
      }
    };

    // Check if valid log type
    if (!colors[type]) {
      throw new TypeError(
        "Logger type must be either info, warn, error, success or debug."
      );
    }

    const config = logConfig[type];
    const color = colors[type];

    // Format and output log
    return console.log(
      `${color.label(
        `${config.emoji} ${config.label}${config.padding}${color.time(timestamp)} `
      )} ${color.text(message)}`
    );
  }

  // Convenience methods
  static info(content) {
    return this.log(content, 'info');
  }

  static warn(content) {
    return this.log(content, 'warn');
  }

  static error(content) {
    return this.log(content, 'error');
  }

  static success(content) {
    return this.log(content, 'success');
  }

  static debug(content) {
    return this.log(content, 'debug');
  }
}