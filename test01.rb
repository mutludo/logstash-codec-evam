require "logstash/devutils/rspec/spec_helper"
require "lib/logstash/codecs/evam"
require "logstash/event"
require "logstash/json"

def test
	subject = LogStash::Codecs::Evam.new
	data = {"foo" => "bar", "baz" => "hello"}
	event = LogStash::Event.new(data)
	subject.on_event do |e, d|
		puts LogStash::Event.new(data).to_json
		puts d.chomp
		puts LogStash::Json.load(d)["foo"] == data["foo"]
	end
	subject.encode(event)
end

def f
	# subject = LogStash::Codecs::JSON.new
	data = {"foo" => "bar", "baz" => "hello"}
	s = data.map{|k,v| "#{k},#{v}"}.join(',') 
	puts data
	puts s
end

def event2evam(data)
	s = data.map{|k,v| "#{k},#{v}"}.join(',') 
	s
end

def g
	data = {"foo" => "bar", "baz" => "hello"}
	r = event2evam(data)
end

if __FILE__ == $0
  test
end
