#!/bin/bash

sudo apt update 
sudo apt install nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx
# url="https://github.com/pratikkamble14/"

# echo "<h1> Terraform is Running and also Nginx on ec2......., and this is my Github : <a href="https://github.com/pratikkamble14/" class="button-link">Click Me</a> </h1>" | sudo tee /var/www/html/index.html 


sudo tee /var/www/html/index.html > /dev/null <<'EOF'
<h1>Terraform is Running and also Nginx on EC2 and this is my GitHub:
<a href="https://github.com/pratikkamble14/" class="button-link">Click Me</a>
</h1>
EOF