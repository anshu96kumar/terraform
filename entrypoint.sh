              #!/bin/bash
              sudo yum update -y && yum install -y docker
              sudo service docker start
              sudo docker run -d -p 8080:80 nginx