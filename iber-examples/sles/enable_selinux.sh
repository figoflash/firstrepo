source /etc/os-release; zypper ar -f --no-gpgcheck https://download.opensuse.org/repositories/security:/SELinux_legacy/15.4/ SELinux-Legacy; zypper --non-interactive in restorecond policycoreutils setools-console; zypper --non-interactive in selinux-policy-targeted selinux-policy-devel; sed -i 's/\(^GRUB_CMDLINE_LINUX_DEFAULT=.*\)"$/\1 security=selinux selinux=1"/' /etc/default/grub; grub2-mkconfig -o /boot/grub2/grub.cfg