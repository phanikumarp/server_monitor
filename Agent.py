import time
import subprocess

checks = ["python /opt/agents/monitor/SystemCheck.py","python /opt/agents/monitor/NetworkCheck.py"]

if __name__ == "__main__":
     i = 4;	
     while True:
	procs = [subprocess.Popen(check, shell=True) for check in checks]		       	
	#for check in checks:
	#       #http://stackoverflow.com/a/19393328/745018
	#       procs = [subprocess.Popen(['svn', 'update', repo]) for repo in repos]		       	
        print "created subprocess" 
        #i = i-1
        time.sleep(4)
