import sys
import os
import subprocess

# MCP 二进制文件的真实路径
REAL_BIN = "/Applications/iterate.app/Contents/MacOS/寸止"

def main():
    if not os.path.exists(REAL_BIN):
        print(f"Error: Real binary not found at {REAL_BIN}", file=sys.stderr)
        sys.exit(1)
    
    # 将所有输入流、输出流和参数传递给真实的二进制文件
    try:
        process = subprocess.Popen(
            [REAL_BIN] + sys.argv[1:],
            stdin=sys.stdin,
            stdout=sys.stdout,
            stderr=sys.stderr
        )
        process.wait()
        sys.exit(process.returncode)
    except Exception as e:
        print(f"Proxy Error: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
