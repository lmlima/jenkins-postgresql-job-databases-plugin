require 'stringio'

class PostgreSQL

  class Error < RuntimeError
    attr_reader :out

    def initialize(out)
      @out = out
    end
  end

  attr_reader :launcher, :user, :password, :server, :port

  def initialize(launcher, user, password, server, port)
    @launcher = launcher
    @user     = user
    @password = password
    @server   = server
    @port     = port
  end

  def execute(command)
    out = StringIO.new()

    if launcher.execute("bash", "-c", "PGPASSWORD=#{password} psql postgres --host='#{server}' --port='#{port}' --username='#{user}' --command=\"#{command}\"", {:out => out}) != 0
      raise Error.new(out.string), 'PostgreSQL command failed'
    end

    out.string
  end
end
