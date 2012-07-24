module Confine
	class Portal
		DOMAIN_PREFIX = 'experiment.'

		def initialize
			@sliceId = -1
			@sliceSliverId = Hash.new(0)
			#@defaultSliverConf = Hash.new(0)
			#@defaultSliverConf["imageid"] = 1
			#@defaultSliverConf["nwifi"] = 5
			#@defaultSliverConf["neth"] = 2
		end
		
		# Create a slice for the researcher
		# return the slice id of this newly allocated slice
		def createSlice
			result = Hash.new
			result[:id] = @sliceId += 1
			result[:testbed] = "#{DOMAIN_PREFIX}#{result[:id]}"
			result
		end

		### Geef mij testomgeving
		# geef slice
		# return slice id	

		# Make a mock sliver
		def mockSliver(sliceid, hostname)
			sliver = Hash.new{|hash, key| hash[key] = Hash.new}
			sliver[:node][:control_ip] = "10.0.0.#{@sliceSliverId[:sliceid]}"
			sliver[:node][:control_mac] = '00:03:2D:08:1A:88'
			sliver[:node][:hostname] = "#{hostname}"
			sliver[:node][:hrn] = "#{DOMAIN_PREFIX}#{sliceid}.#{hostname}"
			sliver[:location][:x] = '0'
			sliver[:location][:y] = "#{@sliceSliverId[sliceid]}"
			sliver[:location][:z] = '0'
			sliver[:location][:name] = "VirtualWorld.#{sliceid}"
			sliver[:location][:testbedname] = "#{DOMAIN_PREFIX}#{sliceid}"
			@sliceSliverId[sliceid] += 1
			sliver
		end

		# Will try to allocate a group of slivers in the slice of the given slice id
		def createSliverGroup(slice_id, names, opts)
			# Did we receive a slice id?
			raise "CONFINE portal - slice id is nil!" if slice_id.nil?
			# Is it a valid slice id?
			raise "CONFINE portal - slice id (#{slice_id}) does not exists!" if (slice_id > @sliceId)

			puts "CONFINE portal - New Slivergroup allocated."
			slivers = Hash.new
			for i in 0..(Integer(names.length)-1)
				slivers[i] = mockSliver(slice_id, names[i])
			end
			slivers
		end

		### Ahv slice id, geef sliver config
		# param lijst van namen
		# param 
		# return : ACK 
	end
end
