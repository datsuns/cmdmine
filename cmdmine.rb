
class RedcuineRunner
end


class CmdMine
	def self.run input
		params = input.split(' ')
		func = params[0]
		args = params[1..params.length]
		true
	end
end


begin
	print '> '
end while CmdMine.run gets.chomp
