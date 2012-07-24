require 'omf-expctl/handlerCommands'

class OMF::EC::Node < MObject
    attr_reader :w0
    attr_reader :w1
    
    attr_reader :e0
    attr_reader :e1
end

module Confine

    module Node
        def confineInit
            @e0 = @e1 = @w0 = @w1 = false
        end
    
        def configure path, value, status = 'Unknown'
            if path[0] == "net" && path[1] == 'w0'
                @w0 = true
            end
        end
    end

    class OEDLPreprocessor
        include Singleton
        include OMF::EC::NodeSetHelper
        
        def initialize
            @nodes = []
            
            puts "INITTING NODE"
        end
        
        def defProperty(name, defaultValue, description)
            ExperimentProperty.create(name, defaultValue, description)
        end
        
        #
        # Return the context for setting experiment wide properties
        #
        # [Return] a Property Context
        #
        def prop
            return PropertyContext
        end

        alias :property :prop
        
        def defTopology(refName, nodeArray = nil, &block)
            topo = Topology.create(refName, nodeArray)
            if (! block.nil?)
                block.call(topo)
            end
            return topo
        end
        
        def defPrototype(refName, name = nil, &block)
            p = Prototype.create(refName)
            p.name = name
        end
        
        def defGroup(groupName, selector = nil, &block)
            ns = selectNodeSet groupName, selector
            
            ns.each do |node|
                node.extend Node
                node.confineInit
                @nodes << node
            end
            
            return RootNodeSetPath.new(ns, nil, nil, block)
        end
        
        def group(groupName, &block)
            ns = NodeSet[groupName.to_s]
            if (ns == nil)
                return EmptyGroup.new
            end
            return RootNodeSetPath.new(ns, nil, nil, block)
        end
        
        def resource(resName)
        end
        
        def allGroups(&block)
            NodeSet.freeze
            ns = DefinedGroupNodeSet.instance
            return RootNodeSetPath.new(ns, nil, nil, block)
        end
        
        def allNodes!(&block)
        end
        
        def defEvent(name, interval = 5, &block)
        end
        
        def onEvent(name, consumeEvent = false, &block)
            if name != :EXPERIMENT_DONE
                yield
            end
        end
        
        def every(name, interval = 60, initial = nil, &block)
            yield block
        end
        
        def everyNS(selector, interval = 60, &block)
            ns = NodeSet[nodesSelector]
            if ns == nil
                raise "Every: Unknown node set '#{nodesSelector}"
            end
            path = RootNodeSetPath.new(ns)
            path.call &block
        end
        
        def antenna(x, y, precision = nil)
        end
        
        def msSenderName
        end
        
        def addTab(tName, opts = {}, &initProc)
        end
        
        def t1()
        end
        
        def wait(time)
        end
        
        def info(*msg)
        end
        
        def warn(*msg)
        end
        
        def error(*msg)
        end
        
        def quit()
        end
        
        def lsx(xpath = nil)
        end
        
        def ls(xpath = nil)
        end
        
        def printOverview
            @nodes.each do |node|
                puts node.nodeID + " " + (node.e0.to_s) +
                                         (node.e1.to_s) + 
                                         (node.w0.to_s) + 
                                         (node.w1.to_s)
            end
            
            confine = OMF::Services.confine
            response = confine.allocateSlice
            
            slice_el = response.elements.first
            if slice_el.name == "SLICE"
                id = slice_el.elements['SLICE_ID'].first
                domain = slice_el.elements['DOMAIN'].first
            else
                puts "ERROR " + slice_el.text
            end
            
            @nodes.each do |node|
                confine = OMF::Services.confine
                puts "Creating #{node.name.type}"
                g = confine.allocateSliverGroup( :sliceid => id, 
                                             :names => node.nodeID,
                                             :nwifi => 2.to_s,
                                             :neth => 2.to_s,
                                             :imageid => '0',
                                            )
                #x = g.elements.first 
                #puts x.inspect
                # puts x['SLIVER']['IP']
                puts "DONE"
            end
            
            File.open NodeHandler.PREFIX_FILE, 'w' do |f|
                f.write domain
            end
        end
        
        def get_binding
            binding
        end
    end
end
