cd ..
gem build logstash-codec-evam.gemspec
/Users/mertnuhoglu/projects/tools/logstash-1.5.4/bin/plugin install /Users/mertnuhoglu/projects/ruby/logstash_plugins/logstash-codec-evam/logstash-codec-evam-2.0.1.gem
cd examples
/Users/mertnuhoglu/projects/tools/logstash-1.5.4/bin/logstash -f $1
