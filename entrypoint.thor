#!/usr/bin/env ruby
require "bundler"
Bundler.require
Pathname.glob("lib/**.rb").each(&method(:load))

Entrypoint.start
