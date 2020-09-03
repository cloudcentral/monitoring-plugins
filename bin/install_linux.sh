#!/bin/sh

yum install -y epel-release
yum install -y nrpe nagios-plugins-all nagios-plugins-check-updates net-tools 
chkconfig nrpe on
service nrpe restart

# Install custom plugin scripts
for script in check_netint;
do
	curl https://monitor.cloudcentral.com.au/${script} -o /usr/lib64/nagios/plugins/${script}
	chmod +x /usr/lib64/nagios/plugins/${script}
done

if [[ "$(getenforce)" == "Enforcing" ]]; then

	yum install -y policycoreutils-python checkpolicy

	# Install custom selinux modules
	mkdir -p /root/monitoring-selinux-modules
	cd /root/monitoring-selinux-modules
	for module in nrpe_netint_local nrpe_haproxy_local;
	do
		curl https://monitor.cloudcentral.com.au/${module}.te -o ${module}.te
		checkmodule -M -m -o ${module}.mod ${module}.te
		semodule_package -o ${module}.pp -m ${module}.mod
		semodule -i ${module}.pp
	done
fi
