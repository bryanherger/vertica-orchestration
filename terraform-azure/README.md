# Terraform example for Azure

What it does: create a Vertica cluster with a Management Console node plus 1-3 Vertica cluster nodes.  A number of parameters are configurable through variables.tf

What it doesn't (yet): setup the items listed below, add or remove nodes, configure MC (set up users and add cluster), configure Vertica beyond installation.

## Prerequisites

You'll need to set up the following:

Initialize with "terraform init"

Log into Azure with "az login"

Create SSH key pair named "verticatf.sshkey" and "verticatf.sshkey.pub"

Download RPM's to the RPM subfolder.  Using the "centos" image, you'll need the following (note you may use later versions of Vertica since they're installed using wildcard):
dialog-1.2-5.20130523.el7.x86_64.rpm  libgfortran-4.8.5-39.el7.x86_64.rpm  vertica-9.2.1-7.x86_64.RHEL6.rpm          vertica-R-lang-9.2.1-0.x86_64.RHEL6.rpm
haveged-1.9.1-1.el7.x86_64.rpm        libquadmath-4.8.5-39.el7.x86_64.rpm  vertica-console-9.2.1-7.x86_64.RHEL6.rpm

Get the Vertica RPM's from my.vertica.com.  For other packages, you can download RPM's to this folder using e.g.: yum install --downloadonly --downloaddir=rpm/ dialog haveged libgfortran libquadmath

Best of luck and report any issues or feature requests here on GitHub.
