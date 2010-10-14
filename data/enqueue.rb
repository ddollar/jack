#!/usr/bin/env ruby

$:.unshift File.expand_path("../../lib", __FILE__)
require "jack"

Jack.enqueue("alpha.one", :foo => "bar.alpha.one")
Jack.enqueue("alpha.two", :foo => "bar.alpha.two")
Jack.enqueue("bravo.one", :foo => "bar.bravo.one")
Jack.enqueue("bravo.two", :foo => "bar.bravo.two")
Jack.enqueue("charlie.nohandler")
Jack.enqueue("delta.error")

include Jack
