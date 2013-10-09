require 'packetfu'

$count = 0
iface = ARGV[0] || "eth0"

def check_null(p)
  if p.tcp_flags.to_i() == 0
    puts "%-3s ALERT: Nmap NULL Scan detected from %-15s (%s)" % [$count, p.ip_saddr, p.proto.last]
    $count = $count + 1
  end
end


def check_xmas(p)
  if (p.tcp_flags.psh == 1 && p.tcp_flags.fin == 1 && p.tcp_flags.urg == 1)
    puts "%-3s ALERT: Nmap XMAS Scan detected from %-15s (%s)" % [$count, p.ip_saddr, p.proto.last]
    $count = $count + 1
  end
end

def check_nmap(p)
  if p.to_s.match("Nmap")
    puts "%-3s ALERT: Other Nmap Scan detected from %-15s (%s)" % [$count, p.ip_saddr, p.proto.last]
    $count = $count + 1
  end
end

def check_pass(p)
  if p.to_s.match(/(passwd|password)/i)
    puts "%-3s ALERT: Password in the clear detected from %-15s (%s)" % [$count, p.ip_saddr, p.proto.last]
  $count = $count + 1
  end
end

def check_credit(p)
  if p.to_s.match(/(\d{4}|\d{3})(\s|-)?\d{4}(\s|-)?\d{4}(\s|-)?\d{4}/)
    puts "%-3s ALERT: Credit Card in the clear detected from %-15s (%s)" % [$count, p.ip_saddr, p.proto.last]
  $count = $count + 1
  end
end

def check_XSS(p)
  if p.to_s.match(/<script>\s*(alert|window.location)/)
    puts "%-3s ALERT: XSS detected from %-15s (%s)" % [$count, p.ip_saddr, p.proto.last]
  $count = $count + 1
  end
 
end

stream = PacketFu::Capture.new(:start => true, :iface => iface, :promisc => true)
puts "Starting to sniff..."
stream.stream.each do |p|
  pkt = PacketFu::Packet.parse p
  temp = $count
  if pkt.is_tcp?
    check_null pkt
    check_xmas pkt
    if temp == $count
      check_nmap pkt
    end
    check_pass pkt
    check_credit pkt
    check_XSS pkt
  end
end
