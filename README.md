# FreeBSD-FRR
FreeBSD 14.3

## Install required packages

pkg install autoconf automake bison c-ares git gmake json-c libtool \
    libunwind libyang2 pkgconf protobuf-c texinfo py311-pytest py311-sphinx

## Add frr group and user

pw groupadd frr -g 101
pw groupadd frrvty -g 102
pw adduser frr -g 101 -u 101 -G 102 -c "FRR suite" \
   -d /usr/local/etc/frr -s /usr/sbin/nologin

## Build

### Git Clone
git clone https://github.com/frrouting/frr.git frr

### Pre Build
cd frr
./bootstrap.sh
export MAKE=gmake LDFLAGS=-L/usr/local/lib CPPFLAGS=-I/usr/local/include

### Build
./configure \
    --sysconfdir=/usr/local/etc \
    --localstatedir=/var \
    --enable-pkgsrcrcdir=/usr/pkg/share/examples/rc.d \
    --prefix=/usr/local \
    --enable-multipath=64 \
    --enable-user=frr \
    --enable-group=frr \
    --enable-vty-group=frrvty \
    --enable-configfile-mask=0640 \
    --enable-logfile-mask=0640 \
    --enable-fpm \
    --with-pkg-git-version \
    --with-pkg-extra-version=-MyOwnFRRVersion \
    --enable-snmp \
    --enable-fpm \
    --enable-config-rollbacks

### Build and Install
gmake
gmake check
gmake install

## Create empty FRR configuration files

mkdir /usr/local/etc/frr
touch /usr/local/etc/frr/babeld.conf
touch /usr/local/etc/frr/bfdd.conf
touch /usr/local/etc/frr/bgpd.conf
touch /usr/local/etc/frr/eigrpd.conf
touch /usr/local/etc/frr/isisd.conf
touch /usr/local/etc/frr/ldpd.conf
touch /usr/local/etc/frr/nhrpd.conf
touch /usr/local/etc/frr/ospf6d.conf
touch /usr/local/etc/frr/ospfd.conf
touch /usr/local/etc/frr/pbrd.conf
touch /usr/local/etc/frr/pimd.conf
touch /usr/local/etc/frr/ripd.conf
touch /usr/local/etc/frr/ripngd.conf
touch /usr/local/etc/frr/staticd.conf
touch /usr/local/etc/frr/zebra.conf
chown -R frr:frr /usr/local/etc/frr/
touch /usr/local/etc/frr/vtysh.conf
chown frr:frrvty /usr/local/etc/frr/vtysh.conf
chmod 640 /usr/local/etc/frr/*.conf

## Enable IP & IPv6 forwarding
Add the following lines to the end of /etc/sysctl.conf:

#Routing: We need to forward packets
net.inet.ip.forwarding=1
net.inet6.ip6.forwarding=1

## Reboot

## Enable FRR from boot
/etc/rc.conf

frr_enable="YES"

## Create Runtime & DB Directory

mkdir -p /var/run/frr
mkdir -p /var/lib/frr
chown -R frr:frr /var/lib/frr
chown -R frr:frr /var/run/frr

## Create rc.d FRR

### 1.
/usr/local/etc/rc.d/frr

#!/bin/sh
#
# PROVIDE: frr
# REQUIRE: DAEMON
# KEYWORD: shutdown

. /etc/rc.subr

name="frr"
rcvar="frr_enable"

# Path FRR binaries
frr_sbindir="/usr/local/sbin"
frr_etcdir="/usr/local/etc/frr"
frr_rundir="/var/run/frr"
frr_libdir="/var/lib/frr"
frr_daemons_file="${frr_etcdir}/daemons"

start_cmd="frr_start"
stop_cmd="frr_stop"
status_cmd="frr_status"

frr_start()
{
    echo "Starting FRR daemons..."
    mkdir -p ${frr_rundir} ${frr_libdir}
    chown frr:frr ${frr_rundir} ${frr_libdir}
    chmod 750 ${frr_rundir} ${frr_libdir}

    if [ ! -f "${frr_daemons_file}" ]; then
        echo "No daemons file found at ${frr_daemons_file}"
        return 1
    fi

    . ${frr_daemons_file}

    for daemon in zebra bgpd ospfd ospf6d ripd ripngd isisd pimd ldpd nhrpd babeld eigrpd bfdd staticd pbrd pathd; do
        eval enabled=\$${daemon}
        if [ "$enabled" = "yes" ]; then
            echo "  -> Starting $daemon"
            ${frr_sbindir}/${daemon} -d -f ${frr_etcdir}/${daemon}.conf -A 127.0.0.1
        fi
    done
}

frr_stop()
{
    echo "Stopping FRR daemons..."
    killall zebra bgpd ospfd ospf6d ripd ripngd isisd pimd ldpd nhrpd babeld eigrpd bfdd staticd pbrd pathd 2>/dev/null
}

frr_status()
{
    echo "Checking FRR daemons..."
    for daemon in zebra bgpd ospfd ospf6d ripd ripngd isisd pimd ldpd nhrpd babeld eigrpd bfdd staticd pbrd pathd; do
        pgrep -x $daemon >/dev/null && echo "  $daemon is running" || echo "  $daemon is stopped"
    done
}

load_rc_config $name
run_rc_command "$1"

### 2.

/usr/local/etc/frr/daemons

# Daemons configuration for FRR
zebra=yes
bgpd=yes
ospfd=yes
bfdd=yes
ospf6d=no
ripd=no
ripngd=no
isisd=no
ldpd=no
pimd=no
nhrpd=no
eigrpd=no
babeld=no
pbrd=no
pathd=no
snmpd=no

### 3. chmod +x /usr/local/etc/rc.d/frr

## Reboot again

## Start FRR

service frr start
vtysh










