import urllib2
import json
import socket
import traceback

class EC2(object):
    """Retrieve EC2 metadata
    """
    EC2_METADATA_HOST = "http://169.254.169.254"
    METADATA_URL_BASE = EC2_METADATA_HOST + "/latest/meta-data"
    INSTANCE_IDENTITY_URL = EC2_METADATA_HOST + "/latest/dynamic/instance-identity/document"
    TIMEOUT = 0.1  # second
    DEFAULT_PREFIXES = [u'ip-', u'domu']
    metadata = {}

    class NoIAMRole(Exception):
        """
        Instance has no associated IAM role.
        """
        pass

    @staticmethod
    def is_default(hostname):
        hostname = hostname.lower()
        for prefix in EC2.DEFAULT_PREFIXES:
            if hostname.startswith(prefix):
                return True
        return False

    @staticmethod
    def get_iam_role():
        """
        Retrieve instance's IAM role.
        Raise `NoIAMRole` when unavailable.
        """
        try:
            return urllib2.urlopen(EC2.METADATA_URL_BASE + "/iam/security-credentials/").read().strip()
        except urllib2.HTTPError as err:
            if err.code == 404:
                raise EC2.NoIAMRole()
            raise
    
    @staticmethod
    def get_instId():
        """
        Retrieve instance's ID.
        Raise `NoIAMRole` when unavailable.
        """
        try:
            return urllib2.urlopen(EC2.METADATA_URL_BASE + "/instance-id").read().strip()
        except Exception:
            return None 
	
    @staticmethod
    def get_scaling_group():
        """
        Retrieve AWS Auto Scaling Group of the Instance.
        """
        EC2_tags = []
        socket_to = None
	scaling_group = None
        try:
            socket_to = socket.getdefaulttimeout()
            socket.setdefaulttimeout(EC2.TIMEOUT)
        except Exception:
            pass

        try:
            iam_role = EC2.get_iam_role()
            iam_params = json.loads(urllib2.urlopen(EC2.METADATA_URL_BASE + "/iam/security-credentials/" + unicode(iam_role)).read().strip())
            instance_identity = json.loads(urllib2.urlopen(EC2.INSTANCE_IDENTITY_URL).read().strip())
            region = instance_identity['region']
            import boto.ec2
            proxy_settings = {}
            connection = boto.ec2.connect_to_region(
                region,
                aws_access_key_id=iam_params['AccessKeyId'],
                aws_secret_access_key=iam_params['SecretAccessKey'],
                security_token=iam_params['Token']
            )
	    #print "Instance Id is : "+EC2.get_instance_id()
            tag_object = connection.get_all_tags({'resource-id': EC2.get_instId()})
	    for tag in tag_object:
		if "aws:autoscaling:groupName" == tag.name:
		    scaling_group = tag.value
		    break	
            #print tag_object[0]['aws:autoscaling:groupName']		
            #EC2_tags = [u"%s:%s" % (tag.name, tag.value) for tag in tag_object]

        except EC2.NoIAMRole:
            print(
                "Unable to retrieve AWS EC2 custom tags : an IAM role associated with the instance is required"
            )
        except Exception,e:
            print('Problem retrieving custom EC2 tags :%s ' % e)
	    traceback.print_exc()
        try:
            if socket_to is None:
                socket_to = 3
            socket.setdefaulttimeout(socket_to)
        except Exception:
            pass

        return scaling_group

