

require "common.Aclass"

classcacheagent = require "common.classcacheagent".New()

dynamicload = require "common.dynamicload"

require "common.Ex.tableEx"
require "common.Ex.stringEx"
require "common.Ex.ioEx"
require "common.Ex.mathEx"

require "common.Ex.functions"

Timer = require "common.Time.Timer"
---@type Timer
g_Timer = Timer.New()
timeutil = require "common.Time.timeutil"


Tree = require "common.Tree.Tree"
TreeNode = require "common.Tree.TreeNode"

Event = require "common.Message.Event"
---@type Event
g_Event = Event.New()

SubscribeMgr = require "common.Message.Subscribe.SubscribeMgr"
---@type SubscribeMgr
g_SubscribeMgr = SubscribeMgr.New()
SubscribeType = require "common.Message.Subscribe.SubscribeType"
SubscribeNode = require "common.Message.Subscribe.SubscribeNode"
SubscribeGroup = require "common.Message.Subscribe.SubscribeGroup"


ReddotType = require "common.Message.Reddot.ReddotType"
ReddotTreeMgr = require "common.Message.Reddot.ReddotTreeMgr"
ReddotData = require "common.Message.Reddot.ReddotData"

---@type ReddotTreeMgr
g_ReddotTreeMgr = ReddotTreeMgr.New()

DelegateMgr = require "common.Delegate.DelegateMgr"
---@type DelegateMgr
g_DelegateMgr = DelegateMgr.New()
DelegateNode = require "common.Delegate.DelegateNode"

object = require "common.object"