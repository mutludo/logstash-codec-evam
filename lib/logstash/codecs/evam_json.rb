# encoding: utf-8
require "logstash/codecs/base"
require "logstash/util/charset"
require "logstash/json"
require "csv"


# This codec may be used to decode (via inputs) and encode (via outputs)
# full JSON messages. If the data being sent is a JSON array at its root multiple events will be created (one per element).
#
# If you are streaming JSON messages delimited
# by '\n' then see the `json_lines` codec.
#
# Encoding will result in a compact JSON representation (no line terminators or indentation)
#
# If this codec recieves a payload from an input that is not valid JSON, then
# it will fall back to plain text and add a tag `_jsonparsefailure`. Upon a JSON
# failure, the payload will be stored in the `message` field.
class LogStash::Codecs::Evam < LogStash::Codecs::Base
  config_name "evam"

  # The character encoding used in this codec. Examples include "UTF-8" and
  # "CP1252".
  #
  # JSON requires valid UTF-8 strings, but in some cases, software that
  # emits JSON does so in another encoding (nxlog, for example). In
  # weird cases like this, you can set the `charset` setting to the
  # actual encoding of the text and Logstash will convert it for you.
  #
  # For nxlog users, you may to set this to "CP1252".
  config :charset, :validate => ::Encoding.name_list, :default => "UTF-8"

  config :scenario, :validate => :string, :required => true, :default => 'scenario_type'
  config :event, :validate => :string, :required => true, :default => 'event_type'
  config :actor, :validate => :string, :required => true, :default => 'actor'

  public
  def register
    @converter = LogStash::Util::Charset.new(@charset)
    @converter.logger = @logger
  end

  def unnest(dict)
    new_hash = {}
    dict.each do |key, val|
      if val.is_a?(Hash)
        new_hash.merge!(prefix_keys(val, "#{key}_"))
      elsif val.is_a?(Array)
        new_hash[key] = val[val.length-1]
      else
        new_hash[key] = val
      end
    end
    new_hash
  end

  def prefix_keys(dict, prefix)
    unnest(Hash[dict.map { |key, val| [prefix + key, val] }])
  end

  def evam2hash(evam)
    line = evam.chomp("~")
    arr = CSV.parse(line).flatten(1)
    arr = arr.slice(3, arr.length)
    if arr.length % 2 == 1
      raise 'evam event instance has odd number of key-value items'
    end
    h1 = Hash[*arr]
    h1
  end

  def ihash(h, actor_key)
    result = ''
    h.each_pair do |k, v|
      if v.is_a?(Hash)
        result = ihash(v, actor_key)
        if (result != '')
          return result
        end
      else
        if (actor_key == "#{k}")
          result = v
        end
      end
    end
    return result
  end

  def split_path(dict, path)
    keys = path.split('.')
    for k in keys
      dict = dict[k]
    end
    if dict.is_a?(String)
      return dict
    else
      return ''
    end
  end

  def find_actor(dict, actor_key)
    # ihash(dict, actor_key)
    split_path(dict, actor_key)
  end

  def hash2evam(dict)
    actor_id = find_actor(dict, @actor)
    params = 'a,' + actor_id + ',' + @scenario + ',' + @event
    # params = 'a,' + scenario + ',' + event
    pairs = unnest(dict).
        map { |k, v| "#{k},#{v}" }.
        join(',')
    evam = params + ',' + pairs + '~'
    evam
  end

  public
  def decode(data)
    data = @converter.convert(data)
    begin
      decoded = LogStash::Json.load(data)
      if decoded.is_a?(Array)
        decoded.each { |item| yield(LogStash::Event.new("message" => hash2evam(item))) }
      elsif decoded.is_a?(Hash)
        # is_a: tip soruyor
        yield LogStash::Event.new("message" => hash2evam(decoded))
      else
        @logger.info? && @logger.info("JSON codec received a scalar instead of an Arary or Object!", :data => data)
        yield LogStash::Event.new("message" => data, "tags" => ["_jsonparsefailure"])
      end
    rescue StandardError => e
      # This should NEVER happen. But hubris has been the cause of many pipeline breaking things
      # If something bad should happen we just don't want to crash logstash here.
      @logger.warn("An unexpected error occurred parsing input to JSON",
                   :input => data,
                   :message => e.message,
                   :class => e.class.name,
                   :backtrace => e.backtrace)
    end
  end

  # def decode

  public
  def event2evam(event)
    json = event.to_json
    dict = LogStash::Json.load(json)
    hash2evam(dict)
  end

  public
  def encode(event)
    @on_event.call(event, event2evam(event))
    # @on_event.call(event, "hello2")
    # @on_event.call(event, json2evam(event))
  end # def encode

end # class LogStash::Codecs::JSON
