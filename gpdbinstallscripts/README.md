# Summary 

The script is designed to help/ease install / setup a LAB GPDB environment with very little efforts

# Execution

                                     How to automatiically create / use a LAB GPDB environment                                            
                                                                                                                                          
      + Command to download the GPDB software                                                                                             
              - downloadgpcc  <gpdb|gpcc|gpextras>            <--- This will help in downloading the GPDB 		                 
                                                                                                                                          
      + Command to install the GPDB binaries                                                                                              
              - installgpdb <version>                         <--- This will install the multinode GPDB version that you downloading above
              - installgpdb-singlenode <version>              <--- This will install the singlenode version that you downloading above    
              - installgpcc < gpdb version > < gpcc version > <--- This is to install the command center version                          
                                                                                                                                          
      + Command to set environment                                                                                                        
              - envgp <version>            <--- Set the environment of GPDB that you have installed above                                 
              - envgp -l                   <--- List all the installation of Greenplum database                                           
                                                                                                                                          
      + Command to uninstall                                                                                                              
               - removegpdb <version       <--- Uninstall the installtion that you have installed above                                   
                                                                                                                                          
       + Command to stop all running GPDB instance                                                                                        
               - stopallgpdbinstance       <---- This will stop all the gpdb instance.                                                    
                                                                                                                                          
                For more information on how to use the above tool, please refer to the article mentioned below                            
                                                  (Pivotal Employee only)                                                                 
                                   https://support.pivotal.io/hc/en-us/articles/213626727                                                 


# Documentation

### Installation

###### Using git

+ Connect as gpadmin user on your lab server
+ Navigate to the directory "cd /usr/local"
+ Download the file using

```
git clone https://github.com/faisaltheparttimecoder/gpdbinstallscripts.git
```

+ Update the .bashrc or .bash_profile or .profile to set the path

```
echo "source /usr/local/gpdbinstallscripts/installscipt_path.sh" >> ~/.bashrc
```

+ Logout and relogin to use the scripts

###### Manually

+ Download the tar "gpdbinstallscripts.tar" file attached to the article and move to the server via scp or any method
+ Connect as gpadmin user on your lab server
+ untar the file

```
tar -xvf gpdbinstallscripts.tar -C /usr/local
```

+ Update the .bashrc or .bash_profile or .profile to set the path

```
echo "source /usr/local/gpdbinstallscripts/installscipt_path.sh" >> ~/.bashrc
```

+ Logout and relogin to use the scripts

**NOTE:** In case you want to install into different directory other than /usr/local , please modify the scriptpath under the file installscript_path.sh 

```
export scriptpath=/usr/local/gpdbinstallscripts/
```
###### How to obtain the API Token

+ Connect to network.pivotal.io with your username / password
+ Click on Edit profile
+ Scroll to the bottom on the page where you will see your API Token.
+ if its a private computer (eg.s VM) , open the download* file and edit the line below to provide the API TOKEN , this will make the script store the information and never prompt you for the API TOKEN , if its public ( like LAB used by the team ) , dont use your API for security reason.

```
#export api_token="aaaaaAaAAAaaaaAAAAAaaa"
```

###  Upgrade

###### Using git

+ Connect as gpadmin user on your lab server
+ Navigate to the directory "cd /usr/local/gpdbinstallscripts"
+ Pull the updated file using

```
git pull
```

###### Manually

+ untar the new file

```
tar -xvf gpdbinstallscripts.tar -C /tmp
```

+ Remove the old executables

```
rm -rf /usr/local/gpdbinstallscripts/bin
```

+ Copy the new executables

```
cp -R /tmp/gpdbinstallscripts/bin /usr/local/gpdbinstallscripts
```

+ Remove the downloaded binares

```
rm -rf /tmp/gpdbinstallscripts*
```

### Features

###### download

This will help in downloading the GPDB for RHEL version.

NOTE: This script needs the server connected to the internet.

+ This script will download the GPDB software from network.pivotal.io
+ This script table gpdb,gpcc or gpextras as parameters
+ Once executed it will ask for the API token if its not being explicitly set via parameter API_TOKEN
+ Once authenticated, it will list all the GPDB version available and request for what is needs to be downloaded
+ if parameter gpdb is supplied then it download the RHEL version of GPDB.
+ if parameter gpcc is asks for the version of command center that is needed to download
+ if parameter gpextra is supplied then it list all the extras and supplying the file name will help in downloading the necessary file.
+ supply the version and wait for it to download the version of the product

###### installgpdb

This will install the multi node greenplum version that you downloading above 

+ This script takes in the parameter which is the version of the GPDB that you need to install after you have downloaded using the downloadgpdb scripts.
+ This script first verifies if the parameter is supplied
+ If supplied it checks if the version binaries are available on its downloaded directory.
+ If found it finds if there is a previous installation of that same version and prompts if you want to use the older installation.
+ If not found or you want to go ahead , it unzips the binaries.
+ Install the binaries on the master
+ Picks all the host list from ~/gpconfigs/hostfile_segments
+ Verifies from those list which hosts are accessiable and if the directores /data[1-2]/primary and /data[1-2]/mirror is accessiable
+ If it finds exceptions then it skips those host and progress with installation with the available hosts
+ If all hosts are not accessible then the script exits
+ Progress with the binaries installation on the available host
+ Create the gpinitsystem file during this time it verify the available ports on the servers that it will be installing
+ Once done runs gpinitsystem
+ It stores the last used port and the environment of the installation for future reference.
+ It creates a uninstallation script if it needs to remove it in the future
+ Remove the temporary files
+ Prompts to source the environment to use the installation.

###### installgpdb-singlenode

This will install the singlenode version that you downloading above 

This scripts works the same way as installgpdb excepts its works only with one hosts

###### installgpcc

This is to install the command center version

+ This script takes in the parameter which is the version of the GPDB and then command center version that you need to install after you have downloaded using the download scripts and you have installed the GPDB using the installgpdb or installgpdb-singlenode scripts.
+ This script first verifies if the parameter is supplied
+ If supplied it checks if the version binaries are available on its downloaded directory.
+ If there are multiple installation of gpdb version , it prompts to provide which installation you want to use to install the GPCC.
+ If there is already GPCC installed on the GPDB environment it prompts do you want to use it or not
+ If requested to proceed then it uninstalls the existing installation
+ Extracts the binaries
+ Check the GPDB is multi node or single node
+ if its multi node then it pushes the binaires on those hosts
+ Installs the gpperfmon database
+ Updates the pg_hba.conf file
+ Installs the web UI
+ Start the web UI
+ Saves the last used port for future reference
+ Removes temporary files.
+ Prompts to source the environment to use the installation.

###### envgpdb

Set the environment of GPDB that you have installed above

+ This script takes in the parameter which is the version of the GPDB that you need to source after you have installed using the installgpdb or installgpdb-singlenode scripts.
+ You can also use envgpdb -l to list all the installation of GPDB
+ It verifies how many installation are there for that GPDB version
+ If found multiple installation , it prompts to provide the env that it needs to set
+ If the environment is stopped it brings it up 
+ It brings the command center also up if it finds in the installation of the environment
+ Prompts to source the environment to use the installation.

###### removegpdb

Uninstall the installtion that you have installed above

+ This script takes in the parameter which is the version of the GPDB that you need to source after you have installed using the installgpdb or installgpdb-singlenode scripts.
+ It verifies how many installation are there for that GPDB version
+ If found multiple installation , it prompts to provide the env that it needs to set
+ If you supply a on the prompt it will remove all the installation of that version.
+ It uses gpdeletesystem initially to drop the cluster
+ If its not successful then it uses the uninstall script created during installgpdb or installgpdb-singlenode to remove it from the OS
+ It also cleans up GPCC if its found for that environment

###### stopallgpdbinstance

This will stop all the gpdb instance

+ This script doesnt take any parameter
+ It finds all the database running on the servers and stops it one by one
+ If it find something that cant be stopped it prints in the message that it couldn't stop some of the database and it needs manual intervention 
