##
# This module requires Metasploit: https://metasploit.com/download
# Current source: https://github.com/rapid7/metasploit-framework
##

class MetasploitModule < Msf::Auxiliary
  include Msf::Exploit::Remote::Capture

  def initialize
    super(
      'Name'        => 'Pcap Replay Utility',
      'Description' => %q{
        Replay a pcap capture file
      },
      'Author'      => 'amaloteaux',
      'License'     => MSF_LICENSE
    )

    register_options([
      OptPath.new('FILENAME', [true, "The local pcap file to process"]),
      OptString.new('FILE_FILTER', [false, "The filter string to apply on the file"]),
      OptInt.new('LOOP', [true, "The number of times to loop through the file",1]),
      OptInt.new('DELAY', [true, "the delay in millisecond between each loop",0]),
      OptInt.new('PKT_DELAY', [true, "the delay in millisecond between each packet",0]),
    ])

    deregister_options('SNAPLEN','FILTER','PCAPFILE','RHOST','TIMEOUT','SECRET','GATEWAY_PROBE_HOST','GATEWAY_PROBE_PORT')
  end

  def run
    check_pcaprub_loaded # Check first
    pkt_delay = datastore['PKT_DELAY']
    delay = datastore['DELAY']
    loop = datastore['LOOP']
    infinity = true if loop <= 0
    file_filter = datastore['FILE_FILTER']
    filename = datastore['FILENAME']
    verbose = datastore['VERBOSE']
    count = 0
    unless File.exist? filename and File.file? filename
      print_error("Pcap File does not exist")
      return
    end
    open_pcap
    print_status("Sending file...") unless verbose
    while (loop > 0 or infinity) do
      vprint_status("Sending file (loop: #{count = count + 1})")
      inject_pcap(filename, file_filter, pkt_delay )
      loop -= 1 unless infinity
      Kernel.select(nil, nil, nil, (delay * 1.0)/1000) if loop > 0 or infinity
    end
    close_pcap
  end
end
