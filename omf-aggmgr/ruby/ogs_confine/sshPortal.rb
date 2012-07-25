require 'net/ssh'

module Confine
	class SSHPortal
	    NODES_AVAILABLE = {
	                        "abba" => '143.129.77.57', 
	                        "abbb" => '143.129.77.45',
	                       }
	    SSH_PUB_FILE = "/var/lib/vct/keys/id_rsa.pub"
	    DOMAIN_PREFIX = 'confine.pats.ua'
	    SLIVER_PREFIX = '0123456789'
	
	    def initialize
	        @slices = Hash.new
	        @sliceId = 141
	    end
	    
	    def createSlice
	        result = Hash.new
	        slice_id = hexy (@sliceId += 1)
			result[:id] = slice_id
			result[:testbed] = "#{result[:id]}.#{DOMAIN_PREFIX}"
			
			puts slice_id
			puts "dDIE"
			internal_slice = Hash.new
			internal_slice[:info] = result
			internal_slice[:available_nodes] = NODES_AVAILABLE.clone
			internal_slice[:z] = 0
			@slices[slice_id] = internal_slice
			result
	    end
	    
	    def createSliverGroup(short_slice_id, names, opts)
	        # Ignore opts for now :p
	        
	        slice = @slices[short_slice_id]
	        
	        if slice == nil
	            puts @slices.inspect
	            raise ArgumentError.new "Slice not found"
	        end
	        
            slice_id = SLIVER_PREFIX + short_slice_id
            sliver_config = generate_sliver_config slice_id
            
            slivers = []
            
	        names.each do |hostname|
	            name, ip = pick_node slice[:available_nodes]
	            sliver_id = slice_id + "_#{name}"
	            
	            Net::SSH.start(ip, 'root', :password => 'confine') do |ssh|
	                channel = ssh.open_channel do |ch|
	                    ch.exec "confine_sliver_allocate #{slice_id}" do  |ch, success|
	                        stdout = stderr = ''
	                        ch.send_data sliver_config
	                        ch.eof!
	                        abort "Failure" unless success
	                    
	                        ch.on_data do |c, data|
	                            stdout += data
	                        end
	                        
	                        ch.on_extended_data do |c, type, data|
	                            stderr += data
	                        end
	                        
	                        ch.on_close do
	                            state = retrieve_option stdout 'state'
	                            if state != 'allocated'
	                                raise Exception.new "Allocation failed"
	                            end
	                            
	                            stdout.gsub! /^.*option state.*$/, ''
	                            stdout.gsub! slice_id, sliver_id
	                            omf_name = "#{hostname}.#{slice[:info][:testbed]}"
	                            stdout += "       option omf_name '#{omf_name}'"
	                            
	                            sliver = deploy(ssh, slice, slice_id, stdout)
	                            sliver[:node][:hostname] = hostname
                                sliver[:node][:hrn] = "#{omf_name}"
	                            slivers << sliver
	                        end
	                    end
	                end

	                channel.wait
	            end
	        end
	        
	        puts slice[:available_nodes].inspect
	        slivers
	    end
	    
	    private
	    
	    def retrieve_option from, name
	        begin
    	        /^\s*option #{name}\s*'(.*)'\s*$/.match(from)[1]
    	    rescue
    	        nil
    	    end
	    end
	    
	    def hexy i
	        o = i.to_s(16)
	        if o.length < 2
	            o = "0" + o
	        end
	        o
	    end
	    
	    def pick_node nodes
	        key = nodes.keys.first
	        ip = nodes[key]
	        nodes.delete key
	        return key, ip
	    end
	    
	    def convert_ipv4 ipv4_with_netmask
	        ipv4_with_netmask.gsub /\/[0-2]?[0-9]/, ''
	    end
	    
	    def deploy ssh, slice, slice_id, sliver_state
	        channel = ssh.open_channel do |ch|
                ch.exec "confine_sliver_deploy #{slice_id}" do  |ch, success|
                    stderr = stdout = ''
                    ch.send_data sliver_state
                    ch.eof!
                    abort "Failure" unless success
                
                    ch.on_data do |c, data|
                        stdout += data
                    end
                    
                    ch.on_extended_data do |c, type, data|
                        stderr += data
                    end
                    
                    ch.on_close do
                        state = retrieve_option stdout 'state'
                        if state != 'deployed'
                            raise Exception.new "Deployment failed"
                        end
                    
                        start ssh, slice_id
                    end
                end
            end
            channel.wait
            
            sliver = Hash.new
            sliver[:node] = Hash.new
            sliver[:node][:control_ip] = convert_ipv4(retrieve_option sliver_state, 'if01_ipv4')
            sliver[:node][:control_mac] = retrieve_option sliver_state, 'if01_mac'
            sliver[:location] = Hash.new
			sliver[:location][:x] = 0
			sliver[:location][:y] = 0
			sliver[:location][:z] = (slice[:z] += 1)
			sliver[:location][:name] = "VirtualWorld.#{slice_id}"
			sliver[:location][:testbedname] = slice[:info][:testbed]
            sliver
	    end
	    
	    def start ssh, slice_id
	        channel = ssh.open_channel do |ch|
	            ch.exec "confine_sliver_start #{slice_id}" do |ch, success|
	                stderr = stdout = ''
	            
	                ch.on_data do |c, data|
	                    stdout += data
	                end
	                
	                ch.on_extended_data do |c, x, data|
	                    stderr += data
	                end
	                
	                ch.on_close do
	                    state = retrieve_option stdout 'state'
	                    if state != 'started'
	                        raise Exception.new 'Starting failed...'
	                    end
	                end
	            end
	        end
	        channel.wait
	    end
	    
	    def generate_sliver_config sliver_id
	        ssh_pub_key = File.open(SSH_PUB_FILE).read.chomp
	    
	        <<-EOF
config sliver '#{sliver_id}'
    option user_pubkey     "#{ssh_pub_key}"
    option fs_template_url "http://143.129.80.193/images/omf-openwrt-trunk-rootfs-latest.tar.gz"
    option exp_data_url    "http://143.129.80.193/images/omf-pats-experiment-data.tar.gz"
    option exp_name        "hello-openwrt-experiment"
    option vlan_nr         f#{sliver_id[-2..-1]}    # mandatory for if-types isolated
    option if00_type	   internal
    option if00_name	   priv
    option if01_type	   public   # optional
    option if01_name	   pub0
    option if01_ipv4_proto dhcp   # mandatory for if-type public
    option if02_type	   isolated # optional
    option if02_name	   eth0
    option if02_parent     eth0     # mandatory for if-types isolated
#    option if03_type	   isolated # optional
#    option if03_name	   eth1
#    option if03_parent     eth0     # mandatory for if-types isolated
EOF
	    end
	end
end
