--- FilterWords 功能说明
--- time:2023-05-17
--- author：zensyue
--- notes: 用于过滤敏感词

---@class FilterWords
local FilterWords = Aclass("FilterWords")

function FilterWords:ctor()
end

function FilterWords:dctor()
end

---@private
function FilterWords:createNode(c,flag,nodes)
    local node = {}
    node.c = c or nil           --字符
    node.flag = flag or 0       --是否结束标志 0:不是 1:是
    node.nodes = nodes or {}    --保存子节点
    return node
end


---@private
function FilterWords:insertNode(node,cs,index)
    local n = self:findNode(node,cs[index])
    if n == nil then
        n = self:createNode(cs[index])
        table.insert(node.nodes,n)
    end

    if index == #cs then
        n.flag = 1
    end

    index = index + 1
    if index <= #cs then
        self:insertNode(n,cs,index)
    end
end

---@private
function FilterWords:findNode(node,c)
    local nodes = node.nodes
    local rn = nil
    for i,v in ipairs(nodes) do
        if v.c == c then
            rn = v
            break
        end
    end
    return rn
end

---@private
function FilterWords:getCharArray(str)
    return string.utf8list(str)
end

function FilterWords:createTree(words)
    self.rootNode = self:createNode('R') -- 根节点  

    local len = #words
    local count = 0
    for i=1,len do
        local v = words[i]
        local chars = self:getCharArray(v)
        if #chars > 0 then
            self:insertNode(self.rootNode, chars, 1)
        end
        count = count + 1
    end
end

---@private
function FilterWords:toEndNode(chars,word,endNode,wordLen)
    if endNode then
        wordLen = wordLen or #word
        for i = 1, wordLen do
            local index = word[i]
            chars[index] = '*'
        end
        return true
    end
    return false
end

--- 返回安全字符
---@return string
function FilterWords:toSafe(inputStr)
    local chars = self:getCharArray(inputStr)
    local index = 1
    local node = self.rootNode
    local word = {}
    local endNode = nil
    local endIndex = nil
    local wordLen = 0

    while #chars >= index do
        if chars[index] ~= ' ' then
            node = self:findNode(node,chars[index])
        end

        if node == nil then
            --- 配置字库中没有找到,两种情况
            --- 1 已找到结束节点,调回上一个结束点+1重新匹配
            if self:toEndNode(chars,word,endNode,wordLen) then
                index = endIndex
            --- 2 则从上次结束的节点+1开始重新匹配
            else
                index = index - #word
            end
            endNode = nil
            endIndex = nil
            wordLen = 0
            node = self.rootNode
            if not table.isempty(word) then
                word = {}
            end
        else
            table.insert(word,index)
            if node.flag == 1 then
                -- 节点没有子节点,直接替换,下次直接从根节点开始
                if table.isempty(node.nodes) then
                    self:toEndNode(chars,word,node,wordLen)
                    node = self.rootNode
                else
                    endNode = node
                    endIndex = index + 1
                    wordLen = #word
                end
            end
        end
        index = index + 1
    end
    self:toEndNode(chars,word,endNode,wordLen)
    return table.concat(chars)
end

--- 是否为安全字符
---@return boolean
function FilterWords:isSafe(inputStr)
    local chars = self:getCharArray(inputStr)
    local index = 1
    local node = self.rootNode
    local toIndex = 0
    while #chars >= index do
        if chars[index] ~= ' ' then
            node = self:findNode(node,chars[index])
        end
        if node == nil then
            index = index - toIndex
            node = self.rootNode
            toIndex = 0
        elseif node.flag == 1 then
            return false
        else
            toIndex = toIndex + 1
        end
        index = index + 1
    end

    return true
end

return FilterWords
