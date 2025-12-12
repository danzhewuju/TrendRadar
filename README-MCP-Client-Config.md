# MCP 客户端配置指南

本文档详细说明如何配置各种 MCP 客户端以连接 TrendRadar MCP 服务器，特别是配置 Token 认证。

---

## 📋 目录

- [服务器端 Token 配置](#服务器端-token-配置)
- [客户端配置方法](#客户端配置方法)
  - [Cherry Studio](#cherry-studio)
  - [Claude Desktop](#claude-desktop)
  - [其他 MCP 客户端](#其他-mcp-客户端)
- [认证方式说明](#认证方式说明)
- [故障排查](#故障排查)

---

## 🔧 服务器端 Token 配置

### 方式一：环境变量（推荐）

**Linux/Mac:**
```bash
export MCP_AUTH_TOKEN="your-secret-token-here"
./start-http.sh
```

**Windows (PowerShell):**
```powershell
$env:MCP_AUTH_TOKEN="your-secret-token-here"
.\start-http.bat
```

**Windows (CMD):**
```cmd
set MCP_AUTH_TOKEN=your-secret-token-here
start-http.bat
```

### 方式二：命令行参数

直接修改启动脚本，添加 `--auth-token` 参数：

```bash
python -m mcp_server.server --transport http --host 0.0.0.0 --port 3333 --auth-token your-secret-token-here
```

### 验证 Token 已启用

启动服务器后，如果看到以下信息，说明 Token 认证已启用：

```
🔒 Token 认证: 已启用
💡 提示: 请在请求头中包含有效的 token
```

---

## 📱 客户端配置方法

### Cherry Studio

Cherry Studio 是一个图形化的 MCP 客户端，配置步骤如下：

#### 1. 打开设置

启动 Cherry Studio，点击右上角 ⚙️ **设置** 按钮

#### 2. 添加 MCP 服务器

在设置页面找到：**MCP** → 点击 **添加**

#### 3. 填写配置

**无 Token 认证（仅用于本地测试）:**
```
类型: streamableHttp
URL: http://localhost:3333/mcp
```

**有 Token 认证（推荐）:**

根据服务器端支持的认证方式，选择以下任一方式：

**方式一：Authorization Bearer 头（推荐）**

⚠️ **重要**：必须在 token 前面加上 `Bearer ` 前缀（注意 Bearer 后面有一个空格）！

```
类型: streamableHttp
URL: http://localhost:3333/mcp
Headers:
  Authorization: Bearer your-secret-token-here
```

或者使用 JSON 配置：
```json
{
  "url": "http://localhost:3333/mcp",
  "headers": {
    "Authorization": "Bearer your-secret-token-here"
  }
}
```

**方式二：X-API-Token 头（更简单，无需 Bearer 前缀）**

这种方式不需要 Bearer 前缀，直接使用 token 值即可：

```
类型: streamableHttp
URL: http://localhost:3333/mcp
Headers:
  X-API-Token: your-secret-token-here
```

或者使用 JSON 配置：
```json
{
  "url": "http://localhost:3333/mcp",
  "headers": {
    "X-API-Token": "your-secret-token-here"
  }
}
```

**方式三：查询参数（不推荐，仅用于测试）**
```
类型: streamableHttp
URL: http://localhost:3333/mcp?token=your-secret-token-here
```

> ⚠️ **注意**：如果 Cherry Studio 不支持自定义请求头，可能需要使用查询参数方式，但这不够安全，建议仅用于测试环境。

#### 4. 保存并启用

- 点击 **保存** 按钮
- 确保 MCP 服务器列表中的开关是 **开启** 状态 ✅

---

### Claude Desktop

Claude Desktop 使用 JSON 配置文件来管理 MCP 服务器。

#### 配置文件位置

**Mac:**
```
~/Library/Application Support/Claude/claude_desktop_config.json
```

**Windows:**
```
%APPDATA%\Claude\claude_desktop_config.json
```

#### 配置示例

**无 Token 认证:**
```json
{
  "mcpServers": {
    "trendradar": {
      "command": "uvx",
      "args": [
        "mcp-server-trendradar"
      ]
    }
  }
}
```

**有 Token 认证（HTTP 模式）:**

如果 Claude Desktop 支持 HTTP 传输和自定义请求头，可以这样配置：

```json
{
  "mcpServers": {
    "trendradar": {
      "url": "http://localhost:3333/mcp",
      "headers": {
        "Authorization": "Bearer your-secret-token-here"
      }
    }
  }
}
```

或者使用 X-API-Token 头：

```json
{
  "mcpServers": {
    "trendradar": {
      "url": "http://localhost:3333/mcp",
      "headers": {
        "X-API-Token": "your-secret-token-here"
      }
    }
  }
}
```

> ⚠️ **注意**：Claude Desktop 的 HTTP 传输支持可能因版本而异，请参考官方文档确认。

---

### 其他 MCP 客户端

对于其他 MCP 客户端，配置方式类似，主要需要：

1. **设置服务器 URL**: `http://your-server:3333/mcp`
2. **添加认证头**（如果服务器启用了 Token 认证）:
   - `Authorization: Bearer <token>` （推荐）
   - `X-API-Token: <token>` （备选）
   - 或在 URL 中添加查询参数 `?token=<token>` （不推荐）

---

## 🔐 认证方式说明

服务器端支持三种认证方式，按优先级排序：

### 1. Authorization Bearer 头（推荐）

**格式:**
```
Authorization: Bearer <token>
```

**优点:**
- 符合 OAuth 2.0 标准
- 大多数 HTTP 客户端都支持
- 安全性高

**示例:**
```bash
curl -H "Authorization: Bearer your-secret-token-here" \
     http://localhost:3333/mcp
```

### 2. X-API-Token 头

**格式:**
```
X-API-Token: <token>
```

**优点:**
- 简单直接
- 易于理解

**示例:**
```bash
curl -H "X-API-Token: your-secret-token-here" \
     http://localhost:3333/mcp
```

### 3. 查询参数（不推荐）

**格式:**
```
?token=<token>
```

**缺点:**
- Token 会出现在 URL 中，可能被记录到日志
- 安全性较低
- 仅建议用于测试环境

**示例:**
```bash
curl "http://localhost:3333/mcp?token=your-secret-token-here"
```

---

## 🔍 故障排查

### 问题 1: 客户端连接失败，返回 401 错误

**原因:** Token 认证失败

**常见错误示例：**
```json
// ❌ 错误：缺少 Bearer 前缀
{
  "headers": {
    "Authorization": "chingblxyh666888"
  }
}

// ✅ 正确：包含 Bearer 前缀
{
  "headers": {
    "Authorization": "Bearer chingblxyh666888"
  }
}

// ✅ 或者使用 X-API-Token（无需 Bearer 前缀）
{
  "headers": {
    "X-API-Token": "chingblxyh666888"
  }
}
```

**解决方案:**
1. 确认服务器端已启用 Token 认证（启动时看到 "🔒 Token 认证: 已启用"）
2. 检查客户端配置的 Token 是否与服务器端一致
3. **如果使用 Authorization 头，必须包含 `Bearer ` 前缀（注意 Bearer 后面有一个空格）**
4. 如果使用 X-API-Token 头，直接使用 token 值，无需 Bearer 前缀
5. 尝试使用其他认证方式（如 X-API-Token）来排除问题

### 问题 2: Cherry Studio 不支持自定义请求头

**解决方案:**
1. 使用查询参数方式（仅用于测试）: `http://localhost:3333/mcp?token=your-token`
2. 或者暂时禁用服务器端的 Token 认证（不推荐用于生产环境）

### 问题 3: 客户端无法连接到服务器

**检查清单:**
- [ ] 服务器是否正在运行？
- [ ] 服务器监听的地址和端口是否正确？
- [ ] 防火墙是否阻止了连接？
- [ ] URL 路径是否正确（应该是 `/mcp`）？

### 问题 4: Token 包含特殊字符导致认证失败

**解决方案:**
- 如果 Token 包含特殊字符，确保在配置文件中正确转义
- 建议使用简单的字母数字组合作为 Token

---

## 📝 最佳实践

1. **使用强 Token**: 使用足够长且随机的字符串作为 Token（建议至少 32 个字符）
2. **使用环境变量**: 不要在代码或配置文件中硬编码 Token
3. **优先使用 Bearer 认证**: 使用 `Authorization: Bearer` 头，符合标准
4. **定期更换 Token**: 定期更换 Token 以提高安全性
5. **仅在生产环境启用**: 本地开发可以暂时禁用 Token 认证

---

## 🔗 相关文档

- [README-Cherry-Studio.md](./README-Cherry-Studio.md) - Cherry Studio 完整部署指南
- [README.md](./README.md) - 项目主文档
- [MCP 协议规范](https://modelcontextprotocol.io/) - 官方 MCP 协议文档

---

## 💡 示例：完整的配置流程

### 服务器端

```bash
# 1. 设置 Token
export MCP_AUTH_TOKEN="my-super-secret-token-12345"

# 2. 启动服务器
./start-http.sh
```

### 客户端（Cherry Studio）

```
类型: streamableHttp
URL: http://localhost:3333/mcp
Headers:
  Authorization: Bearer my-super-secret-token-12345
```

### 测试连接

在 Cherry Studio 中输入：
```
帮我获取最新的新闻
```

如果配置成功，AI 会调用 TrendRadar 工具并返回新闻数据。

---

**需要帮助？** 如果遇到问题，请查看 [故障排查](#故障排查) 部分或提交 Issue。

