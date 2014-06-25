module Puppet::Parser::Functions
    newfunction(:figlet_magic, :type => :rvalue) do |args|
	hostname = args[0]
	%x[/usr/bin/figlet -f doom #{hostname}]
    end
end
