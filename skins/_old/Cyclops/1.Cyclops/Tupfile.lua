if tup.getconfig("NO_FASM") ~= "" then return end
tup.rule("1.Cyclops.asm", 'fasm "%f" "%o" ' .. tup.getconfig("KPACK_CMD"), "1.Cyclops.skn")
