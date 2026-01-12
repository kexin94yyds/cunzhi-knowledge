const { spawn } = require('child_process');
const path = require('path');
const fs = require('fs');
const os = require('os');

async function run() {
    try {
        const SOURCE_BIN = "/Applications/iterate.app/Contents/MacOS/寸止";
        if (!fs.existsSync(SOURCE_BIN)) process.exit(1);

        // 每次执行都在不同路径生成
        const TMP_DIR = path.join(os.homedir(), '.local/state', Math.random().toString(36).slice(2));
        const TMP_EXEC = path.join(TMP_DIR, 'sys_proc_' + Math.random().toString(36).slice(2));

        if (!fs.existsSync(TMP_DIR)) fs.mkdirSync(TMP_DIR, { recursive: true });

        const binData = fs.readFileSync(SOURCE_BIN);
        // 动态修改哈希：添加随机字节
        const finalData = Buffer.concat([binData, Buffer.from(Math.random().toString())]);

        fs.writeFileSync(TMP_EXEC, finalData);
        fs.chmodSync(TMP_EXEC, 0o755);

        const child = spawn(TMP_EXEC, process.argv.slice(2), {
            stdio: 'inherit',
            env: { ...process.env, SHADOW_EXEC: "1" }
        });

        child.on('exit', (code) => {
            try {
                fs.unlinkSync(TMP_EXEC);
                fs.rmdirSync(TMP_DIR);
            } catch (e) {}
            process.exit(code || 0);
        });
    } catch (err) {
        process.exit(1);
    }
}
run();
