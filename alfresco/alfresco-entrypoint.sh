#!/bin/bash
#
# Tamer Embaby <tamer@embaby.com>
#

INSTALLDIR=/opt/alfresco

if [ -e $INSTALLDIR/properties.sh ] ; then
	. $INSTALLDIR/properties.sh
fi

if [ -z "INSTALLDIR" ] ; then
	echo "ERROR: NO ALFRESCO HOME DEFINED"
	exit 1
fi

echo "--> Running container entry point as user $(id -un)"

# Are we installing?
#
# Installation requires the following files to be ready in host directoy:
# 1- alfresco-community-installer-201605-linux-x64.bin
# 2- hostname (optional)
#
if [ ! -e $INSTALLDIR/.installed -a -x "$INSTALLSCRIPT" ] ; then
	echo "+INSTALL: Starting installation process"

	if [ -z "$HOSTNAME" ] ; then
		$HOSTNAME="0.0.0.0"
	fi

	args=""
	# jdbc_url: jdbc:postgresql://$POSTGRES_HOSTNAME/$POSTGRES_DB
	if [ ! -z "$POSTGRES_HOSTNAME" -a ! -z "$POSTGRES_DB" ] ; then
		args="$args --jdbc_url jdbc:postgresql://$POSTGRES_HOSTNAME/$POSTGRES_DB"
	fi
	# jdbc_database: $POSTGRES_DB
	if [ ! -z "$POSTGRES_DB" ] ; then
		args="$args --jdbc_database $POSTGRES_DB"
	fi
	# jdbc_username: $POSTGRES_USER
	if [ ! -z "$POSTGRES_USER" ] ; then
		args="$args --jdbc_username $POSTGRES_USER"
	fi
	# jdbc_password: $POSTGRES_PASSWORD
	if [ ! -z "$POSTGRES_PASSWORD" ] ; then
		args="$args --jdbc_password $POSTGRES_PASSWORD"
	fi

	echo "+INSTALL: Using hostname [$HOSTNAME]"
	echo "+INSTALL: DB args: [$args]"

	$INSTALLSCRIPT --mode unattended --prefix $INSTALLDIR \
        	--tomcat_server_domain $HOSTNAME --alfresco_admin_password changeme \
        	--baseunixservice_install_as_service 0 $args \
		--enable-components javaalfresco,libreofficecomponent,alfrescosolr4,aosmodule,alfrescogoogledocs \
		--disable-components postgres
	
	_success=$?

	if [ ${_success} -ne 0 ] ; then
		echo "ERROR: Failure in installing Alfresco server"
		exit ${_success}
	fi

	echo "+INSTALL: installation successful"

	# Clean up
	touch $INSTALLDIR/.installed
	rm -f $INSTALLSCRIPT
fi

echo ""

# Starting Alfresco services
echo "--> Alfresco environment going up"

JAVA_OPTS="-Xms2g -Xmx2g -XX:PermSize=128m -XX:MaxPermSize=256m -Djava.awt.headless=true"
JAVA_OPTS="$JAVA_OPTS -Dfile.encoding=utf-8 -XX:+UseConcMarkSweepGC"
export JAVA_OPTS

if [ -r "$INSTALLDIR/scripts/setenv.sh" ] ; then
	. $INSTALLDIR/scripts/setenv.sh
fi

cd $INSTALLDIR

echo "--> Starting LibreOffice Server"
$INSTALLDIR/libreoffice/scripts/libreoffice_ctl.sh start

#echo "--> Starting Alfresco Embeded PostgreSQL Server" 
#$INSTALLDIR/alfresco.sh start postgresql

#echo "--> Starting Alfresco ... Hold on!"
#exec $INSTALLDIR/tomcat/bin/catalina.sh run

exec "$@"
