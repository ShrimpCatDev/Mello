require 'love_extensions'

local function testArgs()
    if love.arg.parseGameArguments(arg)[1] == "--test" then
        local fsutil = require 'libraries.FSUtil'
        local lust = require 'tests.tools.Lust'

        local selectedTest = love.arg.parseGameArguments(arg)[2]

        local tests = fsutil.scanFolder("tests/specs")
        local specs = {}

        if #tests <= 0 then
            printf("[Love.Test] : No tests to run!")
            love.event.quit()
        end

        for _, test in ipairs(tests) do
            local tn = test:match("([^/\\]+)%.[^.]+$")
            specs[tn] = require((test:gsub("/", ".")):gsub("%.lua", ""))
        end

        if type(selectedTest) == "string" then
            specs[selectedTest](lust)
        else
            for testName, spec in ipairs(specs) do
                print("Running spec for: " .. testName)
                spec(lust)
                print("------------------------------------------------------------------------")
            end
        end

        love.event.quit()

        return
    end
end

function love.load()
    testArgs()
end

function love.draw()

end

function love.update()

end
