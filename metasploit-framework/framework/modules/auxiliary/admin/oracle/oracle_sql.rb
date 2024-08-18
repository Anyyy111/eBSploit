##
# This module requires Metasploit: https://metasploit.com/download
# Current source: https://github.com/rapid7/metasploit-framework
##

class MetasploitModule < Msf::Auxiliary
  include Msf::Exploit::ORACLE

  def initialize(info = {})
    super(update_info(info,
      'Name'           => 'Oracle SQL Generic Query',
      'Description'    => %q{
          This module allows for simple SQL statements to be executed
          against an Oracle instance given the appropriate credentials
          and sid.
      },
      'Author'         => [ 'MC' ],
      'License'        => MSF_LICENSE,
      'References'     =>
        [
          [ 'URL', 'https://www.metasploit.com/users/mc' ],
        ],
      'DisclosureDate' => '2007-12-07'))

      register_options(
        [
          OptString.new('SQL', [ false, 'The SQL to execute.',  'select * from v$version']),
        ])
  end

  def run
    return if not check_dependencies

    query = datastore['SQL']

    begin
      print_status("Sending statement: '#{query}'...")
      result = prepare_exec(query)
      # Need this if statement because some statements won't return anything
      if result
        result.each do |line|
          print_status(line)
        end
      end
    rescue => e
      return
    end
  end
end
