@echo off
chcp 65001 >nul

echo ============================================================
echo   TrendRadar MCP Server (HTTP 模式)
echo ============================================================
echo.

REM 检查虚拟环境
if not exist ".venv\Scripts\python.exe" (
    echo ❌ [错误] 虚拟环境未找到
    echo 请先运行 setup-windows.bat 或 setup-windows-en.bat 进行部署
    echo.
    pause
    exit /b 1
)

echo [模式] HTTP (适合远程访问)
echo [地址] http://localhost:3333/mcp
echo [提示] 按 Ctrl+C 停止服务
echo.

REM 检查是否设置了 token（优先使用环境变量）
if defined MCP_AUTH_TOKEN (
    echo [认证] Token 已启用（从环境变量读取）
    echo.
    uv run python -m mcp_server.server --transport http --host 0.0.0.0 --port 3333 --auth-token "%MCP_AUTH_TOKEN%"
) else (
    echo [认证] Token 未设置（如需启用，请设置环境变量: set MCP_AUTH_TOKEN=your-token）
    echo.
    uv run python -m mcp_server.server --transport http --host 0.0.0.0 --port 3333
)

pause
