# Debugging Issues

Direct any issue or questions to `alisalm1 AT msu DOT edu`


### Network Shared Drive 

 `Note: This is applicable on Server and Client`

If gluster daemon is not running, restart it  

	
	./shared-drive.sh restartgluster

If previously created shared volumes are causing issues

	# Remove caches and earlier volume related data (make backup before doing so!) 
	./shared-drive.sh fixfolderconflict
	
	# Fix permissions for gluster application
	./shared-drive.sh fixpermissions

Removing cache and other related files from gluster library for previously configured volumes may generate extra messages (particularly related to geographic data) such as below but does not interfere with normal operation. This was tested for glusterfs 10.1.
 

    Traceback (most recent call last):
    File "/usr/lib/x86_64-linux-gnu/glusterfs/python/syncdaemon/gsyncd.py", line 325, in <module> main()
    File "/usr/lib/x86_64-linux-gnu/glusterfs/python/syncdaemon/gsyncd.py", line 41, in main
    argsupgrade.upgrade()
    File "/usr/lib/x86_64-linux-gnu/glusterfs/python/syncdaemon/argsupgrade.py", line 85, in upgrade
    init_gsyncd_template_conf()
    File "/usr/lib/x86_64-linux-gnu/glusterfs/python/syncdaemon/argsupgrade.py", line 50, in init_gsyncd_template_conf
    fd = os.open(path, os.O_CREAT | os.O_RDWR)
    FileNotFoundError: [Errno 2] No such file or directory: '/var/lib/glusterd/geo-replication/gsyncd_template.conf'
 
