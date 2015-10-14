#!/bin/sh
LOGSTASH=/Users/mertnuhoglu/projects/tools/logstash-1.5.4
GEM=./logstash-codec-evam-2.0.1.gem
$LOGSTASH/bin/plugin install $GEM
$LOGSTASH/bin/logstash -f evam06.conf
