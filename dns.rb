require 'Net/DNS'
require 'socket'
require 'pp'

sock = UDPSocket.new
sock.bind('0.0.0.0', 53)

while true
  packet, address = sock.recvfrom(1024)
  address_family, port, host, address = address

  request = Net::DNS::Packet.parse(packet)

  #pp request.header.opCode_str
  #pp request.question.size
  if request.header.opCode_str == 'QUERY' && request.question.size == 1
    q = request.question.first
    #pp q.class
    #p q.qName
    #p q.qType.class
    #p q.qClass.class
    response = Net::DNS::Packet.new(q.qName)
    response.header.id = request.header.id
    response.header.qr = 1

    #pp [Net::DNS::QueryTypes::A, Net::DNS::QueryTypes::ANY]
    #pp [Net::DNS::QueryClasses::IN, Net::DNS::QueryClasses::ANY]
    if [Net::DNS::QueryTypes::A, Net::DNS::QueryTypes::ANY].include?(q.qType.to_i) && [Net::DNS::QueryClasses::IN, Net::DNS::QueryClasses::ANY].include?(q.qClass.to_i)
      #puts "HERE"
      response.answer << Net::DNS::RR.new(
        :name => q.qName, :type => 'A', :class => 'IN', :ttl => 60, :address => '127.0.0.1'
      )
    end
  else
    response = Net::DNS::Packet.new
    response.header.id = request.header.id
    response.header.qr = 1
    response.header.rcode = 'NOTIMPL'
  end

  sock.send(response.data, 0, host, port)
end
