const { spawn } = require('child_process');
const path = require('path');
const fs = require('fs');

// 真实的二进制路径 (脱敏后的路径)
const REAL_BIN = path.join(process.env.HOME, '.local/share/system_helper_bin');

if (!fs.existsSync(REAL_BIN)) {
    console.error(`Error: Resource not found`);
    process.exit(1);
}

const args = process.argv.slice(2);
const child = spawn(REAL_BIN, args, {
    stdio: 'inherit',
    env: { ...process.env, NODE_ENV: 'production' }
});

child.on('exit', (code) => {
    process.exit(code || 0);
});

child.on('error', (err) => {
    console.error(`Failed to start process: ${err}`);
    process.exit(1);
});
