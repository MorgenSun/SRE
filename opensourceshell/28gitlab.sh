wget http://download.mylab.local:8888/gitlab-ee-16.6.2-ee.0.el7.x86_64.rpm -P /app/server/
cd /app/server/
yum install -y gitlab-ee-16.6.2-ee.0.el7.x86_64.rpm
gitlab-ctl reconfigure
gitlab-ctl status
sed -i 's/gitlab.example.com/gitlab.mylab.local/g' /etc/gitlab/gitlab.rb


echo 'Password:'  `cat /etc/gitlab/initial_root_password  | grep  'Password' | grep -v '#' | awk -F ":" '{print $2}'`