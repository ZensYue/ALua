# ALua
lua常用方法，前后端可通用。



## Lua目录

具体使用方法可以参考[单元测试用例](https://github.com/ZensYue/ALua/tree/main/Lua/common/UnitTest)。

Lua

├── common

│···├── **BT** 行为树，带使用案例。

│···├── **Delegate** 委托。

│···├──  **Ex** 内置库table、string等扩展。

│···├── **Message** 消息包含事件、订阅、红点。

│···├── **Time** 时间模块包括常用时间方法，定时器。

│···├── **Tree** 树结构

│···├── **UnitTest** 单元测试

│···├── **Aclass.lua** 模拟面向对象、Reimport方法

│···├── **classcacheagent.lua** class缓存复用方法

│···├── **dynamicload.lua** 动态加载

│···└── **object.lua** 基础对象



## 文档

ALuaClient、ALuaServer 暂时不提供了，后续有空再写。有得选可以用全CSharp开发。

如果需要用到Lua开发，推荐：

1. 客户端：[XLua](https://github.com/Tencent/xLua)+[YooAsset](https://github.com/tuyoogame/YooAsset)
2. 服务端：[Skynet](https://github.com/cloudwu/skynet)、[Moon](https://github.com/sniper00/moon)
3. 工具：[luban](https://github.com/focus-creative-games/luban)。作者也有写Lua导表工具和协议代码生成工具，有需要私聊。



