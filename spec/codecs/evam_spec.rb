require "logstash/devutils/rspec/spec_helper"
require "logstash/codecs/evam"
require "logstash/event"
require "logstash/json"
require "insist"

describe LogStash::Codecs::Evam do
  subject do
    next LogStash::Codecs::Evam.new
  end
  # test case
  # subject = LogStash::Codecs::JSON.new

  context "#decode2" do
    it "should flatten nested json docs" do
      data = {"actor" => "003", "foo" => "bar", "baz" => {"bah" => ["a","b","c"]}}
      data = LogStash::Json.dump(data)
      subject.decode(data) do |event|
        puts event['message']
        insist { event.is_a? LogStash::Event }
        insist { event["message"] } == "a,scenario_type,event_type,foo,bar,baz_bah,c~"
      end
    end
  end

  context "#decode" do
    it "should return an event from data in evam event format" do
      data = {"foo" => "bar", "baz" => "hello"}
      data = LogStash::Json.dump(data)
      subject.decode(data) do |event|
        puts event['message']
        insist { event.is_a? LogStash::Event }
        insist { event["message"] } == "a,scenario_type,event_type,foo,bar,baz,hello~"
      end
    end
  end


  context "#encode" do
    it "should return json data" do
      data = {"foo" => "bar", "baz" => "hello"}
      event = LogStash::Event.new(data)
      got_event = false
      subject.on_event do |e, d|
        insist { d.chomp.include?("foo,bar,baz,hello") } == true
        got_event = true
      end
      subject.encode(event)
      insist { got_event }
    end
  end

  context "#encode2" do
    it "should convert json to evam syntax" do
      data = {"foo" => "bar", "baz" => "hello"}
      insist { data.map { |k, v| "#{k},#{v}" }.join(',') } == "foo,bar,baz,hello"
      data = {"foo" => "bar", "baz" => "hello"}
      data = {"bah" => ["a", "b", "c"]}
      data.map { |k, v| "#{k},#{v}" }.join(',')
    end
  end

end
