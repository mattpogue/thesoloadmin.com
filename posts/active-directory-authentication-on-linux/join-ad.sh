# Script to handle the process of joining the domain.
# Run with username where:
# username is the SAM name for the domain admins account - e.g. brownm for martin.brown
#
# The script produces lots of output to help with debugging any issues. See
# https://www.redhat.com/en/files/resources/en-rhel-intergrating-rhel-6-active-directory.pdf
# for a full description of the process (albeit RedHat rather than Debian).
#
# Note that it is very important that the hostname of the machine is set up correctly!

if [ "$#" != 1 ]
then
  echo "Usage: join-ad.sh username"
  exit 1
fi

username=$1
domain=$(hostname --domain)
echo "Using account ${username} to join domain ${domain}..."
echo ""

# Quit on error
set -e

# Uncomment to debug
#set -x

# Upper-case version of the domain name
upper_domain=$(echo ${domain} | tr [a-z] [A-Z])

# Find the short hostname and get an upper-case version of it
short_hostname=$(hostname --short)
upper_short_hostname=$(echo ${short_hostname} | tr [a-z] [A-Z])

# Log into the domain as the administrator, asking user for password
# The domain part must be in upper-case
echo "Logging into domain as the administrator"
/usr/bin/kinit "${username}@${upper_domain}"
echo ""

# List what kerberos sent back
echo "Listing kerberos tickets for the domain administrator:"
echo "------------------------------------------------------------------------"
klist
echo ""

# Join AD and put the machine credentials in the krb5.keytab
echo "Requesting domain join using administrator kerberos ticket"
net ads join -k

# List the machine credentials
echo "Listing kerberos tickets for the machine:"
echo "------------------------------------------------------------------------"
klist -k
echo ""

# Wait for 5s to allow everything to catch up - sometimes 5s isn't enough
echo "Waiting for everything to catch up..."
sleep 5
echo ""

# Sign in using the machine credentials
echo "Signing in using machine credentials ${upper_short_hostname}$"
kinit -k ${upper_short_hostname}$
echo ""

# Did it work?
joinedAd=$?

if [ $joinedAd -ne 0 ]
then
    echo "Error: could not join the domain with machine credentials ${upper_short_hostname}$"
    exit 1
else
    echo "Joined the domain using machine credentials ${upper_short_hostname}$"
    echo ""
    echo "Listing kerberos machine ticket:"
    echo "------------------------------------------------------------------------"
    klist
    echo ""

    # Now restart SSSD and everything should be happy :-)
    echo "Enabling and restarting sssd"
    systemctl enable sssd
    systemctl restart sssd
    if [ $? -ne 0 ]
    then
      echo "Error: could not start the System Security Services Daemon (SSSD)"
      exit 1
    else
      echo "System Security Services Daemon (SSSD) restarted and enabled."
      echo "AD should now be working!"
    fi
fi

exit 0