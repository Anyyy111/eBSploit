##
# This module requires Metasploit: https://metasploit.com/download
# Current source: https://github.com/rapid7/metasploit-framework
##

class MetasploitModule < Msf::Auxiliary

  # Exploit mixins should be called first
  include Msf::Exploit::Remote::SMB::Client
  include Msf::Exploit::Remote::SMB::Client::Authenticated
  include Msf::Exploit::Remote::SMB::Client::PipeAuditor

  # Scanner mixin should be near last
  include Msf::Auxiliary::Scanner
  include Msf::Auxiliary::Report

  def initialize
    super(
      'Name'        => 'SMB Session Pipe Auditor',
      'Description' => 'Determine what named pipes are accessible over SMB',
      'Author'      => 'hdm',
      'License'     => MSF_LICENSE
    )

    deregister_options('RPORT', 'SMBDirect')
  end

  # Fingerprint a single host
  def run_host(ip)

    pipes = []

    [[139, false], [445, true]].each do |info|

      datastore['RPORT'] = info[0]
      datastore['SMBDirect'] = info[1]

      begin
        connect
        smb_login()
        check_named_pipes.each do |pipe_name, _|
          pipes.push(pipe_name)
        end

        disconnect()

        break
      rescue Rex::Proto::SMB::Exceptions::SimpleClientError, Rex::ConnectionError => e
        vprint_error("SMB client Error with RPORT=#{info[0]} SMBDirect=#{info[1]}: #{e.to_s}")
      end
    end

    if(pipes.length > 0)
      print_good("Pipes: #{pipes.join(", ")}")
      # Add Report
      report_note(
        :host	=> ip,
        :proto => 'tcp',
        :sname	=> 'smb',
        :port	=> rport,
        :type	=> 'Pipes Found',
        :data	=> "Pipes: #{pipes.join(", ")}"
      )
    end
  end


end
