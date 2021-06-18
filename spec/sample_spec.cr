require "./spec_helper"
require "../src/webserver"
require "uri"
require "http/client"
require "./model/*"

describe Sample::WebServer do

  describe "#port" do
    server = Sample::WebServer.new(330)
    it "correctly set port" do
      server.port.should eq 330
   end
  end

  describe "#Requests" do
      server = Sample::WebServer.new(33003)
      puts "Test WebServer port"
      it "correctly WebServer nto running" do
        server.port.should eq 33003
        server.running.should eq false
      end
      puts "Test WebServer get_post_put"
      it "correctly WebServer run" do
         spawn do
            server.run
         end
        sleep(3.seconds)
        server.port.should eq 33003
        server.running.should eq true
     end
     sleep(3.seconds)
     puts "Test WebServer get_post_put"
      it "correctly WebServer get_post_put" do
        response = HTTP::Client.get "http://localhost:33003"
        response.status_code.should eq 200
        response = HTTP::Client.post URI.new("http", "localhost",33003)
        response.status_code.should eq 200
        server.usersCount.should eq 0
        response = HTTP::Client.put("http://localhost:33003",  form: "action=add")
        response.status_code.should eq 200
        server.usersCount.should eq 1
        response = HTTP::Client.put("http://localhost:33003",  form: "action=delete")
        response.status_code.should eq 200
        server.usersCount.should eq 0
        response = HTTP::Client.put("http://localhost:33003",  form: "action=add")
        response.status_code.should eq 200
        server.usersCount.should eq 1
        response = HTTP::Client.put("http://localhost:33003",  form: "action=delete")
        response.status_code.should eq 200
        server.usersCount.should eq 0
        response = HTTP::Client.post URI.new("http", "localhost",33003)
        response.status_code.should eq 200
        server.usersCount.should eq 0
        response = HTTP::Client.put("http://localhost:33003",  form: "&12=add1")
        response.status_code.should eq 500
        server.usersCount.should eq 0
        response = HTTP::Client.put("http://localhost:33003",  form: "action1=delete")
        response.status_code.should eq 500
        server.usersCount.should eq 0
        response = HTTP::Client.put("http://localhost:33003",  form: "some=add")
        response.status_code.should eq 500
        server.usersCount.should eq 0
        response = HTTP::Client.put("http://localhost:33003",  form: "action=stop")
        response.status_code.should eq 200
        server.running.should eq false
     end
   end
end


