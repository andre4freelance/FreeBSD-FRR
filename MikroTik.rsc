/interface ethernet
set [ find default-name=ether1 ] comment=FreeBSD disable-running-check=no
set [ find default-name=ether2 ] disable-running-check=no
/routing bgp template
add as=64522 disabled=no name=EBGP output.redistribute=connected,static,bgp router-id=10.10.100.2 routing-table=main
/ip address
add address=10.10.100.2/30 interface=ether1 network=10.10.100.0
add address=10.110.110.110 interface=lo network=10.110.110.110
add address=10.120.120.120 interface=lo network=10.120.120.120
add address=10.130.130.130 interface=lo network=10.130.130.130
/routing bgp connection
add disabled=no local.role=ebgp name=FreeBSD output.redistribute=connected,static,bgp remote.address=10.10.100.1/32 .as=64521 router-id=10.10.100.2 routing-table=\
    main templates=EBGP