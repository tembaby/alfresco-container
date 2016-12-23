#### Installation:
- You already got the source from GIT repository because you are reading this file

- Directory hierarchy:
root/
  docker-compose.yml
  README.md
  alfresco/			Alfresco Docker container folder
    alfresco-entrypoint.sh	Docker entry point for Alfresco container
    properties.sh		Configration parameters for Alfresco installation
    Dockerfile			Dockerfile to build Alfresco container
    alfresco/			Shared volume for Alfresco
  db_store/			PostgreSQL Docker container folder
    data/			Shared volume for PostgreSQL database storage

- On host file: Create group "alfresco" (GID: 888) and user "alfresco" (UID: 888), home directory /opt/alfresco
- Login with user "alfresco"
- Move the above hierarchy to the file /opt/alfresco (or donwload it from GIT)
- Build the Alfresco container:

$ docker-compose build alfresco

- If SELinux is enabled, run the following command on all shared volumes (Needed to run that on CentOS 7.2, docker 1.9.1):

$ chcon --recursive --type=svirt_sandbox_file_t --range=s0 /path/to/volume

- Copy Alfresco installation file "alfresco-community-installer-201605-linux-x64.bin" to alfresco shared volume:
- Copy the file properties.sh to alfresco shared volume and change:
  - HOSTNAME
  To match hostname of the Docker host

- Change hostname as well in docker-compose.yml filei (alfresco service):
    hostname: <your docker host hostname>

- Bring the environment up without -d parameter time to make sure it installs everything OK:

$ docker-compose up

- After finishing and accessing Alfresco on port 8080, press Ctrl-C
- Start the environment in daemon mode:

$ docker-compose up -d

#### Notes:
- The data directory: alfresco/alfresco must be chown 888.888 before running docker compose from from host server

* Post installation actions:
- Open the file alfresco/libreoffice/scripts/libreoffice_ctl.sh and change the line:

SOFFICE="$SOFFICEWRAPPER --nofirststartwizard --nologo --headless --accept=socket,host=localhost,port=$SOFFICE_PORT\;urp\;StarOffice.ServiceManager"

To read:

SOFFICE="$SOFFICEWRAPPER --nofirststartwizard --nologo --headless --accept=socket,host=localhost,port=$SOFFICE_PORT;urp;StarOffice.ServiceManager"

Note: removed the backslaches around ;urp;

- Add the following to the file tomcat/shared/classes/alfresco-global.properties:

# -te
cifs.enabled=false
#cifs.tcpipSMB.port=445
ftp.enabled=false
nfs.enabled=false
# Transformers limitations
content.transformer.OpenOffice.extensions.xls.pdf.maxSourceSizeKBytes=10240
content.transformer.OpenOffice.extensions.docx.pdf.maxSourceSizeKBytes=10240
content.transformer.OpenOffice.extensions.xlsx.pdf.maxSourceSizeKBytes=10240
content.transformer.OpenOffice.extensions.pptx.pdf.maxSourceSizeKBytes=10240
content.transformer.OpenOffice.extensions.ppt.pdf.maxSourceSizeKBytes=10240
content.transformer.OpenOffice.extensions.txt.pdf.maxSourceSizeKBytes=5120
content.transformer.OpenOffice.extensions.doc.pdf.maxSourceSizeKBytes=10240

#### TODO:
- Stop file server: smb, ftp - OK
- Fix libreoffice_ctl libz warning

alfresco_1  | --> Starting LibreOffice Server
alfresco_1  | ps: /opt/alfresco/common/lib/libz.so.1: no version information available (required by /lib64/libdw.so.1)
alfresco_1  | ps: /opt/alfresco/common/lib/libz.so.1: no version information available (required by /lib64/libdw.so.1)
alfresco_1  | /opt/alfresco/libreoffice/scripts/libreoffice_ctl.sh : libreoffice started at port 8100

- Stop the postgres server gracefully - OK

Now postgres is a separate container

- Move hostname file to variable in variables.sh file instead and add installation file name instead - OK

-> properties.sh

#### AD authentication

- Add the following to tomcat/shared/classes/alfresco-global.properties:

authentication.chain=alfinst:alfrescoNtlm,ldap1:ldap-ad

ntlm.authentication.sso.enabled=false

ldap.authentication.allowGuestLogin=false
ldap.authentication.userNameFormat=%s@domain.com
ldap.authentication.java.naming.provider.url=ldap://domaincontroller.domain.com:389
ldap.authentication.defaultAdministratorUserNames=Administrator,alfresco
ldap.synchronization.java.naming.security.principal=alfresco@domain.com
ldap.synchronization.java.naming.security.credentials=secret
ldap.synchronization.groupSearchBase=ou=Security Groups,ou=Alfresco,dc=domain,dc=com

ldap.synchronization.userSearchBase=ou=User Accounts,ou=Alfresco,dc=domain,dc=com
