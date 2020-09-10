#!/bin/sh

read -p "Enter name of zone: " zone
read -p "Enter CN of node: " hostcn
read -p "Enter icinga ticket: " ticket
read -p "Install vmware checks: " esx_checks

yum install -y epel-release
yum install -y nrpe nagios-plugins-all nagios-plugins-check-updates nagios-plugins-nrpe perl-XML-LibXML bc perl-IPC-Run OpenIPMI freeipmi unzip openssl-devel jq perl-Net-SNMP perl-List-Compare perl-Crypt-Rijndael perl-version perl-SOAP-Lite perl-DateTime perl-DateTime-Format-Strptime python-requests perl-libxml-perl perl-XML-LibXML perl-Time-Duration ipmitool net-snmp-perl wget

yum install -y https://packages.icinga.com/epel/icinga-rpm-release-7-latest.noarch.rpm
yum install -y icinga2
yum install -y chrony

chkconfig chrony on
chkconfig icinga2 on

# get the master CA
icinga2 pki save-cert --host au-south-east-monitor.cloudcentral.com.au --trustedcert /var/lib/icinga2/certs/ca.crt

# register
icinga2 node setup \
--zone $zone \
--parent_zone master \
--parent_host au-south-east-monitor.cloudcentral.com.au,5665 \
--accept-config \
--accept-commands \
--cn $hostcn \
--endpoint monitor-master01.mel.as7551.net,au-south-east-monitor.cloudcentral.com.au,5665 \
--endpoint monitor-master01.cbr.as7551.net,au-east-monitor.cloudcentral.com.au,5665 \
--ticket $ticket \
--trustedcert /var/lib/icinga2/certs/ca.crt \
--disable-confd

service icinga2 restart

cd /tmp
curl https://monitor.cloudcentral.com.au/powernet368_mib.txt -o /usr/share/snmp/mibs/powernet368_mib.txt

if [[ "$esx_checks" == "yes" ]];
then

  curl -L https://github.com/cloudcentral/nagios-plugins-check_vmware_esx/archive/master.zip -o /tmp/check_esx.zip
  unzip check_esx.zip
  cp /tmp/nagios-plugins-check_vmware_esx-master/check_vmware_esx.pl /usr/lib64/nagios/plugins/check_vmware_esx
  chmod +x /usr/lib64/nagios/plugins/check_vmware_esx
  restorecon /usr/lib64/nagios/plugins/check_vmware_esx
  mkdir /usr/lib64/nagios/plugins/modules
  cp -r /tmp/nagios-plugins-check_vmware_esx-master/modules/* /usr/lib64/nagios/plugins/modules

  curl https://raw.githubusercontent.com/cloudcentral/monitoring-plugins/master/lib/VMware-vSphere-Perl-SDK-6.5.0-4566394.x86_64.tar.gz -o vmware-perl-sdk.tar.gz
  tar -zxvf vmware-perl-sdk.tar.gz
  cd vmware-vsphere-cli-distrib
  echo y | ./vmware-install.pl -d
fi

curl https://raw.githubusercontent.com/cloudcentral/monitoring-plugins/master/plugins/check_qnap -o /usr/lib64/nagios/plugins/check_qnap
chmod +x /usr/lib64/nagios/plugins/check_qnap

curl https://raw.githubusercontent.com/cloudcentral/monitoring-plugins/master/plugins/check_forti.pl-o /usr/lib64/nagios/plugins/check_forti.pl
chmod +x /usr/lib64/nagios/plugins/check_forti.pl
