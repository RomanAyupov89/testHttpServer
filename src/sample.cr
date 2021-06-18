# TODO: Write documentation for `Sample`
require "kemal"
require "./webserver"
server = Sample::WebServer.new(33000)
server.run

server.printStart(server.port)


