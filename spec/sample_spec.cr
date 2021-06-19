require "./spec_helper"
require "../src/webserver"
require "uri"
require "http/client"
require "./model/*"
PORTCHECK =   330
PORT      = 33003
enum Address
  Http
  Local
end
enum Actions
  Add
  Delete
  Stop
  WrongAdd
  WrongDel
  WrongAdd1
end

def address_to_text(address : Address)
  case address
  when Address::Http
    "http://localhost:33003"
  when Address::Local
    "localhost"
  else
    raise "unknown address: #{address}"
  end
end

def actions_to_text(action : Actions)
  case action
  when Actions::Add
    "action=add"
  when Actions::Delete
    "action=delete"
  when Actions::Stop
    "action=stop"
  when Actions::WrongAdd
    "&12=add1"
  when Actions::WrongDel
    "action1=delete"
  when Actions::WrongAdd1
    "some=add"
  else
    raise "unknown action: #{action}"
  end
end

describe Sample::WebServer do
  describe "#port" do
    server = Sample::WebServer.new(PORTCHECK)
    it "correctly set port" do
      server.port.should eq PORTCHECK
    end
  end

  describe "#Requests" do
    server = Sample::WebServer.new(PORT)
    puts "Test WebServer port"
    it "correctly WebServer nto running" do
      server.port.should eq PORT
      server.running.should eq false
    end
    puts "Test WebServer run"
    it "correctly WebServer run" do
      spawn do
        server.run
      end
      sleep(2.seconds)
      server.port.should eq PORT
      server.running.should eq true
    end
    sleep(2.seconds)
    puts "Test WebServer get_post_put"
    it "correctly WebServer get_post_put" do
      response = HTTP::Client.get address_to_text(Address::Http)
      response.status_code.should eq HTTP::Status::OK.code
      response = HTTP::Client.post URI.new("http", address_to_text(Address::Local), PORT)
      response.status_code.should eq HTTP::Status::OK.code
      server.usersCount.should eq 0
      response = HTTP::Client.put(address_to_text(Address::Http), form: actions_to_text(Actions::Add))
      response.status_code.should eq HTTP::Status::OK.code
      server.usersCount.should eq 1
      response = HTTP::Client.put(address_to_text(Address::Http), form: actions_to_text(Actions::Delete))
      response.status_code.should eq HTTP::Status::OK.code
      server.usersCount.should eq 0
      response = HTTP::Client.put(address_to_text(Address::Http), form: actions_to_text(Actions::Add))
      response.status_code.should eq HTTP::Status::OK.code
      server.usersCount.should eq 1
      response = HTTP::Client.put(address_to_text(Address::Http), form: actions_to_text(Actions::Delete))
      response.status_code.should eq HTTP::Status::OK.code
      server.usersCount.should eq 0
      response = HTTP::Client.post URI.new("http", address_to_text(Address::Local), PORT)
      response.status_code.should eq HTTP::Status::OK.code
      server.usersCount.should eq 0
      response = HTTP::Client.put(address_to_text(Address::Http), form: actions_to_text(Actions::WrongAdd))
      response.status_code.should eq HTTP::Status::INTERNAL_SERVER_ERROR.code
      server.usersCount.should eq 0
      response = HTTP::Client.put(address_to_text(Address::Http), form: actions_to_text(Actions::WrongDel))
      response.status_code.should eq HTTP::Status::INTERNAL_SERVER_ERROR.code
      server.usersCount.should eq 0
      response = HTTP::Client.put(address_to_text(Address::Http), form: actions_to_text(Actions::WrongAdd1))
      response.status_code.should eq HTTP::Status::INTERNAL_SERVER_ERROR.code
      server.usersCount.should eq 0
      response = HTTP::Client.put(address_to_text(Address::Http), form: actions_to_text(Actions::Stop))
      response.status_code.should eq HTTP::Status::OK.code
      server.running.should eq false
    end
    puts "Test WebServer done"
  end
end
