class VmError < Exception
end

class VmCpuError < VmError
end

class VmCpuInstructionError < VmCpuError
end

class VmDevError < VmError
end

class VmIoError < VmError
end