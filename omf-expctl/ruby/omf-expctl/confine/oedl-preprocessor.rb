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
        end
        
        def defPrototype(refName, name = nil, &block)
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
        end
        
        def resource(resName)
        end
        
        def allGroups(&block)
        end
        
        def allNodes!(&block)
        end
        
        def defEvent(name, interval = 5, &block)
        end
        
        def onEvent(name, consumeEvent = false, &block)
        end
        
        def every(name, interval = 60, initial = nil, &block)
        end
        
        def everyNS(selector, interval = 60, &block)
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
                node.w0 = true
                puts node.nodeID + " " + (node.e0.to_s) +
                                         (node.e1.to_s) + 
                                         (node.w0.to_s) + 
                                         (node.w1.to_s)
            end
        end
        
        def get_binding
            binding
        end
    end
end
