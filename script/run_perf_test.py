import sys, os
from urlparse import urlparse
from subprocess import *
rates = [1, 2, 4, 6, 8, 10, 15, 20, 25, 30, 40, 50, 60, 70, 80, 90, 100]
users = xrange(124871,125150)
critical_path_to_announce_ratio = 5

def usage():
    print "Usage: run_perf_test.py <critical_path_file> <announce_url>"
    

if __name__ == "__main__":
    if len(sys.argv) != 3:
        usage()
        sys.exit()
    crit_paths = open(sys.argv[1], 'r').readlines()
    announce_urls = open(sys.argv[2], 'r').readlines()
    critical_urls = []
    for user in users:
        for url in crit_paths:
            sep = '&'
            if urlparse(url)[4] == '':
                sep = '?'
            critical_urls.append(url[0:-1] + sep + "user_id=" + str(user))
    temp = open("temp.httperf.input", 'w')
    announce_num = 0
    i = 0    
    total_written = 0
    for url in critical_urls:
        temp.write(url + "\x00")
        total_written += 1
        i += 1
        if ( i % critical_path_to_announce_ratio) == 0:
            #HTTPERF returns a 400 "Bad request" for announces, while the same request works in browser
	    #Temporarily commenting out into issue resolved
            #temp.write(announce_urls[announce_num][0:-1] + "\x00")
            total_written += 1
            announce_num += 1
            if (announce_num >= len(announce_urls)):
                announce_num = 0
    temp.close()
    results = []
    for rate in rates:
        cmd = "httperf --rate=" + str(rate) + " --wlog=n,temp.httperf.input --num-conns=" + str(total_written) + " --hog --http-version=1.0 --server torrentphobe.cs290demo.com"
        print cmd
        
        p = Popen(cmd, stdin=PIPE, stdout=PIPE, stderr=PIPE, shell=True)
        stdout, stderr = p.communicate()
        result = {"rate" : rate}
        for line in stdout.splitlines():
            output = line.split(' ')
            if output[0] == "Reply" and output[1] == "rate":
                result["replies"] = output[6]
            elif output[0] == "Errors:" and output[1] == "total":
                result["errors"] = output[2]
            print line
        results.append(result)
        print "\n\n"
    for result in results:
        print result["rate"], result["replies"], result["errors"]
    os.system("rm -f temp.httperf.input")
