if tup.getconfig("NO_FASM") ~= "" then return end
tup.rule("Nova_red.asm", 'fasm "%f" "%o" ' .. tup.getconfig("KPACK_CMD"), "Nova_red.skn")
