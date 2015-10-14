# What is logstash-codec-evam

logstash-codec-evam transforms a json formatted input into evam event format.

# How to install

Open a terminal and run:

	$LOGSTASH/bin/plugin install $GEM

$LOGSTASH is the root directory of logstash installation.

$GEM is the path to the logstash-codec-evam.gem file

# How to run

There is a sample configuration file to run: evam06.conf

The name of codec plugin is `evam`. It receives two parameters: `scenario` and `event`.

	codec => evam{
		scenario => 'scenario_type'
		event => 'event_type'
	}





