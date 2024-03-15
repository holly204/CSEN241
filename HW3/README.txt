CSEN 241 HW3
-------------------------------------------------------
Task 1: Defining custom topologies
Question: 
1. What is the output of “nodes” and “net”
        mininet> nodes
        available nodes are:
        h1 h2 h3 h4 h5 h6 h7 h8 s1 s2 s3 s4 s5 s6 s7
        
        mininet> net
        h1 h1-eth0:s3-eth2
        h2 h2-eth0:s3-eth3
        h3 h3-eth0:s4-eth2
        h4 h4-eth0:s4-eth3
        h5 h5-eth0:s6-eth2
        h6 h6-eth0:s6-eth3
        h7 h7-eth0:s7-eth2
        h8 h8-eth0:s7-eth3
        s1 lo:  s1-eth1:s2-eth1 s1-eth2:s5-eth1
        s2 lo:  s2-eth1:s1-eth1 s2-eth2:s3-eth1 s2-eth3:s4-eth1
        s3 lo:  s3-eth1:s2-eth2 s3-eth2:h1-eth0 s3-eth3:h2-eth0
        s4 lo:  s4-eth1:s2-eth3 s4-eth2:h3-eth0 s4-eth3:h4-eth0
        s5 lo:  s5-eth1:s1-eth2 s5-eth2:s6-eth1 s5-eth3:s7-eth1
        s6 lo:  s6-eth1:s5-eth2 s6-eth2:h5-eth0 s6-eth3:h6-eth0
        s7 lo:  s7-eth1:s5-eth3 s7-eth2:h7-eth0 s7-eth3:h8-eth0

2. What is the output of “h7 ifconfig”
        mininet> h7 ifconfig
        h7-eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
                inet 10.0.0.7  netmask 255.0.0.0  broadcast 10.255.255.255
                inet6 fe80::7025:6fff:fe93:c4f8  prefixlen 64  scopeid 0x20<link>
                ether 72:25:6f:93:c4:f8  txqueuelen 1000  (Ethernet)
                RX packets 72  bytes 5440 (5.4 KB)
                RX errors 0  dropped 0  overruns 0  frame 0
                TX packets 12  bytes 936 (936.0 B)
                TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
        
        lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
                inet 127.0.0.1  netmask 255.0.0.0
                inet6 ::1  prefixlen 128  scopeid 0x10<host>
                loop  txqueuelen 1000  (Local Loopback)
                RX packets 0  bytes 0 (0.0 B)
                RX errors 0  dropped 0  overruns 0  frame 0
                TX packets 0  bytes 0 (0.0 B)
                TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

-------------------------------------------------------------------------------------------------
Task 2: Analyze the “of_tutorial’ controller
Questions
1. Draw the function call graph of this controller. For example, once a packet comes to the
controller, which function is the first to be called, which one is the second, and so forth?
        The function graph is:
        launch ---> start_switch ----> __init__() ----> _handle_PacketIn() ----> act_like_hub() ----> resend_packet() ----> self.connection.send(msg)

2. Have h1 ping h2, and h1 ping h8 for 100 times (e.g., h1 ping -c100 p2).
a. How long does it take (on average) to ping for each case?
        h1 ping h2: 
        mininet> h1 ping h2
        --- 10.0.0.2 ping statistics ---
        100 packets transmitted, 100 received, 0% packet loss, time 101427ms
        
        mininet> h1 ping h8
        --- 10.0.0.2 ping statistics ---
        100 packets transmitted, 100 received, 0% packet loss, time 109604ms
        
        average for h1 ping h2: 4.083ms
        average for h1 ping h8: 17.961ms

b. What is the minimum and maximum ping you have observed?
        minimum for h1 ping h2: 2.215ms
        maximum for h1 ping h2: 13.146ms
        
        minimum for h1 ping h8: 7.872ms
        maximum for h1 ping h8: 67.589ms

c. What is the difference, and why?
        it takes less time for h1 pings h2 compared to h1 pings h8. 
        This is because when h1 ping h8, there are more switches to for h1 to travel to h8 than travel to h2.

3. Run “iperf h1 h2” and “iperf h1 h8”

a. What is “iperf” used for?
        Iperf is a commonly used network testing tool that can create TCP and UDP data streams 
        and measure the throughput of a network that is carrying them.

b. What is the throughput for each case?
        mininet> iperf h1 h2
        *** Iperf: testing TCP bandwidth between h1 and h2 
        .*** Results: ['14.95 Mbits/sec', '15.11 Mbits/sec']
        mininet> iperf h1 h8
        *** Iperf: testing TCP bandwidth between h1 and h8 
        *** Results: ['12.86 Mbits/sec', '12.97 Mbits/sec']

c. What is the difference, and explain the reasons for the difference.
        'iperf h1 h2' is higher than 'iperf h1 h8', it is due to more switches between h1 and h8 than switches between h1 and h2.

4. Which of the switches observe traffic? Please describe your way for observing such
traffic on switches (e.g., adding some functions in the “of_tutorial” controller).
        All of the switches observe traffic. To observe such traffic, we can add below log code in the function                   _handle_PacketIn, before self.act_like_hub(packet, packet_in)
        log.info("Logging of Switch Traffic: %s " % (self.connection))

----------------------------------------
Task 3: MAC Learning Controller
Questions
1. Describe how the above code works, such as how the "MAC to Port" map is established.
You could use a ‘ping’ example to describe the establishment process (e.g., h1 ping h2).
        When "h1 ping h2", the function graph is:
        launch ---> start_switch ----> __init__() ----> _handle_PacketIn() ----> act_like_switch()
        in the function act_like_switch(), 
        if the source MAC is not in "MAC to Port" map, it's added to the map; 
        if the source MAC is in "MAC to Port" map, Send packet out the associated port;
        otherwise, the process is the same as act_like_hub().

2. (Comment out all prints before doing this experiment) Have h1 ping h2, and h1 ping
h8 for 100 times (e.g., h1 ping -c100 p2).
a. How long did it take (on average) to ping for each case?
        average for h1 ping h2: 2.293ms
        average for h1 ping h8: 16.745ms
		
b. What is the minimum and maximum ping you have observed?

        minimum for h1 ping h2: 1.768ms
        maximum for h1 ping h2: 13.008ms
        
        minimum for h1 ping h8: 8.063ms
        maximum for h1 ping h8: 63.859ms

c. Any difference from Task 2 and why do you think there is a change if there is?
        The ping time is a little less than task 2. 
        One possible explanation for this could be the "MAC to Port" map, 
        which speeds up transmission by sending packets straight to their destination instead than flooding them.

3. Q.3 Run “iperf h1 h2” and “iperf h1 h8”.
a. What is the throughput for each case?
        mininet> iperf h1 h2
        *** Iperf: testing TCP bandwidth between h1 and h2 
        *** Results: ['23.63 Mbits/sec', '29.84 Mbits/sec']
        
        mininet> iperf h1 h8
        *** Iperf: testing TCP bandwidth between h1 and h8 
        *** Results: ['18.93 Mbits/sec', '20.04 Mbits/sec']

b. What is the difference from Task 2 and why do you think there is a change if
there is?
        The throughput for Task 3 is a little more than Task 2 for both the cases. 
        The possible explanation for this could be the "MAC to Port" map helps switch to the destination port,
        which reduces the network congestion by not flooding all the network ports.

