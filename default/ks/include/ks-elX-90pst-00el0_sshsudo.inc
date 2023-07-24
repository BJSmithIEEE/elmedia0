### ks/include/ks-elX-90pst-00el0_sshsudo.inc

# These accounts need to match those in '20sec-00el0_accts' (i.e., ks-elX-20sec-00el0_accts.inc)
# TIP:  Use elmedia0 default '20sec-00el0_accts' and this '90pst-00el0_sshsudo' files as 'templates'
#         for your own '20sec-my_accts' and '90pst-my_sshsudo' files and use them in a modified kickstart
SYSWHEEL="sysadmin"
SYSSUDO="ansadmin"


### both SYSWHEEL and SYSSUDO should have a default password good for at least 60 days from kickstart
for u in ${SYSWHEEL} ${SYSSUDO} ; do
	/usr/bin/chage -M 60 -m 1 -E $(date -d +60days +%Y-%m-%d) -d $(date +%Y-%m-%d) ${u}
done


### both SYSWHEEL and SYSSUDO should have explicit stanzas guaranteeing they can always SSH into the system
# IMPORTANT:  These stanzas need to be at the end of /etc/ssh/sshd_config, so move/uncomment after system is up
# EXAMPLE /etc/ssh/sshd_config block (commented out by default)
echo -e "\n#####\tBEGIN Match - NEEDS TO BE AT THE BOTTOM / AFTER ALL OTHER CONFIG" >> /etc/ssh/sshd_config
for u in ${SYSWHEEL} ${SYSSUDO} ; do
	for t in Group User ; do
		echo -e "\n###\tExplicit, guaranteed SSH access for ${t} ${u}" >> /etc/ssh/sshd_config
		echo -e "#Match ${t}\t${u}" >> /etc/ssh/sshd_config
		echo -e "#\tAllow${t}s\t${u}" >> /etc/ssh/sshd_config
		echo -e "#\tPasswordAuthentication yes" >> /etc/ssh/sshd_config
	done
done
echo -e "\n#####\tEND Match - NEEDS TO BE AT THE BOTTOM / AFTER ALL OTHER CONFIG\n" >> /etc/ssh/sshd_config


### SYSSUDO should not be in wheel, so explicitly granted sudo (revokable)
for u in ${SYSSUDO} ; do
	echo -e "${u}\tALL=(ALL)\tALL" >> /etc/sudoers.d/${u}
done

