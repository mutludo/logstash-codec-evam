require "logstash/devutils/rspec/spec_helper"
require "lib/logstash/codecs/evam"
require "logstash/event"
require "logstash/json"
require "csv"

def ihash3(h, actor_key)
  memo = ''
  h.each_pair do |k, v|
    if v.is_a?(Hash)
      result = ihash3(v, actor_key)
      if (result != '')
        memo = result
      end
    else
      if (actor_key == "#{k}")
        memo = v
      end
    end
  end
  return memo
end

def ihash2(h, actor_key)
  actor_id = h.reduce("") { |memo, (key, val)| memo = val if key == actor_key }
  return actor_id
end

def ihash(h, actor_key)
  h.each_pair do |k, v|
    if v.is_a?(Hash)
      # puts "key: #{k} recursing..."
      ihash(v, actor_key)
    else
      # MODIFY HERE! Look for what you want to find in the hash here
      if (actor_key == "#{k}")
        puts "key: #{k} value: #{v}"
        return v
      end
    end
  end
end

def test_hash_reduce
  data = {"a" => 10, "b" => 20}
  data.reduce(0) { |memo, (key, val)| memo += val }
  data.reduce(0) { |memo, (key, val)| memo }
  data.reduce(0) { |memo, (key, val)|
    if (true)
      memo += val
    end
  }
  data.reduce(0) { |memo, (key, val)|
    if (key == "b")
      memo += val
    end
  }
  data.reduce(0) { |memo, (key, val)|
    if (key == "b")
      memo = val
    end
  }
  data.reduce(0) { |memo, (key, val)|
    if (key == "b")
      memo = key
    end
  }
  b = "b"
  data.reduce(0) { |memo, (key, val)|
    if (key == b)
      memo = key
    end
  }
  b = "actor"
  data = {"actor" => "001", "foo" => "bar", "baz" => {"bah" => ["a", "b", "c"]}}
  data.reduce(0) { |memo, (key, val)|
    if (key == b)
      memo = key
    end
  }
  b = "actor"
  data = {"a" => 10, "actor" => 20}
  data.reduce(0) { |memo, (key, val)|
    if (key == b)
      memo = val
    end
  }
  b = "actor"
  data = {"a" => 10, "b" => {"actor" => 20} }
  data.reduce(0) { |memo, (key, val)|
    if (key == b)
      memo = val
    end
  }
end

def test_find_key_in_hash
  data = {"a" => {"actor" => "001"}, "foo" => "bar", "baz" => {"bah" => ["a", "b", "c"]}}
  # ihash(data, "actor")
  # ihash2(data, "actor")
  ihash3(data, "actor")
end

def find_actor(dict, actor_path)
  actor_id = dict[actor_path]
  actor_id
end

def test_actor
  data = {"actor" => "001", "foo" => "bar", "baz" => {"bah" => ["a", "b", "c"]}}
  puts find_actor(data, "actor")
end

def test_flattening
  subject = LogStash::Codecs::Evam.new
  data = {"foo" => "bar", "baz" => {"bah" => ["a", "b", "c"]}}
  json = LogStash::Json.dump(data)
  subject.decode(json) { |event| puts event['message'] }
end

def unnest(hash)
  new_hash = {}
  hash.each do |key, val|
    if val.is_a?(Hash)
      new_hash.merge!(prefix_keys(val, "#{key}_"))
    elsif val.is_a?(Array)
      new_hash[key] = val[-1]
    else
      new_hash[key] = val
    end
  end
  new_hash
end

def prefix_keys(hash, prefix)
  unnest(Hash[hash.map { |key, val| [prefix + key, val] }])
end

def flatten_nested_hash
  data = {"foo" => "bar", "baz" => {"bah" => ["a", "b", "c"]}}
  unnest(data)
end

def hash2evam
  subject = LogStash::Codecs::Evam.new
  data = {"foo" => "bar", "baz" => "hello"}
  event = LogStash::Event.new(data)
  subject.on_event do |e, d|
    json = LogStash::Event.new(data).to_json
    puts e
    puts event
    puts e.equal?(event) # true
    puts json
    puts d.chomp
    puts LogStash::Json.load(d)["foo"] == data["foo"]
  end
  subject.encode(event)
  data.map { |k, v| "#{k},#{v}" }.join(',')
  # error: map is undefined for Event
  # event.map{|k,v| "#{k},#{v}"}.join(',')
  # converting event object to hash
  json = event.to_json
  hash = LogStash::Json.load(json)
  evam = hash.map { |k, v| "#{k},#{v}" }.join(',')
end

def f
  # subject = LogStash::Codecs::JSON.new
  data = {"foo" => "bar", "baz" => "hello"}
  s = data.map { |k, v| "#{k},#{v}" }.join(',')
  puts data
  puts s
end

def event2evam(data)
  s = data.map { |k, v| "#{k},#{v}" }.join(',')
  s
end

def g
  data = {"foo" => "bar", "baz" => "hello"}
  r = event2evam(data)
end

def array2hash
  # http://stackoverflow.com/questions/39567/what-is-the-best-way-to-convert-an-array-to-a-hash-in-ruby
  a1 = ['apple', 1, 'banana', 2]
  h1 = Hash[*a1.flatten(1)]
  puts "h1: #{h1.inspect}"
end

def csv2array
  # http://stackoverflow.com/questions/4673358/split-a-csv-style-string-with-ruby
  csv_string = "apple,1,banana,2"
  arr = CSV.parse(csv_string).flatten(1)
end

def evamcsv2hash
  line = "a,scenario1,event_type1,apple,1,banana,2~".chomp("~")
  arr = CSV.parse(line).flatten(1)
  arr = arr.slice(3, arr.length)
  if arr.length % 2 == 1
    raise 'evam event instance has odd number of key-value items'
  end
  h1 = Hash[*arr]
end

if __FILE__ == $0
  test_find_key_in_hash
  # hash2evam
  # array2hash
  # csv2array
end
