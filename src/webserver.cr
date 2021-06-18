# TODO: Write documentation for `Sample`
require "kemal"
require "./models/*"
module Sample
  class WebServer
   @@users = [] of User
   @@running : Bool = false


   def initialize(@port : Int32)
      end
    def port
       @port
    end
    def running
       @@running
    end
    def usersCount
        @@users.size
    end
    def printStart(port : Int32)
       puts "Listen port = "+ port.to_s
    end
    get "/" do
      printRequest("GET")
      getHandler
    end
    post "/" do |env|
      printRequest("POST")
      postHandler
    end

    put "/" do |env|
     printRequest (env.params.body.to_s)
     case env.params.body["action"]
     when "delete"
       puts "delete"
       deleteHandler
     when "add"
       puts "add"
       addHandler
     when "stop"
       puts "stop"
       stopHandler
     else
       getError
     end
    end
    def run
       @@running=true
       Kemal.run(@port)
    end

   def self.postHandler
      indent = "\n"
      count = "User count = " + @@users.size.to_s + indent
      count + indent + "Users = " +  @@users.to_s + indent
   end

  def self.getHandler
      "Usage:
      default port=33000
      1) curl -X GET http://localhost:port for get usage
      1) curl -X POST http://localhost:port for get users count
      2) curl -X PUT -d \"action=add\" localhost:port for add to user
      3) curl -X PUT -d \"action=delete\" localhost:port for delete user
      4) curl -X PUT -d \"action=stop\" localhost:port for stop server
      \n"
  end

  def self.deleteHandler
      indent = "\n"
      if @@users.size > 0
       removeName =  @@users.last().name
       @@users.pop()
       "Remove user" + removeName  + indent
      else
        "No users for delete" + indent
      end
  end

  def self.addHandler
      user = User.new("UserName" + @@users.size.to_s)
      @@users.push(user)
      indent = "\n"
      "Add user = " + user.name + indent + @@running.to_s
  end

  def self.stopHandler
      Kemal.stop()
      @@running=false
  end

  def self.getError
      "Unsupported query!\n"
  end

  def self.printRequest(data : String)
    indent = "\n"
    puts "Request!  = " + data + indent
  end

  end
end


