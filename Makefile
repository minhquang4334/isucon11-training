.DEFAULT_GOAL := help

install: ## install tool in server
	@wget https://github.com/tkuchiki/alp/releases/download/v0.4.0/alp_linux_amd64.zip
	@sudo apt-get install unzip
	@unzip alp_linux_amd64.zip
	@sudo mv alp /usr/local/bin
	@rm alp_linux_amd64.zip
	
	@sudo apt install -yq redis-server
	@sudo systemctl enable redis-server

install-db: ## install monitor tool in db
	@sudo apt-get update
#	@sudo rm /var/lib/apt/lists/lock
#	@sudo rm /var/lib/dpkg/lock
#	@sudo rm /var/lib/dpkg/lock-frontend
	@sudo apt-get install percona-toolkit
#	@wget https://www.percona.com/downloads/percona-toolkit/3.0.3/binary/debian/jessie/x86_64/percona-toolkit_3.0.3-1.jessie_amd64.deb
#	@sudo dpkg -i *.deb
	@wget https://github.com/KLab/myprofiler/releases/download/0.2/myprofiler.linux_amd64.tar.gz
	@tar xf myprofiler.linux_amd64.tar.gz
	@mv myprofiler ~/bin
	@rm myprofiler.linux_amd64.tar.gz

enable-ruby: ## disable go and enable ruby
	@sudo systemctl stop isucondition.go.service
	@sudo systemctl disable isucondition.go.service
	@sudo systemctl start isucondition.ruby.service
	@sudo systemctl enable isucondition.ruby.service
	@export PATH=$HOME/local/ruby/bin:$HOME/ruby/bin:$PATH

restart: ## restart all service
	@sudo rm /var/log/nginx/access.log
	@sudo rm /var/log/nginx/error.log
	@make -s nginx-restart
#	@make -s db-restart
	@make -s ruby-restart

ruby-log: ## Ruby server's log
	@sudo journalctl -f isucondition.ruby.service

ruby-restart: ## Restart Server
	@sudo systemctl restart isucondition.ruby.service
	@echo 'Restart isu-ruby'

nginx-restart: ## Restart nginx
	@sudo systemctl restart nginx
	@echo 'Restart nginx'

nginx-log: ## tail nginx access.log
	@sudo tail -f /var/log/nginx/access.log

nginx-error-log: ## tail nginx error.log
	@sudo tail -f /var/log/nginx/error.log

alp: ## Run alp
	@alp -f /var/log/nginx/access.log  --sum  -r --aggregates '/channel/\d+, /history/\d+, /profile/\w+, /icons/\w+' --start-time-duration 5m

db-restart: ## Restart mysql
	@sudo rm /var/lib/mysql/slow-query.log
	@sudo touch /var/lib/mysql/slow-query.log
	@sudo chown mysql:mysql /var/lib/mysql/slow-query.log
	@sudo systemctl restart mysql
	@echo 'Restart mysql'

db-log: ## tail mysql.log
	@sudo tail -f /var/log/mysql/mysql.log

myprofiler: ## Run myprofiler
	@myprofiler -user=isucon -password=isucon -host=127.0.0.1

git-init:
	@echo 'Generate SSH key..'
	@ssh-keygen
	@echo 'ssh key created OK!'
	@printf '\n'
	@cat ~/.ssh/id_rsa.pub
	@printf '\n'

	@echo 'Init Isucon Repository..'
	@rm -rf .git && git init
	@echo 'Init Repo OK!'

	@echo 'Config Git email and user name...'
	@git config user.email "minhquang4334@gmail.com"
	@git config user.name "minhquang4334"
	@echo 'Config Git OK!'

	@echo 'add remote..'
	@git remote add origin git@github.com:minhquang4334/isucon11-training.git
	@echo 'Init Repo OK!'

	@printf '残りのタスク: \n1. Create Git Ignore File \n2.Deploy KeyをGithubに入れる\n3.Push to Github\n\n'

.PHONY: help
help:
	@grep -E '^[a-z0-9A-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

