#!/usr/bin/env ruby

class TerminalServer
  attr_accessor :servername

  def self.servers
    @servers ||= []
  end

  def self.servers_for_user(username)
    servers.find_all{|ts| ts.has_user? username }
  end

  def self.prompt_for_server(username)
    require 'readline'

    servers         = servers_for_user(username)

    if servers.length > 1
      puts "This user is logged into multiple servers. Please select which session you would like to shadow from the list below:"
      servers.each_with_index do |server, index|
        puts "\t#{index + 1}. #{server.servername.ljust(20)}\t(#{server.sessions[username][:state]})"
      end

      response = Readline.readline("> ", true)

      servers[response.to_i - 1]
    else
      servers.first
    end
  end

  def self.execute_user_command(username, command, options = '')
    if selected_server = prompt_for_server(username)
      selected_server.send(:execute_user_command, username, command, options)
    elsif servers_for_user(username).length > 0
      puts "Sorry I didn't understand your server selection."
    else
      puts "I'm sorry that user wasn't found."
    end
  end

  def self.shadow_user(username)
    execute_user_command(username, 'shadow')
  end

  def self.disconnect_user(username)
    execute_user_command(username, 'tsdiscon')
  end

  def self.logoff_user(username)
    execute_user_command(username, 'logoff')
  end

  def self.reset_user(username)
    execute_user_command(username, 'reset session')
  end

  def self.message_user(username, message)
    execute_user_command(username, 'msg', message)
  end

  def initialize(servername, options={})
    @servername = servername

    self.class.servers << self
  end

  def sessions
    @sessions ||= load_sessions
  end

  def load_sessions
    output = `query user /SERVER:#{@servername}`
    sessions = Hash.new

    output.split("\n").each do |line|
      next if line =~ /USERNAME/

      fields = line.split(/\s{2,}/)
      sessions[fields[0].strip.downcase] = {
        :username     => line[1,23].strip,
        :session_name => line[23,19].strip,
        :session_id   => line[41,3].strip,
        :state        => line[46,10].strip,
        :idle_time    => line[55,8].to_i,
        :login_time   => line[65,25].strip
      }
    end

    sessions
  end

  def has_user?(username)
    !!sessions[username.strip.downcase]
  end

  def execute_user_command(username, command, options = '')
    return false unless sessions[username.strip.downcase][:session_id] =~ /\d+/

    session_id = sessions[username.strip.downcase][:session_id]

    `#{command} #{session_id} /SERVER:#{@servername} #{options}`
  end

  def shadow_user(username)
    execute_user_command(username, 'shadow')
  end

  def disconnect_user(username)
    execute_user_command(username, 'tsdiscon')
  end

  def logoff_user(username)
    execute_user_command(username, 'logoff')
  end

  def reset_user(username)
    execute_user_command(username, 'reset session')
  end

  def message_user(username, message)
    execute_user_command(username, 'msg', message)
  end
end

if __FILE__ == $PROGRAM_NAME
  require 'optparse'

  options = {:servers => []}

  option_parser = OptionParser.new do |opts|
    opts.on('-a','--all', 'List all users on all servers.') do
      options[:all] = true
    end

    opts.on('--server-file FILENAME', 'Read list of servers from a file (each servername should be on a single line).') do |filename|
      options[:servers] << File.read(filename).split("\n")
    end

    opts.on('--server SERVERNAME', 'Initialize a server instance.') do |servername|
      options[:servers] << servername
    end

    opts.on('-u USER','--user USER', 'List or shadow for a specific user only.') do |user|
      options[:user] = user
    end

    opts.on('-s','--shadow', 'Shadow a user. (requires --user)') do
      options[:shadow] = true
    end

    opts.on('-r','--reset', 'Terminate a users session immediately.  (requires --user)') do
      options[:reset] = true
    end

    opts.on('-l','--logoff', 'Logoff a users session.  (requires --user)') do
      options[:logoff] = true
    end

    opts.on('-d','--disconnect', 'Disconnect a users session.  (requires --user)') do
      options[:disconnect] = true
    end

    opts.on('-m MESSAGE','--message MESSAGE', 'Message a single user or all users.  (requires --user or --all)') do |message|
      options[:message] = message
    end

    opts.on('-v','--verbose') do
      options[:verbose]
    end
  end

  option_parser.parse!

  if options[:all] || options[:user]
    options[:servers].each do |name|
      TerminalServer.new(name)
    end
  end

  if options[:user] && options[:shadow]
    TerminalServer.shadow_user(options[:user])
  elsif options[:user] && options[:logoff]
    TerminalServer.logoff_user(options[:user])
  elsif options[:user] && options[:reset]
    TerminalServer.reset_user(options[:user])
  elsif options[:user] && options[:logoff]
    TerminalServer.logoff_user(options[:user])
  elsif options[:user] && options[:disconnect]
    TerminalServer.disconnect_user(options[:user])
  elsif options[:user] && options[:message]
    TerminalServer.message_user(options[:user], options[:message])
  elsif options[:all] && options[:message]
    TerminalServer.servers.each do |ts|
      ts.sessions.each do |username, details|
        ts.message_user(username, options[:message])
      end
    end
  elsif options[:user]
    servers = TerminalServer.servers_for_user(options[:user])
    puts "The user is logged into the following servers:"
    servers.each do |server|
      puts "\t#{ts.servername.ljust(25)}(#{ts.sessions[options[:user]][:state]})"
    end
  elsif options[:all]
    TerminalServer.servers.each do |ts|
      puts "Server: #{ts.servername}"
      ts.sessions.each do |username, details|
        puts "\t#{username.ljust(20)}\t#{details[:session_id]}"
      end
    end
  else
    puts option_parser.help
  end
end