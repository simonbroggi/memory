---@alias listElement entity

---@class List
---@field private size number
---@field onAdded function
---@field onRemoved function
local List = {}

local List_mt = {
    __index = List,
    __len = function(t) return t.size end,
}

---Adds an element to the List.
---@param e listElement must be of reference type and not the string 'size', 'onAdded' or 'onRemoved'
---@return List self
function List:add(e)
    local size = self.size + 1

    self[size] = e
    self[e] = size
    self.size = size

    if self.onAdded then self:onAdded(e) end
    return self
end

---Removes an element from the List.
---@param e listElement to remove
---@return List self
function List:remove(e)
    local index = self[e]
    if not index then return self end
    local size  = self.size

    if index == size then
        self[size] = nil
    else
        local other = self[size]

        self[index] = other
        self[other] = index

        self[size] = nil
    end

    self[e] = nil
    self.size = size - 1

    if self.onRemoved then self:onRemoved(e) end
    return self
end

---Clears the List completely.
---@return List self the empty list
function List:clear()
    for i = 1, self.size do
        local e = self[i]
        self[e] = nil
        self[i] = nil
    end
    self.size = 0
    return self
end

---Returns true if the List has the element e.
---@param e listElement to check for.
---@return boolean true if the List has the element.
function List:has(e)
    return self[e] and true or false
end

---Returns the element at an index.
---@param i number Index to get from.
---@return listElement e element the index i.
function List:get(i)
    return self[i]
end

---Returns the index of an element in the List.
---@param e listElement to get index of
---@return number index of object in the List.
function List:indexOf(e)
    if (not self[e]) then
        error("bad argument #1 to 'List:indexOf' (Object was not in List)", 2)
    end

    return self[e]
end

---Sorts the List in place, using the order function.
---The order function is passed to table.sort internally so documentation on table.sort can be used as reference.
---@param order function takes two Entities (a and b) and returns true if a should go before b.
---@return self List the ordered list
function List:sort(order)
    table.sort(self, order)

    for key, obj in ipairs(self) do
        self[obj] = key
    end

    return self
end

---Swaps the elements at the given indices.
---@param i1 number index of the first element.
---@param i2 number index of the second element.
---@return self List
function List:swap(i1, i2)
    --if i1 == i2 then return self end
    local o1, o2 = self[i1], self[i2]
    self[i1], self[i2] = self[i2], self[i1]
    self[o1], self[o2] = i2, i1
    return self
end

return List_mt