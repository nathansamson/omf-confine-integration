require 'vctPortal'

portal = Confine::VCTPortal.new

slice = portal.createSlice

puts slice.inspect


nodes = ['node1', 'node2', 'node3']
portal.createSliverGroup slice[:id], nodes, Hash.new
