---@diagnostic disable: need-check-nil
TaskManager = {}
TaskManager.__index = TaskManager

local isLocalLoggingEnabled = false;

function TaskManager:new(superSurvivor)
	CreateLogLine("TaskManager", isLocalLoggingEnabled, "function: TaskManager:new() called");
	local o = {}
	setmetatable(o, self)
	self.__index = self

	o.TaskUpdateCount = 0
	o.TaskUpdateLimit = 0
	o.parent = superSurvivor
	o.Tasks = {}
	o.TaskCount = 0
	o.Tasks[0] = nil
	o.CurrentTask = 0
	o.LastTask = 0
	o.LastLastTask = 0

	return o
end

function TaskManager:setTaskUpdateLimit(toValue)
	self.TaskUpdateLimit = toValue
	self.TaskUpdateCount = 0
end

function TaskManager:AddToTop(newTask)
	CreateLogLine("TaskManager", isLocalLoggingEnabled, "function: TaskManager:AddToTop() called");
	if (newTask == nil) then return false end

	self.LastLastTask = self.LastTask -- WIP - Cows: "LastTask" is undefined...
	self.LastTask = self:getCurrentTask()
	self.CurrentTask = newTask.Name

	if (self.LastTask == self.CurrentTask) then
		CreateLogLine("TaskManager", isLocalLoggingEnabled, "... possibly stuck in task loop ...");
	end
	if (self.LastLastTaskt == self.CurrentTask) then
		CreateLogLine("TaskManager", isLocalLoggingEnabled, "... possibly stuck in task loop ...");
	end

	self.TaskUpdateCount = 0
	for i = self.TaskCount, 1, -1 do
		self.Tasks[i] = self.Tasks[i - 1]
	end

	self.Tasks[0] = newTask

	self.TaskCount = self.TaskCount + 1
end

function TaskManager:AddToBottom(newTask)
	self.Tasks[self.TaskCount] = newTask
	self.TaskCount = self.TaskCount + 1
end

function TaskManager:Display()
	CreateLogLine("TaskManager", isLocalLoggingEnabled, "function: TaskManager:Display() called");
	for i = 1, self.TaskCount - 1 do
		if (self.Tasks[i] ~= nil) then
			CreateLogLine("TaskManager", isLocalLoggingEnabled, tostring(self.Tasks[i].Name));
		end
	end
end

function TaskManager:clear()
	-- Cows: Why do we need to force complete the tasks?
	for i = 1, self.TaskCount - 1 do -- before clearing run the force complete task of any task that has one
		if (self.Tasks[i] ~= nil) and (self.Tasks[i].ForceComplete ~= nil) then
			return self.Tasks[i]:ForceComplete()
		end
	end

	self.TaskCount = 0
	self.Tasks[0] = nil
end

function TaskManager:moveDown()
	while ((not self.Tasks[0]) or (self.Tasks[0]:isComplete() == true)) do
		if (self.Tasks[0] ~= nil) and (self.Tasks[0].OnComplete ~= nil) then self.Tasks[0]:OnComplete() end

		if (self.TaskCount <= 1) then
			self:clear()
			break
		else
			for i = 1, self.TaskCount - 1 do
				self.Tasks[i - 1] = self.Tasks[i]
			end
			self.TaskCount = self.TaskCount - 1
		end
	end

	self.TaskUpdateCount = 0

	return false
end

function TaskManager:getCurrentTask()
	if (self.Tasks[0] ~= nil) and (self.Tasks[0].Name ~= nil) then
		return self.Tasks[0].Name
	else
		return "None"
	end
end

function TaskManager:getTask()
	if (self.Tasks[0] ~= nil) then
		return self.Tasks[0]
	else
		return nil
	end
end

function TaskManager:getThisTask(index)
	if (self.Tasks[index] ~= nil) then
		return self.Tasks[index]
	else
		return nil
	end
end

function TaskManager:removeTaskFromName(thisName)
	for i = 1, self.TaskCount - 1 do
		if (self.Tasks[i] ~= nil) and (self.Tasks[i].Name == thisName) then
			if (self.Tasks[i].OnComplete) then self.Tasks[i]:OnComplete() end
			self.Tasks[i] = nil;
		end
	end
	return nil
end

function TaskManager:getTaskFromName(thisName)
	for i = 1, self.TaskCount - 1 do
		if (self.Tasks[i] ~= nil) and (self.Tasks[i].Name == thisName) then
			return self.Tasks[i];
		end
	end

	return nil;
end

function TaskManager:update()
	CreateLogLine("TaskManager", isLocalLoggingEnabled, "function: TaskManager:update() called");
	self = AIManager(self) -- WIP - Cows: THIS IS THE REFERENCE TO THE AI FOLDER FILES

	if (self == nil) then
		return
	end

	local currentTask = self:getCurrentTask();

	if (self.TaskUpdateLimit ~= 0) and (self.TaskUpdateLimit ~= nil) and (self.TaskUpdateCount > self.TaskUpdateLimit) then
		self.Tasks[0] = nil
		self:moveDown();

		CreateLogLine("TaskManager", isLocalLoggingEnabled,
			self.parent:getName() .. " stopped their task due to setTaskUpdateLimit"
		);
	elseif (self.Tasks[0] ~= nil)
		and (self.Tasks[0] ~= false)
		and (self.Tasks[0]:isComplete() == false) then
		self.Tasks[0]:update()
		self.TaskUpdateCount = self.TaskUpdateCount + 1
	else
		self:moveDown()
	end
end
